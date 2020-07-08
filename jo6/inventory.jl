include("../common/event.jl")
import Base.rand

mutable struct Inventory
    timeArrival # L
    demandRd # G
    thresholdTrigger # s
    enoughS # S
    priceSell # r
    priceOrderF::Function # c(y)
    priceHold # h

    stock # x

    ordered # y
    costOrdering # C
    costHolding # H
    revenue # R
    lastTime # t
end
struct CeilRd
    rd
end
function rand(rd::CeilRd)
    ceil(rand(rd.rd))
end

function inventorySimple(; timeArrival=5, demandRd=CeilRd(Exponential(5)) ,thresholdTrigger=10, enoughS=30, stock=10, priceSell=1, priceOrderF=(x) -> x * 0.6, priceHold=0.1)
    Inventory(timeArrival, demandRd, thresholdTrigger, enoughS, priceSell, priceOrderF, priceHold, stock, 0, 0, 0, 0, 0)
end

function inventoryStr(shop::Inventory)
    "shop (stock=$(shop.stock), ordered=$(shop.ordered), costOrdering=$(shop.costOrdering), costHolding=$(shop.costHolding), revenue=$(shop.revenue), lastTime=$(shop.lastTime), profitRate=$((shop.revenue - shop.costHolding - shop.costOrdering) / shop.lastTime))"
end

function customerEnter(pq, tNow, shop::Inventory)
    sv1("$tNow: Customer entering $(inventoryStr(shop))")
    shop.costHolding += (tNow - shop.lastTime) * shop.stock * shop.priceHold

    demand = rand(shop.demandRd)
    purchased = min(shop.stock, demand)
    shop.stock -= purchased
    shop.revenue += purchased * shop.priceSell
    if shop.ordered == 0 && shop.stock < shop.thresholdTrigger
        toOrder = shop.enoughS - shop.stock
        shop.ordered = toOrder
        push!(pq, SEvent(tNow + shop.timeArrival) do pq, tNow
            sv1("$tNow: Order arriving at $(inventoryStr(shop))")
            shop.costHolding += (tNow - shop.lastTime) * shop.stock * shop.priceHold

            shop.stock += shop.ordered
            shop.costOrdering += shop.priceOrderF(shop.ordered)

            shop.ordered = 0
            shop.lastTime = tNow
            sv1("$tNow: Order recieved at $(inventoryStr(shop))")
        end)
    end

    shop.lastTime = tNow
    sv1("$tNow: Customer left $(inventoryStr(shop)) having bought $purchased (demand=$demand)")
end

function simInventory(tEnd=3) 
    println("########################\nStarting!\n")
    shop = inventorySimple()
    pq = BinaryMinHeap{SEvent}()
    producer(pq, 0, Exponential(1 / 3), (pq, tNow) -> customerEnter(pq, tNow, shop) ; tEnd=Inf)
    realClosingTime = -1
    closingTime = tEnd
    while ! (isempty(pq))
        cEvent = pop!(pq)
        println("-> receiving event at $(cEvent.time)")
        cEvent.callback(pq, cEvent.time)
        if cEvent.time >= closingTime
            realClosingTime = cEvent.time
            break
        end
    end
    println("\n\nThe $(inventoryStr(shop)) closed at $realClosingTime")
    println("Remaining events: $(length(pq))")
end

##
simInventory(30)
