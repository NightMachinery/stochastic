all = 1
for (i in 1:4) {
all = all * 100
}

r1 = runif(all)

r = sqrt(1-r1^2)

print(sum(r)*4/all
)