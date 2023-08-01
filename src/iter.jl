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

pt(args...) = partition_(args...) |> collect
pt(n::Int64) = X -> pt(X, n)

drwhile(args...) = dropwhile_(args...) |> collect
drwhile(f)       = X -> drwhile(f, X)

flat(args...) = flatten_(args...) |> collect




# fl_(args...)      = filter_(args...)
# mp_(args...)      = map_(args...)
# tk_(args...)      = take_(args...)
# pt_(args...)      = partition_(args...)
# drwhile_(args...) = dropwhile_(args...)
# flat_(args)       = flat_(args...)



# TODO ???
# curried 'foreach'
apply(args...) = foreach(args...)
apply(f::Function) = X -> apply(f, X)



# TODO ???
# yet more synonyms
hd(args...) = tk(args...)

cn(args...)     = count(args...)
cn(f::Function) = X -> count(f, X)

is(T::Type) = x -> isa(x, T)




# silter/sort specials
flbyval(f::Function, d::AbstractDict) = typeof(d)( fl(x->f(x[2]), d) )
flbyval(f::Function)                  = X -> flbyval(f, X)

# TODO reversable..
sortbyval(d::OrderedDict; args...) = sort(d; byvalue=true, args...)
# by key is default




# second..
second(X::Tuple)         = X[2]
second(X::AbstractArray) = X[eachindex(X)[2]]
function second(itr)
    i = 1
    for x in itr
        i == 2  &&  ( return x )
        i += 1
    end
    throw(ArgumentError("collection too small"))
end




# stateless iterator peek
function peekgeneric(X)
    (x, itr_rest) = Iterators.peel(X)
    itr_unpeeled = Iterators.flatten( ( (x,), itr_rest ) )
    return (x, itr_unpeeled)
end










include("iter.jl_exports")
end # module
