# the random variable X can take on any of the values 1, . . . , 10
# with respective probabilities 0.06, 0.06, 0.06, 0.06, 0.06, 0.15, 0.13, 0.14, 0.15, 0.13
# P{j} = (p1{j} + p2{j})/2

p1 = [repeat([10 // 100], 5)..., 10 // 100, 1 // 100, 28 // 100, 10 // 100, 1 // 100]
p2 = [repeat([2 // 100], 5)..., 20 // 100, 25 // 100, 0 // 100, 20 // 100, 25 // 100]
@assert sum(p1) == 1
@assert sum(p2) == 1

using StatsBase
function X()
    if rand(Bool)
        sample(1:10, Weights(p1))
    else
        sample(1:10, Weights(p2))
    end
end

##
data = [X() for i in 1:10^6]
sad(data)