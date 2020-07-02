function NPolar()
    u1 = rand()
    u2 = rand()
    r = sqrt(-2 * log(u1))
    θ = 2 * pi * u2
    x = r * cos(θ)
    y = r * sin(θ)
    return x, y
end

function NPolar2()
    u1 = rand()
    r = sqrt(-2 * log(u1))
    UN = Uniform(-1, 1)
    while true
        v1 = rand(UN)
        v2 = rand(UN)
        v12 = sqrt(v1^2 + v2^2)
        if v12 > 1
            continue
        end
        x = r * v1 / v12
        y = r * v2 / v12
        return x, y
    end
end

##
@benchmark NPolar() samples = 10^8
# BenchmarkTools.Trial: 
#   memory estimate:  0 bytes
#   allocs estimate:  0
#   --------------
#   minimum time:     50.764 ns (0.00% GC)
#   median time:      52.080 ns (0.00% GC)
#   mean time:        63.948 ns (0.00% GC)
#   maximum time:     33.912 μs (0.00% GC)
#   --------------
#   samples:          77339
#   evals/sample:     986

@benchmark NPolar2() samples = 10^8
# BenchmarkTools.Trial: 
#   memory estimate:  0 bytes
#   allocs estimate:  0
#   --------------
#   minimum time:     55.742 ns (0.00% GC)
#   median time:      59.024 ns (0.00% GC)
#   mean time:        64.203 ns (0.00% GC)
#   maximum time:     1.537 μs (0.00% GC)
#   --------------
#   samples:          77226
#   evals/sample:     982

# So ~32 ns vs 90 ns for accept-reject
##

include("../common/plotSamples2.jl")

function drawNPolar(mean = 0, std = 1)
    plt = drawSamples((λ)->(NPolar()[λ] * std) + mean, (λ)->rand(Distributions.Normal(mean, std)), [1])
    display(plt)
    # plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end

function drawNPolars(mean = 0, std = 1)
    plt = drawSamples((λ)->(NPolar()[λ] * std) + mean, (λ)->(NPolar2()[λ] * std) + mean, [1,2])
    display(plt)
    # plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end
##
drawNPolars(300, 4)
drawNPolars(-550, 14)