using Zygote
using Base.MathConstants


function poisson(lan=15, n=200)
    p = Float64[e^-lan]
    pc = Float64[p[end]]
    sizehint!(p, n + 10)
    sizehint!(pc, n + 10)
    for i = 1:n - 1
        push!(p, (lan / i) * p[end])
        push!(pc, pc[end] + p[end])
    end
    return p, pc
end

poi4, tmp = poisson(4, 101)
poi2, tmp = poisson(2, 101)
poi400, tmp = poisson(400, 10^3+1)
poi398, tmp = poisson(398, 10^3+1)

function poi(λ, x)
    # factorial(big(x) calls external
    # (((2.7182818284590)^-λ) * (λ^x)) / factorial(big(x))
    if λ == 4
        return poi4[x + 1]
    elseif λ == 2
        return poi2[x + 1]
    elseif λ == 400
        return poi400[x + 1]
    elseif λ == 398
        return poi398[x + 1]
    else
        throw("unsupported λ=$(λ)")
        return 0
    end
end

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

    function D1(x)
        poi(λ, x)
    end
    D2 = D1
    r = ceil(Int, λ / 50)
    rD = max(λ - r - 5, 0)
    rU = max(λ, λ + r)
    rD = 0
    rU = r*5
    if meatPoissonMode
        rD = 0
        rU = limDefault
    end
    function M0(x)
        if meatPoissonMode
            return poi(λ - 2, x)
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

##
using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations #some extra functions
f4(x0,x1) = -EBuy(4, (r) -> x0 + x1 * r)
f400(x0,x1) = -EBuy(400, (r) -> x0 + x1 * r, limDefault=10^3)

function f4Super(x)
    -EBuy(4, function (r)
    if 0 <= r <= 19
        return max(floor(x[floor(Int, r)+1]), 0) # alt: (not) floor the x array
    else
        return 0
    end 
end, meatPoissonMode=true)
end
function cleanSuperMin(x)
    map(x) do i
        max(floor(i), 0)
    end
end
##
result = optimize(f4Super, repeat([4.0], 20), ParticleSwarm(), Optim.Options(iterations=10^2))
supermin_raw = result.minimizer
supermin = cleanSuperMin(supermin_raw)
# supermin3 (meatPoissonMode=true, no float)
# 20-element Array{Float64,1}:
#     5.324044929767436
#     4.625586302078443
#     3.395262699899529
#     2.8519294201149323
#  -796.7412437730721
#    -6.406772817920561
#  -745.4533396346479
#    -4.116601927468185
#    -4.1041080884721115
#   -13.749579768305143
#    -2.30262679227498
#   -37.292749590942854
#    -1.1633327699707907
#   -14.932863320219129
#   -45.46030758047885
#   -41.904222575872325
#    -3.83642280705102
#   -27.506186930756265
#     0.3245926217435346
#  -106.06975806227284

# julia> f4Super(supermin3)
# -106.68671373868042

# julia> f4Super(supermin2)
# -104.14510377962442

# julia> f4Super([5 4 3 2 repeat([0], 16)...])
# -106.68671373868042
# supermin2 (meatPoissonMode=true, float allowed)
# 20-element Array{Float64,1}:
#    5.9927530973038365
#    3.904455635218287
#    2.995170759525546
#    1.999741377747799
#    0.9962878759166065
#   -1.8669090630863072
#    0.20423571000488652
#    0.616468658790437
#  -40.67021958473202
#    1.2615151826570485
#  -15.109231661425241
#   -1.4346446630396352
#  -17.176612477695436
#   -2.6939350388988577
#   -1.6604160977164046
#   -6.1196155582200795
#  -12.295571243794146
#    6.513840977411906
#   -5.606193338629621
#  -16.890296612854517
# supermin (meatPoissonMode=false)
# 20-element Array{Float64,1}:
#       4.999999999999997
#       3.999999999999998
#       2.999999999999924
#       1.9999999999999936
#       0.9999999999999936
#       0.9999999999999992
#      -5.577472288818667
#    -115.32148836440626
#   -1735.24248173241
#    4604.403732472405
#    -533.4947039215108
#      16.40141671419129
#      -7.954642808426176
#     -11.764342733609261
#       5.987035050725909
#  -14153.593152555848
#      -9.155862357033577
#    -256.13128024007625
#      -0.8150765873415937
#       4.48850259141765
##
using Gadfly
plot(x=0:19, y=supermin)
##
result = optimize(x-> f400(x[1],x[2]), [0.0,0.0], ParticleSwarm(), Optim.Options(iterations=10^2))
# result = optimize(x-> f400(x[1],x[2]), [0.0,0.0], LBFGS(), autodiff=:forward, Optim.Options(iterations=20))
#  * Status: success
#  * Candidate solution
#     Minimizer: [5.46e+02, -9.12e-02]
#     Minimum:   -1.600000e+04
#  * Found with
#     Algorithm:     L-BFGS
#     Initial Point: [0.00e+00, 0.00e+00]
#  * Convergence measures
#     |x - x'|               = 4.81e+01 ≰ 0.0e+00
#     |x - x'|/|x'|          = 8.80e-02 ≰ 0.0e+00
#     |f(x) - f(x')|         = 4.68e-06 ≰ 0.0e+00
#     |f(x) - f(x')|/|f(x')| = 2.93e-10 ≰ 0.0e+00
#     |g(x)|                 = 1.07e-11 ≤ 1.0e-08
#  * Work counters
#     Seconds run:   235  (vs limit Inf)
#     Iterations:    8
#     f(x) calls:    40
#     ∇f(x) calls:   40

##
# zygote can't take the gradient of f400 (I left it running for 8 hours)
# and flux is even more useless
using Flux
x0, x1 = 5, -1
f(x0,x1) = -EBuy(4, (r) -> x0 + x1 * r)
loss() = f(x0, x1)
l = loss() # ~ 3

gs = gradient(params(x, y)) do
    f(x, y)
  end

# θ = Params([x0,x1])
# grads = gradient(() -> loss(), θ)

# using Flux.Optimise: update!

# η = 0.1 # Learning Rate
# for p in (x0, x1)
#   update!(p, -η * grads[p])
# end