tic()
n = 5

dup = 10^1 #10^5

rint = function(n1){
ceiling(runif(dup)*n1)
}

nv = 1:n
nm = matrix(list(),nrow=dup,ncol=n, byrow=TRUE)
for (i in 1:n) {
si = rint(i)

for (j in 1:dup) {
ix = si[j]
nm[j,i] = nm[j,ix]
nm[j,ix] = i
}
nm[,i] = nm[,i]
nm[

}

t=toc()
nm
t