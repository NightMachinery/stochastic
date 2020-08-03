(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using Random

include("../common/alias.jl")
using Distributions

n = 5
dist1 = Binomial(n, 0.4)
probArr = [pdf(dist1, i) for i in 0:n]
# probArr =>
#         [0.07776, 0.25920000000000015, 0.3456, 0.2304, 0.07679999999999998, 0.010240000000000008]
@assert abs(sum(probArr) - 1) < 10^-9

D1Alias = preP(probArr)
##
data = [D1Alias() for i in 1:10^7]
sad(data)
# Dim1  │ 
# ──────┼──────────
# 1     │  0.077703
# 2     │  0.256552
# 3     │  0.323052
# 4     │  0.255543
# 5     │ 0.0769053
# 6     │ 0.0102448