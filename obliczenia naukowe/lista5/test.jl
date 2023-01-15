include("blocksys.jl")
include("matrixgen.jl")

using .blocksys
using LinearAlgebra

function test()
    results_gauss = open("results_gauss.csv", "w")
    write(results_gauss, "n;d;s;m")
    results_pivot = open("results_pivot.csv", "w")
    write(results_pivot, "n;d;s;m")
    results_lu = open("results_lu.csv", "w")
    write(results_lu, "n;d;s;m")
    results_pivot_lu = open("results_pivot_lu.csv", "w")
    write(results_pivot_lu, "n;d;s;m")
    for size in 100:2000:10100
        sum_d = [0.0, 0.0, 0.0, 0.0]
        sum_s = [0.0, 0.0, 0.0, 0.0]
        sum_m = [0.0, 0.0, 0.0, 0.0]
        for k in 1:100
            matrixgen.blockmat(size, 10, 10.0, "A.txt")
            A, n, l = blocksys.load_matrix("A.txt")
            b = blocksys.calculate_b(A, n, l)
            x, s, m = @timed blocksys.solveGauss(A, b, n, l)
            d = norm(ones(n) - x)
            sum_d[1] += d
            sum_s[1] += s
            sum_m[1] += m
            A, n, l = blocksys.load_matrix("A.txt")
            b = blocksys.calculate_b(A, n, l)
            x, s, m = @timed blocksys.solveGaussPivoted(A, b, n, l)
            d = norm(ones(n) - x)
            sum_d[2] += d
            sum_s[2] += s
            sum_m[2] += m
            A, n, l = blocksys.load_matrix("A.txt")
            b = blocksys.calculate_b(A, n, l)
            x, s, m = @timed blocksys.solveGaussLU(A, b, n, l)
            d = norm(ones(n) - x)
            sum_d[3] += d
            sum_s[3] += s
            sum_m[3] += m
            A, n, l = blocksys.load_matrix("A.txt")
            b = blocksys.calculate_b(A, n, l)
            x, s, m = @timed blocksys.solveGaussPivotedLU(A, b, n, l)
            d = norm(ones(n) - x)
            sum_d[4] += d
            sum_s[4] += s
            sum_m[4] += m
            print("\r $(size+k) / 10100")
        end
        for i in 1:4
            sum_d[i] /= 100
            sum_s[i] /= 100
            sum_m[i] /= 100
        end
        write(results_gauss, "\n$(size);$(sum_d[1]);$(sum_s[1]);$(sum_m[1])")
        write(results_pivot, "\n$(size);$(sum_d[2]);$(sum_s[2]);$(sum_m[2])")
        write(results_lu, "\n$(size);$(sum_d[3]);$(sum_s[3]);$(sum_m[3])")
        write(results_pivot_lu, "\n$(size);$(sum_d[4]);$(sum_s[4]);$(sum_m[4])")
    end
    close(results_gauss)
    close(results_pivot)
    close(results_lu)
    close(results_pivot_lu)
end

test()
