using DataStructures
function preP(p)
    n = length(p)
    u = p * n
    uover = MutableBinaryMaxHeap{Tuple{Rational{Int},Int}}()
    uunder = MutableBinaryMinHeap{Tuple{Rational{Int},Int}}()
    k = Array{Int}(undef, n)
    function pushu(i, u)
        if u < 1
            push!(uunder, (u, i))
        elseif u > 1
            push!(uover, (u, i))
        end
    end
    for (i, u) in enumerate(u)
        pushu(i, u)
    end
    while ! isempty(uunder)
        (uu, iu) = pop!(uunder)
        if isempty(uover)
            k[iu] = -1 # Mark as invalid. We can also use a dummy default value.
            continue
        end
        (uo, io) = pop!(uover)
        k[iu] = io
        pushu(io, uo - (1 - uu))
    end

    P = let n = n, u = u, k = k
        @inline function x()
            i = rand(1:n)
            @inbounds if rand() <= u[i]
                return i
            else
                return k[i]
            end
        end
    end
    println("Precomputed alias tables for $p")
    return P
end

