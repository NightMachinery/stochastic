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
function producer(pq, tNow, rd, callback; tEnd=Inf)
    sv1("producer called at $tNow")
    tNext = tNow + rand(rd)
    if tNext < tEnd 
        sv1("production scheduled for $tNext")
        push!(pq, SEvent((pq, tNow) -> begin
            producer(pq, tNow, rd, callback ; tEnd=tEnd)
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
producerTest()
##
mutable struct Server 
    queue::Int
    coresAvailable::Int
    rd
    callback
    name
end

function serverSimple(callback ; cores=3, rd=Uniform(1, 2), name="Unnamed")
    Server(0, cores, rd, callback, name)
end

function serverMaybeProcess(pq, tNow, server::Server)
    if server.queue > 0 && server.coresAvailable > 0
        server.coresAvailable -= 1
        server.queue -= 1
        tNext = tNow + rand(server.rd)
        push!(pq, SEvent(function (pq, tNow)
            sv1("$(serverStr(server)) processing an exit ...")
            server.coresAvailable += 1
            serverMaybeProcess(pq, tNow, server)
            server.callback(pq, tNow)
        end, tNext))
        # push!(pq, SEvent(server.callback, tNext))
    end
end

function serverEnter(pq, tNow, server::Server)
    sv1("Person entering $(serverStr(server)) at $tNow")
    server.queue += 1
    serverMaybeProcess(pq, tNow, server)
end

function serverStr(s1::Server)
    "$(s1.name)(queue=$(s1.queue), coresAvailable=$(s1.coresAvailable))"
end
##

function stest1()
    println("########################\nStarting!\n")
    pq = BinaryMinHeap{SEvent}()

    s1 = serverSimple( ; cores=4, name="MonkeyHut") do pq, tNow
        println("Hurray! Person exited $(serverStr(s1)) at $tNow")
    end
    producer(pq, 0, Exponential(inv(3)), (pq, tNow) -> serverEnter(pq, tNow, s1) ; tEnd=20)
    while ! (isempty(pq))
        cEvent = pop!(pq)
        println("-> receiving event at $(cEvent.time)")
        cEvent.callback(pq, cEvent.time)
    end
    println("The End!")
    pq 
end

stest1()