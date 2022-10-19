gamma = Dict()

function s(word, suf)
    n = length(suf)
    return suf != word[end-n+1:end]
end

function ctf(p, q, a, m)
    if haskey(gamma, (q, a))
        return gamma[(q, a)]
    end
    k = min(m, q+1)

    while s(push!(p[1:q], a), p[1:k])
        k-=1
    end
    gamma[(q, a)] = k
    return k
end

function fam(t, p)
    n, m = length(t), length(p)
    res = []
    q = 0
    for (i, a) in Iterators.enumerate(t)
        q = ctf(p, q, a, m)
        if q == m
            res = push!(res, i-m)
        end
    end
    return res
end

function main()
    if length(ARGS) < 2
        println("Wywoływanie: julia FA.jl <wzorzec> <nazwa pliku>")
        return
    end

    pattern = collect(ARGS[1])
    txt = String(read(ARGS[2]))
    r = fam(txt, pattern)
    println("results:\n"*join(r, ", "))
end

if abspath(PROGRAM_FILE) == @__FILE__

   main()

end