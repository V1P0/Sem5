include("blocksys.jl")

using .blocksys

A = blocksys.load_matrix("test_data/Dane16_1_1/A.txt")
b = blocksys.load_vector("test_data/Dane16_1_1/b.txt")
print(A*b)