n = 10^6
p = runif(n)
p2x = function(p) {
x = -1
if (p <= 0.3) {
x = 1
} else if (p <= 0.4) {
x = 2
} else if (p <= 0.6) {
x = 4
} else if (p <= 0.7) {
x = 5
} else if (p <= 0.9) {
x = 8
} else {
x = 10
}
#print(x)
}
res = (sapply(p, p2x))
table(res)/n
# hist(res,breaks=c(0,1,2,4,5,8,10))

