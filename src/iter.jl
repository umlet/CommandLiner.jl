module Iter


using OrderedCollections


import Base.Iterators


# synonyms to
# - ensure currying, regardless of recent changes to, e.g., filter() in Base
# - always use the Iterators-variants instead of Base for consistency
# - minimize typing on command line


cl(args...) = collect(args...)

fl_(args...)      = Iterators.filter(args...)
mp_(args...)      = Iterators.map(args...)
tk_(args...)      = Iterators.take(args...)
pt_(args...)      = Iterators.partition(args...)
drwhile_(args...) = Iterators.dropwhile(args...)

fl_(f)      = X -> fl_(f, X)
mp_(f)      = X -> mp_(f, X)
tk_(n)      = X -> tk_(X, n)
pt_(n)      = X -> pt_(X, n)
drwhile_(f) = X -> drwhile_(f, X)




fl(args...) = fl_(args...) |> cl
fl(f)       = X -> fl(f, X)

mp(args...) = mp_(args...) |> cl
mp(f)       = X -> mp(f, X)  # don't restrict 'f' to Function, in order to be able to use constructors

tk(args...)  = tk_(args...) |> cl
tk(n::Int64) = X -> tk(X, n)
tk(X) = tk(X, 10) 

pt(args...) = pt_(args...) |> cl
pt(n::Int64) = X -> pt(X, n)

drwhile(args...) = drwhile_(args...) |> cl
drwhile(f)       = X -> drwhile(f, X)


flatten_(args...) = Iterators.flatten(args...)
flatten(args...) = flatten_(args...) |> cl


# curried 'foreach'
apply(f::Function, X) = foreach(f, X)
apply(f::Function) = X -> apply(f, X)




hd(args...) = tk(args...)

cn(args...)     = count(args...)
cn(f::Function) = X -> count(f, X)

is(T::Type) = x -> isa(x, T)




flbyval(f::Function, d::AbstractDict) = typeof(d)( fl(x->f(x[2]), d) )
flbyval(f::Function)                  = X -> flbyval(f, X)


# TODO reversable..
sortbyval(d::OrderedDict; args...) = sort(d; byvalue=true, args...)
# by key is default




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




include("iter.jl_exports")
end # module
