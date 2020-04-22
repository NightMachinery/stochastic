

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

p = [1 // 10, 3 // 10, 4 // 10, 36 // 1000, 98 // 1000, 5 // 1000]
push!(p, 1 - sum(p))
@assert sum(p) == 1
@defonce const P = preP(p)

using InteractiveUtils

if true
    @btime P()

# @benchmark [P() for i in 1:10^5]

    using FreqTables
# @benchmark prop(freqtable([P() for i in 1:10^5]))
    display(@benchmark prop(freqtable([P() for i in 1:10^7])))
    function res()
        return prop(freqtable([P() for i in 1:10^7]))
    end
    println(@btime res())

else
    # testing inline
    function res3()
        # i = []
        # for j in 1:10^4
        #     push!(i, P())
        # end
        # return i
        [P() for i in 1:10^4]
    end
    @code_llvm res3()
    println("******************************")
    function res2()
        i = 0
        for j in 1:10^4
            i += P()
        end
        return i
    end
    @code_llvm res2()
    println("---------------------------------")
    function ff()
        P()
    end
    @code_llvm ff()
end
# let
#     function getT()
#         # gteatime = [333333]
#         # push!(gteatime,99999)
#         local teatime = 8
#         function ff2()
#             return teatime
#         end
#         return ff2
#     end
#     local T8 = getT()
#     function ff()
#         T8()
#     end
#     @code_llvm ff()
#     ff()
# end

# @benchmark res()


# # function ff()
# #     @inbounds begin
# #         a = collect(1:2)
# #         a[38270]
# #     end
# # end
# # ff()