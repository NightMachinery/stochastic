@inline function e1()
    -log(rand())
end

function stdN()
    while true
        x = e1()
        if rand() <= (MathConstants.e^(((x - 1)^2) / -2))
            if rand(Bool)
                return x
            else
                return -x
            end
        end
    end
end

##############

include("../common/plotSamples2.jl")

function drawNormal(mean = 0, std = 1)
    plt = drawSamples((λ)->(stdN() * std) + mean, (λ)->rand(Distributions.Normal(mean, std)), [1])
    display(plt)
    plt  |> SVGJS("./plots/Normal(mean=$mean, std=$std).svg", 26cm, 20cm)
end
##############
drawNormal()
drawNormal(34,4)
drawNormal(-200,26)