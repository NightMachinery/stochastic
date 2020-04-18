using Gadfly, RDatasets, Distributions
iris = dataset("datasets", "iris")
p = plot(iris, x = :SepalLength, y = :SepalWidth, Geom.point);
display(p)

import Plots, StatsPlots
dist = Gamma(2)
StatsPlots.scatter(dist, leg = false)
display(StatsPlots.bar!(dist, func = cdf, alpha = 0.3))
