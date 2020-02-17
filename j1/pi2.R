all = 10000
for (i in 1:2) {
all = all * 100
}

r1 = runif(all)
r2 = runif(all)

r = r1^2 + r2^2
#rp = r < 1
#ina = sum(rp)
ina = length(r[r<=1])
print(ina*4/all)