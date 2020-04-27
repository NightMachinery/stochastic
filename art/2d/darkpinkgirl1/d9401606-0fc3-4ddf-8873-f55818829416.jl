drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:105 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 1, transform = (x->begin
                                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:105 =#
                                log1p(x)
                            end))
            end), point_size = 1mm, n = 10 * 10 ^ 2, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:110 =#
            cs = ColorSchemes.deepsea
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:115 =#
            get(cs, log1p(x) * 3 + 0.25)
        end, alphas = [1.0])