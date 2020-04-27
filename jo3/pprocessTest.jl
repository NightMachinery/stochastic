include("./pprocess.jl")
include("../common/plotSamples2.jl")
using DataFrames
###
@doc """
λs should be a singleton [λ] for now.
"""->function drawP2D(; λs = [1], G = P2D, n = 10^2, colorscheme = ColorSchemes.gnuplot2, alpha = 0.1, kwargs...)
    data = [
    let xy = G(λ)
        DataFrame(λ = λ,
            n = i,
            xs = xy[:,1],
            ys = xy[:,2]
        )
    end
        for i ∈ 1:n, λ ∈ λs
    ]
    data = vcat(data...)
    # sa(data)
    levels = function (z)
        minz = minimum(z)
        maxz = maximum(z)
        stepz = min(0.1, ((maxz - minz) / 6))
        println("stepz: $stepz, minz: $minz, maxz: $maxz")
        # maxz * 0.5 ...
        return [0.6.^collect(1:1:8); 10^-3]
        return minz:stepz:maxz
    end
    # levels = [0:0.02:0.2; 0.3:0.2:2;]
    plt = plot(data, x = :xs, y = :ys,
        # Scale.color_continuous(colormap = x->colorant"red"),
        Scale.color_sqrt(colormap = x->get(colorscheme, x)),
        style(default_color = RGB(0, 0, 1),
            alphas = [alpha],
            highlight_width = 0cm,
            line_width = 0.7mm,
            grid_color = RGBA(0, 1, 0, 0),
        ),
        # Geom.density2d(levels = levels),
        color = :n,
        Geom.point(),
        Coord.cartesian(fixed = true,
        # xmin = 9.5, xmax = 10.5,
        # ymin = 19.5, ymax = 20.5,
        # xmin = 0, xmax = 20,
        # ymin = 10, ymax = 30,
        ),
        )
    println("Done!")
    return plt
end
###
# drawP2D()
function pcircle(λ)
    center = (10, 20)
    r = 2
    xmin = center[1] - r
    xmax = center[1] + r
    ymin = center[2] - r
    ymax = center[2] + r
    function circlerate(x, y)
        dis = sqrt((x - center[1])^2 + (y - center[2])^2)
        if dis > r
            return 0
        else
            d = r - dis
            areafactor = r / (r - d + 0.01)
            # areafactor = 1
            return d * areafactor / 100
        end
    end
    nhP2D(10^2, circlerate ; xmin = xmin,xmax = xmax,ymin = ymin,ymax = ymax)  
end
# plt = drawP2D(G = pcircle, n = 8 * (10^2), colorscheme = ColorSchemes.prism, alpha = 0.6)
# plt |> SVG("./tmp/circle.svg", 20cm, 20cm)
@plot drawP2D(G = pcircle, n = 7 * (10^2), colorscheme = ColorSchemes.linear_ternary_blue_0_44_c57_n256, alpha = 0.6) png "hmm "
###
function drawP(λs = [1,2])
    plt = drawSamples((λ)->P(λ), (λ)->rand(Distributions.Poisson(λ)), λs, title1 = "Poisson (simulated via memoized tables)", title2 = "Distributions.jl's")
    display(plt)
    # plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end

function drawPP(λs = [1] ; n = 10, from = -10, to = 10, G = PP, V = PPExp, alpha_d = 0.8, alpha_c = 0.8, colorscheme = ColorSchemes.gnuplot2)
    p_shared::Array{Any,1} = [style(grid_color = RGBA(0, 1, 0, 0))]
    append!(p_shared, [Guide.xlabel(""), Coord.Cartesian(xmin = from, xmax = to)])
    # append!(p_shared, [Guide.xlabel(""), Coord.Cartesian(xmin = 0, xmax = 100, ymin = 0, ymax = 100)])
    p_d = [Guide.ylabel("Occurences")]
    p_c = [Guide.ylabel("Occurences (cumulative)")]
    plt = drawSamples((λ)->G(λs[1], from, to), (λ)->V(λs[2], from, to), [1:n;], n = 1, title1 = "Poisson Processes (λ=$(λs[1]); Colors show different runs; Total runs $n)", title2 = "Poisson Processes (λ=$(λs[2]); Colors show different runs; Total runs $n)", density = false, alpha_d = alpha_d, alpha_c = alpha_c, p_shared = p_shared, p_d = p_d, p_c = p_c, colorscheme = colorscheme)
    display(plt)
    # plt  |> PNG("./plots/play/$(uuid4().value).png", 26cm, 20cm, dpi = 150)
    println("Done!")
