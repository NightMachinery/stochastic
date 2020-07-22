using Distributions

function EBuy(λ, buy ; limDefault=10^2, meatPoissonMode=false)

    function sell1(d1, m0)
        min(d1, buy(m0) + m0)
    end

    function trash1(d1, m0)
        max(m0 - d1, 0)
    end

    function remaining1(d1, m0)
        max(0, buy(m0) - max(0, d1 - m0))
    end

    function sell2(d1, m0, d2)
        r1 = remaining1(d1, m0)
        min(d2, buy(r1) + r1)
    end

    function trash2(d1, m0, d2)
        max(0, remaining1(d1, m0) - d2)
    end

    function profit(d1, m0, d2)
        profit_price = 20
        waste_price = -100

        profit_price * (sell1(d1, m0) + sell2(d1, m0, d2)) + waste_price * (trash1(d1, m0) + trash2(d1, m0, d2))
    end

    D1Rng = Poisson(λ)
    D2Rng = D1Rng
    function D1(x)
        pdf(D1Rng, x)
    end
    D2 = D1
    M0Rng = Poisson(λ - 2)
    r = ceil(Int, λ / 50)
    rD = max(λ - r - 5, 0)
    rU = max(λ, λ + r)
    if meatPoissonMode
        rD = 0
        rU = limDefault
    end
    function M0(x)
        if meatPoissonMode
            return pdf(M0Rng, x)
        else
            if rD <= x <= rU
                return 1 // (rU - rD + 1)
            else
                return 0
            end
        end
    end

    function EProfit(; limID=rD, limIU=rU, limJ=limDefault, limK=limDefault)
        sum = 0
        for i in limID:limIU
            if M0(i) == 0
                continue
            end
            Sj = 0
            for j in 0:limJ
                Sk = 0

                for k in 0:limK
                    Sk += D2(k) * profit(j, i, k)
                end

                Sj += D1(j) * Sk
            end
            if i == limID
                # return Sj
                # println("With m0=0, EProfit = $(Sj)")
            end
            # println("i=$(i), Sj=$(Sj)")
            sum += M0(i) * Sj
        end

        return sum
    end

    EProfit()
end


## visualization

##
# sucks for this problem, probably useful for really expensive functions
using PyCall
bopt = pyimport("bayes_opt")
bo = bopt.BayesianOptimization
pbounds = Dict("x0" => (0, 1000), "x1" => (-3, 0))
function f_bo_4(; x0, x1) 
    EBuy(4, (meat) -> max(0, x0 + x1 * meat), limDefault=10^2)
end
function f_bo_400(; x0, x1) 
    EBuy(400, (meat) -> max(0, x0 + x1 * meat), limDefault=10^3, meatPoissonMode=false)
end
optimizer = bo(
    f=f_bo_400,
    pbounds=pbounds,
    random_state=1,
)
optimizer.maximize(init_points=10, n_iter=10,)
println(optimizer.max)
# f_bo_400 meatPoissonMode=true:
# init_points=10, n_iter=10, "x0" => (0, 1000), "x1" => (-3, 0) 
# Dict{Any,Any}("target" => 14970.285535199482,"params" => Dict{Any,Any}("x1" => -0.6560654265606134,"x0" => 416.9051617225262))
# init_points=20, n_iter=20, pbounds = Dict("x0" => (0, 1000), "x1" => (-3, 0))
# Dict{Any,Any}("target" => 15282.512004533919,"params" => Dict{Any,Any}("x1" => -0.39148778986272426,"x0" => 418.57140487304156))
# f_bo_4:
# pbounds = Dict("x0" => (0, 100), "x1" => (-3, 0))
# |  200      |  90.75    |  5.044    | -0.9496   |
##
using BlackBoxOptim
function f(x) 
    -EBuy(400, (meat) -> max(0, x[1] + x[2] * meat), limDefault=10^3)
end
res = bboptimize(f; SearchRange=[(0.0, 1000.0), (-2.0, 0.0)], MaxSteps=100, NumDimensions=2, NThreads=Threads.nthreads() - 1)

