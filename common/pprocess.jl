using Base.MathConstants, Distributions


function poisson(lan = 15, n = 200)
    p = Float64[e^-lan]
    @assert p[1] > 0
    pc = Float64[p[end]]
    sizehint!(p, n + 10)
    sizehint!(pc, n + 10)
    for i = 1:n - 1
        push!(p, (lan / i) * p[end])
        push!(pc, pc[end] + p[end])
    end
    @assert (1.0 - pc[end]) <= 10^-8 "pc[end] is $(pc[end]) and not 1.0" 
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
##
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
##
function nhPP(λ0, λ::Function, from = 10, to = 30)
    filter(event->(rand() <= λ(event) / λ0), PPExp(λ0, from, to))
    # PP doesn't work for rate ~= 750 because of floating point errors.
end
##
function P2D(λ = 1 ; xmin = 1, xmax = 6, ymin = 10, ymax = 20)
    width = xmax - xmin
    height = ymax - ymin
    area = width * height
    rate = λ * area
    n = rand(Poisson(rate))
    ux = Uniform(xmin, xmax)
    uy = Uniform(ymin, ymax)

    return [[rand(ux) for i in 1:n] [rand(uy) for i in 1:n]]
end
@doc """
λ: (x,y) -> rate
"""->function nhP2D(λ0, λ::Function ; kwargs...)
    all = P2D(λ0 ; kwargs...)
    n = size(all)[1]
    thinned = Array{Float64,2}(undef, n, 2)
    thinnedN = 0
    for i in 1:n
        if rand() <= (λ(all[i,1], all[i,2]) / λ0)
            thinnedN += 1
            thinned[thinnedN, 1] = all[i,1]
            thinned[thinnedN, 2] = all[i,2]
        end
    end
    return view(thinned, 1:thinnedN, :)

    # filteredrows = filter(event->(rand() <= λ(event...) / λ0), collect(eachrow(all)))
    # return hcat(filteredrows)'
end    
# TODO Polar 2D circle poisson