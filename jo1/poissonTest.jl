include("./poisson.jl")
using Statistics, DataFrames, Gadfly, Colors, ColorSchemes

# for (i,v) in enumerate(p)
#         println("$i:   $v")
# end
const n = 200
const lans = [5:5:155;]
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
mid = DataFrame(
        # lambda = 200,
        i = lans,
        cdf = [cdf(Poisson(lan), lan) for lan in lans],
)
begin
        set_default_plot_size(30cm, 15cm)
        l1 = layer(vcat(a...), x = :i, y = :cdf, color = :lambda, Geom.line) # , Coord.cartesian(ymin=0, ymax=1)
        l2 = layer(vcat(ver...), x = :i, y = :cdf, color = :lambda, Geom.point)
        l3 = layer(
                mid,
                x = :i,
                y = :cdf,
                Geom.point,
                style(default_color = RGBA(1.0, 105 / 255, 180 / 255, 0.2)),
        )
        # alpha ignored here

        # l2 = layer(y=[x -> cdf(Poisson(lan), x) for lan in lans], xmin=[0], xmax=[n - 1], Stat.func(num_samples=50), Geom.point)

        p = plot(
                l3,
                l1,
                l2,
                Coord.cartesian(ymin = 0, ymax = 1),
                Theme(
                        key_label_font_size = 14pt,
                        major_label_font_size = 20pt,
                        minor_label_font_size = 15pt,
                        # alphas = [1],
                ),
                # Scale.color_continuous(colormap=c->ColorSchemes.dense.colors[trunc(Int,(1-c)*255)+1])
                Scale.color_continuous(
                        colormap = c -> get(ColorSchemes.gnuplot2, c),
                ),
                # Scale.color_continuous(colormap=Scale.lab_gradient(ColorSchemes.jet.colors))
        )
        # p = hstack(plot(l1),plot(l2))
        display(p)
end

# p |> PNG("p1.png", 60cm, 30cm, dpi=150)

#fit(Distributions.Poisson, 0:n-1, poisson(10)[1])

# println(sum(p))
