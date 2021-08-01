#need to denote pass moves some way
#maybe use mininmax Q value
State = Tuple{UInt64, UInt64}

struct Policy
    move::UInt8
    policy::Float32
    state::State
end

#better to store sum
mutable struct Node
    visits::UInt64
    original_Q::Float32
    value::Float32
    child::Vector{Policy}
    #rename to successor
end

TT = Dict{State, Node}

#maybe change to AbstractFloat?
#actually only lambda * policy matters
function pibar(policy :: Vector{Float32}, value :: Vector{Float32}, lambda) Float32
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

function sample(p::Float32, prob :: Vector{Float32}, vector)
    for (pr, el) in zip(prob, vector)
        if pr > p
            return el
        else
            p -= pr
        end
    end
end

function sample(dict::TT, node::State)
    return sample(pibar(dict, node), dict[node].child)
end

#because DAG/RAVE
#better to update all child
#there are typically 5~10 child nodes anyway
function update(dict::TT, node::State)
    node = dict[node]
    node.visits = 1 + sum((x -> dict[x.state].visits)(node.child))
    node.value = node.original_Q + sum((x -> dict[x.state].value)(node.child))
end

function search(dict :: TT, root :: State, expand)
    path = [root]
    while root in keys(dict)
        root = sample(dict, node) 
        push!(path, node)
    end
    expand(dict, root)
    reverse!(path)
    for node in path
        update(dict, nodes)
    end
    #update nodes in path just in backwards
end