end
###
drawP([1:3:100;])
###
drawPP([0.5,10], n = 20)
drawPP([5,5], n = 20)
drawPP([0.1,0.5], n = 70, from = 0, to = 100, alpha_d = 0.8, alpha_c = 0.7, colorscheme = ColorSchemes.devon)
drawPP([0.08,0.15], n = 320, from = 0, to = 100, alpha_d = 0.8, alpha_c = 0.9, colorscheme = ColorSchemes.sun,
G = function (λ, from, to)
    res = PP(λ, from, to) 
    return res .+ rand(Normal(0, 500))
end,
V = function (λ, from, to)
    res = PP(λ, from, to) 
    return map(x->x + rand(Normal(0, 300)), res)
end)
###
function layerpdf(s ; color = RGBA(0, 1, 0, 0.7), line_width = 0.5mm, density = true, style_more...)
    return layer(
        x = s,
        Geom.line(),
        Stat.histogram(bincount = 10),
        style( ; line_width = line_width, default_color = color, style_more...),
    )
end

# colorscheme = ColorSchemes.seismic
colorscheme = ColorSchemes.seismic

# set_default_plot_size(25cm,25cm)
drawPP(["undef", "undef"], n = 100, from = 0, to = 100, alpha_d = 0.5, alpha_c = 0.9,
# colorscheme = ColorSchemes.gist_rainbow,
colorscheme = function (i, n, alpha)
    # RGBA(get(colorscheme, 1 - (i / n)), alpha)
    RGBA(get(colorscheme, (i / n)), alpha)
    # RGBA(get(colorscheme, rand()), alpha)
end,
G = function (λ, from, to)
    # sqrt(to^2-x^2)
    nhPP(10^2, (x)->sqrt(to^2 - x^2) / 8, from, to)
end,
V = function (λ, from, to)
    0
    # nhPP(10^4, (x)->abs(tan(x)) * 10, from, to)
end)
###
n = 10^4
@benchmark P(20) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  16 bytes
#   allocs estimate:  1
#   --------------
#   minimum time:     93.477 ns (0.00% GC)
#   median time:      175.804 ns (0.00% GC)
#   mean time:        190.944 ns (0.24% GC)
#   maximum time:     5.799 μs (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     950
PRng = Poisson(20)
@benchmark rand(PRng) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  0 bytes
#   allocs estimate:  0
#   --------------
#   minimum time:     325.426 ns (0.00% GC)
#   median time:      476.695 ns (0.00% GC)
#   mean time:        516.843 ns (0.00% GC)
#   maximum time:     17.325 μs (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     223
@benchmark PP(20) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  3.19 KiB
#   allocs estimate:  5
#   --------------
#   minimum time:     3.724 μs (0.00% GC)
#   median time:      4.195 μs (0.00% GC)
#   mean time:        5.371 μs (15.13% GC)
#   maximum time:     1.864 ms (99.29% GC)
#   --------------
#   samples:          10000
#   evals/sample:     7
@benchmark PPExp(20) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  6.39 KiB
#   allocs estimate:  2
#   --------------
#   minimum time:     7.052 μs (0.00% GC)
#   median time:      8.090 μs (0.00% GC)
#   mean time:        9.499 μs (7.66% GC)
#   maximum time:     2.716 ms (99.32% GC)
#   --------------
#   samples:          10000
#   evals/sample:     4
@benchmark PPExp(10^2, 0, 10) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  15.77 KiB
#   allocs estimate:  2
#   --------------
#   minimum time:     14.924 μs (0.00% GC)
#   median time:      19.573 μs (0.00% GC)
#   mean time:        27.218 μs (0.00% GC)
#   maximum time:     676.980 μs (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     1
@benchmark nhPP(10^2, (x)->sqrt(10^2 - x^2) / 8, 0, 10) samples = n seconds = Inf
# BenchmarkTools.Trial: 
#   memory estimate:  22.77 KiB
#   allocs estimate:  3
#   --------------
#   minimum time:     28.080 μs (0.00% GC)
#   median time:      33.708 μs (0.00% GC)
#   mean time:        42.494 μs (3.28% GC)
#   maximum time:     7.241 ms (99.03% GC)
#   --------------
#   samples:          10000
#   evals/sample:     1