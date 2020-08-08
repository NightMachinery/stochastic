module SIR
##
(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random, Distributions, DataStructures, Lazy
include("../common/event.jl")
##
# We are assuming the unit time is one day.

@enum InfectionStatus Healthy = 1 Recovered RecoveredRemission Sick Dead 

###
# daySegments = 864 # 86400 seconds in a day
# exp2geomP(λ) = λ/daySegments
# geomTrial(λ) = rand() < (exp2geomP(λ))
###

mutable struct Place{T} 
    name::String
    width::Float64
    height::Float64
    people::Set{T}
    function Place(; name="", width, height, people=Set())
        new{Person}(name, width, height, people)
    end
end
mutable struct Marketplace
    place::Place
end
mutable struct Workplace
    place::Place
    startTime::Float64
    endTime::Float64
    function Workplace(; place, startTime, endTime)
        new(place, startTime, endTime)
    end
end
function workDuration(workplace::Workplace)
    return workDuration.endTime - workplace.startTime
end
function leisureDuration(workplace::Workplace)
    return 1.0 - workDuration(workplace)
end

idCounter = 0
mutable struct Person # <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    # vel::NTuple{2, Float64}

    status::InfectionStatus
    currentPlace::Place # Union{Place,Nothing}
    workplace::Union{Workplace,Nothing}
    isIsolated::Bool
    sickEvent::Union{Int,Nothing}
    # removableEvents::Array{Int}
    function Person(; id=-1, pos=(0., 0.), status=Healthy, currentPlace, workplace=nothing, isIsolated=false, 
        sickEvent=nothing
        # ,removableEvents=[]
        )
        me = new(id, pos, status, currentPlace, workplace, isIsolated, 
        sickEvent
        # ,removableEvents
        )
        push!(currentPlace.people, me)
        me
    end
end

function defaultNextConclusion()
    rand(Uniform(4, 15))
end
function defaultHasDiedλ(p_recovery)
    function hasDied()
        if rand() <= p_recovery 
            return false
        else
            return true
        end
    end
    return hasDied
end
function defaultNextCompleteRecovery()
    rand(Uniform(5, 7))
end

mutable struct CoronaModel{F1,F2,F3}
    centralPlace::Place
    marketplaces::Array{Marketplace}
    smallGridMode::Bool
    # Workplaces::Workplace
    pq::MutableBinaryMinHeap{SEvent}
    nextConclusion::F1
    hasDied::F2
    nextCompleteRecovery::F3
    nextSickness::Function
    function CoronaModel{F1,F2,F3}(centralPlace, marketplaces, smallGridMode, pq, nextConclusion::F1, hasDied::F2, nextCompleteRecovery::F3, nextSickness) where {F1,F2,F3}
        me = new(centralPlace, marketplaces, smallGridMode, pq, nextConclusion, hasDied, nextCompleteRecovery)
        me.nextSickness = (p::Person) -> nextSickness(me, p)
        me
    end
    # function CoronaModel{F1}(; centralPlace=Place(; width=100, height=70),
    #      marketplaces=[], smallGridMode=false, nextSickness,
    #      pq=MutableBinaryMinHeap{SEvent}(),
    #      nextConclusion::F1=defaultNextConclusion,
    #      hasDied=defaultHasDiedλ(0.9),
    #      nextCompleteRecovery=defaultNextCompleteRecovery
    #      ) where F1 <: Function
    #     me = new(centralPlace, marketplaces, smallGridMode, pq, nextConclusion, hasDied, nextCompleteRecovery) # uninitialized
    #     me.nextSickness = (p::Person) -> nextSickness(me, p)
    #     me
    # end
end
function CoronaModel(; centralPlace=Place(; width=100, height=70),
    marketplaces=[], smallGridMode=false, nextSickness,
    pq=MutableBinaryMinHeap{SEvent}(),
    nextConclusion::F1=defaultNextConclusion,
    hasDied::F2=defaultHasDiedλ(0.9),
    nextCompleteRecovery::F3=defaultNextCompleteRecovery
    ) where {F1,F2,F3}

    CoronaModel{F1,F2,F3}(centralPlace, marketplaces, smallGridMode, pq, nextConclusion, hasDied, nextCompleteRecovery, nextSickness)
end

function newPerson(; kwargs...)
    idCounter += 1
    Person(; id=idCounter, kwargs...)
end

function randomizePos(person::Person)
    person.pos = (rand(Uniform(0, person.currentPlace.width)), rand(Uniform(0, person.currentPlace.height)))
    return person
end

@copycode alertStatus begin
    # beep when people die? :D In general, producing a sound plot from this sim might be that much more novel ...
    sv1("$tNow: Person #$(person.id) is $(person.status)")
end
function runModel(; model::CoronaModel, n=10, simDuration=2)

    removedEvents = BitSet()
    function pushEvent(callback::Function, time::Float64)
        return push!(model.pq, SEvent(callback, time)) # returns handle to event
    end
    # function cleanupEvents(person::Person)
    #     cleanupEvents(person.removableEvents)
    # end
    function cleanupEvents(handles::AbstractArray{Int})
        for handle in handles 
            if handle ∉ removedEvents
                delete!(model.pq, handle)
                push!(removedEvents, handle)
            end
        end
    end
    function cleanupEvents(handle::Int)
        cleanupEvents([handle])
    end
    function cleanupEvents(handle::Nothing) end
    function recalcSickness(tNow, place::Place)
        for person in place.people
            cleanupEvents(person.sickEvent)
            genSickEvent(tNow, person)
        end
    end
    function infect(tNow, person::Person)
        person.status = Sick
        @alertStatus
        recalcSickness(tNow, person.currentPlace)
        pushEvent(tNow + model.nextConclusion()) do tNow
            if model.hasDied()
                person.status = Dead
            else
                person.status = RecoveredRemission
                # DONE schedule transition to Recovered
                pushEvent(tNow + model.nextCompleteRecovery()) do tNow
                    person.status = Recovered
                    @alertStatus
                    recalcSickness(tNow, person.currentPlace)
                end
            end
            @alertStatus
            recalcSickness(tNow, person.currentPlace)
        end
    end
    function genSickEvent(tNow, person::Person)
        tillNext = model.nextSickness(person)
        if tillNext >= 0
            sickEvent = pushEvent(tNow + tillNext) do tNow
                infect(tNow, person)
            end
            person.sickEvent = sickEvent
        end
        return person
    end
    firstSickPerson = true # ensures we'll have at least one sick person
    function randomizeSickness(person::Person)
        if firstSickPerson || rand() < 0.1
            firstSickPerson = false
            infect(0, person)
            sv1("Person #$(person.id) randomized to sickness.")
        end
        return person
    end
    people = [@>> Person(; id=i, currentPlace=model.centralPlace) randomizePos() randomizeSickness() for i in 1:n]
    recalcSickness(0, model.centralPlace)

    cEvent = nothing
    while ! (isempty(model.pq))
        cEvent, h = top_with_handle(model.pq)
        cleanupEvents(h)
        if cEvent.time > simDuration
            println("Simulation has exceeded authorized duration. Concluding.")
            break
        end
        sv1("-> receiving event at $(cEvent.time)")
        cEvent.callback(cEvent.time)
    end
    println("Simulation ended at $(cEvent.time)")
    # model.pq  # causes stackoverflow on VSCode displaying it
    people
end

##
let λ = 0.1, rd = Exponential(inv(λ))
    global nextSicknessExp
    function nextSicknessExp(model::CoronaModel, person::Person)::Float64
        if person.status == Healthy
            rand(rd)
        else
            -1.0
        end
    end
end
serverVerbosity = 0 ; @time ps = runModel(; model=CoronaModel(; nextSickness=nextSicknessExp), simDuration=10^3, n=10^3);
# 0.765242 seconds (14.47 M allocations: 459.282 MiB, 5.13% gc time)
@assert sum(1 for p in ps if (p.status == Recovered || p.status == Dead)) == 10^3
##
end