function z4()
    x::Float64 = nextfloat(1.0)
    while x*(1/x) == 1
        x = nextfloat(x)
    end
    return x
end

println(z4())