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

gauss(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64)

In-place Gauss elimination.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block
"""
function gauss(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64) :: Nothing
    for k in 1 : n -1
        for i in k + 1 : min(n, k + l + 1)
            z = A[i, k] / A[k, k]
            A[i, k] = 0.0

            for j in k + 1 : min(n, k + l + 1)
                A[i, j] -= z * A[k, j]
            end
            
            b[i] -= z* b[k]
        end
    end
end

"""

gaussLU(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)

Gauss elimination with LU decomposition.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `L::SparseMatrixCSC{Float64, Int64}`: lower triangular matrix
"""
function gaussLU(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)
    L = spzeros(n, n)

    for k in 1 : n - 1
        L[k, k] = 1.0
        for i in k + 1 : min(n, k + l + 1)
            z = A[i, k] / A[k, k]
            L[i, k] = z
            A[i, k] = 0.0
            for j in k + 1 : min(n, k + l)
                A[i, j] -=  z * A[k, j]
            end
        end
    end
    
    L[n, n] = 1
    
    return L
end

    
"""

gaussPivoted(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64)

Gauss elimination with pivoting.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `b::Vector{Float64}`: vector
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `perm::Vector{Int64}`: permutation vector
"""

function gaussPivoted(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, l::Int64)
    perm = collect(1 : n)

    for k in 1 : n - 1
        maxInColValue = 0
        maxInColIndex = 0

        for i in k : min(n, k + l + 1)
            if abs(A[perm[i], k]) > maxInColValue
                maxInColValue = abs(A[perm[i], k])
                maxInColIndex = i
            end
        end

        perm[maxInColIndex], perm[k] = perm[k], perm[maxInColIndex]

        for i in k + 1 : min(n, k + l + 1)
            z = A[perm[i], k] / A[perm[k], k]
            A[perm[i], k] = 0.0

            for j in k + 1 : min(n, k + 2 * l)
                A[perm[i], j] -= z * A[perm[k], j]
            end
            b[perm[i]] -= z * b[perm[k]]
        end
    end

    return perm
end

"""

gaussPivotedLU(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)

Gauss elimination with pivoting and LU decomposition.

time complexity: O(n*l^2).

# Arguments
- `A::SparseMatrixCSC{Float64, Int64}`: matrix
- `n::Int64`: number of rows
- `l::Int64`: size of block

# Returns
- `L::SparseMatrixCSC{Float64, Int64}`: lower triangular matrix
- `perm::Vector{Int64}`: permutation vector
"""

function gaussPivotedLU(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)
    L = spzeros(n, n)

    perm = collect(1 : n)

    for k in 1 : n - 1
        maxInColValue = 0
        maxInColIndex = 0

        for i in k : min(n, k + l + 1)
            if abs(A[perm[i], k]) > maxInColValue
                maxInColValue = abs(A[perm[i], k])
                maxInColIndex = i
            end
        end
        
        perm[maxInColIndex], perm[k] = perm[k], perm[maxInColIndex]

        for i in k + 1 : min(n, k + l + 1)
            z = A[perm[i], k] / A[perm[k], k]

            L[perm[i], k] = z
            A[perm[i], k] = 0.0

            for j in k + 1 : min(n, k + 2 * l)
                A[perm[i], j] -= z * A[perm[k], j]
            end
        end
    end

    return L, perm
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
    gauss(A, b, n, l)
    
    x_n = zeros(Float64, n)

    for i in n:-1:1
        x_i = 0
        for j in i + 1 : min(n, i + l)
            x_i += A[i, j] * x_n[j]
        end
        x_n[i] = (b[i] - x_i) / A[i, i]
    end

    return x_n
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
    perm = gaussPivoted(A, b, n, l)

    x_n = zeros(Float64, n)

    for k in 1 : n-1
        for i in k + 1 : min(n, k + 2 * l)
            b[perm[i]] -= A[perm[i], k] * b[perm[k]]
        end
    end

    for i in n:-1:1
        x_i = 0
        for j in i + 1 : min(n, i + 2 * l)
            x_i += A[perm[i], j] * x_n[j]
        end
        x_n[i] = (b[perm[i]] - x_i) / A[perm[i], i]
    end

    return x_n
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
    L = gaussLU(A, n, l)
        
    x_n = zeros(Float64, n)

    for k in 1 : n - 1
        for i in k + 1 : min(n, k + l + 1)
            b[i] -= L[i, k] * b[k]
        end
    end
    
    for i in n : -1 : 1
        x_i = 0
        for j in i + 1 : min(n, i + l)
            x_i += A[i, j] * x_n[j]
        end
        x_n[i] = (b[i] - x_i) / A[i, i]
    end

    return x_n
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
    L, perm = gaussPivotedLU(A, n, l)
    
    x_n = zeros(Float64, n)

    for k in 1 : n - 1
        for i in k + 1 : min(n, k + l + 1)
            b[perm[i]] -= L[perm[i], k] * b[perm[k]]
        end
    end
    
    for i in n : -1 : 1
        x_i = 0
        for j in i + 1 : min(n, i + 2 * l)
            x_i += A[perm[i], j] * x_n[j]
        end
        x_n[i] = (b[perm[i]] - x_i) / A[perm[i], i]
    end

    return x_n
end


end