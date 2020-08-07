(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end

using Random

function initConf(rows, columns)
    # [ [0, [rand((-1,1)) for i in 1:height ]..., 0] for j in 1:width ]
    [ rand((-1, 1)) for h in 1:columns, w in 1:rows ]
end
function getSpin(conf, row, column)
    rows, columns = size(conf)
    if 1 <= column <= columns && 1 <= row <= rows
        conf[row, column]
    else
        0
    end
end 
function updateConf(conf, β)
    rows, columns = size(conf)

    row = rand(1:rows)
    column = rand(1:columns)

    up = (row - 1, column)
    down = (row + 1, column)
    right = (row, column - 1)
    left = (row, column + 1)
    neighbors = (up, down, right, left)

    neighbors_energy = sum(getSpin(conf, neighbor...) for neighbor in neighbors)
    PPlus = 1 / (1 + ℯ^(-2β * neighbors_energy))
    res = -1
    if rand() <= PPlus
        res = 1
    end
    conf[row, column] = res
    return conf
end

function ising(; β=0, rows=100, columns=100, n=10^6)
    conf = initConf(rows, columns)
    for i in 1:n
        updateConf(conf, β)
    end
    return conf
end

##
using Images, ImageView, Gtk, TestImages, GtkReactive
# this will show an image in which the highest value
# of the array is white and the lowest is black 
# imshow(rand(Int, 3, 3))
imshow(ising())
imshow(ising(; β=1))
imshow(ising(; β=-1))
##
data = [toGray.(ising(;β=i)) for i in -2:0.02:0.6]
@defonce const criticalβ = log(1 + √2) / 2 # 0.44
using Images, ImageView, Gtk, TestImages, GtkReactive, Distributions
using PerceptualColourMaps
begin
    imgsig = Signal(cdata[1])
    guidict = imshow_gui((300, 300))
    canvas = guidict["canvas"]
    Gtk.showall(guidict["window"])
    imshow(canvas, imgsig)
    endcolorview(RGB, permutedims(applycolormap(toGray.(ising(;β=-6)), cmap("R3")), [3, 1, 2]))
end
function animateising(; colormap="R1", framesleep=0.1, initsleep=1, kwargs...)
    begin
        toGray(x) = x == 1 ? rand(Uniform(0.7, 1)) : rand(Uniform(0.0, 0.1)) # 0.0
    # R3 is beautiful
        cdata = [colorview(RGB, permutedims(applycolormap(d, cmap(colormap ; kwargs...)), [3, 1, 2])) for d in data]
    end
    begin
        push!(imgsig, cdata[1])
        sleep(initsleep)
        for i in 2:length(cdata)
        # push!(imgsig, rand(10, 10))
            push!(imgsig, cdata[i])
            sleep(framesleep)
        end
    end
end
function showising(β, colormap="R1" ; kwargs...)
    push!(imgsig, colorview(RGB, permutedims(applycolormap(toGray.(ising(;β=β)), cmap(colormap; kwargs...)), [3, 1, 2])));
end
##
# imshow rocks! We can even add a third dimension for β!
isings = cat((ising(;β=i) for i in -3:0.1:3)... ; dims=3)
imshow(isings)