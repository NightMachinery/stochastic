using Distributions
function A(n)
    (1 - 2 * (cdf(Normal(), sqrt(n) / 100) - 1 / 2), 1 -  (cdf(Normal(), sqrt(n) / 100) - cdf(Normal(), -sqrt(n) / 100)))
end