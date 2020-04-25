using Base.MathConstants


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
###

include("../common/plotSamples2.jl")

function drawP(λs = [1,2])
    plt = drawSamples((λ)->P(λ), (λ)->rand(Distributions.Poisson(λ)), λs, title1 = "Poisson (simulated via memoized tables)", title2 = "Distributions.jl's")
    display(plt)
    # plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end

function drawPP(λs = [1] ; n = 10, from = -10, to = 10)
    p_shared = [Guide.xlabel(""), Coord.Cartesian(xmin = from, xmax = to)]
    p_d = [Guide.ylabel("Occurences")]
    p_c = [Guide.ylabel("Occurences (cumulative)")]
    plt = drawSamples((λ)->PP(λs[1], from, to), (λ)->PP(λs[2], from, to), [1:n;], n = 1, title1 = "Poisson Processes (λ=$(λs[1]); Colors show different runs; Total runs $n)", title2 = "Poisson Processes (λ=$(λs[2]); Colors show different runs; Total runs $n)", density = false, alpha_d = 0.8, alpha_c = 0.8, p_shared = p_shared, p_d = p_d, p_c = p_c)
    display(plt)
    # plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end
###
drawPP([0.5,10], n = 20)
