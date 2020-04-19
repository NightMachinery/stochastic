using Base.MathConstants


function poisson(lan = 15, n = 200)
        p = Float64[e^-lan]
        pc = Float64[p[end]]
        sizehint!(p, n + 10)
        sizehint!(pc, n + 10)
        for i = 1:n-1
                push!(p, (lan / i) * p[end])
                push!(pc, pc[end] + p[end])
        end
        return p, pc
end
