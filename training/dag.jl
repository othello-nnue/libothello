#need to denote pass moves some way
State = Tuple{UInt64, UInt64}

struct Policy
    move::UInt8
    policy::Float32
    state::State
end

#better to store sum
mutable struct Node
    visits::UInt64
    value::Float32
    child::Vector{Policy}
    #rename to successor
end

TT = Dict{State, Node}

#maybe change to AbstractFloat?
#actually only lambda * policy matters
function pubar(policy :: Vector{Float32}, value :: Vector{Float32}, lambda) Float32
    #perform binary search...
    mina = max((value + lambda * policy)...)
    maxa = max(value...) + lambda
    while true
        a = (maxa + mina) / 2
        v =  policy ./ (a .- value)
        val = lambda * sum(v)
        if val == 1 
            return lambda * v
        elseif val > 1
            mina = a
        elseif val < 1
            maxa = a
        end
    end
end

function pibar(dict :: TT, node :: State)
    node = dict[node]
    policy = (x -> x.policy).(node.child)
    value = ((x -> -x.value / x.visits)∘(x -> dict[x.state])).(node.child)
    return pibar (policy, value, node.visits ^ -0.5)
end

function expand(dict :: TT, node :: State, model)
    #do something...
end

function search(dict :: TT, root :: State)

end
