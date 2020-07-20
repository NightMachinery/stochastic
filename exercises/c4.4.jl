function myPermute(a)
    a = collect(a)
    len = length(a)
    mark = len
    for i in 1:len
        chosen = rand(1:mark)
        tmp = a[mark]
        a[mark] = a[chosen]
        a[chosen] = tmp
        mark -= 1
    end
    a
end

function hits(n)
    shuffled = myPermute(1:n)
    hits = 0
    for i in 1:n
        if shuffled[i] == i
            hits += 1
        end
    end
    hits
end

##
using Statistics
n = 100
data = [hits(n) for i in 1:10^6]
println("mean=$(mean(data)), var=$(std(data; corrected=true)^2)")
# => mean=1.000046, var=1.0003289982129984
## test 1
println("############")
sad(myPermute(1:100))
println("############")
## test 2
println("############")
sa(myPermute(1:100))
println("############")
##

