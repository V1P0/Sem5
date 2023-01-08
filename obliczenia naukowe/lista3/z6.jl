include("iters.jl")

function f1(x)
    return exp(1-x)-1
end

function f1p(x)
    return -exp(1-x)
end

function f2(x)
    return x*exp(-x)
end

function f2p(x)
    return (1-x)*exp(-x)
end
println("metoda bijekcji")
println(Iters.mbisekcji(f1, 0.5, 1.5, 10.0^(-5.0), 10.0^(-5.0)))
println(Iters.mbisekcji(f2, -1.0, 1.0, 10.0^(-5.0), 10.0^(-5.0)))
println("metoda Newtona")
println(Iters.mstycznych(f1, f1p, 1.0, 10.0^(-5.0), 10.0^(-5.0), 100))
println(Iters.mstycznych(f1, f1p, 1000.0, 10.0^(-5.0), 10.0^(-5.0), 100))
println(Iters.mstycznych(f2, f2p, 0.0, 10.0^(-5.0), 10.0^(-5.0), 100))
println(Iters.mstycznych(f2, f2p, 0.0, 10.0^(-5.0), 10.0^(-5.0), 100))
println(Iters.mstycznych(f2, f2p, 1.0, 10.0^(-5.0), 10.0^(-5.0), 100))
println(Iters.mstycznych(f2, f2p, 2.0, 10.0^(-5.0), 10.0^(-5.0), 100))
println("metoda siecznych")
println(Iters.msiecznych(f1, 1.0, 1.5, 10.0^(-5.0), 10.0^(-5.0), 100))
println(Iters.msiecznych(f2, 0.0, 0.5, 10.0^(-5.0), 10.0^(-5.0), 100))