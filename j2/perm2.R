tic()
n = 5

dup = 10^1 #10^5

rint = function(n1){
ceiling(runif(dup)*n1)
}

#allv = rep(rep(-1, n),dup)
allv = matrix(list(), nrow=dup, ncol=n)

nv = 1:n
nm = matrix(rep(nv,dup),nrow=dup,ncol=n, byrow=TRUE)
nend = n
for (i in 1:n) {
si = rint(nend)

for (j in 1:dup) {
ix = si[j]
allv[j,i] = nm[j,ix]
nm[j,ix] = nm[j,nend]
}

nend = nend - 1
}
#v

t=toc()
allv
t