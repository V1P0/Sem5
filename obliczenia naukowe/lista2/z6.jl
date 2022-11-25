# Mateusz Jończak 261691
using Plots

function rek(x, c)
    return Float64(x^2+c)
end

function draw(x::Float64, c)
    start = x
    xs = [k for k in 1:40]
    ys::Vector{Float64} = [Float64(0) for _ in 1:40]
    for n in xs
        x = rek(x, c)
        ys[n] = x
    end
    savefig(plot(xs, ys, seriestype = :scatter, legend = false), "x$start-c$c.png")
end

draw(Float64(1), -2)
draw(Float64(2), -2)
draw(Float64(1.99999999999999),-2)
draw(Float64(1), -1)
draw(Float64(-1), -1)
draw(Float64(0.75), -1)
draw(Float64(0.25), -1)
