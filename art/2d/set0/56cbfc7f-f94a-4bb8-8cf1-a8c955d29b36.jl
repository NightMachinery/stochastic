drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:106 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 6, transform = (x->begin
                                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:106 =#
                                x
                            end))
            end), point_size = 0.7mm, n = 10 * 10 ^ 2, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:111 =#
            cs = ColorSchemes.gnuplot2
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:118 =#
            return get(cs, x ^ 6 * 100 + 0.13)
        end, alphas = [0.6])