# Mateusz Jończak 261691
using LinearAlgebra
include("hilb.jl")
include("matcond.jl")
using Printf

function z3(A)
    x = ones(size(A)[1])
    b = A*x

    gauss = A\b
    invert = inv(A)*b

    return gauss, invert
end

function err(x1, x2)
    return norm(x1-x2)/norm(x1)
end

function h()
    for n in 2:20
        A = hilb(n)
        g, i = z3(A)
        println(
            n," & ",
            cond(A)," & ",
            rank(A)," & ",
            err(ones(n), g)," & ",
            err(ones(n), i), " \\\\"
        )
    end
end

function r()
    for n in [5, 10, 20]
        for c in [0,1,3,7,12,16]
            A = matcond(n, Float64(10^c))
            g, i = z3(A)
            println(
                n," & ",
                "\$10^{", c, "}\$ & ",
                cond(A)," & ",
                rank(A)," & ",
                err(ones(n), g)," & ",
                err(ones(n), i), " \\\\"
            )
        end
    end
end

r()