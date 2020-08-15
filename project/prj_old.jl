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
bella()
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
##
function luxorSave(place::Place, dest)
        # be sure to output images with even width and height, or encoding them will need padding
    padTop = 16
    scaleFactor = 3
    Drawing(place.width * scaleFactor, (place.height + padTop) * scaleFactor, dest)
    scale(scaleFactor)
    background("white")
    sethue("black")
    text(place.name, 10, padTop - 6)
    translate(0, padTop)
    for person::Person in place.people
        sethue(colorPerson(person))
        circle(person.pos.x, person.pos.y, 2.3, :fillstroke)
    end
    finish()
end
function makieSave(tNow)
    frames = floor(Int, ((tNow - lastTime) / 10) / (1 / framerate))
    if frames <= 0
        return
    end
    lastTime = tNow

    frameCounter += 1
    for place in Iterators.flatten(((model.centralPlace,), model.workplaces, model.marketplaces))
        placedir = "$plotdir/$(place.name)"
        mkpath(placedir)
        dest = "$placedir/$(@sprintf "%06d" frameCounter).png"
        luxorSave(place, dest)
        println("Key frame saved: $dest")
        for i in 2:frames
            frameCounter += 1
            destCopy = "$placedir/$(@sprintf "%06d" frameCounter).png"
            
            cmd = `cp  $dest $destCopy`
                # println(string(cmd))
                # flush(STDOUT)
            run(cmd, wait=false)
        end
    end

        # error("hi")
end