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

function drawSamples(E, V, λs = [1] ; n = 10^4)
    function getPlots(F ; p_d = [], p_c = []) 
        shared = [
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
    )
    V_d, V_c = getPlots(V,
    )

    ours = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, "Ours", hcenter, vbottom))
    theirs = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, "Theirs", hcenter, vbottom))
    return (vstack(ours, hstack(E_d, E_c), theirs, hstack(V_d, V_c)))
end

set_default_plot_size(26cm, 20cm)