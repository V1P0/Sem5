X = [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957]
Y = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

function a(x, y, t::Type)
    s::t = 0
    for i in 1:5
        s = s + x[i] * y[i]
    end
    return s
end

function b(x, y, t::Type)
    s::t = 0
    for i in 5:-1:1
        s = s + x[i] * y[i]
    end
    return s
end

function c(x, y, t::Type)
    k = [a*b for (a, b) in zip(x, y)]
    pos = [a for a in k if a > 0]
    sort!(pos, rev=true)
    neg = [a for a in k if a < 0]
    sort!(neg)
    s::t = 0
    for a in pos
        s+=a
    end
    for a in neg
        s+=a
    end

    return s
end

function d(x, y, t::Type)
    k = [a*b for (a, b) in zip(x, y)]
    pos = [a for a in k if a > 0]
    sort!(pos)
    neg = [a for a in k if a < 0]
    sort!(neg, rev=true)
    s::t = 0
    for a in neg
        s+=a
    end
    for a in pos
        s+=a
    end

    return s
end

T = Float32

println(a(X, Y, T))
println(b(X, Y, T))
println(c(X, Y, T))
println(d(X, Y, T))

T = Float64

println(a(X, Y, T))
println(b(X, Y, T))
println(c(X, Y, T))
println(d(X, Y, T))