# λ=400:
# 47 steps, SearchRange=[(0.0, 1000.0), (-2.0, 0.0)]
# (-15282.512004533954, [641.6391215778216, -1.1118424609926385])
# #
# bigger range
# Optimization stopped after 101 steps and 283.48 seconds
# Termination reason: Max number of steps (100) reached
# Steps per second = 0.36
# Function evals per second = 0.55
# Improvements/step = 0.62000
# Total function evaluations = 155


# Best candidate found: [1403.93, -3.08899]

# Fitness: -15282.512004534
##
using BlackBoxOptim
function f400_2(x) 
    -EBuy(400, (meat) -> max(0, x[1] + x[2] * meat + x[3] * (meat^2)), limDefault=10^3)
end
function f4_2(x) 
    -EBuy(4, (meat) -> max(0, x[1] + x[2] * meat + x[3] * (meat^2)), limDefault=10^2)
end
res_f400_2 = bboptimize(f400_2; SearchRange=[(0.0, 1100.0), (-10.0, 10.0), (-10.0, 10.0)], MaxSteps=100, NumDimensions=3, NThreads=Threads.nthreads() - 1)
# result of `bboptimize(f400_2; SearchRange=[(0.0, 1100.0), (-10.0, 10.0), (-10.0, 10.0)], MaxSteps=100, NumDimensions=3, NThreads=Threads.nthreads() - 1)`:
# Optimization stopped after 101 steps and 283.14 seconds
# Termination reason: Max number of steps (100) reached
# Steps per second = 0.36
# Function evals per second = 0.54
# Improvements/step = 0.61000
# Total function evaluations = 153
# Best candidate found: [755.471, -2.20859, -7.60046]
# Fitness: -15089.014405441
res = bboptimize(f4_2; SearchRange=[(0.0, 1100.0), (-10.0, 10.0), (-10.0, 10.0)], MaxSteps=10000, NumDimensions=3, NThreads=Threads.nthreads() - 1)
# f4_2:
# Optimization stopped after 10001 steps and 52.87 seconds
# Termination reason: Max number of steps (10000) reached
# Steps per second = 189.16
# Function evals per second = 190.58
# Improvements/step = 0.18420
# Total function evaluations = 10076


# Best candidate found: [5.11035, -1.18801, 0.0664189]

# Fitness: -91.220613074
##
# Cbc, GLPK
using JuMP, Ipopt
m = Model(optimizer_with_attributes(Ipopt.Optimizer, "max_cpu_time" => 10.0))
@variable(m, x1 <= 0)
@variable(m, x2 >= 0)
function f(m, b) 
    EBuy(4, (meat) -> max(0, b + m * meat), limDefault=10^2)
    # EBuy(400, (meat) -> max(0, b + m * meat), limDefault=10^3)
end
JuMP.register(m, :f, 2, f, autodiff=true)
@NLobjective(m, Max, f(x1, x2))
optimize!(m)
println("x1=m=$(value(x1)), x2=b=$(value(x2)), objective=$(objective_value(m)), direct objective=$(f(value(x1), value(x2)))")
##
using JuMP, Ipopt
m = Model(optimizer_with_attributes(Ipopt.Optimizer, "max_cpu_time" => 60.0))
@variable(m, x0)
@variable(m, x1)
@variable(m, x2)
function f(x0, x1, x2) 
    EBuy(4, (meat) -> max(0, x0 + x1 * meat + x2 * (meat^2)), limDefault=10^2, meatPoissonMode=true)
    # EBuy(400, (meat) -> max(0, b + m * meat), limDefault=10^3)
