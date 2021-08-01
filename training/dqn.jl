include("./ffi.jl");
#using Pkg
#Pkg.add("Bits")
#Pkg.add("Flux")
using Bits
using Flux

toplane(a::UInt64) = reshape(bits(a), 8, 8, 1, 1)

input(a::UInt64, b::UInt64) = cat(toplane(a), toplane(b), dims = 3)

#output(a::UInt64, b::UInt64) = model(vcat(bits(a), bits(b)))
function output(a::UInt64, b::UInt64) 
    stable = Othello.stable(a, b)
    temp = model(input(a, b))
    temp = max.(2 * toplane(stable & a) .- 1,temp)
    temp = min.(1 .- 2 * toplane(stable & b),temp)
    return temp
end
function bitboard_to_array(a::UInt64)
    ret = []
    while a != 0
        x = UInt8(scan1(a) - 1)
        a &= a - 1
        push!(ret, x)
    end
    return ret
end

function play(a::UInt64, b::UInt64, c::UInt8)
    t = Othello.flip(a, b, c)
    @assert t != 0
    return (xor(b, t), xor(a, t, UInt64(1) << c))
end

function rand_agent(a::UInt64, b::UInt64)
    moves = Othello.moves(a,b)
    pair = bitboard_to_array(moves)
    return rand(pair)
end

function model_agent(a::UInt64, b::UInt64)
    moves = Othello.moves(a,b)
    pair = (x->(x,-output(play(a,b,x)...))).(bitboard_to_array(moves))
    maxmove = findmax((x->sum(x[2])).(pair))[2]
    return pair[maxmove][1]
end

function good_agent(a::UInt64, b::UInt64)
    moves = Othello.moves(a,b)
    pair = (x->(x,Othello.moves(play(a,b,x)...))).(bitboard_to_array(moves))
    maxmove = findmin((x->count_ones(x[2])).(pair))[2]
    return pair[maxmove][1]
end

function against_random()
    turn = rand(Bool)

    a = 0x0000_0008_1000_0000
    b = 0x0000_0010_0800_0000
    while Othello.moves(a,b) != 0 || Othello.moves(b,a) != 0
        if Othello.moves(a,b) == 0
            (a,b) = (b,a)
        else
            turn = !turn
        end
        if turn
            move = model_agent(a,b)
        else
            move = rand_agent(a,b)
        end
        (a,b) = play(a, b, move)
    end
    score = count_ones(a)
    if turn
        score = 64 - score
    end
    return score
end

RADAMW(η = 0.001, β = (0.9, 0.999), decay = 0) =
  Flux.Optimiser(RADAM(1, β), WeightDecay(decay), Descent(η))


#model = Chain(Dense(128, 256, relu), Dense(256, 256, relu), Dense(256, 64, tanh))
nf = 32 #number of filters
model = Chain(
    Conv((3, 3), 2=>nf, relu, pad=SamePad()),
    Conv((3, 3), nf=>nf, relu, pad=SamePad()),
    Conv((3, 3), nf=>nf, relu, pad=SamePad()),
    Conv((3, 3), nf=>nf, relu, pad=SamePad()),
    Conv((3, 3), nf=>nf, relu, pad=SamePad()),
    Conv((3, 3), nf=>nf, relu, pad=SamePad()),
    Conv((3, 3), nf=>1, tanh, pad=SamePad()),
)
loss(x, y) = Flux.Losses.mse(model(x), y)
opt = RADAMW(0.1, (0.9, 0.999), 1)
epsilon = 0.9

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
        pair = (x->(x,-output(play(a,b,x)...))).(bitboard_to_array(moves))

        maxmove = findmax((x->sum(x[2])).(pair))[2]
        
        if rand() < epsilon
            move = rand(pair)[1]
        else
            move = pair[maxmove][1]
        end
        
        push!(x_train, input(a, b))
        push!(y_train, pair[maxmove][2])
        
        (a, b) = play(a, b, move)
    end
    #push!(x_train, vcat(bits(a), bits(b)))
    #push!(y_train, (x-> 2*x - 1).(bits(a)))

    if length(x_train) > 256

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
        x_train = []
        y_train = []
    end
end
