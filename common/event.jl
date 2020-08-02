using Distributions
using DataStructures
import Base.isless

struct SEvent
    callback
    time::Float64
end

function isless(a::SEvent, b::SEvent)
    isless(a.time, b.time)
end

serverVerbosity = 1
function sv1(args... ; kwargs...)
    if serverVerbosity >= 1
        println(args... ; kwargs...)
    end
end

##
function producer(pq, tNow, rd, callback; tEnd=Inf, arrivalDist=false)
    sv1("producer called at $tNow")
    tNext = rand(rd)
    if arrivalDist == false 
        tNext += tNow
    #     sv1("Producer is in between-arrival mode")
    #     @labeled arrivalDist
    # else
    #     sv1("Producer is in exact-arrival mode")
    #     @labeled arrivalDist
    end
    if tNext < tEnd 
        sv1("production scheduled for $tNext")
        push!(pq, SEvent((pq, tNow) -> begin
            producer(pq, tNow, rd, callback ; tEnd=tEnd, arrivalDist=arrivalDist)
            callback(pq, tNow) 
        end, tNext))
        # push!(pq, SEvent(callback, tNext))
    end
end

function producerTest()
    println("Starting!\n\n\n")
    pq = BinaryMinHeap{SEvent}()

    producer(pq, 0, Exponential(1), function (pq, tNow)
        println("Callback from producer at $tNow")
        # sa(pq)
        # println("\n--------\n")
    end ; tEnd=20)
    while ! (isempty(pq))
        cEvent = pop!(pq)
        println("receiving event at $(cEvent.time)")
        cEvent.callback(pq, cEvent.time)
    end
    println("The End!")
    pq 
end

##
# producerTest()