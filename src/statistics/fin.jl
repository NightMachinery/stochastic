a = 0
r = 1.1
for i in 1:7
	global a
	a += 110/(r^i)
end
a += (1000*1.075)/(r^7)
@labeled a
##
a = 0
r = 1.035
n = 20
pmt = 40
for i in 1:n
	global a
	a += pmt/(r^i)
end
a += (1000)/(r^n)
@labeled a
##
a = 0
r = 1.0995
n = 13
pmt = 110
for i in 1:n
	global a
	a += pmt/(r^i)
end
a += (1000)/(r^n)
@labeled a
##
a = 0
r = 1.01
n = 48
pmt = 350
for i in 1:n
	global a
	a += pmt/(r^i)
end
@labeled a
##
a = 0
r = 1.01
n = 60
pmt = 350
for i in 1:n
	global a
	a += pmt/(r^i)
end
@labeled a
##
y = 0
for i in 0:11
 global y
 y += 350*((1 + 0.1/12)^i)
end
@labeled y
n = 4
a = 0
r = 1.124
n = 4
# n = 5
pmt = y
for i in 1:n
	global a
	a += pmt/(r^i)
end
@labeled a
##
0.06 + 0.05*0.9
##
0.06 + 0.05*1.2
##
(7500*0.105 + 2500*0.12)/(7500+2500)
##
(1087.17/1000)^(1/7)
##
((1.1238^(1/12))-1)*12
##
(1 + 0.11728/12)^12
##
for s in (270, 290, 310, 325.5, 309.2)
	EBIT = s*0.12
	@labeled EBIT*(1-0.49)
end
##
(15.77)/(0.1157+0.05)
##
r = 1.1157
13.77/r + 14.79/r^2 + 15.81/r^3 + 16.6/r^4 + 95.17/r^4
##