function GLHeavy(n, λ)
    res = 0
    for i in 1:n
        res += log(rand())
    end
    return -(res / λ)
end
function GMHeavy(n, λ)
    res = 1
    for i in 1:n
        res *= rand()
    end
    return -(log(res) / λ)
end

N = 152
λ = 7
#########

ec("Log Heavy:")
display(@benchmark GLHeavy(N, λ))
ec("* Heavy:")
display(@benchmark GMHeavy(N, λ))

######
using Colors, Gadfly, ColorSchemes, Distributions, Compose

function layerpdf(s ; color = RGBA(0, 1, 0, 0.7), line_width = 0.5mm)
    return layer(
        x = s,
        Geom.histogram(density = true),
        style(line_width = line_width, default_color = color),
    )
end
function layercdf(s ; color = RGBA(0, 1, 0, 0.7), line_width = 0.5mm)
    n = length(s)
    return layer(x = sort(s),
    y = (1:n) ./ n,
    Geom.line,
    style(line_width = line_width, default_color = color),
    )
end
function plotSamples(ss ; p_d = [], p_c = [])
    n = length(ss) + 1 # no white color
    Ds = [layerpdf(s, color = RGBA(get(ColorSchemes.gnuplot2, i / n), 0.7)) for (i, s) in enumerate(ss)]
    Cs = [layercdf(s, color = RGBA(get(ColorSchemes.gnuplot2, i / n), 0.7)) for (i, s) in enumerate(ss)]
    p_d = plot(Ds..., p_d...)
    p_c = plot(Cs..., p_c...)
    return p_d, p_c
end

function drawSamples(E, V, λs = [1] ; n = 10^4, N)
    function getPlots(F ; p_d = [], p_c = []) 
        shared = [
            # Coord.cartesian(xmin = 0, xmax = 200),
            Guide.xlabel(""),
            Guide.ylabel(""),
        ]
        return plotSamples([[F(λ) for i in 1:n] for λ in λs] ;
            p_d = [
                shared...,
                p_d...
            ],
            p_c = [
                shared...,
                p_c...
            ])
    end
    E_d, E_c = getPlots(E, 
        p_d = [
            Guide.title("Our PDF"),
        ],
        p_c = [
            Guide.title("Our CDF"),
        ]
    )
    V_d, V_c = getPlots(V,
    p_d = [
        Guide.title("Distributions.jl's PDF")
    ],
        p_c = [
            Guide.title("Distributions.jl's CDF"),
        ]
    )

    title1 = compose(context(0, 0, 1w, 0.4h), font("Space Grotesk"), fontsize(24pt), text(0.5, 1.0, "The Gamma Distribution (shape = $N, ⇡λ ⟺ warmer color)", hcenter, vbottom))
    title2 = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, "λs: $λs", hcenter, vbottom))
    uptext = [title1, title2]
    return (vstack(uptext..., hstack(E_d, E_c), hstack(V_d, V_c)))
end

set_default_plot_size(26cm, 20cm)
function drawGamma(N = 5)
    plt = drawSamples((λ)->GMHeavy(N, λ), (λ)->rand(Gamma(N, 1 / λ)), [1:2:15;], N = N)
    display(plt)
    plt  |> SVGJS("./plots/gamma shape=$N.svg", 26cm, 20cm)
end
drawGamma()
drawGamma(152)
drawGamma(3)