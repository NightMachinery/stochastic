(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random
include("../common/event.jl")
##

@enum InfectionStatus Healthy = 1 Recovered RecoveredRemission Sick Dead 

##
# daySegments = 864 # 86400 seconds in a day
# exp2geomP(λ) = λ/daySegments
# geomTrial(λ) = rand() < (exp2geomP(λ))
##

idCounter::Int = 0
mutable struct Person # <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    # vel::NTuple{2, Float64}

    status::InfectionStatus
    currentPlace::Place
    workplace::Union{Workplace,nothing}
    isIsolated::Bool
    function Person(; id, pos=(0., 0.), status=InfectionStatus.Healthy, currentPlace, workplace=nothing, isIsolated=false)
        new(id, pos, status, currentPlace, workplace, isIsolated)
    end
end
mutable struct Place 
    name::String
    width::Float64
    height::Float64
    people
    function Place(; name, width, height, people)
        new(name, width, height, people)
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
struct CoronaModel
    marketplaces::Marketplace
    smallGridMode::Bool
    # Workplaces::Workplace
    nextSickness::Function
    function CoronaModel(; marketplaces, smallGridMode, nextSickness)
        me = new(marketplaces, smallGridMode, nothing)
        me.nextSickness = (p::Person) -> nextSickness(me, p)
        me
    end
end

function newPerson(; kwargs...)
    idCounter += 1
    Person(; id=idCounter, kwargs...)
end

function runModel(; model::CoronaModel)

end
