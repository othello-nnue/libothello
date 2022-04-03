include("./othello.jl");
include("./model.jl");
using Bits
using Flux

model1 = Chain(Dense(128, 256, gelu), Dense(256, 64, tanh))
model2 = Chain(Dense(128, 256, gelu), Dense(256, 64, tanh))

#toplane(a::UInt64) = reshape(bits(a), 8, 8, 1, 1)
input(a::Game) = vcat(bits(a.a), bits(a.b))

#higher is better
function against_random()
    value(a::Game) = sum(model1(input(a)))
    turn = rand(Bool)

    g = init()
    while notend(g)
        if rawmoves(g) == 0
            g = flip(g)
        else
            turn = !turn
        end
        if turn
            move = model_agent(g, value)
        else
            move = rand_agent(g)
        end
        g = g + move
    end
    score = count_ones(g.a)
    if turn
        score = 64 - score
    end
    return score
end

function generate_traindata!(value_net, act_net, position, value)
    g = init()
    while notend(g)
        if rawmoves(g) == 0
            g = flip(g)
        end

        if rand() < epsilon
            move = rand_agent(g)
        else
            move = agent(g) do x
                return sum(act_net(input(x)))
            end
        end

        push!(position, g)
        g = g + move
        push!(value, -value_net(input(g)))
    end
    push!(position, g)
    push!(value, (x -> 2 * x - 1).(bits(g.a)))
end

opt = RADAMW(0.1, (0.9, 0.999), 1)
epsilon = 0.9

while true
    x_train1 = []
    y_train1 = []

    while length(x_train1) <= 256
        generate_traindata!(model2, model1, x_train1, y_train1)
    end

    x_train2 = []
    y_train2 = []

    while length(x_train2) <= 256
        generate_traindata!(model1, model2, x_train2, y_train2)
    end

    x_train1 = map(input, x_train1)
    x_train2 = map(input, x_train2)
    
    x_train1 = hcat(x_train1...)
    y_train1 = hcat(y_train1...)

    x_train2 = hcat(x_train2...)
    y_train2 = hcat(y_train2...)

    t = (x -> against_random()).(1:100)
    print(sum(t) / length(t), "\n")

    # model |> gpu
    global opt

    parameters = params(model1)
    data = [(x_train1, y_train1)]
    loss(x, y) = Flux.Losses.mse(model1(x), y)
    evalcb() = @show(loss(x_train1, y_train1))

    for epoch in 1:2
        Flux.train!(loss, parameters, data, opt, cb=evalcb)
    end

    parameters = params(model2)
    data = [(x_train2, y_train2)]
    loss(x, y) = Flux.Losses.mse(model2(x), y)
    evalcb() = @show(loss(x_train2, y_train2))

    for epoch in 1:2
        Flux.train!(loss, parameters, data, opt, cb=evalcb)
    end
    # open("model/weights.txt", "a+") do io
    #    write(io, string(params(model)))
    # end;

    # model |> cpu
end
