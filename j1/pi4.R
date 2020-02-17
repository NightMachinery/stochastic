a = 9
inc = 10^-a
hinc = inc /2
r = seq(0+hinc,1-hinc,by=inc)
b = sqrt(1-r^2)
print(sum(b)*4/10^a)