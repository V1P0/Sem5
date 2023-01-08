include("iters.jl")

r, fr, k, err =Iters.mbisekcji(
    x -> 3x - exp(x),
    0.0,
    1.0,
    10.0^(-4.0),
    10.0^(-4.0)
)

println(
    "[0;1] & ",
    r," & ",
    fr," & ",
    k," & ",
    err
)

r, fr, k, err =Iters.mbisekcji(
    x -> 3x - exp(x),
    1.0,
    2.0,
    10.0^(-4.0),
    10.0^(-4.0)
)

println(
    "[1;2] & ",
    r," & ",
    fr," & ",
    k," & ",
    err
)