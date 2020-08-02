
# function stdN(u1, u2, sign1)
#     while true
#         x = -log(u1)
#         if u2 <= (MathConstants.e^(((x - 1)^2) / -2))
#             return x * sign1
#         end
#     end
# end

function NPolar_old(u1, u2)
    r = sqrt(-2 * log(u1))
    θ = 2 * pi * u2
    x = r * cos(θ)
    y = r * sin(θ)
    return x, y
end

function NPolar(u1, u2, sign1)
    # u1 = rand() # decreasing on u1
    # u2 = rand() 
    r = sqrt(-2 * log(u1))
    θ = (pi / 2) * u2 # so decreasing on u2 as well
    x = r * cos(θ) * sign1
    # y = r * sin(θ)
    return x
end

function antithetic_z()
    u1 = rand()
    u2 = rand()
    sign1 = rand((-1, 1))
    u1b = 1 - u1
    u2b = 1 - u2
    return [NPolar(u1, u2, sign1), NPolar(u1b, u2b, -sign1)]
end

function antithetic_z_old()
    u1 = rand()
    u2 = rand()
    u1b = 1 - u1
    u2b = 1 - u2
    return [NPolar_old(u1, u2)..., NPolar_old(u1b, u2b)...]
end

function Zorg(z)
    z^3 * ℯ^z
end

##
n = 6

data_normals_anti = [z for i in 1:(10^n * 2) for z in antithetic_z()]
data_anti = [Zorg(z) for z in data_normals_anti]
println("anti: mean=$(mean(data_anti)), var=$(std(data_anti; corrected=true)^2)")

data_normals_anti3 = [z for i in 1:10^n for z in antithetic_z_old()]
data_anti3 = [Zorg(z) for z in data_normals_anti3]
println("anti3: mean=$(mean(data_anti3)), var=$(std(data_anti3; corrected=true)^2)")


data_normals = [z for i in 1:(10^n * 4) for z in rand(Normal())]
data = [Zorg(z) for z in data_normals]
println("Normal: mean=$(mean(data)), var=$(std(data; corrected=true)^2)")

data_normals_anti2 = [z * sign for i in 1:(10^n * 2) for z in rand(Normal()) for sign in (1, -1)]
data_anti2 = [Zorg(z) for z in data_normals_anti2]
println("anti2: mean=$(mean(data_anti2)), var=$(std(data_anti2; corrected=true)^2)")