end
JuMP.register(m, :f, 3, f, autodiff=true)
@NLobjective(m, Max, f(x0, x1, x2))
optimize!(m)
println("x0=$(value(x0)),x1=$(value(x1)), x2=$(value(x2)), objective=$(objective_value(m)), direct objective=$(f(value(x0), value(x1), value(x2)))")
##
function opt4(step=1)
    mymax = -Inf
    maxM = -Inf
    maxB = -Inf
    for m in -10:step:10
        for b in -10:step:10
            curr = EBuy(4, (x) -> m * x + b)
            if curr > mymax
                mymax = curr
                maxM = m
                maxB = b
            end
        end
    end
    println("$(maxM)x + $(maxB), max=$(mymax)")
end
opt4()
##
using ModelingToolkit
@parameters p_a p_b
sys1 = OptimizationSystem(EBuy(4, (meat) -> max(0, p_b - p_a * meat) ; limDefault=10^2), [], [p_a, p_b])
nothing
##
EBuy( 4, (meat) -> max(0, 4 - meat), limDefault=10^2)
# With m0=0, EProfit = 122.79243902842249
# 100.003203060261066
EBuy( 4, (meat) -> max(0, 5 - meat) ; limDefault=10^2) 
# With m0=0, EProfit = 127.67572157252292
# 107.51015707529938
EBuy( 4, (meat) -> max(0, 5.5 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 122.41131072793357
# 104.20422470340004
EBuy( 4, (meat) -> max(0, 4.5 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 125.23408030047273
# 103.75668006778024
EBuy( 4, (meat) -> max(0, 3 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 104.36925504225923
# 81.41500287494729
EBuy( 4, (meat) -> max(0, 7 - meat) ; limDefault=10^2)
# With m0=0, EProfit = 90.2364312658074
# 78.29477631299676
EBuy( 4, (meat) -> max(0, 10 - meat) ; limDefault=10^2)
# With m0=0, EProfit = -82.75163797624171
# -85.48826766326272
EBuy( 4, (meat) -> max(0, 4) ; limDefault=10^2)
# With m0=0, EProfit = 127.2548616574279
# 93.15345245147779
EBuy( 4, (meat) -> max(0, 5) ; limDefault=10^2)
# With m0=0, EProfit = 131.62316690347978
# 71.18532186271467
EBuy( 4, (meat) -> max(0, 40) ; limDefault=10^2)
# With m0=0, EProfit = -3040.000000000001
# -3240.000000000001
EBuy( 4, (meat) -> max(0, 1) ; limDefault=10^2)
# With m0=0, EProfit = 39.56659469664482
# 47.36929031901994
EBuy( 4, (meat) -> max(0, 0) ; limDefault=10^2)
# With m0=0, EProfit = 0.0
# 8.724792121641496
##
EBuy( 400, (meat) -> max(0, 600 - meat) ; limDefault=10^3) 
# With m0=0, EProfit = 15999.999999999976
# 14970.38590044147
EBuy( 400, (meat) -> max(0, 500 - meat) ; limDefault=10^3)
# With m0=0, EProfit = 15999.999879997378
# 14970.385780438863
EBuy( 400, (meat) -> max(0, 400) ; limDefault=10^3)
# With m0=0, EProfit = 15727.630166187062
# 14465.746084818367
EBuy( 400, (meat) -> max(0, 400 - meat) ; limDefault=10^3)
# With m0=0, EProfit = 15727.630166187062
# 14465.746084818367
EBuy( 400, (meat) -> max(0, 500) ; limDefault=10^3)
# With m0=0, EProfit = 15999.99993999849
# 6197.51026506349
EBuy( 400, (meat) -> max(0, 700 - meat) ; limDefault=10^3)
# With m0=0, EProfit = 15999.897657317053
# 14970.383528682078
EBuy( 400, (meat) -> max(0, 300) ; limDefault=10^3)
# With m0=0, EProfit = 11999.999994352858
# 14970.385884998796
EBuy( 400, (meat) -> max(0, 1000 - meat) ; limDefault=10^3)
# With m0=0, EProfit = -4000.0000000021128
# -4000.0000000033624
EBuy( 400, (meat) -> max(0, 100) ; limDefault=10^3)
# With m0=0, EProfit = 4000.0000000000014
# 10724.463080529767