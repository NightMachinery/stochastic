include("../common/plotSamples2.jl")
using Distributions, StatsBase

function FxP2(power)
    maximum([rand() for i in 1:power])
end

function FxP3(power)
    # rejection sampling
    res = rand()
    if rand() <= res^(power - 1) # (power * (res^(power - 1)))/power
        return res
    else
        return FxP3(power)
    end
end
##
drawSamples((x) -> FxP2(4), (x) -> FxP(4))
drawSamples((x) -> FxP3(4), (x) -> FxP(4))
