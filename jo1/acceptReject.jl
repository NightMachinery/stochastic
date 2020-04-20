begin
    q = 0.2
    c = 1.1
    p = [0.18, 0.2, 0.19, 0.22, 0.21]
    @assert sum(p) == 1

    function Y()
        return ceil(Int, rand() * 5)
    end
# Y()

    function X()
        while true
            y = Y()
            if rand() <= (p[y] / (q * c)) # if we use q*c without parens the instability breaks our results.
                return y
            end
        end
    end
# X()



    n = 10^7
    @time a = [X() for i in 1:n]

    using FreqTables
    x = prop(freqtable(a))
end
display(prop(freqtable(a)))

using SplitApplyCombine
display(map(x->length(x) / n, group(a)))

ys = [Y() for i in 1:n]
display(map(x->length(x) / n, group(ys)))


using Gadfly, Colors
set_default_plot_size(30cm, 15cm)
display(plot(x = a, Geom.histogram(density = true, position = :dodge), Scale.x_discrete, Theme(
# bar_highlight=RGB(0,0.5,1),
 bar_spacing = 3mm)
 # , Scale.discrete_color_manual("darkred", "red", "pink", "darkblue", "blue")
 ))
# import StatsPlots
# StatsPlots.histogram(a, normalize = :probability)
