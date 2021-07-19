using ForceImport
import GLM
@force using DataFrames, GLM

X = [-2, -1, 0, 1, 2]
Y = [2, 2, 3, 4, 3]

data = DataFrame(; X, Y)

ols = GLM.lm(@formula(Y ~ X + X^2), data)

##
using SymPy 

@vars a b γ

e1 = sum(let x = X[i], y = Y[i] 
    (-x^2) * (y - a * x^2 - b * x - γ) end 
for i in 1:length(X))

e2 = sum(let x = X[i], y = Y[i] 
    (-x) * (y - a * x^2 - b * x - γ) end 
for i in 1:length(X))

e3 = sum(let x = X[i], y = Y[i] 
    (y - a * x^2 - b * x - γ) end 
for i in 1:length(X))

linsolve((e1,e2,e3), (a,b,γ))