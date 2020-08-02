include("../common/plotSamples2.jl")
using Distributions, StatsBase

f_g(x) = 30(x - 2x^2 + x^3)
function Q22_pdf(x)
    # g(x) = x
    # f(x)/g(x) = 30(x - 2x^2 + x^3)
    # 30(1 -4x +3x^2) = 0 => x=1,1//3
    # max f/g = 40//9
    if 0 <= x <= 1
        return 30(x^2 - 2x^3 + x^4)
    else
        return 0
    end
end

function Q22()
    while true
        res = √(2rand())
        if (rand() <= (Q22_pdf(res) / (res * (4.45))))
            return res
        end
    end
end
##
let xs = 0:0.05:1
    display(plot(x=xs, y=[Q22_pdf(x) for x in xs], Geom.line()))
end
drawSamples((x) -> Q22(), (x) -> 0 ; n=10^5)
