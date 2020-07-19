using Distributions

function EBuy(λ, buy ; limDefault=10^3)

    function sell1(d1, m0)
        min(d1, buy(m0) + m0)
    end

    function trash1(d1, m0)
        max(m0 - d1, 0)
    end

    function remaining1(d1, m0)
        max(0, buy(m0) - max(0, d1 - m0))
    end

    function sell2(d1, m0, d2)
        r1 = remaining1(d1, m0)
        min(d2, buy(r1) + r1)
    end

    function trash2(d1, m0, d2)
        max(0, remaining1(d1, m0) - d2)
    end

    function profit(d1, m0, d2)
        profit_price = 20
        waste_price = -100

        profit_price * (sell1(d1, m0) + sell2(d1, m0, d2)) + waste_price * (trash1(d1, m0) + trash2(d1, m0, d2))
    end

    D1Rng = Poisson(λ)
    D2Rng = D1Rng
    function D1(x)
        pdf(D1Rng, x)
    end
    D2 = D1
    M0Rng = Poisson(λ - 2)
    function M0(x)
        pdf(M0Rng, x)
    end

    function EProfit(limI=limDefault, limJ=limDefault, limK=limDefault)
        sum = 0
        for i in 0:limI
            Sj = 0

            for j in 0:limJ
                Sk = 0

                for k in 0:limK
                    Sk += D2(k) * profit(j, i, k)
                end

                Sj += D1(j) * Sk
            end
            if i == 0
                println("With m0=0, EProfit = $(Sj)")
            end
            sum += M0(i) * Sj
        end

        return sum
    end

    EProfit()
end

##
EBuy( 4, (meat) -> max(0, 4 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 122.79243902842249
# 100.003203060261066
EBuy( 4, (meat) -> max(0, 5 - meat) ; limDefault=10^2) 
# With m0=0, EProfit = 127.67572157252292
# 107.51015707529938
EBuy( 4, (meat) -> max(0, 5.5 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 122.41131072793357
# 104.20422470340004
EBuy( 4, (meat) -> max(0, 4.5 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 125.23408030047273
# 103.75668006778024
EBuy( 4, (meat) -> max(0, 3 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 104.36925504225923
# 81.41500287494729
EBuy( 4, (meat) -> max(0, 7 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 90.2364312658074
# 78.29477631299676
EBuy( 4, (meat) -> max(0, 10 - meat) ; limDefault=10^2)
# With m0=0, EProfit = -82.75163797624171
# -85.48826766326272
EBuy( 4, (meat) -> max(0, 4) ; limDefault=10^2)
# With m0=0, EProfit = 127.2548616574279
# 93.15345245147779
EBuy( 4, (meat) -> max(0, 5) ; limDefault=10^2)
# With m0=0, EProfit = 131.62316690347978
# 71.18532186271467
EBuy( 4, (meat) -> max(0, 40) ; limDefault=10^2)
# With m0=0, EProfit = -3040.000000000001
# -3240.000000000001
EBuy( 4, (meat) -> max(0, 1) ; limDefault=10^2)
# With m0=0, EProfit = 39.56659469664482
# 47.36929031901994
EBuy( 4, (meat) -> max(0, 0) ; limDefault=10^2)
# With m0=0, EProfit = 0.0
# 8.724792121641496
##
EBuy( 400, (meat) -> max(0, 600 - meat) ; limDefault=10^3) 
# With m0=0, EProfit = 15999.999999999976
# 14970.38590044147
EBuy( 400, (meat) -> max(0, 500 - meat) ; limDefault=10^3)
# With m0=0, EProfit = 15999.999879997378
# 14970.385780438863
EBuy( 400, (meat) -> max(0, 400) ; limDefault=10^3)
# With m0=0, EProfit = 15727.630166187062
# 14465.746084818367
EBuy( 400, (meat) -> max(0, 400 - meat) ; limDefault=10^3)
# With m0=0, EProfit = 15727.630166187062
# 14465.746084818367
EBuy( 400, (meat) -> max(0, 500) ; limDefault=10^3)
# With m0=0, EProfit = 15999.99993999849
# 6197.51026506349
EBuy( 400, (meat) -> max(0, 700 - meat) ; limDefault=10^3)
# With m0=0, EProfit = 15999.897657317053
# 14970.383528682078
EBuy( 400, (meat) -> max(0, 300) ; limDefault=10^3)
# With m0=0, EProfit = 11999.999994352858
# 14970.385884998796
EBuy( 400, (meat) -> max(0, 1000 - meat) ; limDefault=10^3)
# With m0=0, EProfit = -4000.0000000021128
# -4000.0000000033624
EBuy( 400, (meat) -> max(0, 100) ; limDefault=10^3)
# With m0=0, EProfit = 4000.0000000000014
# 10724.463080529767