include("../common/alias.jl")
using Distributions

n = 5
dist1 = Binomial(n, 0.4)
probArr = [pdf(dist1, i) for i in 0:n]
@assert abs(sum(probArr) - 1) < 10^-9

D1Alias = preP(probArr)
##
data = [D1Alias() for i in 1:10^7]
sad(data)