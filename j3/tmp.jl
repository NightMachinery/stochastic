p = [[6 5 3 1]
    [3 6 2 2]
    [3 4 3 1]]

s = [[1.5 1]
    [2 2.5]
    [5 4.5]
    [16 17]]

r = p*s
rb = mapslices(r, dims=[2]) do x
    s1, s2 = x
    s1 >= s2
end
