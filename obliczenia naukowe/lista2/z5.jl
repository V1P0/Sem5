# Mateusz Jończak 261691
function rec(x, r, prec)
    return prec(x+prec(r*prec(x*(1-x))))
end



function p1()
    r = 3
    p = Float32(0.01)
    pm = p
    for n in 1:40

        p = rec(p, r, Float32)
        pm = rec(pm, r, Float32)
        if n == 10
            pm = floor(pm, digits=3)
        end
        println(n, " & ", p, " & ", pm, "\\\\")
    end
end

function p2()
    r = 3
    p32 = Float32(0.01)
    p64 = Float64(0.01)
    for n in 1:40

        p32 = rec(p32, r, Float32)
        p64 = rec(p64, r, Float64)
        println(n, " & ", p32, " & ", p64, "\\\\")
    end
end

p2()