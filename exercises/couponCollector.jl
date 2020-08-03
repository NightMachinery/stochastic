(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end

using Random, Distributions

function EN(; ns, ps, runs=10^5)
    @assert sum(ps) == 1
    @assert length(ns) == length(ps)

    kinds = length(ns)
    n = sum(ns)
    function EN_givenTs(; ts)
        T = maximum(ts)
        n + T - sum(ps[i] * ts[i] for i in 1:kinds)
    end
    Ti(i) = rand(Gamma(ns[i], inv(ps[i]))) # Gamma distribution with shape parameter α and scale θ
    TS() = [Ti(i) for i in 1:kinds]
    EN_givenTs_samples = [EN_givenTs(ts=TS()) for i in 1:runs]

    @labeled ns
    @labeled ps
    @labeled mean(EN_givenTs_samples)
    # return EN_givenTs_samples
end

##
p = [ 1 // 3, 1 // 9, 1 // 12, 1 // 5]
if sum(p) < 1
    push!(p, 1 - sum(p))
end
EN(; ns=[rand(1:10) for i in p], ps=p)

# ns =>
#         [3, 5, 10, 1, 5]
# ps =>
#         Rational{Int64}[1//3, 1//9, 1//12, 1//5, 49//180]
# mean(EN_givenTs_samples) =>
#         120.50300978101272

EN(; ns=[3,7], ps=[0.9,0.1])

# ns =>
#         [3, 7]
# ps =>
#         [0.9, 0.1]
# mean(EN_givenTs_samples) =>
#         69.97309050731829