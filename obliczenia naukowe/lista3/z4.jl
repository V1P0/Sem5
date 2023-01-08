include("iters.jl")
r, fr, k, err =Iters.mbisekcji(
    x -> sin(x) - (x/2.0)^2.0,
    1.5,
    2.0,
    (10.0^(-5.0))/2.0,
    (10.0^(-5.0))/2.0
)

println(
    "1 & ",
    r," & ",
    fr," & ",
    k," & ",
    err
)

r, fr, k, err = Iters.mstycznych(
    x -> sin(x) - (x/2.0)^2.0,
    x -> cos(x) - x/2.0,
    1.5,
    (10.0^(-5.0))/2.0,
    (10.0^(-5.0))/2.0,
    200
)

println(
    "2 & ",
    r," & ",
    fr," & ",
    k," & ",
    err
)

r, fr, k, err = Iters.msiecznych(
    x -> sin(x) - (x/2.0)^2.0,
    1.0,
    2.0,
    (10.0^(-5.0))/2.0,
    (10.0^(-5.0))/2.0,
    200
)

println(
    "3 & ",
    r," & ",
    fr," & ",
    k," & ",
    err
)