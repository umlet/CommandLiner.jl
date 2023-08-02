module Str




iscomment(s::AbstractString) = startswith(s, '#')


splitind1(s::AbstractString, i::Int64) = SubString{String}(s, firstindex(s), prevind(s, i))
splitind2(s::AbstractString, i::Int64) = SubString{String}(s, nextind(s,i), lastindex(s))


# already curried; use original functions!
#sw(s::AbstractString) = x -> startswith(x, s)
#ew(s::AbstractString) = x -> endswith(x, s)


jn(args...)           = join(args...)  # single arg call of join returns string
jn(c::Char)           = X -> jn(X, c)
jn(s::AbstractString) = X -> jn(X, s)




# get file extension
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
