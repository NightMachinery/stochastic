using Statistics, Plots, StatsPlots

# Simulating a Mafia game with only Mafias, citizens, and a doctor where Mafias
# play the citizen protocol during the day. Also, we suppose that the doctor is
# somehow stupid and doesn't discern that saving certain people never prevents
# the night killing.

function play()
    Ts = repeat([true],3)
    Fs = repeat([false],7)

    while true
        F = length(Fs)
        T = length(Ts)
        if T >= F
            # Mafias have won
            return true
        elseif T == 0
            # Citizens have won
            return false
        end

        # Citizens kill a random person (note that this is the worst case for
        # Mafia.)
        if rand() <= (F/(F+T))
            pop!(Fs)
            F -= 1
        else
            pop!(Ts)
            T -= 1
        end
        if rand() > (1/(F+T))
            # doctor failed
            pop!(Fs)
        end
    end
end

n = 10^6
@time res = map(_ -> play(),1:n)
println("p(Mafia wins) = $(count(res)/length(res))")
# It's about 0.88

histogram(res, normalize = :probability)

# @time begin
#  res = fill(false,1:n)
#  for i in 1:n
#      res[i] = play()
#  end
# end
