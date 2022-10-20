function z3(start::Float64, finish::Float64, increment::Float64)
    a = b = nextfloat(start)-start
    start += increment
    while start < finish
        v = nextfloat(start)-start
        a = min(a, v)
        b = max(a, v)
        start += increment
    end
    println("min = $a, max = $b equal = $(a==b)")
end
