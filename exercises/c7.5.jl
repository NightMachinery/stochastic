include("../common/event.jl")

include("../common/pprocess.jl")

##
mutable struct Server 
    queue::Int
    coresAvailable::Int
    rd
    callback
    name
    queueCheckExpirations::Deque{Function}
end

function serverSimple(callback ; cores=3, rd=Uniform(1, 2), name="Unnamed")
    Server(0, cores, rd, callback, name, Deque{Function}())
end

function serverMaybeProcess(pq, tNow, server::Server)
    if server.queue > 0 && server.coresAvailable > 0
        server.queue -= 1
        hisCallback = popfirst!(server.queueCheckExpirations)
        if hisCallback(pq, tNow)
            server.coresAvailable -= 1
            tNext = tNow + rand(server.rd)
            push!(pq, SEvent(function (pq, tNow)
                sv1("$(serverStr(server)) processing an exit ...")
                server.coresAvailable += 1
                serverMaybeProcess(pq, tNow, server)
                server.callback(pq, tNow)
                sv1("Hurray! Person exited $(serverStr(server)) at $tNow")
            end, tNext))
            # push!(pq, SEvent(server.callback, tNext))
        else
            # expired
            # sv1("$(serverStr(server)) updated because the service requester had already left ...")
            serverMaybeProcess(pq, tNow, server) # redundant?
        end
    end
end

function serverEnter(callback, pq, tNow, server::Server)
    sv1("Person entering $(serverStr(server)) at $tNow")
    server.queue += 1
    push!(server.queueCheckExpirations, callback)
    serverMaybeProcess(pq, tNow, server)
end

function serverStr(s1::Server)
    "$(s1.name)(queue=$(s1.queue), coresAvailable=$(s1.coresAvailable))"
end
##

struct VectorRd
    vector
    emptyValue
end

import Base.rand

function rand(vrd::VectorRd)
    v = vrd.vector
    if isempty(v)
        vrd.emptyValue
    else
        popfirst!(v)
    end
end

function stest1()
    println("########################\nStarting!\n")
    pq = BinaryMinHeap{SEvent}()

    s1 = serverSimple( ; cores=1, name="MonkeyHut") do pq, tNow
        println("MONKEY POWER!")
    end
    
    iAmNth = 0
    customerLeaveD() = rand(Exponential(1)) 
    leavers = Deque{Int}()

    producer(pq, 0, VectorRd(nhPP(100, (t) -> t / 2, 0, 10), 11.1) # Exponential(inv(3)) # use nonhomo Poisson for entering
    , function (pq, tNow)
        iAmNth += 1
        iAmNth_me = iAmNth # we need to save this
        sv1("Person #$iAmNth_me has entered the server $(s1.name)")
        haveILeaved = false
        tExp = tNow + customerLeaveD()
        sv1("Person #$iAmNth_me will leave at $tExp if not processed.")

        push!(pq, SEvent(tExp) do pq, tNow
            haveILeaved = true
        end)

        serverEnter(pq, tNow, s1) do pq, tNow
            if haveILeaved
                sv1("!!! Person #$(iAmNth_me) has already left $(s1.name)")
                push!(leavers, iAmNth_me)
            end
            return (! haveILeaved)
        end

    end ; tEnd=10, arrivalDist=true)

    while ! (isempty(pq))
        cEvent = pop!(pq)
        println("-> receiving event at $(cEvent.time)")
        cEvent.callback(pq, cEvent.time)
    end
    @labeled leavers
    println("The End!")
    pq 
end
##