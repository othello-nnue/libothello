# Simple Gumbel Alphazero with n = 2
# Don't even need to implement tree search

using Random

function select(policy, topk)
    gumbel = -log(Random.randexp(size(policy))) #for later use
    gumbeled = log(policy) + gumbel
    temp = partialsortperm(gumbeled, topk)
    return gumbel, temp
end

function move()
end

#give child_values=0 when unvisited
function completed_value(value, policy, visits, child_values)
    policy_sum = sum(policy .* (visits .> 0))
    value_sum = value + sum(visits)/policy_sum * sum(policy .* child_value)
    total_visits = 1 + sum(visits)
    return value_sum/total_visits
end

function policy_target()
end
