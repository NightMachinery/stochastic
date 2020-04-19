function bsbetween(arr, elem, s, e)
    function bsbetween1(arr, elem, s, e)
        # println("CALLED $elem $s $e")
        if e - s <= 1
            if elem == arr[s]
                return s, s
            elseif elem == arr[e]
                return e, e
            elseif elem < arr[s]
                return s - 1, s
            elseif elem > arr[e]
                return e, e + 1
            else
                return s, e
            end
        end
        i = floor(Int, (e - s) / 2) + s
        if elem <= arr[i]
            return bsbetween1(arr, elem, s, i)
        else
            return bsbetween1(arr, elem, i, e)
        end
    end
    indices = bsbetween1(arr, elem, s, e)
    return indices
    # return (indices, (arr[indices[1]], arr[indices[2]]))
end
function bsbetween(arr, elem)
    return bsbetween(arr, elem, 1, length(arr))
end

# inlining this helps a tiiiiny bit
function bsbetween2(arr, elem)
    s = 1
    e = length(arr)

    if elem == arr[s]
        return s, s
    elseif elem == arr[e]
        return e, e
    end

    while true
        if e - s <= 1
            if elem < arr[s]
                return s - 1, s
            elseif elem > arr[e]
                return e, e + 1
            else
                return s, e
            end
        end
        i = floor(Int, (e - s) / 2) + s
        if elem <= arr[i]
            e = i
            continue
            # return bsbetween1(arr, elem, s, i)
        else
            s = i
            continue
            # return bsbetween1(arr, elem, i, e)
        end
    end
end
