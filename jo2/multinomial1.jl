#!/usr/bin/env julia

include("../jo1/binarysearch.jl")

@inline function sampleP(u, p)
    return bsbetween2(p, u)[2]
end

function genProbs(r)
    p = Array{Float64}(undef, r)
    pSep = 0
    pc = sort!(push!([rand() for i in 1:(r - 1)], 1))
    for (i, sep) in enumerate(pc)
        p[i] = sep - pSep
        pSep = sep
    end
    @assert sum(p) == 1
    return p, pc
end

pd, pc = genProbs(7)
n = 10^5

using FreqTables
res = prop(freqtable([sampleP(rand(), pc) for i in 1:n]))
println("pd: ")
sa(pd)
println("Res r^n method:")
sa(res)

# n^r

using DataStructures

function multi(pd, pc, n)
    r = length(pd)
    res2 = SortedDict{Int,Float64}()
    i = r
    csum = 0
    for p in reverse(pd)
        local tsum = 0
        # ec("before\ni: $i\npc[i]: $(pc[i])\np: $p\ntsum: $tsum\ncsum: $csum")
        # try
        tsum = sum([rand() <= (p / (pc[i])) for j in 1:(n - csum)])
        # catch e
            # @infiltrate
        # end
        push!(res2, i => (tsum)) 
        csum += tsum
        i -= 1
        # ec("after\ntsum: $tsum\ncsum: $csum")
    end
    return res2
end

ec("n^r: ")
begin
    # pd, pc = genProbs(7)
    global res2
    res2 = multi(pd, pc, n)
    res2p = map(kv->kv[1] => (kv[2] / n), collect(res2))
    sa(res2p)
end