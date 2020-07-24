using StatsBase, Distributions
function genDs()
    return rand(Exponential(10))
end
function genDs2()
    # return rand(Exponential(20)) 
    # return genDs() + genDs()
    a = genDs()
    c = rand(Exponential(rand(1:30)))
    if a >= c
        return genDs() + c
    else
        return a
    end
end
n = 10^5
using DataFrames, Gadfly
ys = (1:n) ./ n
data1 = sort([genDs() for i in 1:n])
data2 = sort([genDs2() for i in 1:n])
dataAll = vcat(DataFrame(diceNumber=1, num=ys, res=data1), DataFrame(diceNumber=2, num=ys, res=data2))
# plot(dataAll, x=:res, y=:num, color=:diceNumber, Geom.line(), Scale.x_discrete, Scale.color_discrete_manual("orange", "red", "green", "blue"))
plot(dataAll, x=:res, y=:num, color=:diceNumber, Geom.density(), Scale.color_discrete_manual("red", "blue"))
# nothing