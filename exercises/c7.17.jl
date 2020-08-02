# Estimate, by a simulation study, the expected worth of owning an option
# to purchase a stock anytime in the next 20 days for a price of 100 if the
# present price of the stock is 100. Assume the model of Section 7.8, with
# µ = −0.05, σ = 0.3, and employ the strategy presented there.

using Distributions, Statistics

stdNormal = Normal()
function std_cdf(x)
    cdf(stdNormal, x)
end

verbosity = 0
function pv1(args... ; kwargs...)
    if verbosity >= 1
        println(args... ; kwargs...)
    end
end

function stockOption(; μ=-0.05, σ=0.3, K=100, n=20)
    α = μ + (σ^2) / 2
    nrd = Normal(μ, σ)
    # S = [K] # one-indexed
    m = n
    Pm = K
    for m in n:-1:0
        if Pm > K 
            passAll = true
            for i in 1:m
                bi = (i * μ - log(ℯ, K / Pm)) / (σ * √i)
                if ! (Pm > 
                (K + Pm * ℯ^(i * α) * std_cdf(σ * √i + bi) - K * std_cdf(bi)) )
                    passAll = false
                end
            end
            if passAll
                pv1("Passed all tests at m=$(m) with Pm=$(Pm)")
                return Pm
            end
        end
        if m == 0
            pv1("Option never exercised.")
            return K
        end

        Pm = Pm * ℯ^(rand(nrd)) # S[(n - m) + 1]
    end

    @assert false "Bug5492"
end

##
data = [stockOption() for i in 1:10^5]
println("(mean-K)=$(mean(data) - 100), var=$(std(data; corrected=true)^2)")
# (mean-K)=43.988115052578166, var=7156.759701096597