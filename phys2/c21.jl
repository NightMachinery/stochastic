## Useful functions
# rad2deg
##
using PhysicalConstants.CODATA2018
# -
using Unitful
using ForceImport
@force using Unitful.DefaultSymbols
# https://painterqubits.github.io/Unitful.jl/stable/highlights/
# 8m == 800cm
# -
##
ϵ0 = 8.85 * 10 * -12
e_k = 8.99 * 10^9
FE(q1, q2, r)::Number = e_k * (abs(q1) * abs(q2) / abs2(r))
q_e = 1.6 * 10^-19
#
g_k = 6.67 * 10^-11
FG(m1, m2, r) = g_k * (m1 * m2 / abs2(r))
m_e = 1.67 * 10^-27
#
mag2(p) = sqrt(abs2(p[1]) + abs2(p[2]))
function FV(forceFn, p1, p2)
	r = mag2(p2 - p1)
	m1 = p1[3]
	m2 = p2[3]
	force = forceFn(m1, m2, r)
	angle = atan(p2[2] - p1[2], p2[1] - p1[1]) # so this force is from p1 towards p2
	# angle = atan(p1[2] - p2[2], p1[1] - p2[1]) # so this force is from p2 towards p1
	@labeled (angle |> rad2deg) 
	@labeled force * cos(angle)
	@labeled force * sin(angle)
	return [force * cos(angle), force * sin(angle)] * sign(m1) * sign(m2)
end
function fnMul(f, v)
	function f2(args... ; kargs...)
		return v * f(args... ; kargs...)
	end
	return f2
end
FVE(args...) = FV(fnMul(FE, -1), args...)
## 
# c21.p11:
a = 0.05
q1 = [0, a, 100 * 10^-9]
q2 = [a, a, -100 * 10^-9]
q3 = [0, 0, 200 * 10^-9]
q4 = [a, 0, -200 * 10^-9]
f31 = FVE(q3, q1)
f32 = FVE(q3, q2)
f34 = FVE(q3, q4)
f3net = f31 + f32 + f34
##
r_core = 4 * 10^-15
fee = FE(q_e, q_e, r_core) 
fee_g = FG(m_e, m_e, r_core)
## P4_C1
Mass = typeof(1.0u"kg")
Speed = typeof(1.0u"m/s")
MyDegree = typeof(1.0°)

LinearMomentumScalar(mass::Mass, speed::Speed) = mass * speed
lms = LinearMomentumScalar
LinearMomentumVector(mass::Mass, speed::Vector{Speed}) = mass * speed
lmv = LinearMomentumVector
function vecθ(length, θ)
	# No general degree dimension, so leave it untyped to dispatch automatically
	[length * cos(θ), length * sin(θ)]
end
function vec2θ(v)
	return mag2(v), uconvert(°, atan(v[2], v[1])u"rad")
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
#-
ni_V2 = (lmv(he_m,he_V) - (lmv(he_m,he_V2)))/ni_m
@labeled ni_V2
@labeled vec2θ(ni_V2)
##