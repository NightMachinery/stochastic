(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random, DataStructures

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

function serverSimple(callback ; cores=3, rd=Uniform(0, 1), name="Unnamed")
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
            serverMaybeProcess(pq, tNow, server)
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
    customerLeaveD() = rand(Uniform(0, 1)) # rand(Exponential(1)) 
    leavers = Deque{Int}()

    # VectorRd(nhPP(100, (t) -> 10, 0, 100), 101.1)
    producer(pq, 0,  Exponential(inv(10)) # use nonhomo Poisson for entering

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

    end ; tEnd=100, arrivalDist=false)

    while ! (isempty(pq))
        cEvent = pop!(pq)
        println("-> receiving event at $(cEvent.time)")
        cEvent.callback(pq, cEvent.time)
    end
    @labeled leavers
    @labeled length(leavers)
    @labeled iAmNth
    println("The End!")
    pq 
end
##
stest1()
########################
# Starting!

# producer called at 0
# production scheduled for 2.2870005127091853
# -> receiving event at 2.2870005127091853
# producer called at 2.2870005127091853
# production scheduled for 2.871322996426014
# Person #1 has entered the server MonkeyHut
# Person #1 will leave at 3.2564352043257188 if not processed.
# Person entering MonkeyHut(queue=0, coresAvailable=1) at 2.2870005127091853
# -> receiving event at 2.871322996426014
# producer called at 2.871322996426014
# production scheduled for 3.3378386956037622
# Person #2 has entered the server MonkeyHut
# Person #2 will leave at 3.0674252289203103 if not processed.
# Person entering MonkeyHut(queue=0, coresAvailable=0) at 2.871322996426014
# -> receiving event at 3.0674252289203103
# -> receiving event at 3.2564352043257188
# -> receiving event at 3.3378386956037622
# producer called at 3.3378386956037622
# production scheduled for 4.160985100713693
# Person #3 has entered the server MonkeyHut
# Person #3 will leave at 4.104551253083947 if not processed.
# Person entering MonkeyHut(queue=1, coresAvailable=0) at 3.3378386956037622
# -> receiving event at 4.104551253083947
# -> receiving event at 4.160985100713693
# producer called at 4.160985100713693
# production scheduled for 4.801724163035355
# Person #4 has entered the server MonkeyHut
# Person #4 will leave at 4.999620054688613 if not processed.
# Person entering MonkeyHut(queue=2, coresAvailable=0) at 4.160985100713693
# -> receiving event at 4.242331044163493
# MonkeyHut(queue=3, coresAvailable=0) processing an exit ...
# !!! Person #2 has already left MonkeyHut
# !!! Person #3 has already left MonkeyHut
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=0, coresAvailable=0) at 4.242331044163493
# -> receiving event at 4.801724163035355
# producer called at 4.801724163035355
# production scheduled for 5.583180227716514
# Person #5 has entered the server MonkeyHut
# Person #5 will leave at 6.216869254427679 if not processed.
# Person entering MonkeyHut(queue=0, coresAvailable=0) at 4.801724163035355
# -> receiving event at 4.999620054688613
# -> receiving event at 5.326224547295775
# MonkeyHut(queue=1, coresAvailable=0) processing an exit ...
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=0, coresAvailable=0) at 5.326224547295775
# -> receiving event at 5.583180227716514
# producer called at 5.583180227716514
# production scheduled for 5.795403517161721
# Person #6 has entered the server MonkeyHut
# Person #6 will leave at 6.620178524161407 if not processed.
# Person entering MonkeyHut(queue=0, coresAvailable=0) at 5.583180227716514
# -> receiving event at 5.795403517161721
# producer called at 5.795403517161721
# production scheduled for 5.918209809451393
# Person #7 has entered the server MonkeyHut
# Person #7 will leave at 5.873023779026029 if not processed.
# Person entering MonkeyHut(queue=1, coresAvailable=0) at 5.795403517161721
# -> receiving event at 5.873023779026029
# -> receiving event at 5.918209809451393
# producer called at 5.918209809451393
# production scheduled for 5.978911315351526
# Person #8 has entered the server MonkeyHut
# Person #8 will leave at 6.0857300971577715 if not processed.
# Person entering MonkeyHut(queue=2, coresAvailable=0) at 5.918209809451393
# -> receiving event at 5.978911315351526
# producer called at 5.978911315351526
# production scheduled for 6.250851182450309
# Person #9 has entered the server MonkeyHut
# Person #9 will leave at 5.988351731608971 if not processed.
# Person entering MonkeyHut(queue=3, coresAvailable=0) at 5.978911315351526
# -> receiving event at 5.988351731608971
# -> receiving event at 6.0857300971577715
# -> receiving event at 6.216869254427679
# -> receiving event at 6.250851182450309
# producer called at 6.250851182450309
# production scheduled for 6.334452548934455
# Person #10 has entered the server MonkeyHut
# Person #10 will leave at 6.416732476751355 if not processed.
# Person entering MonkeyHut(queue=4, coresAvailable=0) at 6.250851182450309
# -> receiving event at 6.334452548934455
# producer called at 6.334452548934455
# production scheduled for 6.686406549755106
# Person #11 has entered the server MonkeyHut
# Person #11 will leave at 6.626510984631606 if not processed.
# Person entering MonkeyHut(queue=5, coresAvailable=0) at 6.334452548934455
# -> receiving event at 6.416732476751355
# -> receiving event at 6.620178524161407
# -> receiving event at 6.626510984631606
# -> receiving event at 6.686406549755106
# producer called at 6.686406549755106
# production scheduled for 6.750918302919446
# Person #12 has entered the server MonkeyHut
# Person #12 will leave at 10.064369104939422 if not processed.
# Person entering MonkeyHut(queue=6, coresAvailable=0) at 6.686406549755106
# -> receiving event at 6.750918302919446
# producer called at 6.750918302919446
# production scheduled for 6.777080755999138
# Person #13 has entered the server MonkeyHut
# Person #13 will leave at 8.062873403325233 if not processed.
# Person entering MonkeyHut(queue=7, coresAvailable=0) at 6.750918302919446
# -> receiving event at 6.777080755999138
# producer called at 6.777080755999138
# production scheduled for 7.149182075841922
# Person #14 has entered the server MonkeyHut
# Person #14 will leave at 7.968313656555972 if not processed.
# Person entering MonkeyHut(queue=8, coresAvailable=0) at 6.777080755999138
# -> receiving event at 7.050449771079335
# MonkeyHut(queue=9, coresAvailable=0) processing an exit ...
# !!! Person #6 has already left MonkeyHut
# !!! Person #7 has already left MonkeyHut
# !!! Person #8 has already left MonkeyHut
# !!! Person #9 has already left MonkeyHut
# !!! Person #10 has already left MonkeyHut
# !!! Person #11 has already left MonkeyHut
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=2, coresAvailable=0) at 7.050449771079335
# -> receiving event at 7.149182075841922
# producer called at 7.149182075841922
# production scheduled for 7.16805174175886
# Person #15 has entered the server MonkeyHut
# Person #15 will leave at 8.09366286841447 if not processed.
# Person entering MonkeyHut(queue=2, coresAvailable=0) at 7.149182075841922
# -> receiving event at 7.16805174175886
# producer called at 7.16805174175886
# production scheduled for 7.519833330021689
# Person #16 has entered the server MonkeyHut
# Person #16 will leave at 7.689418336253971 if not processed.
# Person entering MonkeyHut(queue=3, coresAvailable=0) at 7.16805174175886
# -> receiving event at 7.519833330021689
# producer called at 7.519833330021689
# production scheduled for 7.8423506980851965
# Person #17 has entered the server MonkeyHut
# Person #17 will leave at 11.217235172867035 if not processed.
# Person entering MonkeyHut(queue=4, coresAvailable=0) at 7.519833330021689
# -> receiving event at 7.689418336253971
# -> receiving event at 7.8423506980851965
# producer called at 7.8423506980851965
# production scheduled for 8.271321140171706
# Person #18 has entered the server MonkeyHut
# Person #18 will leave at 9.661083985066368 if not processed.
# Person entering MonkeyHut(queue=5, coresAvailable=0) at 7.8423506980851965
# -> receiving event at 7.968313656555972
# -> receiving event at 8.062873403325233
# -> receiving event at 8.09366286841447
# -> receiving event at 8.271321140171706
# producer called at 8.271321140171706
# production scheduled for 8.830024397879953
# Person #19 has entered the server MonkeyHut
# Person #19 will leave at 8.525600541625549 if not processed.
# Person entering MonkeyHut(queue=6, coresAvailable=0) at 8.271321140171706
# -> receiving event at 8.525600541625549
# -> receiving event at 8.830024397879953
# producer called at 8.830024397879953
# production scheduled for 8.92040308609834
# Person #20 has entered the server MonkeyHut
# Person #20 will leave at 10.617029436584467 if not processed.
# Person entering MonkeyHut(queue=7, coresAvailable=0) at 8.830024397879953
# -> receiving event at 8.92040308609834
# producer called at 8.92040308609834
# production scheduled for 8.935810018738321
# Person #21 has entered the server MonkeyHut
# Person #21 will leave at 9.698441558490813 if not processed.
# Person entering MonkeyHut(queue=8, coresAvailable=0) at 8.92040308609834
# -> receiving event at 8.935810018738321
# producer called at 8.935810018738321
# production scheduled for 9.034193762914976
# Person #22 has entered the server MonkeyHut
# Person #22 will leave at 9.373069516148291 if not processed.
# Person entering MonkeyHut(queue=9, coresAvailable=0) at 8.935810018738321
# -> receiving event at 9.034193762914976
# producer called at 9.034193762914976
# production scheduled for 9.076622312662817
# Person #23 has entered the server MonkeyHut
# Person #23 will leave at 9.52836304386002 if not processed.
# Person entering MonkeyHut(queue=10, coresAvailable=0) at 9.034193762914976
# -> receiving event at 9.039600746248654
# MonkeyHut(queue=11, coresAvailable=0) processing an exit ...
# !!! Person #13 has already left MonkeyHut
# !!! Person #14 has already left MonkeyHut
# !!! Person #15 has already left MonkeyHut
# !!! Person #16 has already left MonkeyHut
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=6, coresAvailable=0) at 9.039600746248654
# -> receiving event at 9.076622312662817
# producer called at 9.076622312662817
# production scheduled for 9.114782098857619
# Person #24 has entered the server MonkeyHut
# Person #24 will leave at 9.155674741733685 if not processed.
# Person entering MonkeyHut(queue=6, coresAvailable=0) at 9.076622312662817
# -> receiving event at 9.114782098857619
# producer called at 9.114782098857619
# production scheduled for 9.198083140790919
# Person #25 has entered the server MonkeyHut
# Person #25 will leave at 11.278499110299954 if not processed.
# Person entering MonkeyHut(queue=7, coresAvailable=0) at 9.114782098857619
# -> receiving event at 9.155674741733685
# -> receiving event at 9.198083140790919
# producer called at 9.198083140790919
# production scheduled for 9.232514860529362
# Person #26 has entered the server MonkeyHut
# Person #26 will leave at 9.300125576809263 if not processed.
# Person entering MonkeyHut(queue=8, coresAvailable=0) at 9.198083140790919
# -> receiving event at 9.232514860529362
# producer called at 9.232514860529362
# production scheduled for 9.259517236113506
# Person #27 has entered the server MonkeyHut
# Person #27 will leave at 9.53341182389663 if not processed.
# Person entering MonkeyHut(queue=9, coresAvailable=0) at 9.232514860529362
# -> receiving event at 9.259517236113506
# producer called at 9.259517236113506
# production scheduled for 9.689785201071853
# Person #28 has entered the server MonkeyHut
# Person #28 will leave at 9.475339722596178 if not processed.
# Person entering MonkeyHut(queue=10, coresAvailable=0) at 9.259517236113506
# -> receiving event at 9.300125576809263
# -> receiving event at 9.373069516148291
# -> receiving event at 9.475339722596178
# -> receiving event at 9.52836304386002
# -> receiving event at 9.53341182389663
# -> receiving event at 9.661083985066368
# -> receiving event at 9.689785201071853
# producer called at 9.689785201071853
# production scheduled for 9.790126146574558
# Person #29 has entered the server MonkeyHut
# Person #29 will leave at 11.002490458249758 if not processed.
# Person entering MonkeyHut(queue=11, coresAvailable=0) at 9.689785201071853
# -> receiving event at 9.698441558490813
# -> receiving event at 9.790126146574558
# producer called at 9.790126146574558
# production scheduled for 9.811542275580647
# Person #30 has entered the server MonkeyHut
# Person #30 will leave at 10.49927226776059 if not processed.
# Person entering MonkeyHut(queue=12, coresAvailable=0) at 9.790126146574558
# -> receiving event at 9.811542275580647
# producer called at 9.811542275580647
# production scheduled for 9.827454564106297
# Person #31 has entered the server MonkeyHut
# Person #31 will leave at 14.55837180572951 if not processed.
# Person entering MonkeyHut(queue=13, coresAvailable=0) at 9.811542275580647
# -> receiving event at 9.827454564106297
# producer called at 9.827454564106297
# production scheduled for 9.876378288660515
# Person #32 has entered the server MonkeyHut
# Person #32 will leave at 10.013247250916011 if not processed.
# Person entering MonkeyHut(queue=14, coresAvailable=0) at 9.827454564106297
# -> receiving event at 9.876378288660515
# producer called at 9.876378288660515
# Person #33 has entered the server MonkeyHut
# Person #33 will leave at 10.455326587636588 if not processed.
# Person entering MonkeyHut(queue=15, coresAvailable=0) at 9.876378288660515
# -> receiving event at 10.013247250916011
# -> receiving event at 10.064369104939422
# -> receiving event at 10.455326587636588
# -> receiving event at 10.49927226776059
# -> receiving event at 10.617029436584467
# -> receiving event at 10.685031420091205
# MonkeyHut(queue=16, coresAvailable=0) processing an exit ...
# !!! Person #18 has already left MonkeyHut
# !!! Person #19 has already left MonkeyHut
# !!! Person #20 has already left MonkeyHut
# !!! Person #21 has already left MonkeyHut
# !!! Person #22 has already left MonkeyHut
# !!! Person #23 has already left MonkeyHut
# !!! Person #24 has already left MonkeyHut
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=8, coresAvailable=0) at 10.685031420091205
# -> receiving event at 11.002490458249758
# -> receiving event at 11.217235172867035
# -> receiving event at 11.278499110299954
# -> receiving event at 12.39232591532676
# MonkeyHut(queue=8, coresAvailable=0) processing an exit ...
# !!! Person #26 has already left MonkeyHut
# !!! Person #27 has already left MonkeyHut
# !!! Person #28 has already left MonkeyHut
# !!! Person #29 has already left MonkeyHut
# !!! Person #30 has already left MonkeyHut
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=2, coresAvailable=0) at 12.39232591532676
# -> receiving event at 13.574087284568568
# MonkeyHut(queue=2, coresAvailable=0) processing an exit ...
# !!! Person #32 has already left MonkeyHut
# !!! Person #33 has already left MonkeyHut
# MONKEY POWER!
# Hurray! Person exited MonkeyHut(queue=0, coresAvailable=1) at 13.574087284568568
# -> receiving event at 14.55837180572951
# leavers =>
#         Deque [[2, 3, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 32, 33]]
# The End!