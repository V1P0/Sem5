
gamma = Dict()

function cmf(p)
    m = length(p)
    pf = Array(1:m)
    pf[1] = 0
    k = 0
    for q in 2:m
        while k > 0 && p[k+1] != p[q]
            k = pf[k]
        end
        if p[k+1] == p[q]
            k = k+1
        end
        pf[q] = k
    end
    return pf
end


function kmpm(t, p)
    n, m = length(t), length(p)
    res = []
    q = 0
    pf = cmf(p)
    for (i, a) in Iterators.enumerate(t)
        while q > 0 && p[q+1] != a
            q = pf[q]
        end
        if p[q+1] == a
            q = q+1
        end
        if q == m
            res = push!(res, i-m)
            q = pf[q]
        end
    end
    return res
end

function main()
    if length(ARGS) < 2
        println("Wywoływanie: julia KMP.jl <wzorzec> <nazwa pliku>")
        return
    end

    pattern = collect(ARGS[1])
    txt = String(read(ARGS[2]))
    r = kmpm(txt, pattern)
    println("results:\n"*join(r, ", "))
end

if abspath(PROGRAM_FILE) == @__FILE__

   main()

end