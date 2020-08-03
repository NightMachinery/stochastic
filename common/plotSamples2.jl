using Colors, Gadfly, ColorSchemes, Distributions, Compose, UUIDs, Printf
import Cairo, Fontconfig

function layerpdf(s ; color=RGBA(0, 1, 0, 0.7), line_width=0.5mm, density=true, style_more...)
    return layer(
        x=s,
        # Geom.histogram(density = density),
        Geom.line(),
        Stat.histogram(density=density),
        style( ; line_width=line_width, default_color=color, style_more...),
    )
end
function layercdf(s ; color=RGBA(0, 1, 0, 0.7), line_width=0.5mm, density=true, style_more...)
    n = length(s)
    ys = (1:n)
    if density
        ys = ys ./ n
    end
    return layer(x=sort(s),
        y=ys,
        Geom.line,
        style( ; line_width=line_width, default_color=color, style_more...),
        )
end
function plotSamples(ss ; p_d=[], p_c=[], alpha_d=0.7, alpha_c=0.7 , colorscheme=ColorSchemes.gnuplot2, kwargs...)
    n = length(ss) + 1 # no white color
    if (colorscheme isa Function)
        getcolor = colorscheme
    else
        getcolor = function (i, n, alpha)
            RGBA(get(colorscheme, i / n), alpha)
        end
    end
    Ds = [layerpdf(s ; color=getcolor(i, n, alpha_d), kwargs...) for (i, s) in enumerate(ss)]
    Cs = [layercdf(s ; color=getcolor(i, n, alpha_c), kwargs...) for (i, s) in enumerate(ss)]
    p_d = plot(Ds..., p_d...)
    p_c = plot(Cs..., p_c...)
    return p_d, p_c
end

function drawDistribution(E ; kwargs...)
    # if we only draw E, the plot will be become too tall and ugly, so let's just run it twice.
    # drawSamples((λ) -> E(), nothing)
    drawSamples((λ) -> E(), (λ) -> E() ; kwargs...)

    ## this didn't incease the details on the scales, but pressing `c` on the interactive graph shows exact coordinates so who cares.
    # p_c=[Scale.x_continuous(minticks=6, labels=x -> @sprintf("%0.3f", x))]
end

"""
E(λ) is our generator function of the distribution.
V(λ) is the verifier generator function of the distribution.
n is the number of samples to draw from them.
λs are the lambdas with which to generate distributions.
"""
function drawSamples(E, V, λs=[1] ; n=10^4, title1="Ours", title2="Theirs",  p_d=[], p_c=[], p_shared=[Guide.xlabel(""), Guide.ylabel("")] , kwargs...)
    function getPlots(F) 
        return plotSamples([collect(Iterators.flatten([F(λ) for i in 1:n])) for λ in λs] ;
            p_d=[
                p_shared...,
                p_d...
            ],
            p_c=[
                p_shared...,
                p_c...
            ], kwargs...)
    end
    E_d, E_c = getPlots(E)
    ours = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, title1, hcenter, vbottom))
    out = [hstack(E_d, E_c)] 
    if ! (V === nothing)
       V_d, V_c = getPlots(V)
       theirs = compose(context(0, 0, 1w, 0.4h), font("Jokerman"), fontsize(14pt), text(0.5, 1.0, title2, hcenter, vbottom))
       out = [ours, out..., theirs, hstack(V_d, V_c)]
    end

    return (vstack(out...))
end
##
macro plot(cmd, format="pngplus", prefix="", path="tmp/plots", forceNames=false)
    pltcmd = :(plt = $cmd)
    # cmdstr = replace(string(cmd), '\n' => " PANDA ")
    cmdstr = string(cmd)
    format = lowercase(string(format))
    pngplus = false
    if format == "pngplus"
        format = "png"
        pngplus = true
    end
    prefix = string(prefix)
    # /Applications/Firefox.app/Contents/MacOS/firefox
    return quote
        outdir = "$(pwd())/$($path)"
        mkpath(outdir)

        name = $cmdstr
        if any(['\n', '/']) do badChar occursin(badChar, name) end
            if $forceNames
                name = replace(replace(replace(replace(name, "\n" => " "), "//" => " MOD "), "/" => " MOD "), r"#[^#]*#" => "")
                
            else
                name = string(uuid4())
            end
            open("$outdir/$name.jl", "w") do io
                print(io, $cmdstr)
            end
        end

        file = "$(outdir)/$($prefix)$(name).$($format)" # can't quote expressions inside ``.

        $(esc(pltcmd))

        if $format == "svg"
            plt |> SVG(file)
            run(`open -a Safari $(file)`)
        elseif $format == "png"
            plt |> PNG(file, dpi=300)
            run(`open -a Preview $(file)`)
            if $pngplus
                file2 = "$(outdir)/$($prefix)$($cmdstr).auto.svg"
                plt |> SVG(file2)
            end
        elseif $format == "html"
            plt |> SVGJS(file)
            run(`open -a Safari $(file)`)
        else
            throw("Unsupported format in @plot")
        end
        println("Saved plot to $file")
    end
end
##

# set_default_plot_size(20cm, 18cm)
set_default_plot_size(26cm, 18cm)