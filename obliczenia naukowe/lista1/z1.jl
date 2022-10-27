# Mateusz Jończak 261691

# x - typ zmiennej dla której liczymy epsilon maszynowy
function my_eps(x::Type)
    eps::x = 1
    while 1+eps/2 > 1
        eps = eps/2
    end
    return eps
end
# x - typ zmiennej dla której liczymy eta
function my_eta(x::Type)
    e::x = 1
    while e/2 > 0
        e = e/2
    end
    return e
end
# x - typ zmiennej dla której liczymy MAX
function my_max(x::Type)
    a::x= 1
    while isfinite(a*2)
        a = a*2
    end
    g::x = a/2
    while isfinite(a+g)
        a = a+g
        g = g/2
    end
    return a
end


