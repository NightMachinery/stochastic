using Exfiltrator
klein = [0 1 2 3; 
		 1 0 3 2;
		 2 3 0 1;
		 3 2 1 0]
# parse(Int,"032301210"; base=4) == 60516

function fm(sz = 4)
    esz = sz - 1
    tsz = (esz^2)

	st = sa # show table

    function createTable(tablecode)
	tablecodeStr = string(tablecode; base=sz, pad=tsz) # string((0:(esz)...,))
	table = reshape(map(collect(tablecodeStr)) do el
		parse(Int, el)
		end, esz,esz)
	table = vcat([0:esz;]', hcat([1:esz;], table))
	# sa(table)
    end

	function tableGet(table, i, j)
		table[i + 1, j + 1]
	end

	function isAssoc(table; verbose=false)
		# assuming 0 is the idendity
		for i in 1:esz, j in 1:esz, z in 1:esz
			t1 = tableGet(table, (tableGet(table, i, j)), z)
			t2 = tableGet(table, i, (tableGet(table, j, z)))
			if t1 != t2
				if verbose
					st(table)
					println("Not assoc: ($(i)&$(j))&$(z)=$t1 != $t2=$(i)&($(j)&$(z))")
				end
				return false
			end
		end
		return true
	end

	function getInvL(table, i)
		res = Set{Int}()
		for L in 0:esz
			if tableGet(table, L, i) == 0
				push!(res, L)
			end
		end
		return res
	end
	function getInvR(table, i)
		res = Set{Int}()
		for L in 0:esz
			if tableGet(table, i, L) == 0
				push!(res, L)
			end
		end
		return res
	end
	function getInv(table, i)
		intersect(getInvL(table, i), getInvR(table, i))
	end

	foundMonoids = 0

    for tablecode in 0:(sz^(tsz) - 1)
		table = createTable(tablecode)

		# ## q1.b
		# if ! (! isempty(getInv(table, tableGet(table, 1,2))) && isempty(getInv(table, tableGet(table, 2, 1))))
		# 		# st(table)
		# 		continue
		# end
		# ##

		if isAssoc(table; verbose=false)
			foundMonoids += 1
			
			# if table == klein
			# 	println("klein found at $tablecode")
			# end
			## q1.b
			# if ! isempty(getInv(table, tableGet(table, 1,2))) && isempty(getInv(table, tableGet(table, 2, 1))) 
			# 	st(table)
			# end
			## q5
			# for i in 1:esz
			# 	if tableGet(table, i, i) == i
			# 		@goto skip
			# 	end
			# end
			##
			st(table)
			@label skip
		end
	end

	@labeled foundMonoids
	# test = rand(1:10)
	@exfiltrate
end
##
fm()
# BenchmarkTools.Trial: 
#   memory estimate:  292.25 MiB
#   allocs estimate:  3410223
#   --------------
#   minimum time:     209.150 ms (6.61% GC)
#   median time:      250.114 ms (7.66% GC)
#   mean time:        252.103 ms (7.50% GC)
#   maximum time:     336.619 ms (6.04% GC)
#   --------------
#   samples:          20
#   evals/sample:     1
##
# BenchmarkTools.Trial: 
#   memory estimate:  826.14 MiB
#   allocs estimate:  8075427
#   --------------
#   minimum time:     460.583 ms (10.87% GC)
#   median time:      479.842 ms (11.21% GC)
#   mean time:        490.879 ms (10.98% GC)
#   maximum time:     564.568 ms (10.93% GC)
#   --------------
#   samples:          11
#   evals/sample:     1
##
isAssoc(klein) 