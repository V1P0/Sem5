module blocksys

using SparseArrays

function load_matrix(file_name::String) :: Tuple{SparseMatrixCSC{Float64, Int64}, Int, Int}
    # open file
    file = open(file_name)
    # read first line
    line = readline(file)
    # split line
    line = split(line)
    # convert to int
    n = parse(Int, line[1])
    l = parse(Int, line[2])
    A = spzeros(n, n)
    while !eof(file)
        line = readline(file)
        line = split(line)
        i = parse(Int, line[1])
        j = parse(Int, line[2])
        A[i, j] = parse(Float64, line[3])
    end
    close(file)
    return A, n, l
end

function load_vector(file_name::String) :: Tuple{Vector{Float64}, Int}
    # open file
    file = open(file_name)
    # read first line
    line = readline(file)
    # split line
    line = split(line)
    # convert to int
    n = parse(Int, line[1])
    b = zeros(n)
    for i = 1:n
        line = readline(file)
        b[i] = parse(Float64, line)
    end
    close(file)
    return b, n
end




end