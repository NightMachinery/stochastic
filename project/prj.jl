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
    removableEvents::Array{Int}
    function Person(; id=-1, pos=(0., 0.), status=InfectionStatus.Healthy, currentPlace, workplace=nothing, isIsolated=false, removableEvents=[])
        me = new(id, pos, status, currentPlace, workplace, isIsolated, removableEvents)
        push!(currentPlace.people, me)
        me
    end
end

function defaultNextConclusion()
    rand(Uniform(2,4))
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

mutable struct CoronaModel
    centralPlace::Place
    marketplaces::Array{Marketplace}
    smallGridMode::Bool
    # Workplaces::Workplace
    pq::MutableBinaryMinHeap{SEvent}
    nextConclusion::Function
    hasDied::Function
    nextSickness::Function
    function CoronaModel(; centralPlace=Place(; width=100, height=70),
         marketplaces=[], smallGridMode=false, nextSickness,
         pq=MutableBinaryMinHeap{SEvent}(),
         nextConclusion=defaultNextConclusion,
         hasDied=defaultHasDiedλ(0.9))
        me = new(centralPlace, marketplaces, smallGridMode, pq, nextConclusion, hasDied) # uninitialized
        me.nextSickness = (p::Person) -> nextSickness(me, p)
        me
    end
end

function newPerson(; kwargs...)
    idCounter += 1
    Person(; id=idCounter, kwargs...)
end

function randomizePos(person::Person)
    person.pos = (rand(Uniform(0, person.currentPlace.width)), rand(Uniform(0, person.currentPlace.height)))
    return person
end

function runModel(; model::CoronaModel)
    n = 10
    function pushEvent(callback::Function, time::Float64)
        return push!(model.pq, SEvent(callback, time)) # returns handle to event
    end
    function cleanupEvents(person::Person)
        cleanupEvents(person.removableEvents)
    end
    function cleanupEvents(handles::AbstractArray{Int})
        for handle in handles 
            delete!(model.pq, handle)
        end
    end
    function genSickEvent(tNow, person::Person))
        tillNext = model.nextSickness(person)
        if tillNext >= 0
            pushEvent(tNow + tillNext) do tNow
                person.status = InfectionStatus.Sick
                sickEvent = pushEvent(tNow + model.nextConclusion()) do tNow
                    if model.hasDied()
                        person.status = InfectionStatus.Dead
                    else
                        person.status = InfectionStatus.RecoveredRemission
                        # TODO schedule transition to Recovered
                    end
                    # TODO recalculate the next sickness events of all people in person.currentPlace
            end
            push!(person.removableEvents, sickEvent)
            # TODO recalculate the next sickness events of all people in person.currentPlace
        end
        return person
    end
    people = [@>> Person(; currentPlace=model.centralPlace) randomizePos() for i in 1:n]

end

##
let λ = 10, rd = Exponential(inv(λ))
    global nextSicknessExp
    function nextSicknessExp(person::Person)::Float64
        if person.status == InfectionStatus.Healthy
            rand(rd)
        else
            -1.0
        end
    end
end
runModel(; model=CoronaModel(; nextSickness=nextSicknessExp))