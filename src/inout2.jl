#!/usr/bin/env julia

using OrderedCollections

function _eachline(f;   skipcomments::Bool=true, skipempty::Bool=true)
    iscomment(s::AbstractString) = startswith(s, "#")

    itr = f=="-"  ?  eachline(stdin)  :  eachline(f)
    if skipcomments     itr = Iterators.filter(!iscomment, itr)  end
    if skipempty        itr = Iterators.filter(!isempty, itr)    end
    return itr
end

mutable struct Eachrow
    header::Array{String}
    lineindex::Int64
    delimiter
    inneritr
    _f
end

function Base.iterate(itr::Eachrow, _state=nothing)
    itemstate = iterate(itr.inneritr)
    itemstate === nothing  &&  return nothing

    itr.lineindex += 1
    line,_ = itemstate
    ss = split(line, itr.delimiter)
    if length(ss) != length(itr.header)
        fprint = itr._f==stdin  ?  "<stdin>"  :  "file '$(string(itr._f))'"
        error("ERROR: eachrow: number of fields does not match header in $(fprint), line $(itr.lineindex); $(length(itr.header)) expected, $(length(ss)) found")
    end

    row = OrderedDict(zip(itr.header, ss))
    return (row, nothing)
end
Base.IteratorSize(::Type{Eachrow}) = Base.SizeUnknown()
Base.eltype(::Type{Eachrow}) = OrderedDict{String,StubString{String}}

# f: filename, stream, stdin="-" ..
function eachrow(f=stdin; del="|", skipcomments::Bool=true, skipempty::Bool=true)
    inneritr = _eachline(f;   skipcomments=skipcomments, skipempty=skipempty)
    itemstate = iterate(inneritr)
    itemstate === nothing  &&  return Iterators.empty(OrderedDict{String,StubString{String}})

    firstline,_ = itemstate
    header = split(firstline, '|')

    return Eachrow(header, 0, del, inneritr, f)
end


function @main(args)
    for row in eachrow(args[1])
        println(row)
    end
end

