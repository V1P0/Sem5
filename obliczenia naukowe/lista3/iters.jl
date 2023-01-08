module Iters

B_Z = 2^(-2.0^32)

function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
    u = f(a)
    v = f(b)
    e = b - a

    if sign(u) == sign(v)
        return (a, u, 0, 1);
    end

    k = 0
    c = 0
    w = 0

    while true
        e = e/2
        c = a + e
        w = f(c)

        if abs(e) < delta || abs(w) < epsilon
            return (c, w, k, 0)
        end

        if sign(w) != sign(u)
            b = c
            v = w
        else
            a = c
            u = w
        end
        k+=1
    end
end


function mstycznych(f, pf, x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)

    v = f(x0)

    if abs(v) < epsilon
        return (x0, v, 0, 0)
    end

    xn = x0
    xn1 = x0

    k = 0
    for k in 1:maxit
        xn1 = xn - (v/pf(xn))
        v = f(xn1)

        if abs(pf(xn)) < B_Z || isinf(abs(pf(xn)))
            return (xn, f(xn), k, 2)
        end

        if abs(xn1 - xn) < delta || abs(v) < epsilon
            return (xn1, v, k, 0)
        end
        xn = xn1
    end
    return (xn1, v, k, 1)
end

function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxint::Int)
    v = f(x0)
    w = f(x1)
    a = x0
    b = x1

    k = 0
    for k in 0:maxint
        if abs(v) > abs(w)
            a,b = b,a
            v,w = w,v
        end
        d = (b-a)/(w-v)
        b = a
        w = v
        a = a - d * v
        v = f(a)
        
        if abs(v) < epsilon || abs(b-a) < delta
            return (a, v, k, 0)
        end
    end
    return (a, v, k, 1)
end

end