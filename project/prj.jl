module SIR
using Luxor
##
(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random, Distributions, DataStructures, Lazy, MLStyle, UUIDs, IterTools
using Gadfly
import Cairo, Fontconfig
using Colors
using ForceImport
@force using Luxor
using MLStyle.AbstractPatterns: literal
include("../common/event.jl")
#
# We are assuming the unit time is one day.

sceneSize = (2100, 1500)
@enum InfectionStatus Healthy = 1 Recovered RecoveredRemission Sick Dead 
MLStyle.is_enum(::InfectionStatus) = true
# tell the compiler how to match it
MLStyle.pattern_uncall(e::InfectionStatus, _, _, _, _) = literal(e)
###
# daySegments = 864 # 86400 seconds in a day
# exp2geomP(λ) = λ/daySegments
# geomTrial(λ) = rand() < (exp2geomP(λ))
###

mutable struct Place{T} 
    name::String
    width::Float64
    height::Float64
    plotPos::NamedTuple{(:x, :y),Tuple{Float64,Float64}}
    people::Set{T}
    function Place(; name, width, height, people=Set(), plotPos)
        new{Person}(name, width, height, plotPos, people)
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
    pos::NamedTuple{(:x, :y),Tuple{Float64,Float64}} # NTuple{2,Float64} # Node{NTuple{2,Float64}}
    # vel::NTuple{2, Float64}

    status::InfectionStatus # Node{InfectionStatus}
    currentPlace::Place # Node{Place} # Union{Place,Nothing}
    workplace::Union{Workplace,Nothing}
    isIsolated::Bool
    sickEvent::Union{Int,Nothing}
    # removableEvents::Array{Int}
    function Person(; id=-1, pos=(x = 0., y = 0.), status=Healthy, currentPlace, workplace=nothing, isIsolated=false, 
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
###
function colorPerson(person::Person)
    colorStatus(getStatus(person))
end
function statusFromString_(status::String)
    eval(Meta.parse(status))
end
@defonce const statusFromString = memoize(statusFromString_)
function colorStatus(status::InfectionStatus)
    # we'll need to disable the border to be able to hide points by using α=0
    # α = 0.6 # we need to use alpha=vector in Gadfly:
    # `plot(x=[1,2],y=[4,5], color=[RGBA(1,1,1,1), RGB(1,0,1)], alpha=[1,0.1])`
    @match status  begin
        Sick => RGB(1, 0, 0) # :red    
        Healthy => RGB(0, 1, 0) # :green
        Dead => RGB(0, 0, 0) # :black
        RecoveredRemission => RGB(1, 0.7, 0) # RGB(1, 1, 0) # :yellow
        Recovered => RGB(0, 1, 1) # :blue
    end
    # @match status  begin
    #     Sick => RGBAf0(1, 0, 0, α) # :red    
    #     Healthy => RGBAf0(0, 1, 0, α) # :green
    #     Dead => RGBAf0(0, 0, 0, α) # :black
    #     RecoveredRemission => RGBAf0(1, 1, 0, α) # :yellow
    #     Recovered => RGBAf0(0, 1, 1, α) # :blue
    # end
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
    name::String
    centralPlace::Place
    marketplaces::Array{Marketplace}
    workplaces::Array{Workplace}
    smallGridMode::Bool
    μ::Float64
    pq::MutableBinaryMinHeap{SEvent}
    nextConclusion::F1
    hasDied::F2
    nextCompleteRecovery::F3
    nextSickness::F4
    function CoronaModel{F1,F2,F3,F4}(name, centralPlace, marketplaces, workplaces, smallGridMode, μ, pq, nextConclusion::F1, hasDied::F2, nextCompleteRecovery::F3, nextSickness::F4) where {F1,F2,F3,F4}
        me = new(name, centralPlace, marketplaces, workplaces, smallGridMode, μ, pq, nextConclusion, hasDied, nextCompleteRecovery, nextSickness)
        # me.nextSickness = (p::Person) -> nextSickness(me, p)
        me
    end
end
function CoronaModel(; name="untitled", centralPlace=Place(; name="Central", width=500, height=500, plotPos=(x = 10, y = 10)),
    marketplaces=[], workplaces=[], smallGridMode=false,μ=1.0, nextSickness::F4,
    pq=MutableBinaryMinHeap{SEvent}(),
    nextConclusion::F1=defaultNextConclusion,
    hasDied::F2=defaultHasDiedλ(0.8),
    nextCompleteRecovery::F3=defaultNextCompleteRecovery
    ) where {F1,F2,F3,F4}

    CoronaModel{F1,F2,F3,F4}(name, centralPlace, marketplaces, workplaces, smallGridMode, μ, pq, nextConclusion, hasDied, nextCompleteRecovery, nextSickness)
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
function insertPeople(dt::DataFrame, t, people)
    for status in instances(InfectionStatus)
        push!(dt, (t, count(people) do p p.status == status end, string(status)))    
    end
    dt
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
function runModel(; model::CoronaModel, n::Int=10, simDuration::Number=2, visualize::Bool=true, sleep::Bool=true, framerate::Int=30)
    @injectModel nextSickness
    internalVisualize::Bool = visualize
    visualize = false
    removedEvents = BitSet()
    function pushEvent(callback::Function, time::Float64)
        return push!(model.pq, SEvent(callback, time)) # returns handle to event
    end
    runID = "$(model.name) - $(uuid4())"
    plotdir = "$(pwd())/makiePlots/$(runID)"
    if internalVisualize
        mkpath(plotdir)
        @labeled plotdir
        # xs = []
        # ys = []
        # cs = []
        #     scene = Scene(resolution=sceneSize)
    end
    frameCounter = 0
    lastTime = 0
    function drawPlace(place::Place)
        # be sure to output images with even width and height, or encoding them will need padding
        old_matrix = getmatrix()
        padTop = 16

        translate(place.plotPos.x, place.plotPos.y)
        sethue("black")
        text(place.name, 10, padTop - 6)
        translate(0, padTop)
        rect(0, 0, place.width, place.height, :stroke)
        rect(0, 0, place.width, place.height, :clip)
        for person::Person in place.people
            sethue(colorPerson(person))
            circle(person.pos.x, person.pos.y, 2.3, :fillstroke)
        end
        clipreset()
        setmatrix(old_matrix)
    end
    function makieSave(tNow)
        frames = floor(Int, ((tNow - lastTime) / 10) / (1 / framerate))
        if frameCounter == 0
            frames = 1 # because we need to copy the previous keyframe, we need a bootstrap method
        end
        if frames <= 0
            return
        end
        lastTime = tNow

        # use previous keyframe
        dest = "$plotdir/all/$(@sprintf "%06d" frameCounter).png"
        mkpath(dirname(dest))
        for i in 2:frames
            frameCounter += 1
            destCopy = "$plotdir/all/$(@sprintf "%06d" frameCounter).png"
        
            cmd = `cp  $dest $destCopy`
            # println(string(cmd))
            # flush(STDOUT)
            run(cmd, wait=false)
        end

        frameCounter += 1
        dest = "$plotdir/all/$(@sprintf "%06d" frameCounter).png"
 
        scaleFactor = 3
        Drawing(600 * scaleFactor, 600 * scaleFactor, dest) # HARDCODED
        scale(scaleFactor)
        background("white")

        for place in Iterators.flatten(((model.centralPlace,), model.workplaces, model.marketplaces))
            drawPlace(place)
        end

        finish()
        println("Key frame saved: $dest")

        # error("hi")
    end
    function event2aniTime(tNow)
        # With the %f format specifier, the "2" is treated as the minimum number of characters altogether, not the number of digits before the decimal dot. 
        mins = floor(tNow / 60)
        secs = tNow - 60 * mins
        @sprintf "%02d:%012.9f" mins secs 
    end
    function setStatus(tNow, person::Person, status::InfectionStatus)
        # person.status[] = status
        person.status = status
        @alertStatus
        recalcSickness(tNow, person.currentPlace)
        if visualize
            cs[person.id] = colorPerson(person)
            makieSave(tNow)
        end 
    end
    function setPos(tNow, person::Person, pos)
        # person.pos[] = pos
        person.pos = pos
        # TODO2 react to pos change
    end
    function randomizePos(tNow, person::Person)
        setPos(tNow, person, (x = rand(Uniform(0, getPlace(person).width)), y = rand(Uniform(0, getPlace(person).height))))
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
        if Inf > tillNext >= 0
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

    dt::Union{DataFrame,Nothing} = nothing
    if internalVisualize
        # (scatter!([Point(getPos(person)) for person in people], color=[colorPerson(person) for person in people]))
        xs = [person.pos[1] for person in people]
        ys = [person.pos[2] for person in people]
        cs = [colorPerson(person) for person in people]
        visualize = true
        makieSave(0)

        dt = DataFrame(Time=Float64[], Number=Int64[], Status=String[])
    end

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
        if visualize
            insertPeople(dt, cEvent.time, people)
        end
    end
    println("Simulation ended at day $(cEvent.time)")
    # model.pq  # causes stackoverflow on VSCode displaying it
    if visualize
        plotTimeseries(dt, "$plotdir/timeseries.png")
    end
    people, dt
end
function plotTimeseries(dt::DataFrame, dest)
    mkpath(dirname(dest))
    plot(dt, x=:Time, y=:Number, color=:Status,
        Geom.line(),
        Scale.color_discrete_manual([colorStatus(status) for status in instances(InfectionStatus)]...),
        Theme(
            key_label_font_size=30pt,
            key_title_font_size=37pt,
            major_label_font_size=29pt,
            minor_label_font_size=27pt,
            line_width=2pt,
            background_color="white",

            # alphas = [1],
        )
    ) |> PNG(dest, 26cm, 18cm, dpi=150)
    bello()
end

firstbell()
##
serverVerbosity = 0
function nextSicknessExp(model::CoronaModel, person::Person)::Float64
    if getStatus(person) == Healthy
        rand(Exponential(inv(model.μ)))
    else
        -1.0
    end
end
function execModel(; visualize=true, n=10^3, model, simDuration=10^4)
    println("Took $(@elapsed ps, dt = runModel(; model=model, simDuration, n=n, visualize=visualize))")
    # 0.765242 seconds (14.47 M allocations: 459.282 MiB, 5.13% gc time)
    # Parametrizing nextSickness: 0.616788 seconds (12.02 M allocations: 230.663 MiB, 3.71% gc time)
    # storing allData 10x slowed to ~10
    # using observables 10x slowed to ~75
    # abandoning observables (+makie scene): 0.973560406

    visualize ? bello() : bello()
    @assert sum(1 for p in ps if (getStatus(p) == Recovered || getStatus(p) == Dead)) == n "Total recovered and dead people don't match total people."

    global lastPeople, lastDt = ps, dt
    # return ps, dt
    nothing
end
model1(μ=0.1 ; kwargs...) = execModel(; kwargs..., model=CoronaModel(; μ,nextSickness=nextSicknessExp))
#
function nsP1_2(model::CoronaModel, person::Person)::Float64
    @match getStatus(person) begin
        Recovered ||
        Healthy =>
        rand(Exponential(inv(model.μ)))
        _ =>
        -1.0
    end
end
m1_2(μ=0.1 ; n=10^2, kwargs...) = execModel(; n, kwargs..., model=CoronaModel(; μ,nextSickness=nsP1_2))
# Simulation ended at day 994.8028213815833
# Took 430.67870536 (+vis)
#
function nsP2_g(model::CoronaModel, person::Person, infectors, infectables)::Float64
    count_sick = count(model.centralPlace.people) do p p.status in infectors end
    if count_sick == 0
        return -1
    end
    rd = Exponential(inv(model.μ * count_sick))
    if getStatus(person) in infectables
        rand(rd)
    else
        -1.0
    end
end
nsP2_1_1(model::CoronaModel, person::Person) = nsP2_g(model, person, (Sick,), (Healthy,))
nsP2_1_2(model::CoronaModel, person::Person) = nsP2_g(model, person, (Sick,), (Healthy, Recovered))
nsP2_2_1(model::CoronaModel, person::Person) = nsP2_g(model, person, (Sick, RecoveredRemission), (Healthy,))
nsP2_2_2(model::CoronaModel, person::Person) = nsP2_g(model, person, (Sick, RecoveredRemission), (Healthy, Recovered))

m2_1_1(μ=1 / 10^2 ; n=10^2, kwargs...) = execModel(; n, kwargs..., model=CoronaModel(; name="$(@currentFuncName)¦ n=$n, μ=$(μ)", μ, nextSickness=nsP2_1_1))
m2_1_2(μ=1 / 10^2 ; n=10^2, kwargs...) = execModel(; n, kwargs..., model=CoronaModel(; name="$(@currentFuncName)¦ n=$n, μ=$(μ)", μ, nextSickness=nsP2_1_2))
m2_2_1(μ=1 / 10^2 ; n=10^2, kwargs...) = execModel(; n, kwargs..., model=CoronaModel(; name="$(@currentFuncName)¦ n=$n, μ=$(μ)", μ, nextSickness=nsP2_2_1))
m2_2_2(μ=1 / 10^2 ; n=10^2, kwargs...) = execModel(; n, kwargs..., model=CoronaModel(; name="$(@currentFuncName)¦ n=$n, μ=$(μ)", μ, nextSickness=nsP2_2_2))
# Key frame saved: /Users/evar/Base/_Code/uni/stochastic/makiePlots/m2_2_2¦ n=1000, μ=0.01 - 5ae4f090-2430-4868-b8d0-8322c62e23e1/all/001218.png
# Simulation ended at day 458.51707686527175
# Took 528.464985147
# Key frame saved: /Users/evar/Base/_Code/uni/stochastic/makiePlots/m2_2_2¦ n=1000, μ=0.001 - 8bbcbc15-b331-4e3b-a153-b8082e87291f/all/000854.png
# Simulation ended at day 323.698439247161
# Took 451.879709406
#
##
ps1 = model1()
##
function insertPeople(dt, t, people)
    for status in instances(InfectionStatus)
        push!(dt, (t, count(people) do p p.status == status end, string(status)))    
    end
    dt
end
dt = DataFrame(t=Float64[], n=Int64[], status=String[])
insertPeople(dt,2.2,ps1)
## 
# dt = DataFrame(t=1,
#     n=count(ps1) do p p.status == Healthy end,
#     status=string(Healthy)
# )

dt = DataFrame(Time=Float64[], Number=Int64[], Status=String[])
insertPeople(dt,2.2,ps1)
insertPeople(dt,3.0,ps1)
plot(dt, x=:Time, y=:Number, color=:Status,
    Geom.line(),
    Scale.color_discrete_manual([colorStatus(status) for status in instances(InfectionStatus)]...)
)
# plot(dt, x=:t, y=:n, color=:status,
#     Scale.x_discrete(levels=[2.2,3.0]),    
#     Stat.dodge(position=:stack), Geom.bar(position=:stack),
#     Guide.manual_color_key("Legend", collect(string.(instances(InfectionStatus))), [colorStatus(status) for status in instances(InfectionStatus)])
# )
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