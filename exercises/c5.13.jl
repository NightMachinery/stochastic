(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random

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
@benchmark FxP2(4) samples=10^6
@benchmark FxP3(4) samples=10^6
@benchmark FxP(4) samples=10^6
##
@plot drawSamples((x) -> FxP2(4), (x) -> FxP(4)) png "c5.13 max - " "exercises/plots" true
@plot drawSamples((x) -> FxP3(4), (x) -> FxP(4)) png "c5.13 rejection - " "exercises/plots" true
