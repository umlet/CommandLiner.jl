module Tably


import ..Iter: map_


struct Cell
    s::String
    orient::Symbol
    function Cell(s::AbstractString, orient=:left)  # or :right, :center
        @assert orient in (:left, :l, :right, :r)   # TODO :center
        return new(s, orient)
    end
end
Base.length(x::Cell) = length(x.s)
function pad(x::Cell, n::Int64=0)
    x.orient in (:left, :l)   &&  return rpad(x.s, n)
    x.orient in (:right, :r)  &&  return lpad(x.s, n)
    @assert false
end

struct MiniRow{N}
    cells::NTuple{N, Cell}
    function MiniRow{N}(cells::AbstractVector{Cell}) where {N}
        @assert typeof(N) === Int64
        return new(NTuple{N,Cell}(cells))
    end
end
function makerow(ss::AbstractVector{<:AbstractString}, orients::AbstractVector{Symbol}=Symbol[])
    N = length(ss)
    if length(orients) == N
    elseif length(orients) == 0
        orients = fill(:left, N)
    else
        error("invalid orient setting")
    end
    return MiniRow{N}(Cell.(ss, orients))
end
maketable(N::Int64) = MiniRow{N}[]

# mytable = Vector{MiniRow{3}}()
# push!(mytable, minirow(["safasdasd.jpg", "1587", "(13500 Kb)"], [:l,:r,:r]))
# push!(mytable, minirow(["safasdsa.jpg", "1556", "(1500 Kb)"], [:l,:r,:r]))
# push!(mytable, minirow(["safs.jpg", "12", "(135 Kb)"], [:l,:r,:r]))
# push!(mytable, minirow(["saf.jpg", "1", "(4533 Kb)"], [:l,:r,:r]))
# push!(mytable, minirow(["safaasasdasdsdasd.jpg", "1587", "(13500 Kb)"], [:l,:r,:r]))
# push!(mytable, minirow(["sasa.jpg", "145556", "(13500 Kb)"], [:l,:r,:r]))
# push!(mytable, minirow(["sa", "1232", "(1 Gb)"], [:l,:r,:r]))
# push!(mytable, minirow(["s.jpg", "11", "(13 Kb)"], [:l,:r,:r]))

# using Base.Iterators
# Cs = partition(mytable, 3) |> map_(collect) |> collect
# C = Cs[1]



function joininterleave(ss::AbstractVector{<:AbstractString}, infixes::AbstractVector{<:AbstractString})
    if length(infixes) != length(ss) - 1
        error("invalid infixes: ss=$(ss); infixes=$(infixes)")
    end
    #push!(infixes, "")  # XXX compiler error if push! uses original 'infixes' -- push! seems to be executed before the check above, which then fails
    infixes2 = [infixes ; ""]
    return join(s*infix for (s,infix) in zip(ss, infixes2))
end

function tostrs(C::AbstractVector{MiniRow{N}}; prefix::AbstractString="", infix::Union{AbstractString, AbstractVector{<:AbstractString}}=" ", suffix::AbstractString="") where {N}
    RET = String[]
    maxlengths_byrow = C |> map_(x->length.(x.cells)) |> collect
    #maxlengths = ( maximum(x) for x in zip(maxlengths_byrow...) )
    maxlengths = reduce((x,y)->max.(x,y), maxlengths_byrow)
    for row in C
        ss_row = pad.(row.cells, maxlengths)
        middle = infix isa AbstractString  ?  join(ss_row, infix)  :  joininterleave(ss_row, infix)
        s = string(prefix, middle, suffix)
        push!(RET, s)
    end
    return RET
end

# arrays must be non-empty; only last one may be shorter
function tostrs(Cs::AbstractVector{<:AbstractVector{<:MiniRow}}; firstprefix::AbstractString="", innersuffix::AbstractString=" ", innerprefix::AbstractString=" ", lastsuffix::AbstractString="", rowinfix::Union{AbstractString, AbstractVector{<:AbstractString}}=" ", colinfix::AbstractString="|")
    sss = Vector{Vector{String}}()
    for (i,C) in enumerate(Cs)
        prefix = i == firstindex(Cs)  ?  firstprefix  :  innerprefix
        suffix = i == lastindex(Cs)   ?  lastsuffix   :  innersuffix
        ss = tostrs(C; prefix=prefix, infix=rowinfix, suffix=suffix)
        push!(sss, ss)
    end

    RET = String[]

    for i in eachindex(sss[1])
        ss_RET = String[]
        for ss in sss
            isassigned(ss, i)  &&  push!(ss_RET, ss[i])
        end
        push!(RET, join(ss_RET, colinfix))
    end
    return RET
end


function stringify(C::AbstractVector{<:MiniRow}; n::Int64=0, kwargs...)  # n>0: row char width; n=0: autowidth; n<0: |n| cols
    N = length(C)
    N == 0  &&  return String[]  # partition below now always works

    if n < 0
        ncols = -n
        npart = N % ncols == 0  ?  div(N, ncols)  :  div(N, ncols) + 1
        Cs = Base.Iterators.partition(C, npart) |> map_(collect) |> collect
        return tostrs(Cs; kwargs...)
    end

    if n == 0
        n = displaysize(stdout)[2]
        n <= 0  &&  ( n = 80 )
    end

    # now: flow to fit n char width
    RET::Vector{String} = []
    for ncols in 1:N
        npart = N % ncols == 0  ?  div(N, ncols)  :  div(N, ncols) + 1
        Cs = Base.Iterators.partition(C, npart) |> map_(collect) |> collect
        ss = tostrs(Cs; kwargs...)
        if ncols == 1  # first iteration; always valid
            RET = ss
            continue
        end
        if length(ss[1]) <= n  # still valid
            RET = ss
            continue
        end
        if length(ss[1]) > n
            return RET
        end
    end
    return RET
end




include("tably.jl_exports")
end # module

