using StatsBase
function genDs()
    d1 = rand(1:6)
    d2 = rand(1:6)
    dmin = min(d1, d2)
    dmax = max(d1, d2)
    return dmin, dmax
end
function genDs2()
    d1 = rand(1:6)
    d2 = rand(1:6)
    dmin = min(d1, d2)
    dmax = sample(dmin:6, Weights(vec([1 repeat([2], 6 - dmin)...])))
    dmaxold = max(d1, d2)
    # dif = 0
    # if dmaxold > dmax
    #     dif = 1
    # elseif dmax > dmaxold
    #     dif = -1
    # end
    dif = dmax - dmaxold
    return dmin, dmax, dif
end
n = 10^5
data = [genDs() for i in 1:n]
data1 = [i[1] for i in data]
sort!(data1)
data2 = [i[2] for i in data]
sort!(data2)
datab = [genDs2() for i in 1:n]
datab1 = [i[1] for i in datab]
sort!(datab1)
difs = [i[3] for i in datab]
using Statistics
println("average diff: $(mean(difs))")
datab2 = [i[2] for i in datab]
sort!(datab2)
using DataFrames, Gadfly
ys = (1:n) ./ n
dataAll = vcat(DataFrame(diceNumber=1, num=ys, res=data1), DataFrame(diceNumber=2, num=ys, res=data2), DataFrame(diceNumber=3, num=ys, res=datab1), DataFrame(diceNumber=4, num=ys, res=datab2))
# plot(dataAll, x=:res, y=:num, color=:diceNumber, Geom.line(), Scale.x_discrete, Scale.color_discrete_manual("orange", "red", "green", "blue"))
plot(dataAll, x=:res, y=:num, color=:diceNumber, Geom.density(), Scale.x_discrete, Scale.color_discrete_manual("orange", "red", "green", "blue"))
nothing