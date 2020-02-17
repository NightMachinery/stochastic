n = 10^5
un = 1000
inc = 1/un
unf = seq(inc,1,inc)
u = seq(1,un)
p = runif(n)
p2x = function(p) {
i = min(which(unf > p))
#u[i]
i
}
res = (sapply(p, p2x))
hist(res)
#table(res)/n