using Exfiltrator
klein = [0 1 2 3; 
		 1 0 3 2;
		 2 3 0 1;
		 3 2 1 0]
# parse(Int,"032301210"; base=4) == 60516

function fm()
    sz = 4
    esz = sz - 1
    tsz = (esz^2)

	st = sa # show table

    function createTable(tablecode)
	tablecodeStr = string(tablecode; base=sz, pad=tsz) # string((0:(esz)...,))
	table = reshape(map(collect(tablecodeStr)) do el
		parse(Int, el)
		end, 3,3)
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
		if isAssoc(table; verbose=false)
			# st(table)
			foundMonoids += 1
			# if table == klein
			# 	println("klein found at $tablecode")
			# end
			## q1.b
			if ! isempty(getInv(table, tableGet(table, 1,2))) # && isempty(getInv(table, tableGet(table, 2, 1))) 
				st(table)
			end
			##
		end
	end

	@labeled foundMonoids
	# test = rand(1:10)
	@exfiltrate
end
##
fm()
##
isAssoc(klein) 