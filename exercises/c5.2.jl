# We use the inverse method:
# 0 < U < 1/4: X = 2√U + 2
# 1/4 < U < 1: X = 6(1 - Sqrt[1 - U]/Sqrt[3]) 
## Mathematica calculations:
# Solve[1 - 3/4 (2 - a/3)^2 == y, a]
# {{a -> 6 (1 - Sqrt[1 - y]/Sqrt[3])}, {a -> 
#    6 (1 + Sqrt[1 - y]/Sqrt[3])}} 

(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random

function X_C5_2()
    u = rand()
    if 0 <= u <= 1 / 4
        return 2sqrt(u) + 2
    else
        return 6(1 - sqrt(1 - u) / sqrt(3))
    end
end

include("../common/plotSamples2.jl")
@plot drawDistribution(X_C5_2) png "c5.2 - " "exercises/plots"