module Str




iscomment(s::AbstractString) = isempty(s)  ?  false  :  s[1] == '#'


splitind1(s::AbstractString, i::Int64) = SubString{String}(s, firstindex(s), prevind(s, i))
splitind2(s::AbstractString, i::Int64) = SubString{String}(s, nextind(s,i), lastindex(s))


# already solved; use original functions!
#sw(s::AbstractString) = x -> startswith(x, s)
#ew(s::AbstractString) = x -> endswith(x, s)


jn(args...)           = join(args...)  # single arg call of join returns string
jn(c::Char)           = X -> jn(X, c)
jn(s::AbstractString) = X -> jn(X, s)


# obsolete:
# Base.IteratorSize(::Type{Iterators.PartitionIterator{T}}) where {T<:AbstractString} = Base.SizeUnknown()
# Base.IteratorEltype(::Type{Iterators.PartitionIterator{T}}) where {T<:AbstractString} = Base.HasEltype()
# Base.eltype(::Type{Iterators.PartitionIterator{T}}) where {T<:AbstractString} = SubString{T}
# function Base.iterate(itr::Iterators.PartitionIterator{<:AbstractString}, state = firstindex(itr.c))
#     state > ncodeunits(itr.c) && return nothing
#     lastind = min(nextind(itr.c, state, itr.n - 1), lastindex(itr.c))
#     return SubString(itr.c, state, lastind), nextind(itr.c, lastind)
# end
# eachsplitn(args...) = ipartition(args...)  # always stays iteratory for long string




# TODO move to file

# file extension:
# original logic:
#   file.txt    -> ".txt"
#   file.       -> "."
#   file        -> ""
#   .file       -> ""
#   .           -> ""
# new logic:
#   file.txt    -> "txt"
#   file.       -> ""
#   file        -> nothing
#   .file       -> nothing
#   .           -> nothing
function ext(s)
    _,e = splitext(s)
    e == ""  &&  return nothing
    @assert startswith(e, '.')
    return chop(e; head=1, tail=0)
end




include("str.jl_exports")
include("str.jl_docs")
end # module
