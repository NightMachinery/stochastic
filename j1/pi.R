isIn = function() {
x = c(runif(1),runif(1))
l2 = x %*% x
l2 <= 1
}

# in/ll * 4

ina = 0
all = 10000
for (i in 1:2) {
all = all * 100
}
for (i in 1:all) {
if (isIn()) {
ina = ina + 1
}

}

print(ina*4/all)