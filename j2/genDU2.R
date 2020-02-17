n = 10^4
p = runif(n)
res = ceiling(p*1000)
hist(res)
#plot(density(res))
#table(res)/n