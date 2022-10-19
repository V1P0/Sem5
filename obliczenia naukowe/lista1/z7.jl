function f(x::Float64)
    return sin(x)+cos(3*x)
end

function d(fun::Function, x::Float64, h::Float64)
    return (fun(x+h)-fun(x))/h
end

function f_prim(x::Float64)
    return cos(x)-3*sin(3*x)
end

for h in [2.0^-n for n in 0:54]
    println("h = ", h)
    println("1+h = ", 1+h)
    println("|f_prim - ~f_prim| = ", abs(f_prim(1.0)-d(f, 1.0, h)))
end