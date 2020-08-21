using DifferentialEquations
f(u,p,t) = p * u
prob = ODEProblem(f, 10, (0, 20), 3)
sol = solve(prob)
##
function lorenz!(du, u, p, t)
    σ, ρ, β = p
    du[1] = σ * (u[2] - u[1])
    du[2] = u[1] * (ρ - u[3]) - u[2]
    du[3] = u[1]u[2] - β * u[3]
end
l1 = [1.0, 0.0, 0.0]
l2 = [1.1, 0.1, 0.0]
l3 = [1.5, 0.0, 0.1]
p = (10, 50, 8 / 3)
prob_lo = ODEProblem(lorenz!, l1, (-20.0, 40.0), p) # 10,28,8/3
sol_lo = solve(prob_lo)
# sol_lo2 = (solve(ODEProblem(lorenz!, l2, (-20.0, 40.0), (10, 50, 8 / 3))))
sol_lo2 = (solve(ODEProblem(lorenz!, l2, (-20.0, 40.0), p)))
# sol_lo3 = (solve(ODEProblem(lorenz!, l0, (-20.0, 40.0), (37, 50, 8 / 3))))
# sol_lo3 = (solve(ODEProblem(lorenz!, l3, (-20.0, 40.0), (30, 50, 5))))
sol_lo3 = (solve(ODEProblem(lorenz!, l3, (-20.0, 40.0), p)))
##
using Plots
##
using MeshCat
vis = Visualizer()
using GeometryTypes
using CoordinateTransformations
using ColorTypes
using ColorSchemes
using Exfiltrator
##
function u(; ts=-20:0.01:40, size=0.3)
    verts = [Point3f0(sol_lo(t)...) for t in ts]
    colors = [RGB{Float32}(get(ColorSchemes.Blues_9, i / length(verts))) for i in 1:length(verts)]
    verts2 = [Point3f0(sol_lo2(t)...) for t in ts]
    colors2 = [RGB{Float32}(get(ColorSchemes.Greens_9, i / length(verts2))) for i in 1:length(verts2)]
    verts3 = [Point3f0(sol_lo3(t)...) for t in ts]
    colors3 = [RGB{Float32}(get(ColorSchemes.Purples_9, i / length(verts3))) for i in 1:length(verts3)]
# setobject!(vis, PointCloud(verts, colors))
    material = PointsMaterial(size=size) # color=RGBA(0, 0, 1, 1.0),
    setobject!(vis, PointCloud(vcat(verts, verts2, verts3), vcat(colors, colors2, colors3)), material)
    # setobject!(vis, PointCloud(vcat(verts2), vcat(colors2)), material)
    @exfiltrate
    return nothing
end