include("./ffi.jl");
using Bits
using Flux

function output(a::UInt64, b::UInt64) 
    model(vcat(Bits.bits(a), Bits.bits(b)))
end

model = Flux.Chain(Dense(128, 256, relu), Dense(256, 256, relu), Dense(256, 64, tanh))
param = params(model)
epsilon = 0.001

x_train = []
y_train = []

for epoch in 1:100000
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
            x = UInt8(Bits.scan1(moves) - 1)
            t = Othello.flip(a, b, x)
            out = output(xor(b, t), xor(a, t, moves & -moves))
            moves &= moves - 1
            append!(pair, [(x, out)])
        end

        maxmove = findmax((x->sum(x[2])).(pair))[2]
        
        if rand() < epsilon
            move = rand(pair)[1]
        else
            move = pair[maxmove][1]
        end
        
        flip = Othello.flip(a, b, move)
        append!(x_train, [vcat(Bits.bits(a), Bits.bits(b))])
        append!(y_train, [pair[maxmove][2]])

        (a,b) = (xor(b, flip), xor(a, flip, UInt64(1) << move))
    end
    append!(x_train, [vcat(Bits.bits(a), Bits.bits(b))])
    append!(y_train, [(x-> 2*x - 1).(Bits.bits(a))])

    print("YAY\n", length(x_train), length(y_train), "\n")
    sleep(0.1)
    if length(x_train) > 2048
        print("PLEASE IMPELEMENT TRAINING")
        x_train = []
        y_train = []
        break
    end
end
loss(x, y) = Flux.Losses.mse(model(x), y)
opt = Flux.Descent()


