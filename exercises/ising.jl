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
using Images, ImageView
# this will show an image in which the highest value
# of the array is white and the lowest is black 
# imshow(rand(Int, 3, 3))
imshow(ising())
imshow(ising(; β=1))
imshow(ising(; β=-1))
##
# imshow rocks! We can even add a third dimension for β!
isings = cat((ising(;β=i) for i in -3:0.1:3)... ; dims=3)
imshow(isings)