using Random


function initConf(n)
    randperm(n)
end
function updateConf(pv, conf, u1)
    pv = accumulate(+, pv[conf]) # permute the probs according to current config
    req = findfirst(pv) do p
        p > u1
    end
    if req > 1
        tmp = conf[req - 1]
        conf[req - 1] = conf[req]
        conf[req] = tmp
    end
    return req
end
function listRecording(; requests=100, pv, runs=10^3)
    @assert sum(pv) == 1
    n = length(pv)
    uSums = [] 
    reqSums = []
    for run in 1:runs
        conf = initConf(n)
        reqs = []
        us = []
        for i in 1:requests
            u = rand()
            push!(us, u)
            push!(reqs, updateConf(pv, conf, u))
        end
        sum_reqs = sum(reqs)
        push!(reqSums, sum_reqs)
        push!(uSums, sum(us))
    end

    cov_reqSums_uSums = cov(reqSums, uSums)
    var_uSums = cov(uSums)
    c = -cov_reqSums_uSums / var_uSums
    reqSums_mean = mean(reqSums)
    uSums_real_mean = requests / 2

    reqSums_c = []
    for i in 1:runs
        push!(reqSums_c, reqSums[i] + c * (uSums[i] - requests / 2))
    end

    reqSums_c_mean = mean(reqSums_c)

    reqSums_c_mean_direct = reqSums_mean + c * (mean(uSums) - uSums_real_mean)

    @labeled c
    @labeled reqSums_mean
    @labeled reqSums_c_mean
    @labeled reqSums_c_mean_direct
    @labeled reqSums_mean / requests
    @labeled reqSums_c_mean / requests
    @labeled reqSums_c_mean_direct / requests
    @labeled cov(reqSums)
    @labeled cov(reqSums_c)
end

# p = [1 // 10, 3 // 10, 4 // 10, 36 // 1000, 98 // 1000, 5 // 1000]
p = [ 45 // 100, 45 // 100, 1 // 30, 1 // 30]
if sum(p) < 1
    push!(p, 1 - sum(p))
end
listRecording(; pv=p)

# c =>
#         -2.729932343336256
# reqSums_mean =>
#         184.064
# reqSums_c_mean =>
#         184.5582354450116
# reqSums_c_mean_direct =>
#         184.55823544501177
# reqSums_mean / requests =>
#         1.8406399999999998
# reqSums_c_mean / requests =>
#         1.845582354450116
# reqSums_c_mean_direct / requests =>
#         1.8455823544501178
# cov(reqSums) =>
#         129.99389789789788
# cov(reqSums_c) =>
#         67.22491207948629