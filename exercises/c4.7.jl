(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random

using OffsetArrays
function D()
    exhaustMe = OffsetArray(repeat([false], 11), 2:12)
    res = 0
    while ! all(exhaustMe)
        res += 1
        exhaustMe[rand(1:6) + rand(1:6)] = true
    end
    res
end

##
data = [D() for i in 1:10^6]
println("mean=$(mean(data))")
# => 61.2