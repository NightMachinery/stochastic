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
##
