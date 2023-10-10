module Iter


using OrderedCollections


import Base.Iterators


# synonyms for command line and in-code usage
# - ensure currying, regardless of recent changes to, e.g., filter() in Base
# - always use the Iterators-variants instead of Base for consistency
# - minimize typing on command line


cl(args...) = collect(args...)




# synonyms for Iterator functions + currying (if applicable)
filter_(args...) = Base.Iterators.filter(args...)  # just alias
filter_(f)       = X -> filter_(f, X)  # curried variant (v1.9) exists only in Base!

map_(args...) = Base.Iterators.map(args...)  # just alias
map_(f)       = X -> map_(f, X) 

take_(args...)  = Iterators.take(args...)
take_(n::Int64) = X -> take_(X, n)

partition_(args...)  = Iterators.partition(args...)
partition_(n::Int64) = X -> partition_(X, n)

dropwhile_(args...)     = Iterators.dropwhile(args...)
dropwhile_(f::Function) = X -> dropwhile_(f, X)

flatten_(args...) = Iterators.flatten(args...)




# safely named in-REPL synonyms for collecting Iterator variants + currying
# => full names from 'Hack' should be imported instead in the REPL
fl(args...) = filter_(args...) |> collect
fl(f)       = X -> fl(f, X)

mp(args...) = map_(args...) |> collect
mp(f)       = X -> mp(f, X)  # don't restrict 'f' to Function, in order to be able to use constructors

tk(args...)  = take_(args...) |> collect
tk(n::Int64) = X -> tk(X, n)
tk(X) = tk(X, 10) 

part(args...) = partition_(args...) |> collect
part(n::Int64) = X -> part(X, n)

drwhile(args...) = dropwhile_(args...) |> collect
drwhile(f)       = X -> drwhile(f, X)

flat(args...) = flatten_(args...) |> collect




# fl_(args...)      = filter_(args...)
# mp_(args...)      = map_(args...)
# tk_(args...)      = take_(args...)
# pt_(args...)      = partition_(args...)
# drwhile_(args...) = dropwhile_(args...)
# flat_(args)       = flat_(args...)




# curried 'foreach' -- can't shadow for same reasons as Base.map
apply(args...) = foreach(args...)
apply(f::Function) = X -> apply(f, X)




# yet more synonyms
#hd(args...) = tk(args...)  # TODO name useful enough?

cn(args...)     = count(args...)  # example: X |> cn(is(SomeType))
cn(f::Function) = X -> count(f, X)

is(args...) = isa(args...)
is(T::Type) = x -> isa(x, T)




# silter/sort specials
flbyval(f::Function, d::AbstractDict) = typeof(d)( filter_(x->f(x[2]), d) )
flbyval(f::Function)                  = X -> flbyval(f, X)

sortbyval(d::OrderedDict; args...) = sort(d; byvalue=true, args...)
# by key is default




# second..
second(X::Tuple)         = X[2]
second(X::AbstractArray) = X[eachindex(X)[2]]
function second(itr)
    skip = true
    for x in itr
        skip  &&  ( skip = false;  continue ) 
        return x
    end
    throw(ArgumentError("iterator has no second item"))
end




# stateless iterator peek
function peekgeneric(X)
    (x, itr_rest) = Iterators.peel(X)
    itr_unpeeled = Iterators.flatten( ( (x,), itr_rest ) )
    return (x, itr_unpeeled)
end




# use before Base.map:
# julia> import CommandLiner: map, filter
baremodule Hack
    import Base
    import Base.Iterators

    filter(args...) = Base.collect(Base.Iterators.filter(args...))
    filter(f::Function) = X -> filter(f, X)

    map(args...) = Base.collect(Base.Iterators.map(args...))
    map(f) = X -> map(f, X)  # no restriction to Function in order to allow constructors
end




mutable struct PartitionBy{T}  # mutable to avoid buffer copy & to keep inner iterator state
    const inneritr

    const f  # could also be constructor
    fval_current

    buf::Vector{T}

    function PartitionBy(f, itr)
        et = eltype(itr)
        buf = Vector{et}()
        return new{et}(Base.Iterators.Stateful(itr),   f, missing,   buf)
    end
end
function Base.iterate(itr::PartitionBy, _state=nothing)
    while !isempty(itr.inneritr)
        x = first(itr.inneritr);  fval = itr.f(x)
        if isempty(itr.buf)
            push!(itr.buf, x);  itr.fval_current = fval
            continue
        end

        # can add element
        fval == itr.fval_current  &&  ( push!(itr.buf, x);  continue )

        # can't add element
        itr.buf, buf  =  [], itr.buf
        push!(itr.buf, x);  itr.fval_current = fval
        return (buf, _state)
    end
    # inner iterator done..
    if !isempty(itr.buf)
        itr.buf, buf  =  [], itr.buf
        return (buf, _state)
    end
    return nothing
end
partitionby(f, itr) = PartitionBy(f, itr)
partitionby(f) = X -> partitionby(f, X)




include("iter.jl_exports")
end # module
