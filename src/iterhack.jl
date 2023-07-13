

# peek for non-stateful iterators
# returns element and new, full iterator
function peekgeneric(X)
    (x, itr_rest) = Iterators.peel(X)
    itr_unpeeled = Iterators.flatten( ( (x,), itr_rest) )
    return (x, itr_unpeeled)
end


# just aliases
filter_(args...) = Base.Iterators.filter(args...)  # just alias
filter_(f) = X -> filter_(f, X)  # curried variant (v1.9) exists only in Base!

map_(args...) = Base.Iterators.map(args...)  # just alias
map_(f) = X -> map_(f, X) 


# HACK:
# use before Base.map:
# julia> import CommandLiner: map, filter
baremodule IterHack
    import Base
    import Base.Iterators

    filter(args...) = Base.collect(Base.Iterators.filter(args...))
    filter(f) = X -> filter(f, X)

    map(args...) = Base.collect(Base.Iterators.map(args...))
    map(f) = X -> map(f, X)
end


include("iterhack.jl_exports")
