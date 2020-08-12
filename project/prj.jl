module SIR
##
(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random, Distributions, DataStructures, Lazy, MLStyle, Makie
using MLStyle.AbstractPatterns: literal
include("../common/event.jl")
#
# We are assuming the unit time is one day.

sceneSize = (2100, 1500)
@enum InfectionStatus Healthy = 1 Recovered RecoveredRemission Sick Dead 
MLStyle.is_enum(::InfectionStatus) = true
# tell the compiler how to match it
MLStyle.pattern_uncall(e::InfectionStatus, _, _, _, _) = literal(e)
function colorPerson(person::Person)
    colorStatus(getStatus(person))
end
function colorStatus(status::InfectionStatus)
    # we'll need to disable the border to be able to hide points by using α=0
    α = 0.6
    @match status  begin
        Sick => RGBAf0(1, 0, 0, α) # :red    
        Healthy => RGBAf0(0, 1, 0, α) # :green
        Dead => RGBAf0(0, 0, 0, α) # :black
        RecoveredRemission => RGBAf0(1, 1, 0, α) # :yellow
        Recovered => RGBAf0(0, 1, 1, α) # :blue
    end
end
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

mutable struct Person # <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64} # Node{NTuple{2,Float64}}
    # vel::NTuple{2, Float64}

    status::InfectionStatus # Node{InfectionStatus}
    currentPlace::Place # Node{Place} # Union{Place,Nothing}
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

mutable struct CoronaModel{F1,F2,F3,F4}
    centralPlace::Place
    marketplaces::Array{Marketplace}
    smallGridMode::Bool
    # Workplaces::Workplace
    pq::MutableBinaryMinHeap{SEvent}
    nextConclusion::F1
    hasDied::F2
    nextCompleteRecovery::F3
    nextSickness::F4
    function CoronaModel{F1,F2,F3,F4}(centralPlace, marketplaces, smallGridMode, pq, nextConclusion::F1, hasDied::F2, nextCompleteRecovery::F3, nextSickness::F4) where {F1,F2,F3,F4}
        me = new(centralPlace, marketplaces, smallGridMode, pq, nextConclusion, hasDied, nextCompleteRecovery, nextSickness)
        # me.nextSickness = (p::Person) -> nextSickness(me, p)
        me
    end
end
function CoronaModel(; centralPlace=Place(; width=100, height=70),
    marketplaces=[], smallGridMode=false, nextSickness::F4,
    pq=MutableBinaryMinHeap{SEvent}(),
    nextConclusion::F1=defaultNextConclusion,
    hasDied::F2=defaultHasDiedλ(0.9),
    nextCompleteRecovery::F3=defaultNextCompleteRecovery
    ) where {F1,F2,F3,F4}

    CoronaModel{F1,F2,F3,F4}(centralPlace, marketplaces, smallGridMode, pq, nextConclusion, hasDied, nextCompleteRecovery, nextSickness)
end

# idCounter = 0
# function newPerson(; kwargs...)
#     idCounter += 1
#     Person(; id=idCounter, kwargs...)
# end
function getStatus(person::Person)
    person.status# []
end
function getPos(person::Person)
    person.pos# []
end
function getPlace(person::Person)
    person.currentPlace# []
end
@copycode alertStatus begin
    # beep when people die? :D In general, producing a sound plot from this sim might be that much more novel ...
    sv1("$tNow: Person #$(person.id) is $(getStatus(person))")
end
macro injectModel(name)
    quote
        function $(esc(name))(args...; kwargs...)
            $(esc(:(model.$name)))($(esc(:model)), args... ; kwargs...)
        end
    end
end
function runModel(; model::CoronaModel, n=10, simDuration=2, visualize=true, sleep=true)
    @injectModel nextSickness
    removedEvents = BitSet()
    function pushEvent(callback::Function, time::Float64)
        return push!(model.pq, SEvent(callback, time)) # returns handle to event
    end

    function setStatus(tNow, person::Person, status::InfectionStatus)
        # person.status[] = status
        person.status = status
        @alertStatus
        recalcSickness(tNow, person.currentPlace)
    end
    function setPos(tNow, person::Person, pos)
        # person.pos[] = pos
        person.pos = pos
        # TODO2 react to pos change
    end
    function randomizePos(tNow, person::Person)
        setPos(tNow, person, (rand(Uniform(0, getPlace(person).width)), rand(Uniform(0, getPlace(person).height))))
        return person
    end
    # function cleanupEvents(person::Person)
    #     cleanupEvents(person.removableEvents)
    # end
    function cleanupEvents(handles::AbstractArray{Int})
        for handle in handles 
            cleanupEvents(handle)
        end
    end
    function cleanupEvents(handle::Int)
        if handle ∉ removedEvents
            delete!(model.pq, handle)
            push!(removedEvents, handle)
        end
    end
    function cleanupEvents(handle::Nothing) end
    function recalcSickness(tNow, place::Place)
        for person in place.people
            cleanupEvents(person.sickEvent)
            genSickEvent(tNow, person)
        end
    end
    # function recalcSickness(tNow, place::Node{Place})
    #     recalcSickness(tNow, place[])
    # end
    function infect(tNow, person::Person)
        setStatus(tNow, person, Sick)
        pushEvent(tNow + model.nextConclusion()) do tNow
            if model.hasDied()
                setStatus(tNow, person, Dead)
            else
                setStatus(tNow, person, RecoveredRemission)
                pushEvent(tNow + model.nextCompleteRecovery()) do tNow
                    setStatus(tNow, person, Recovered)
                end
            end
        end
    end
    function genSickEvent(tNow, person::Person)
        tillNext = nextSickness(person)
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
    people = [@>> Person(; id=i, currentPlace=model.centralPlace) randomizePos(0) randomizeSickness() for i in 1:n]

    if visualize
        scene = Scene(resolution=sceneSize)
        display(scatter!([Point(getPos(person)) for person in people], color=[colorPerson(person) for person in people]))
    end

    allData = []
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
        # push!(allData, (cEvent.time, deepcopy(people)))
    end
    println("Simulation ended at day $(cEvent.time)")
    # model.pq  # causes stackoverflow on VSCode displaying it
    # people
    allData
end
bello()
##
begin
    let λ = 0.1, rd = Exponential(inv(λ))
        global nextSicknessExp
        function nextSicknessExp(model::CoronaModel, person::Person)::Float64
            if getStatus(person) == Healthy
                rand(rd)
            else
                -1.0
            end
        end
    end
    serverVerbosity = 0 ; println("Took $(@elapsed ps = runModel(; model=CoronaModel(; nextSickness=nextSicknessExp), simDuration=10^3, n=10^3))")
# 0.765242 seconds (14.47 M allocations: 459.282 MiB, 5.13% gc time)
# Parametrizing nextSickness: 0.616788 seconds (12.02 M allocations: 230.663 MiB, 3.71% gc time)
# storing allData 10x slowed to ~10
# using observables 10x slowed to ~75
# abandoning observables (+makie scene): 0.973560406
end
bello()
# @assert sum(1 for p in ps[end][2] if (getStatus(p) == Recovered || getStatus(p) == Dead)) == 10^3
##
scene = Scene(resolution=sceneSize)
currentPeople = ps[1][2];
# scatter!([Point(getPos(person)) for person in currentPeople], color=[colorPerson(person) for person in currentPeople])
# Makie.save("m1.png", scene)
display(scatter!([Point(getPos(person)) for person in currentPeople], color=[colorPerson(person) for person in currentPeople]));
function animate1(io=nothing, framerate=30)
    lastTime = 0
    for (d1, d2) in zip(ps, @view ps[2:end])
    # sleep(1 / 1000)
        if io == nothing
            scene.plots[end][:color] = [colorPerson(person) for person in d2[2]] 
            sleep((d2[1] - d1[1]) / 10)
        else
            frames = floor(Int, ((d2[1] - lastTime) / 10) / (1 / framerate))
            if frames > 0
                scene.plots[end][:color] = [colorPerson(person) for person in d2[2]] 
                for i in 1:frames
                    recordframe!(io)
                end
                lastTime = d2[1]
            end
        end
    end
end
bello()
##
framerate = 120
@time record(scene, "test.mkv"; framerate=framerate) do io
    animate1(io, framerate)
    println("Saved animation!")
    bellj()
end
##
diffEvents = Vector{Float64}()
for (d1, d2) in zip(ps, @view ps[2:end])
    global maxDiffEvents
    push!(diffEvents, d2[1] - d1[1])
end
@labeled maximum(diffEvents)
@labeled mean(diffEvents)
@labeled cov(diffEvents)
lines(2:length(ps), diffEvents, color=:blue)
##
end