include("./ffi.jl");
#using Pkg
#Pkg.add("Bits")
#Pkg.add("Flux")
using Bits
using Flux

output(a::UInt64, b::UInt64) = model(vcat(bits(a), bits(b)))

model = Chain(Dense(128, 256, relu), Dense(256, 256, relu), Dense(256, 64, tanh))
loss(x, y) = Losses.mse(model(x), y)
opt = RADAM(0.1)
epsilon = 0.3

x_train = []
y_train = []

while true
    global x_train, y_train

    a = 0x0000_0008_1000_0000
    b = 0x0000_0010_0800_0000
    while Othello.moves(a,b) != 0 || Othello.moves(b,a) != 0
        if Othello.moves(a,b) == 0
            (a,b) = (b,a)
        end

        pair = []
        moves = Othello.moves(a,b)
        while moves != 0
            x = UInt8(scan1(moves) - 1)
            t = Othello.flip(a, b, x)
            out = output(xor(b, t), xor(a, t, moves & -moves))
            moves &= moves - 1
            append!(pair, [(x, -out)])
        end

        maxmove = findmax((x->sum(x[2])).(pair))[2]
        
        if rand() < epsilon
            move = rand(pair)[1]
        else
            move = pair[maxmove][1]
        end
        
        flip = Othello.flip(a, b, move)
        append!(x_train, [vcat(bits(a), bits(b))])
        append!(y_train, [pair[maxmove][2]])

        (a,b) = (xor(b, flip), xor(a, flip, UInt64(1) << move))
    end
    push!(x_train, vcat(bits(a), bits(b)))
    push!(y_train, (x-> 2*x - 1).(bits(a)))

    if length(x_train) > 2048
        model |> gpu
        global opt
        
        parameters = params(model)
        x_train = hcat(x_train...)
        y_train = hcat(y_train...)
        data = [(x_train, y_train)]
        evalcb() = @show(loss(x_train, y_train))

        for epoch in 1:50
            Flux.train!(loss, parameters, data, opt, cb=evalcb)
        end
        open("model/weights.txt", "w") do io
            write(io, params(model))
        end;

        model |> cpu
        x_train = []
        y_train = []
    end
end
