struct Game
    a::UInt64
    b::UInt64
end

Move = UInt8

function Base.:+(a::Game, b::UInt8)
    t = Othello.flip(a.a, a.b, b)
    @assert t != 0
    return Game(xor(a.b, t), xor(a.a, t, UInt64(1) << b))
end

moves(a::Game) = bitboard_to_array(rawmoves(a))
rawmoves(a::Game) = Othello.moves(a.a, a.b)
notend(a::Game) = rawmoves(a) != 0 || rawmoves(flip(a)) != 0
flip(a::Game) = Game(a.b, a.a)
init() = Game(0x0000_0008_1000_0000, 0x0000_0010_0800_0000)

#do something...
function playwhile(agent1, agent2, logger)
    g = init()
    turn = false
    while notend(g)
        if rawmoves(g) == 0
            g = flip(g)
        else
            turn = !turn
        end
        if turn
            move = agent1(g)
        else
            move = agent2(g)
        end
        logger(g, move, turn)
        g = g + move
    end
end