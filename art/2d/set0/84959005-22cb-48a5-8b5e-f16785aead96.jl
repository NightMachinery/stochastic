drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:106 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 6, transform = (x->begin
                                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:106 =#
                                x
                            end))
            end), point_size = 0.7mm, n = 10 * 10 ^ 2, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:111 =#
            cs = ColorSchemes.jet
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:113 =#
            cutoff = 0.4
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:114 =#
            if x >= cutoff
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:115 =#
                return RGB(1, 1, 1)
            end
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:117 =#
            return get(cs, 1 - x / cutoff)
        end, alphas = [0.6])