(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random

include("../common/plotSamples2.jl")
using Distributions, StatsBase

function Fx() 
    rand()
end
function Fx2() 
    # y = x^2 (x>=0)
    # x = √y
    √rand()
end
function Fx3()
    rand()^(1 / 3)
end
function FxP(power)
    rand()^(1 / power)
end
Fx5() = FxP(5)

function Q8a()
    choose = rand(1:3)
    if choose == 1
        return Fx()
    elseif choose == 2
        return Fx3()
    else
        return Fx5()
    end
end
function Q8a_cdf(x)
    (x + x^3 + x^5) / 3
end

function Q8b_cdf(x)
    if 0 < x <= 1
        (1 - ℯ^(-2x) + 2x) / 3
    else
        (3 - ℯ^(-2x)) / 3
    end
end
function Q8b()
    choose = rand(1:3)
    if choose == 1
        return rand(Exponential(1 / 2))
    else
        # 2 and 3
        return rand()
    end
end

function Q8c(α)
    @assert sum(α) == 1
    # for i in α
    #     @assert i >= 0
    # end

    FxP(sample(1:(length(α)), Weights(α)))
end
##
drawDistribution(Fx5)
@plot drawDistribution(Q8a) png "c5.8a - " "exercises/plots"
@labeled Q8a_cdf(0.5)
##
@plot drawDistribution(Q8b) png "c5.8b - " "exercises/plots"
@labeled Q8b_cdf(0.5)
@labeled Q8b_cdf(1)
##
@plot drawSamples((x) -> Q8c([1 // 3,0,1 // 3,0,1 // 3]), (x) -> Q8a()) png "c5.8c - " "exercises/plots" true # should be the same as Q8a
