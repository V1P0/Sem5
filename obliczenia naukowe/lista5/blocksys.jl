"""
blocksys.jl

Module for solving linear system of equations with specific matrix structure.

# Author
- Mateusz Jończak
"""


module blocksys

using SparseArrays
"""
load_matrix(file_name::String) :: Tuple{SparseMatrixCSC{Float64, Int64}, Int, Int}

Loads matrix from file.

# Arguments
- `file_name::String`: name of file

# Returns
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `n::Int`: number of rows
- `l::Int`: size of block
"""
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
    # create arrays for sparse matrix
    rows    = Int64[]
    columns = Int64[]
    values  = Float64[]
    # read data from file
    for line in eachline(file)
        # split line
        row, column, value = split(line)
        # convert to int and push to arrays
        push!(rows,parse(Int64, row))
        push!(columns,parse(Int64, column))
        push!(values,parse(Float64, value))
    end
    # create sparse matrix
    A = sparse(rows, columns, values)
    # close file
    close(file)
    return A, n, l
end
"""
save_vector(file_name::String, x::Vector{Float64}) :: Nothing

Saves vector to file.

# Arguments
- `file_name::String`: name of file
- `x::Vector{Float64}`: vector
"""

function save_vector(file_name::String, x::Vector{Float64}) :: Nothing
    # open file
    file = open(file_name, "w")
    # write data to file
    for i in 1 : length(x)
        write(file, string(x[i]) * 
        if i != length(x) "\n" else "" end)
    end
    # close file
    close(file)
end
"""
load_vector(file_name::String) :: Tuple{Vector{Float64}, Int}

Loads vector from file.

# Arguments
- `file_name::String`: name of file

# Returns
- `b::Vector{Float64}`: vector
- `n::Int`: number of rows
"""
function load_vector(file_name::String) :: Tuple{Vector{Float64}, Int}
    # open file
    file = open(file_name)
    # read first line
    line = readline(file)
    # split line
    line = split(line)
    # convert to int
    n = parse(Int, line[1])
    # create vector
    b = zeros(n)
    # read data from file
    for (i, line) in enumerate(eachline(file))
        # parse to float and push to vector
        b[i] = parse(Float64, line)
    end
    # close file
    close(file)
    return b, n
end

"""

calculate_b(A::SparseMatrixCSC{Float64,Int64}, n::Int64, l::Int64) :: Vector{Float64}

Calculates b = A * ones(n).

time complexity: O(n*l).

# Arguments
- `A::SparseMatrixCSC{Float64,Int64}`: matrix
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `b::Vector{Float64}`: vector
"""
function calculate_b(A::SparseMatrixCSC{Float64,Int64}, n::Int64, l::Int64) :: Vector{Float64}
    b = zeros(Float64, n)

    for i in 1 : n
        for j in max(1, i - (2 + l)) : min(n, i + l)
            b[i] += A[i, j]
        end
    end
        
    return b
end


"""

partialPivot(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64) :: Vector{Int64}

generate pivot table for partial pivoting.

time complexity: O(n*l).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `pivot::Vector{Int64}`: pivot table
"""

function partialPivot(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64) :: Vector{Int64}

    pivot = [x for x in 1 : n]

    for k in 1:Int(n/l)

        for p in (k-1)*l+1 : k*l
            curr = abs(A[pivot[p], p])

            max_value = curr
            max_index = pivot[p]
            search_end = k*l
            for i in (p+1) : search_end
                if i > n
                    break
                end
                potential = A[pivot[i], p]
                if abs(potential) > max_value
                    max_value = abs(potential)
                    max_index = pivot[i]
                end
            end
            if max_value > curr
                pivot[p], pivot[max_index] = pivot[max_index], pivot[p]
            end

        end

    end

    return pivot

end
"""

decomposeIntoLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Tuple{SparseMatrixCSC{Float64, Int64}, Vector{Float64}, Vector{Int64}}

decomposes matrix A into LU.

time complexity: O(n*l).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `LU::SparseMatrixCSC{Float64, Int64}`: LU matrix
- `bprime::Vector{Float64}`: vector
- `pivot::Vector{Int64}`: pivot table
"""
function decomposeIntoLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64, pivot::Vector{Int64} = [x for x in 1:n]) :: Tuple{SparseMatrixCSC{Float64, Int64}, Vector{Float64}}


    LU = copy(A)

    bprime = copy(b)

    for k in 1:Int64(n/l)
        for p in (k-1)*l+1 : k*l

            for i in (p+1) : k*l + l
                if i > n
                    break
                end
                lᵢₚ = LU[pivot[i], p] / LU[pivot[p], p]

                for j in p : k*l + l
                    if j > n
                        break
                    end
                    LU[pivot[i], j] = LU[pivot[i], j] - lᵢₚ * LU[pivot[p], j]
                end

                bprime[pivot[i]] = bprime[pivot[i]] - lᵢₚ * bprime[pivot[p]]

                LU[pivot[i], p] = lᵢₚ
            end
        end
    end

    return LU, bprime

