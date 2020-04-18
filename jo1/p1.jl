using Base.MathConstants
using Statistics, DataFrames, Gadfly, Distributions, Colors, ColorSchemes


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
# for (i,v) in enumerate(p)
#         println("$i:   $v")
# end
n = 200
lans = [5:5:155;]
@time a = [
        DataFrame(lambda = lan, i = [0:n-1;], cdf = poisson(lan, n)[2])
        for lan in lans
]

verx = [0:5:n-1;]
ver = [
        DataFrame(
                lambda = lan,
                i = verx,
                cdf = [cdf(Poisson(lan), i) for i in verx],
        ) for lan in lans
]
begin
        set_default_plot_size(15cm, 7cm)
        l1 = layer(vcat(a...), x = :i, y = :cdf, color = :lambda, Geom.line) # , Coord.cartesian(ymin=0, ymax=1)
        l2 = layer(vcat(ver...), x = :i, y = :cdf, color = :lambda, Geom.point)
        # l2 = layer(y=[x -> cdf(Poisson(lan), x) for lan in lans], xmin=[0], xmax=[n - 1], Stat.func(num_samples=50), Geom.point)

        p = plot(
                l1,
                l2,
                Coord.cartesian(ymin = 0, ymax = 1),
                Theme(
                        key_label_font_size = 14pt,
                        major_label_font_size = 20pt,
                        minor_label_font_size = 12pt,
                        alphas = [1],
                ),
                # Scale.color_continuous(colormap=c->ColorSchemes.dense.colors[trunc(Int,(1-c)*255)+1])
                Scale.color_continuous(colormap=c->get(ColorSchemes.jet,c))
                # Scale.color_continuous(colormap=Scale.lab_gradient(ColorSchemes.jet.colors))
        )
        # p = hstack(plot(l1),plot(l2))
        display(p)
        p |> PNG("p1.png", 60cm, 30cm)
end

#fit(Distributions.Poisson, 0:n-1, poisson(10)[1])

# println(sum(p))
