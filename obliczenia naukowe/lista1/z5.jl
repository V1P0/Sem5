X32::Vector{Float32} = [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957]
Y32::Vector{Float32} = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

X64::Vector{Float64} = [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957]
Y64::Vector{Float64} = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

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
    d::t = 0
    s::t = 0
    for a in pos
        d+=a
    end
    for a in neg
        s+=a
    end

    return d+s
end

function d(x, y, t::Type)
    k = [a*b for (a, b) in zip(x, y)]
    pos = [a for a in k if a > 0]
    sort!(pos)
    neg = [a for a in k if a < 0]
    sort!(neg, rev=true)
    d::t = 0
    s::t = 0
    for a in pos
        d+=a
    end
    for a in neg
        s+=a
    end

    return d+s
end
