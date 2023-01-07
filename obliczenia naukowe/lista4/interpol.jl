# Mateusz Jończak 261691

module Interpol

using PyPlot

function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
    if length(x) != length(f)
        error("Vectors x and f must have the same length")
    end
    len = length(x)

    tmp = copy(f)
    output = Vector{Float64}()
    push!(output, tmp[1])

    for p in (len-1):-1:1
        for k in 1:p
            a = (tmp[k+1] - tmp[k])
            b = (x[k + (len-p)] - x[k])
            tmp[k] = a/b
        end
        push!(output, tmp[1])

    end

    return output

end

function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)

    if length(x) != length(fx)
        error("Vectors x and fx must have the same length")
    end

    n = length(x)

    w = (z,k) -> (k == n ?
                  fx[n]
                : fx[k] + (z - x[k]) * w(z,k+1))

    return w(t, 1)

end

function naturalna(x::Vector{Float64}, fx::Vector{Float64})

    if length(x) != length(fx)
        error("Vectors x and fx must have the same length")
    end

    n = length(x)

    coefficients = [fx[n]]

    for k in (n-1):-1:1

        new_b0 = -coefficients[1] * x[k] + fx[k]
        new_coefficients = vcat([new_b0], coefficients)

        for m in n-k:-1:2
            new_coefficients[m] = coefficients[m-1] - coefficients[m] * x[k]
        end

        coefficients = new_coefficients

    end

    return coefficients

end

function rysujNnfx(f, a::Float64, b::Float64, n::Int)

    h = (b-a)/n
    res = h/10
    x = vec([i for i in a:h:b])

    fx = ilorazyRoznicowe(x, vec([f(i) for i in x]))

    XA = a:res:b

    YA_f = [f(i) for i in XA]
    YA_N = [warNewton(x, fx, i) for i in XA]

    plot(XA, YA_N, label="Newton")
    plot(XA, YA_f, label="f(x)")
    legend()

end

function rysujNnfxDiff(f, a::Float64, b::Float64, n::Int)

    h = (b-a)/n
    res = h/10
    x = vec([i for i in a:h:b])

    fx = ilorazyRoznicowe(x, vec([f(i) for i in x]))

    XA = a:res:b

    YA_f = [f(i) for i in XA]
    YA_N = [warNewton(x, fx, i) for i in XA]

    plot(XA, YA_N-YA_f, label="różnica")
    legend()

end

end