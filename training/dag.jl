dict = Dict{Tuple{UInt64, UInt64}, Node}()

mutable struct Node
    visits::UInt64
    value::Float32
    child::Vector{Policy}
end

struct Policy
    move::UInt8
    policy::Float32
    state::Tuple{UInt64,UInt64}
end
