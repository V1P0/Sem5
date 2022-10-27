# Mateusz Jończak 261691

# x - typ zmiennej dla której liczymy epsilon maszynowy metodą kahana
function kahan(x::Type)
    a::x = 3*(4/x(3)-1)-1
    return a
end