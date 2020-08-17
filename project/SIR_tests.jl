m3_1_1(0.1; discrete_opt=0.1, visualize=true, c=100, initialPeople=gg1(; gaps=vcat([(i, j) for i in 20:22 for j in 1:100], [(i, j) for i in 23:100 for j in 9:11])))
##
begin
    withMW(m3_2_1,0.03; discrete_opt=1//24, visualize=true, c=100, initialPeople=gp_H_dV, isolationProbability=0.9, smallGridMode=0, daysInSec=1, simDuration=1000, tracking=true)
    withMW(m3_2_1,0.03; discrete_opt=1//24, visualize=true, c=100, initialPeople=gp_H_dV, isolationProbability=0.9, smallGridMode=0, daysInSec=1, simDuration=1000, tracking=true, oneMarketMode=true)
    withMW(m3_2_1,0.03; discrete_opt=1//24, visualize=true, c=100, initialPeople=gp_H_dV, isolationProbability=0.9, smallGridMode=20, daysInSec=1, simDuration=1000, tracking=true)

    withMW(m3_2_2,0.03; discrete_opt=1//24, visualize=true, c=100, initialPeople=gp_H_dV, isolationProbability=0.9, smallGridMode=20, daysInSec=4, simDuration=1000, tracking=true)

    withMW(m3_1_1,0.2; discrete_opt=1//24, visualize=true, c=500, isolationProbability=0.3, smallGridMode=80, daysInSec=10, simDuration=1500, tracking=true)

    withMW(m3_2_2,0.2; discrete_opt=1//24, visualize=true, c=500, isolationProbability=0.3, smallGridMode=80, daysInSec=10, simDuration=1500, tracking=true)

    withMW(m3_2_2,0.2; discrete_opt=1//24, visualize=true, c=500, isolationProbability=0.3, smallGridMode=10, daysInSec=10, simDuration=1500, tracking=true)

    withMW(m3_2_2,0.2; discrete_opt=1//24, visualize=true, c=500, isolationProbability=0.3, smallGridMode=10, daysInSec=10, simDuration=1500, tracking=true, oneMarketMode=true)

    withMW(m3_2_2,0.2; discrete_opt=1//24, visualize=true, c=500, isolationProbability=0.3, smallGridMode=10, daysInSec=10, simDuration=1500, tracking=true, oneMarketMode=true, noWork=true)

    ## HERE
    withMW(m3_1_2,0.2; discrete_opt=1//24, visualize=true, c=500, isolationProbability=0.3, smallGridMode=10, daysInSec=10, simDuration=1500, tracking=true)
end