include("./physics.jl")
##
using SymPy 
qn = neutralParticle([0.0m, 0.0m])
@vars d Q real=true
d = (d)u"m"
q1 = Particle(charge=Q*2C, position=vecθ(d, 150°))
q2 = Particle(charge=Q*-2C, position=vecθ(d, -30°))
q3 = Particle(charge=Q*-4C, position=vecθ(d, 30°))
nf = netForce(electricForce, qn, q1, q2, q3)
a = mag2(nf)/ElectricConstant