# Mateusz Jończak 261691

# funkcja f z treści zadania
function f(x::Float64)
    return sin(x)+cos(3*x)
end

# funkcja obliczająca przybliżoną pochodną funkcji fun w punkcie x
function d(fun::Function, x::Float64, h::Float64)
    return (fun(x+h)-fun(x))/h
end

# pochodna funkcji f z zadania
function f_prim(x::Float64)
    return cos(x)-3*sin(3*x)
end

for (h, n) in [(2.0^-n, n) for n in 0:2:54]
    println("\$2.0^{-$n}\$ & ", d(f, 1.0, h), " & ", (abs(f_prim(1.0)-d(f, 1.0, h))), " & ", 1+h, "\\\\")
end