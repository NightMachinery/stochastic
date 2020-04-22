function E(λ)
    -(log(rand()) / λ)
end

#############

using Gadfly, Colors, ColorSchemes, Distributions, StatsBase

function testE(λ = 30, n = 10^6)
    @time g1 = [E(λ) for i = 1:n]

    v1 = [rand(Exponential(1 / λ)) for i = 1:n]

    # @infiltrate

    lc = 1 + log(0.5 / λ) # 1 / (1 + λ)
    alpha = 0.7

    cdf = ecdf(g1)
    # @infiltrate
    xs = 0:10^-4:7
    lCdf = [layer(y = [cdf(i) for i in xs], x = xs, Geom.line, style(default_color = RGBA(lc, 0, 1, 1)))]

    lPdf = [ 
    layer(
        x = g1,
        Geom.density(),
        style(
            # line_width = 0.5mm,
            default_color = RGBA(lc, 0, 1, alpha),
        ),
    ),
    # layer(
    #     x = v1,
    #     Geom.density(),
    #     style(line_width = 1mm, default_color = RGBA(lc, 1, 0, 0.3)),
    # ),
    ]
    return lCdf, lPdf
end

function testEs()
    set_default_plot_size(26cm, 17cm)
    lsPdf = []
    lsCdf = []
    for λ in 0.5:0.5:2
        lCdf, lPdf = testE(λ)
        push!(lsPdf, lPdf...)
        push!(lsCdf, lCdf...)
    end
    pPdf = plot(lsPdf...,  Coord.cartesian(xmin = 0.3, xmax = 6))
    pCdf = plot(lsCdf...)
    display(hstack(pPdf, pCdf))
end
testEs()