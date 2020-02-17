tic()
n = 5

dup = 10^1 #10^5

rint = function(n1){
ceiling(runif(dup)*n1)
}

nv = 1:n
nm = matrix(rep(nv,dup),nrow=dup,ncol=n, byrow=TRUE)
nend = n
for (i in n:1) {
si = rint(i)

for (j in 1:dup) {
ix = si[j]
before = nm[j,i]
nm[j,i] = nm[j,ix]
nm[j,ix] = before
}

}

t=toc()
nm
t