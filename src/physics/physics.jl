## Useful functions
# rad2deg
##
# module Physics

(@isdefined SunHasSet) || begin include("../common/startup.jl") ; println("Using backup startup.jl.") end

using LinearAlgebra
using PhysicalConstants.CODATA2018
using Unitful
using ForceImport

@force using Unitful.DefaultSymbols
Unitful.promote_to_derived() # promotes units toderived units like Joule
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

function shift_unit(u::U, d, n) where {U <: Unitful.Unit}
    i₀ = floor(Int, d / n)
    d = 3i₀
    iszero(d) && return u, 0
    for (i, tens) in enumerate(Unitful.tens(u) .+ (d:(-3 * sign(d)):0))
        haskey(Unitful.prefixdict, tens) && return U(tens, u.power), i - 1 + i₀
    end
    u, 0
end

power_step(::Any) = 3

function shift_unit(u::Unitful.FreeUnits, d)
    tu = typeof(u)
    us, ds, a = tu.parameters

    uu, i = shift_unit(us[1], d, power_step(1u))

    Unitful.FreeUnits{(uu, us[2:end]...),ds,a}(), i
end

logu(::Any, v) = log10(v)
divider(::Any) = 1.0

function si_round(q::Quantity; fspec="{1:+9.4f} {2:s}")
    v, u = ustrip(q), unit(q)
    if !iszero(v)
        u, i = shift_unit(u, logu(q, abs(v)))
        q = u(q / (divider(q)^i))
    end
    format(fspec, ustrip(q), unit(q))
end
ss = si_round
up = upreferred
# @eval Unitful function Base.show(io::IO, mime::MIME"text/plain", x::Quantity)
#     println(io, Main.si_round(x))
# end
# @eval Unitful function Base.show(io::IO, mime::MIME"text/plain", x::Vector{<:Quantity})
#     Base.show([Main.si_round(q) for q in x])
# end
##
# @defonce origShow = Unitful.Base.show
# @eval Unitful function Base.show(io::IO, mime::MIME"text/plain", x::Quantity)
#     Main.origShow(io, mime, upreferred(x))
# end
# @eval Unitful function Base.show(io::IO, mime::MIME"text/plain", x::Vector{<:Quantity})
#     Main.origShow(io, mime, upreferred(x))
# end
##

@eval Unitful function showval(io::IO, x::Number, brackets::Bool=true)
    brackets && print_opening_bracket(io, x)
    # show(io, Main.@sprintf "%e" x)
    print(io, Main.@sprintf "%e" x)
    brackets && print_closing_bracket(io, x)
end

@eval Unitful function showval(io::IO, mime::MIME, x::Number, brackets::Bool=true)
    brackets && print_opening_bracket(io, x)
    # show(io, mime, Main.@sprintf "%e" x)
    print(io, Main.@sprintf "%e" x)
    brackets && print_closing_bracket(io, x)
end
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
ElectricFieldU = u"kg*m/(A^1*s^3)"
ElectricField = typeof(1.0ElectricFieldU)
# @unit Ef "Ef" Ef 1ElectricFieldU true
FluxU = u"N*m^2/C"
Flux = typeof(1.0FluxU)

##
TYPE_LESS = true
TYPE_LESS = false
if TYPE_LESS
    Mass = Number
    Speed = Number
    Length = Number
    MyDegree = Number
    Momentum = Number
    Energy = Number
    Charge = Number
    Force = Number
    ElectricField = Number
    Flux = Number
end
##
Base.@kwdef mutable struct Particle 
    position::Vector{<:Length} = [0.0u"m", 0.0u"m"]
    mass::Mass = 0.0u"kg"
    charge::Charge = 0.0u"C"
    speed::Vector{<:Speed} = [0.0u"m/s", 0.0u"m/s"]
end
##
linearMomentum(mass::Mass, speed::Speed) = mass * speed
linearMomentum(mass::Mass, speed::Vector{<:Speed}) = mass * speed
lmom = linearMomentum
angularMomentum(position::Vector{<:Length}, momentum::Momentum) = cross2(position, momentum)
##
ElectricConstant = 1 / (4 * π * VacuumElectricPermittivity)
electricForce(charge1::Charge, charge2::Charge, r::Length)::Force = (ElectricConstant) * abs(charge1) * abs(charge2) / abs2(r)
electricForce(charge1::Charge, charge2::Charge, r::Vector{<:Length})::Vector{<:Force} = (ElectricConstant) * charge1 * charge2 * r / mag2(r)^3
function electricForce(p1::Particle, p2::Particle)::Vector{<:Force}
    electricForce(p1.charge, p2.charge, p1.position - p2.position)
end
function neutralParticle(position::Vector{<:Length})::Particle
    return Particle(; charge=1u"C", position)
end
function fieldGet(force, particle::Particle, position::Vector{Length})::Vector{<:Force} # @wrongunit should be newton/coulomb
    neutralParticle = neutralParticle(position)
    return force(neutralParticle, particle)
end
function netForce(force, affectedParticle::Particle, particles::Particle ...)
    nf = [0.0u"N" for i in 1:(length(affectedParticle.position))]
    for p in particles
        nf += force(affectedParticle, p)
    end
    return nf
end
## 22.3
function dipoleFieldZ(charge::Charge, d::Length, z::Length)::ElectricField
    return 2 * ElectricConstant * charge * d / z^3
end
##
kineticEnergy(m::Mass, v::Speed)::Energy = 0.5 * m * v^2
kineticEnergy(m::Mass, p::Momentum)::Energy = 0.5 * p^2 / m
kineticEnergy(m::Mass, v::Vector)::Energy = kineticEnergy(m, mag2(v))
ke = kineticEnergy
# tests:
# kineticEnergy(4.0kg,[1.0m/s,1.0m/s])
# kineticEnergy(4.0kg,[4.0kg*m/s,4.0kg*m/s])
##
function vecθ(length, θ)
    # No general degree dimension, so leave it untyped to dispatch automatically
    [length * cos(θ), length * sin(θ)]
end
function vec2θ(v)
    return mag2(v), uconvert(°, atan(v[2], v[1])u"rad")
end
mag2(p) = sqrt(sum(abs2, p)) # norm(p)
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
##
# end #module