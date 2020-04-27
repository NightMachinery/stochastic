drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:105 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 1, transform = (x->begin
                                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:105 =#
                                log1p(x)
                            end))
            end), point_size = 0.8mm, n = 2 * 10 ^ 2, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:110 =#
            cs = ColorSchemes.gnuplot2
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:112 =#
            get(cs, x)
        end, alphas = [0.8, 0.2])