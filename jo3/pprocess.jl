using Base.MathConstants, Distributions


function poisson(lan = 15, n = 200)
    p = Float64[e^-lan]
    pc = Float64[p[end]]
    sizehint!(p, n + 10)
    sizehint!(pc, n + 10)
    for i = 1:n - 1
        push!(p, (lan / i) * p[end])
        push!(pc, pc[end] + p[end])
    end
    @assert (1.0 - pc[end]) <= 10^-9 
    push!(pc, 1) # This is masmal :))
    return pc
end

function u2p(u, pc, λ)
    λ = ceil(Int, λ)
    # @assert λ >= 1 # hmm ...
    if u == pc[λ]
        return λ - 1
    elseif u >= pc[λ]
        for i = λ + 1:length(pc)
            if u <= pc[i]
                return i - 1
            end
        end
        throw("u2p bug: u=$u pc[λ]=$(pc[λ])")
    else
        for i = λ - 1:-1:1
            if u > pc[i]
                return i # +1
            end
        end
        return 0
    end
end

const PC = memoize(poisson)
function P(λ)
    pc = PC(λ, ceil(Int, λ * 3) + 30)
    return u2p(rand(), pc, λ)
end
###
function PP(λ = 1, from = 10, to = 30)
    len = to - from
    rate = λ * len
    n = P(rate)
    UN = Uniform(from, to)
    return [rand(UN) for i in 1:n]
end

function PPExp(λ = 1, from = 10, to = 30)
    ERng = Exponential(1 / λ)
    len = to - from
    rate = λ * len
    process = sizehint!(Array{Float64}(undef, 0), ceil(Int, rate * 2))
    last = from
    while true
        next = rand(ERng) + last
        if next > to
            break
        end
        push!(process, next)
        last = next
    end
    return process
end
###

include("../common/plotSamples2.jl")

function drawP(λs = [1,2])
    plt = drawSamples((λ)->P(λ), (λ)->rand(Distributions.Poisson(λ)), λs, title1 = "Poisson (simulated via memoized tables)", title2 = "Distributions.jl's")
    display(plt)
    # plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end

function drawPP(λs = [1] ; n = 10, from = -10, to = 10, G = PP, V = PPExp, alpha_d = 0.8, alpha_c = 0.8, colorscheme = ColorSchemes.gnuplot2)
    p_shared = []
    # p_shared = [Guide.xlabel(""), Coord.Cartesian(xmin = from, xmax = to)]
    p_d = [Guide.ylabel("Occurences")]
    p_c = [Guide.ylabel("Occurences (cumulative)")]
    plt = drawSamples((λ)->G(λs[1], from, to), (λ)->V(λs[2], from, to), [1:n;], n = 1, title1 = "Poisson Processes (λ=$(λs[1]); Colors show different runs; Total runs $n)", title2 = "Poisson Processes (λ=$(λs[2]); Colors show different runs; Total runs $n)", density = false, alpha_d = alpha_d, alpha_c = alpha_c, p_shared = p_shared, p_d = p_d, p_c = p_c, colorscheme = colorscheme)
    display(plt)
    # plt  |> PNG("./plots/play/$(uuid4().value).png", 26cm, 20cm, dpi = 150)
    println("Done!")
end
###
drawPP([0.5,10], n = 20)
drawPP([5,5], n = 20)
drawPP([0.1,0.5], n = 70, from = 0, to = 100, alpha_d = 0.8, alpha_c = 0.7, colorscheme = ColorSchemes.devon)
drawPP([0.08,0.15], n = 520, from = 0, to = 100, alpha_d = 1, alpha_c = 1, colorscheme = ColorSchemes.sunset,
G = function (λ, from, to)
    res = PP(λ, from, to) 
    return res .+ rand(Normal(0, 500))
end,
V = function (λ, from, to)
    res = PP(λ, from, to) 
    return map(x->x + rand(Normal(0, 500)), res)
end)

###
n = 10^4
@benchmark P(20) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  16 bytes
#   allocs estimate:  1
#   --------------
#   minimum time:     93.477 ns (0.00% GC)
#   median time:      175.804 ns (0.00% GC)
#   mean time:        190.944 ns (0.24% GC)
#   maximum time:     5.799 μs (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     950
PRng = Poisson(20)
@benchmark rand(PRng) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  0 bytes
#   allocs estimate:  0
#   --------------
#   minimum time:     325.426 ns (0.00% GC)
#   median time:      476.695 ns (0.00% GC)
#   mean time:        516.843 ns (0.00% GC)
#   maximum time:     17.325 μs (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     223