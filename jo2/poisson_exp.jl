function P(λ)
    n = 0
    acc = 1
    c = MathConstants.e^(-λ)
    while ((acc *= rand()) >= c)
        n += 1
    end
    return n
end

#############
n = 10^4
bPE = @benchmark g1 = [P(500) for i = 1:n]
display(bPE)
# better naive of before (S3)(L=500,n=10^4):
# BenchmarkTools.Trial: 
#   memory estimate:  78.33 KiB
#   allocs estimate:  6
#   --------------
#   minimum time:     459.663 μs (0.00% GC)
#   median time:      509.715 μs (0.00% GC)
#   mean time:        634.952 μs (2.44% GC)
#   maximum time:     44.075 ms (0.00% GC)
#   --------------
#   samples:          7818
#   evals/sample:     1

# This one:
# BenchmarkTools.Trial: 
#   memory estimate:  78.27 KiB
#   allocs estimate:  4
#   --------------
#   minimum time:     2.450 ms (0.00% GC)
#   median time:      2.957 ms (0.00% GC)
#   mean time:        3.885 ms (0.32% GC)
#   maximum time:     78.130 ms (0.00% GC)
#   --------------
#   samples:          1281
#   evals/sample:     1

#############
E = P
using Distributions
# V = (λ) -> Poisson(λ)
V = nothing
n = 10^4
#############
g1 = [E(2) for i = 1:n] # generate the samples
using Gadfly
p = plot(x = sort(g1), y = (1:n) ./ n, Geom.hair)

##############
include("../common/plotSamples.jl")

testEs(bandwidth = 1)