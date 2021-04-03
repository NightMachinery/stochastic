using Plots
function f1(x)
	ℯ^x - x
end
plot(f1, -30, 5)
##
using ImplicitEquations, Plots
# To avoid type piracy, the operators > and < have been replaced by unicode symbols \gg[tab] and \ll[tab] (Or Lt(f, 0) & Gt(g, 0))
f(x,y) = (x^2 + y^2)
g(x, y) = y - x^3
h(x, y) = y - (-x)
plot((f ≦ 1) & Ge(g, 0) & Ge(h, 0))