include("./othello.jl");
include("./model.jl");
using Bits
using Flux

#toplane(a::UInt64) = reshape(bits(a), 8, 8, 1, 1)
input(a::Game) = vcat(bits(a.a), bits(a.b))
output(a::Game) = model(input(a))
value(a::Game) = sum(output(a))

#higher is better
function against_random()
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


model = Dense(128, 64, tanh)

loss(x, y) = Flux.Losses.mse(model(x), y)
opt = RADAMW(0.1, (0.9, 0.999), 1)
epsilon = 0.9

function generate_traindata!(position, value)
    turn_data = []
    turn = false
    g = init()
    while notend(g)
        if rawmoves(g) == 0
            g = flip(g)
        else
            turn = !turn
        end

        pair = (x->(x,-output(g + x))).(moves(g))
        maxmove = findmax((x->sum(x[2])).(pair))[2]
        
        if rand() < epsilon
            move = rand(pair)[1]
        else
            move = pair[maxmove][1]
        end
        
        push!(position, input(g))
        push!(turn_data, turn)
        
        g = g + move
    end
    score = count_ones(g.a)
    value_data = map(x -> (x == turn ? score : 64 - score), turn_data)
    value = append!(value, value_data)
end

while true
    
    x_train = []
    y_train = []

    while length(x_train) <= 256
        generate_traindata!(x_train, y_train)
    end

    t = (x->against_random()).(1:100)
    print(sum(t)/length(t), "\n")

    model |> gpu
    global opt
    
    parameters = params(model)
    x_train = hcat(x_train...)
    y_train = hcat(y_train...)
    data = [(x_train, y_train)]
    evalcb() = @show(loss(x_train, y_train))

    for epoch in 1:2
        Flux.train!(loss, parameters, data, opt, cb=evalcb)
    end
    #open("model/weights.txt", "a+") do io
    #    write(io, string(params(model)))
    #end;

    model |> cpu
end
