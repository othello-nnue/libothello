include("./ffi.jl");
using Bits
using Flux

function output(a::UInt64, b::UInt64) 
    model(vcat(Bits.bits(a), Bits.bits(b)))
end

model = Flux.Chain(Dense(128, 256, relu), Dense(256, 256, relu), Dense(256, 64, tanh))
param = params(model)
epsilon = 0.001

for epoch in 1:100
    x_train = []
    y_train = []

    a = 0x0000_0008_1000_0000
    b = 0x0000_0010_0800_0000
    while Othello.moves(a,b) != 0 || Othello.moves(b,a) != 0
        if Othello.moves(a,b) == 0
            (a,b) = (b,a)
        moves = Othello.moves(a,b)

        pair = []
        while moves != 0
            x = UInt8(Bits.scan1(moves) - 1)
            
            t = Othello.flip(a,b, x)
            out = output(b\u22bb t, a \u22bb t \u22bb (moves & -moves))
            moves &= moves - 1

            append!(pair, [(x, out)])

        input = vcat(Bits.bits(a), Bits.bits(b))
        maxmove = findmax(pair)
        move = 0
        flip = Othello.flip(a, b, move)
        (a,b) = (b \u22bb flip, a \u22bb flip)
        
        append!(x_train, [input])
        append!(y_train, [output])
    data = [(x_train, y_train)]    
end

loss(x, y) = Flux.Losses.mse(model(x), y)
opt = Flux.Descent()


