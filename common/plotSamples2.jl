using Colors, Gadfly, ColorSchemes, Distributions, Compose, UUIDs
import Cairo, Fontconfig

function layerpdf(s ; color = RGBA(0, 1, 0, 0.7), line_width = 0.5mm, density = true)
    return layer(
        x = s,
        Geom.histogram(density = density),
        style(line_width = line_width, default_color = color),
    )
end
function layercdf(s ; color = RGBA(0, 1, 0, 0.7), line_width = 0.5mm, density = true)
    n = length(s)
    ys = (1:n)
    if density
        ys = ys ./ n
    end
    return layer(x = sort(s),
        y = ys,
        Geom.line,
        style(line_width = line_width, default_color = color),
        )
end
function plotSamples(ss ; p_d = [], p_c = [], alpha_d = 0.7, alpha_c = 0.7 , colorscheme = ColorSchemes.gnuplot2, kwargs...)
    n = length(ss) + 1 # no white color
    Ds = [layerpdf(s ; color = RGBA(get(colorscheme, i / n), alpha_d), kwargs...) for (i, s) in enumerate(ss)]
    Cs = [layercdf(s ; color = RGBA(get(colorscheme, i / n), alpha_c), kwargs...) for (i, s) in enumerate(ss)]
    p_d = plot(Ds..., p_d...)
    p_c = plot(Cs..., p_c...)
    return p_d, p_c
end

function drawSamples(E, V, λs = [1] ; n = 10^4, title1 = "Ours", title2 = "Theirs",  p_d = [], p_c = [], p_shared = [Guide.xlabel(""), Guide.ylabel("")] , kwargs...)
    function getPlots(F) 
        return plotSamples([collect(Iterators.flatten([F(λ) for i in 1:n])) for λ in λs] ;
            p_d = [
                p_shared...,
                p_d...
            ],
            p_c = [
                p_shared...,
                p_c...
            ], kwargs...)
    end
    E_d, E_c = getPlots(E)
    V_d, V_c = getPlots(V)

    ours = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, title1, hcenter, vbottom))
    theirs = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, title2, hcenter, vbottom))
    return (vstack(ours, hstack(E_d, E_c), theirs, hstack(V_d, V_c)))
end

set_default_plot_size(26cm, 20cm)