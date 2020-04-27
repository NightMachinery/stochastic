drawP2D(G = (λ->begin
                #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:104 =#
                imgrate(precision = 10 ^ 0, width = 20, pslope = 0.7)
            end), n = 1 * 10 ^ 2, colorscheme = function (x,)
            #= /Users/evar/Base/_Code/uni/stochastic/jo3/pprocessTest.jl:107 =#
            get(ColorSchemes.gnuplot2, 1 - x)
        end, alpha = 0.7)