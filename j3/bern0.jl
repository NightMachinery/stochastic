using Statistics, Plots, StatsPlots

@time a = map(_ -> [x for x in 1:10^4 if rand() < 0.001], 1:10^5)
al = [length(x) for x in a]
am = mean(al)

println("mean $am max $(maximum(al)) std $(std(al, mean=am))")
histogram(al, normalize = :probability)