end

"""

solveUpperTriangularMatrix(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64, pivot::Vector{Int64} = [x for x in 1:n]) :: Vector{Float64}

solves Ax=b.

time complexity: O(n*l).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block
- `pivot::Vector{Int64}`: pivot table

# Returns
- `x::Vector{Float64}`: solution
"""

function solveUpperTriangularMatrix(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64, pivot::Vector{Int64} = [x for x in 1:n]) :: Vector{Float64}

    x = [0.0 for _ in 1:n]

    for k in Int64(n/l) : -1 : 1
        for p in k*l : -1 : (k-1)*l+1

            tmp = b[pivot[p]]
            for i in (p+1) : (k*l + l)
                if i > n
                    break
                end
                tmp -= x[pivot[i]] * A[pivot[p], i]
            end
            x[pivot[p]] = tmp/A[pivot[p], p]

        end
    end

    return x

end

"""

solveFromLU(LU, b::Vector, n::Int, l::Int, pivot::Vector = [x for x in 1:n])::Array

solves LU*x=b

# Arguments:
- `LU` — LU decomposition of a given matrix
- `b` — the `b` vector
- `n` — the size of the matrix
- `l` — size of block
- `pivot` — pivot table

# Returns
- `x::Vector{Float64}`: solution
"""



function solveFromLU(LU, b::Vector, n::Int, l::Int, pivot::Vector = [x for x in 1:n])::Array


    y = zeros(n)

    for k in 1:Int(n/l)
        for p in (k-1)*l+1 : k*l

            tmp = b[pivot[p]]
            for i in (p-1) : -1 : (k-1)*l - l
                if i <= 0
                    break
                end
                tmp -= y[pivot[i]] * LU[pivot[p], i]
            end

            y[pivot[p]] = tmp

        end
    end

    return solveUpperTriangularMatrix(LU, y, n, l, pivot)

end

"""
gaussianElimination(A, b::Vector, n::Int, l::Int, pivot::Vector = [x for x in 1:n])::Array

Solves the `Ax = b` equation.

# Arguments:
- `A` — the input matrix
- `b` — the `b` vector
- `n` — the size of the matrix
- `l` — size of block
- `pivot` — pivot table
# Returns
— the `x` output vector (solution to the `Ax = b` equation)
"""

function gaussianElimination(A, b::Vector, n::Int, l::Int, pivot::Vector = [x for x in 1:n])::Array

   LU, bprime = decomposeIntoLU(A, b, n, l, pivot)

    return solveUpperTriangularMatrix(LU, bprime, n, l, pivot)

end

"""

solveGauss(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Vector{Float64}

Solves Ax=b with specific A matrix structure.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `x_n::Vector{Float64}`: solution
"""
function solveGauss(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Vector{Float64}
   return gaussianElimination(A, b, n, l)
end

"""

solveGaussPivoted(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Vector{Float64}

Solves Ax=b with specific A matrix structure and pivoting.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `x_n::Vector{Float64}`: solution
"""

function solveGaussPivoted(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64)
    pivot = partialPivot(A, n, l)
    return gaussianElimination(A, b, n, l, pivot)
end

"""

solveGaussLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Vector{Float64}

Solves Ax=b with specific A matrix structure and LU decomposition.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `x_n::Vector{Float64}`: solution 
"""

function solveGaussLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64)
    LU, _ = decomposeIntoLU(A, b, n, l)
    return solveFromLU(LU, b, n, l)

end

"""

solveGaussPivotedLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Vector{Float64}

Solves Ax=b with specific A matrix structure, pivoting and LU decomposition.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `x_n::Vector{Float64}`: solution
"""


function solveGaussPivotedLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64)
    pivot = partialPivot(A, n, l)
    LU, _ = decomposeIntoLU(A, b, n, l, pivot)
    return solveFromLU(LU, b, n, l, pivot)

end


end