using Gadfly, Colors, StatsBase

function testE(λ = 30 ; n = 10^6, bandwidth = nothing)
    @time g1 = [E(λ) for i = 1:n]

    # @infiltrate

    lc = 1 + log(0.5 / λ) # 1 / (1 + λ)
    alpha = 0.7
    cdf = ecdf(g1)
    # @infiltrate
    xs = 0:10^-3:7
    lCdf = [layer(y = [cdf(i) for i in xs], x = xs, Geom.line, style(default_color = RGBA(lc, 0, 1, 1)))]

    lPdf = [ 
    layer(
        x = g1,
        Geom.density(bandwidth = bandwidth),
        style(
            # line_width = 0.5mm,
            default_color = RGBA(lc, 0, 1, alpha),
        ),
    )]

    if V !== nothing
        v1 = [rand(V(λ)) for i = 1:n]
        push!(lPdf,
        layer(
            x = v1,
            Geom.density(bandwidth = bandwidth),
            style(line_width = 1mm, default_color = RGBA(lc, 1, 0, 0.3)),
        )
        )
    end
    return lCdf, lPdf
end

function testEs( ; bandwidth = 0.001)
    set_default_plot_size(26cm, 17cm)
    lsPdf = []
    lsCdf = []
    for λ in 0.5:0.5:2
        lCdf, lPdf = testE(λ, bandwidth = bandwidth)
        push!(lsPdf, lPdf...)
        push!(lsCdf, lCdf...)
    end
    pPdf = plot(lsPdf..., 
    #  Coord.cartesian(xmin = 0, xmax = 10)
     )
    pCdf = plot(lsCdf...)
    display(hstack(pPdf, pCdf))
end