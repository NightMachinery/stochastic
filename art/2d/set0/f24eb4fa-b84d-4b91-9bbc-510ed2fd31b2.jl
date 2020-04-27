drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:106 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 6, transform = (x->begin
                                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:106 =#
                                x
                            end))
            end), point_size = 0.7mm, n = 5 * 10 ^ 2, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:111 =#
            cs = ColorSchemes.deepsea
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:119 =#
            return get(cs, x ^ 2 * 3)
        end, alphas = [0.4])