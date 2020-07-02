using Distributions

function singleserver(; μ=1 / 20,
    σ=1 / 80,
    λ=12,
    tend=8,)
    rngnext = Exponential(1 / λ)
    rngservice = Normal(μ, σ)
    nextservice() = max(0, rand(rngservice))

    entered = []
    departed = []
    nq() = length(entered) - length(departed) # in queue

    ta = 0
    # possible arrival:
    psetarrival(now) = let nexta = now + rand(rngnext) # next arrival's time
        if nexta >= tend
            ta = Inf
        else
            ta = nexta
        end
    end
    psetarrival(0)

    td = Inf # next departure
    pservice(now) = if td === Inf && nq() >= 1
        # no one is being serviced right now and there is at least one person in queue
        td = now + nextservice()
    end

    while true
        if ta === td === Inf
            break
        else
            if ta <= td
                if ta < tend
                    now = ta
                    push!(entered, now)
                    psetarrival(now)
                    pservice(now)
                else
                    throw("Arrival after tend!")
                end
            else
                # td < ta
                now = td
                push!(departed, now)
                td = Inf # mark the processor empty
                pservice(now)
            end
        end
    end 
    return entered, departed
end
##
println("Running single server:")
singleserver()
##
# TODO servers in series and parallel
