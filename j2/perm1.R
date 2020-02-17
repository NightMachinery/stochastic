tic()
n = 1000

dup = 10^5 #10^5

rint = function(n1){
ceiling(runif(1)*n1)
}

#allv = rep(rep(-1, n),dup)
allv = matrix(list(), nrow=dup, ncol=n)
for (j in 1:dup) {
nv = 1:n
nend = n
for (i in 1:n) {
si = rint(nend)
allv[j,i] = nv[si]
nv[si] = nv[nend]
nend = nend - 1
}
#v
}
toc()
#allv