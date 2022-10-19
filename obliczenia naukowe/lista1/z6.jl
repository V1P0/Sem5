function f(x::Float64)
    return sqrt(x^2+1)-1
end

function g(x::Float64)
    return x^2/(sqrt(x^2+1)+1)
end


for x in [8.0^-a for a in 1:10]
    println("f(", x, ") = ", f(x))
    println("g(", x, ") = ", g(x), "\n")
end