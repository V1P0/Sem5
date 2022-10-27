# Mateusz Jończak 261691

#funkcja obliczająca sqrt(x^2+1)-1
function f(x::Float64)
    return sqrt(x^2+1)-1
end

#funkcja obliczająca x^2/(sqrt(x^2+1)+1)
function g(x::Float64)
    return x^2/(sqrt(x^2+1)+1)
end


for x in [-(a*2) for a in 1:15]
    println("\$8^{$x}\$", " & ", f(8.0^x), " & ", g(8.0^x), "\\\\")
end