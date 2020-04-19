include("./poisson.jl")
include("./binarysearch.jl")
using Distributions

const L = 500
const poiL = poisson(L, L*3)[2]
function u2poiL(u)
    return bsbetween(poiL, u)[2] - 1
end

@inline function u2poiL2(u)
    return bsbetween2(poiL, u)[2] - 1
end

function u2poiLS(u)
    i = 0
    for p in poiL
        if u <= p
            return i
        end
        i += 1
    end
end

function u2poiLS2(u)
    if u == poiL[L]
        return L
    elseif u >= poiL[L]
        i = L + 1
        for p in poiL[L+1:end]
            if u <= p
                return i - 1
            end
            i += 1
        end
    else
        i = L - 1
        for p in reverse(poiL[1:L-1])
            if u > p
                return i #+1
            end
            i -= 1
        end
        return 0
    end
end

function u2poiLS3(u)
    if u == poiL[L]
        return L - 1
    elseif u >= poiL[L]
        for i = L+1:length(poiL)
            if u <= poiL[i]
                return i - 1
            end
        end
    else
        for i = L-1:-1:1
            if u > poiL[i]
                return i #+1
            end
        end
        return 0
    end
end

@assert u2poiL(0) == 0
for i = 1:10^4
    r = rand()
    if !(u2poiL(r) == u2poiL2(r) == u2poiLS(r) == u2poiLS2(r) == u2poiLS3(r))
        println("$(u2poiL(r)) == $(u2poiL2(r)) == $(u2poiLS(r)) == $(u2poiLS2(r)) == $(u2poiLS3(r))")
    end
end
# @assert u2poiL(0.5) == 50 # Only for L=50

n = 10^4
if false
    # Times in comment are for n=10^4

    # Binary search (functional style)
    bBS = @benchmark g1 = [u2poiL(rand()) for i = 1:n]
    # 7.039 ms (Huge memory allocations)

    # Binary search (while loop)
    bBS2 = @benchmark g1 = [u2poiL2(rand()) for i = 1:n]
    # 1.091 ms
    # Becomes faster than S with lan=500 n=10^5
    # but S3 still the fastest by a big margin

    # Naive (brute force)
    bS = @benchmark g1 = [u2poiLS(rand()) for i = 1:n]
    # 573.981 μs

    # Better naive (uses iterators)
    bS2 = @benchmark g1 = [u2poiLS2(rand()) for i = 1:n]
    # 2.573 ms

    # Better naive (uses ranges only)
    bS3 = @benchmark g1 = [u2poiLS3(rand()) for i = 1:n]
    # 435.529 μs

    # BS < S2 << S < S3
end

n = 10^7
@time g1 = [u2poiLS3(rand()) for i = 1:n]
# function gen1()
#     out = Vector{Int}(undef, n)
#     for i in 1:n
#         # out[i] = u2poiL(rand())
#         u2poiL(rand())
#         # rand()
#     end
#     return out
# end
# @benchmark gen1()
v1 = [rand(Poisson(L)) for i = 1:n]

using Statistics, DataFrames, Gadfly, Distributions, Colors, ColorSchemes
p = plot(
    layer(
        x = g1,
        Geom.density(bandwidth = 1),
        # color = [RGBA(1, 0, 0, 0.3)],
        style(
            # alphas = [0.3],
            line_width = 1mm,
            default_color = RGBA(0, 0, 1, 0.5),
        ),
    ),
    layer(
        x = v1,
        Geom.density(bandwidth = 1),
        # color = [RGB(0, 1, 0)],
        style(line_width = 1mm, default_color = RGBA(0, 1, 0, 0.5)),
    ),
    # style(alphas = [0.3], line_width =2mm),
);
# alpha is useless on lines?
display(p)
