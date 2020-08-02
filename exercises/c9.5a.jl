function NPolar(u1, u2)
    # u1 = rand()
    # u2 = rand()
    r = sqrt(-2 * log(u1))
    θ = 2 * pi * u2
    x = r * cos(θ)
    y = r * sin(θ)
    return x, y
end

function antithetic_z()
    u1 = rand()
    u2 = rand()
    u1b = 1 - u1
    u2b = 1 - u2
    return [NPolar(u1, u2)..., NPolar(u1b, u2b)...]
end

function Zorg(z)
    z^3 * ℯ^z
end

##
data_normals_anti = [z for i in 1:10^7 for z in antithetic_z()]
data_anti = [Zorg(z) for z in data_normals_anti]
println("anti: mean=$(mean(data_anti)), var=$(std(data_anti; corrected=true)^2)")

data_normals = [z for i in 1:(10^7 * 4) for z in rand(Normal())]
data = [Zorg(z) for z in data_normals]
println("Normal: mean=$(mean(data)), var=$(std(data; corrected=true)^2)")

data_normals_anti2 = [z * sign for i in 1:(10^7 * 2) for z in rand(Normal()) for sign in (1, -1)]
data_anti2 = [Zorg(z) for z in data_normals_anti2]
println("anti2: mean=$(mean(data_anti2)), var=$(std(data_anti2; corrected=true)^2)")

# anti: mean=6.580210629998028, var=3521.696920529584
# Normal: mean=6.598402309096034, var=3619.21725736029
# anti2: mean=6.594510883285163, var=3586.564039420383