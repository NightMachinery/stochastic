include("./physics.jl")
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
## 22.04
v0 = 18m / s
f = (1.5 * 1.4e-7)N
m0 = 1.3e-10kg
a = f / m0
l = 1.6cm
t = l / v0
vy2 = t * a
y2 = (vy2 / 2) * t
##
P = 6.2e-30u"C*m"
q = (10 * ElementaryCharge)
d = P / q
E = 1.5e4u"N/C"
mt = q * E * d 
##
a = 5.8cm
z = a / 2
q = 3.4u"nC"
res = uconvert(ElectricFieldU, (4 * ElectricConstant * q * z) / (z^2 + (a^2) / 2)^(3 / 2))
@labeled res |> up
@labeled (4*q)/(π*VacuumElectricPermittivity*(3^(3/2)*a^2)) |> up
@labeled (4*3.4e-9)/(3.14*8.854188e-12*(3^(3/2)*(5.8e-2)^2))
##
σ = 5.2u"nC/m^2"
a = 2.3cm
b = 11.1cm
z = 4.8cm
#
σ = 1.3u"nC/m^2"
a = 3.1cm
b = 8.2cm
z = 2.0cm
#
t1(r) = -2 * (z^2 + r^2)^(-1 / 2)
res = σ * z / (4 * VacuumElectricPermittivity) * (t1(b) - t1(a))
@labeled res
@labeled res |> up
## P4T1
ΔλCompton(θ::MyDegree ; mass=ElectronMass) = (PlanckConstant/(mass*SpeedOfLightInVacuum))*(1 - cos(θ))
# EFromλ(λ::Length) = PlanckConstant*SpeedOfLightInVacuum/λ
function Efpλ(; E=nothing, λ=nothing, f=nothing, p=nothing)
	changed = false
	if λ == nothing
		if f != nothing
			λ = SpeedOfLightInVacuum/f
			changed = true
		elseif E != nothing
			λ = PlanckConstant*SpeedOfLightInVacuum/E
			changed = true
		end
	end
	if f == nothing
		if λ != nothing
			f = SpeedOfLightInVacuum/λ
			changed = true
		elseif E != nothing
			f = E/PlanckConstant
			changed = true
		end
	end
	if E == nothing
		if f != nothing
			E = PlanckConstant*f
			changed = true
		elseif p != nothing
			E = p*SpeedOfLightInVacuum
			changed = true
		end
	end
	if p == nothing
		if E != nothing
			p = E/SpeedOfLightInVacuum
			changed = true
		end
	end
	if changed
		return Efpλ(; E, λ, f, p)
	else
		return (; E, λ, f, p)
	end
end
## q5
E1 = 100u"MeV"
λ1 = PlanckConstant*SpeedOfLightInVacuum/E1 |> upreferred
λ2 = λ1 + ΔλCompton(pi ; mass=ProtonMass)
@labeled Efpλ(;λ=λ2).E - E1
# E2 = 1.320666e-11 J
# E2 - E1 = -2.815103e-12 J
## q1:p4
θ1 = 15.15°
λ1 = 0.149e-9u"m"
d = λ1 /(sin(θ1)*2)
λ2 = 2*d*sin(θ1 + 0.015°)
@labeled λ2 - λ1
##
Lc = 30e-9u"m"
phi  = PlanckConstant*SpeedOfLightInVacuum/Lc
Km = PlanckConstant*SpeedOfLightInVacuum/(20e-9u"m") - phi
Vs = Km/ElementaryCharge
## sp23.06
Ec = 2.4u"MN/C"
2*pi*0.1m*VacuumElectricPermittivity*1.8m*Ec |> up
## sp23.07
dP = 6.8u"μC/m^2"
dM = 4.3e-6u"C/m^2"
(dP-dM)/2VacuumElectricPermittivity |> up
(dP+dM)/2VacuumElectricPermittivity |> up
##
a = 2.3cm
b = 6.1cm
sphereVolume(r::Length) = (4/3)*π*r^3
v = sphereVolume(b) - sphereVolume(a)
ρ = 3.7u"nC/m^3"
q1 = ρ*v |> up
e1 = ElectricConstant*q1/b^2 |> ElectricFieldU
r = 6.5cm
@labeled λ = e1*2*π*r*VacuumElectricPermittivity |> up
@labeled σ_s = VacuumElectricPermittivity*e1*2/r |> up
@assert (up(σ_s*π*r^2) - up(λ)).val <= 1e-20
## C5 E5.2
En(m, L, n) = ((PlanckConstant^2)/(8*m*L^2))*(n^2)
@labeled En(ElectronMass, 1e-10u"m", 1) & u"eV"
@labeled En(ElectronMass, 1e-10u"m", 1) & u"eV"
@labeled En(ElectronMass, 1e-10u"m", 2) & u"eV"
@labeled En(ElectronMass, 1e-10u"m", 3) & u"eV"
## C26 SP2
R = 2u"mm"
id = 2e5u"A/m^2"
@labeled π*(R^2-(R^2)/4)*id & A
a1 = 3e11u"A/m^4"
@labeled 2*π*a1*(R^4/4-(R/2)^4/4) & A
##
@labeled Pc = (1//4)*(1//10)*(7//10) + (1//2)*(1//10)*(3//10) + (6//10)*(9//10)*(7//10) + (2//10)*(9//10)*(3//10)
@labeled Pcm = 1 - Pc

@labeled ((3//4)//Pc)*(1//10)*(1//2)

@labeled ((1//4)//Pcm)*(1//10)*(8//10)

@labeled (0.08+0.037)/(0.08+0.037*2)
##
a = PlanckConstant/(2*π*(13.6u"eV")*(10^-9)u"s") & ""
my_n(n) = 1/(n-1)^2 - 1/n^2
##
a = 262.8
b = 1.25
a = 237.36
@labeled a/b + a/b^2 + a/b^3
##
a = 0
for i in 0:5
	a += 8/(1.07)^i
end
a