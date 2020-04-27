drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:105 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 1, transform = (x->begin
                                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:105 =#
                                log1p(x)
                            end))
            end), point_size = 1mm, n = 9 * 10 ^ 1, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:112 =#
            get(ColorSchemes.gnuplot2, rand())
        end, alpha = 0.7)