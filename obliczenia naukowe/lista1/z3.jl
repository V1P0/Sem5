function z3(start::Float64, finish::Float64, delta::Float64, increment::Float64)
    while start < finish
        if nextfloat(start)-start != delta
            return false
        end
        start += increment
    end
    return true
end

println(z3(1.0, 2.0, 2^-52, 0.01))