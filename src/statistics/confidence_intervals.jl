using Distributions

failures = 21
n = 500
function bWeight(p)
	# p of failures
	pdf(Binomial(n, p), failures)
end
ps = [0:0.01:1;]
ws = [bWeight(p) for p in ps]
ws = ws / sum(ws)
sa([ps[i] => ws[i] for i in 1:length(ps)])
##
using Plots
plot(ps[1:12]*100, ws[1:12])