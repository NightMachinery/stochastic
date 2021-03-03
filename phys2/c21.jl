## Useful functions
# rad2deg
##
(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end
using LinearAlgebra
using PhysicalConstants.CODATA2018
using Unitful
using ForceImport
@force using Unitful.DefaultSymbols
# https://painterqubits.github.io/Unitful.jl/stable/highlights/
# 8m == 800cm
# -
##
# julia> using Unitful, Latexify, UnitfulLatexify; # this last one is new
# julia> latexify(24u"km")
# L"$24\;\mathrm{km}$"
# julia> latexify(24u"km",unitformat=:siunitx)
# L"\SI{24}{\kilo\meter}"
##
using Formatting

function shift_unit(u::U, d, n) where {U<:Unitful.Unit}
    i₀ = floor(Int, d/n)
    d = 3i₀
    iszero(d) && return u,0
    for (i,tens) in enumerate(Unitful.tens(u) .+ (d:(-3*sign(d)):0))
        haskey(Unitful.prefixdict, tens) && return U(tens, u.power),i-1 + i₀
    end
    u,0
end

power_step(::Any) = 3

function shift_unit(u::Unitful.FreeUnits, d)
    tu = typeof(u)
    us,ds,a = tu.parameters

    uu,i = shift_unit(us[1], d, power_step(1u))

    Unitful.FreeUnits{(uu,us[2:end]...), ds, a}(),i
end

logu(::Any, v) = log10(v)
divider(::Any) = 1.0

function si_round(q::Quantity; fspec="{1:+9.4f} {2:s}")
    v,u = ustrip(q), unit(q)
    if !iszero(v)
        u,i = shift_unit(u, logu(q,abs(v)))
        q = u(q/(divider(q)^i))
    end
    format(fspec, ustrip(q), unit(q))
end
ss = si_round
##
## P4_C1
Mass = typeof(1.0u"kg")
Speed = typeof(1.0u"m/s")
Length = typeof(1.0u"m")
MyDegree = typeof(1.0°)
Momentum = typeof(1.0u"kg*m/s")
Energy = typeof(1.0u"J")
Charge = typeof(1.0u"C")
Force = typeof(1.0u"N")
Base.@kwdef mutable struct Particle 
    position::Vector{Length} = [0.0u"m", 0.0u"m"]
    mass::Mass = 0.0u"kg"
    charge::Charge = 0.0u"C"
    speed::Vector{Speed} = [0.0u"m/s", 0.0u"m/s"]
end
##
LinearMomentum(mass::Mass, speed::Speed) = mass * speed
LinearMomentum(mass::Mass, speed::Vector{Speed}) = mass * speed
lmom = LinearMomentum
AngularMomentum(position::Vector{Length}, momentum::Momentum) = cross2(position, momentum)
##
ElectricConstant = 1 / (4 * π * VacuumElectricPermittivity)
ElectricForce(charge1::Charge, charge2::Charge, r::Length)::Force = (ElectricConstant) * abs(charge1) * abs(charge2) / abs2(r)
ElectricForce(charge1::Charge, charge2::Charge, r::Vector{Length})::Vector{Force} = (ElectricConstant) * charge1 * charge2 * r / norm(r)^3
function ElectricForce(p1::Particle, p2::Particle)::Vector{Force}
    ElectronMass(p1.charge, p2.charge, p1.position - p2.position)
end
##
KineticEnergy(m::Mass, v::Speed)::Energy = 0.5 * m * v^2
KineticEnergy(m::Mass, p::Momentum)::Energy = 0.5 * p^2 / m
KineticEnergy(m::Mass, v::Vector)::Energy = KineticEnergy(m, mag2(v))
ke = KineticEnergy
# tests:
# KineticEnergy(4.0kg,[1.0m/s,1.0m/s])
# KineticEnergy(4.0kg,[4.0kg*m/s,4.0kg*m/s])
##
function vecθ(length, θ)
    # No general degree dimension, so leave it untyped to dispatch automatically
    [length * cos(θ), length * sin(θ)]
end
function vec2θ(v)
    return mag2(v), uconvert(°, atan(v[2], v[1])u"rad")
end
mag2(p) = norm(p) # sqrt(abs2(p[1]) + abs2(p[2]))
function cross2(v1, v2)
    # test: `cross2([1m,0m], [1kg*m/s,1kg*m/s])`
    if length(v1) == 2
        v1 = [v1[1], v1[2], v1[1] * 0]
    end
    if length(v2) == 2
        v2 = [v2[1], v2[2], v2[1] * 0]
    end
    cross(v1, v2)
end
## e1.1
he_m = (6.6465 * 10.0^-27)kg
he_v = 1.518e6u"m/s"
he_V = vecθ(he_v, 0)
ni_m = 2.3253e-26kg
ni_V = vecθ(0.0u"m/s", 0)
he_v2 = 1.199e6u"m/s"
he_a = 78.75°
he_V2 = vecθ(he_v2, he_a)
# -
ni_V2 = (lmom(he_m, he_V) - (lmom(he_m, he_V2))) / ni_m
##
cm_V2 = (he_V2 * he_m + ni_V2 * ni_m) / (he_m + ni_m)
he_cm_V2 = he_V2 - cm_V2
@labeled vec2θ(he_cm_V2)
@labeled ni_cm_V2 = ni_V2 - cm_V2
@labeled vec2θ(ni_cm_V2)
##
@labeled ni_V2
@labeled vec2θ(ni_V2)
@labeled k1 = ke(he_m, he_V)
@labeled k2 = ke(he_m, he_V2) + ke(ni_m, ni_V2)
@labeled k2 - k1
## e1.2
ur_m = 3.9529e-25kg
tho_m = 3.8864e-25kg
he_V = vecθ(1.423e7m / s, 0)
ni_V = -he_V * he_m / tho_m
@labeled vec2θ(ni_V)
@labeled ke(ni_m, ni_V) + ke(he_m, he_V)
##