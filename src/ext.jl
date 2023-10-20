module Ext


using OrderedCollections



# NOTE:
# implementing 'Base.splitext()' is all that is needed for a type to interact with the extension helpers below:
#
# Example:
# struct MyType  s::String  end
#
# Base.splitext(x::MyType) = splitext(x.s)




function ext(x)::Union{String, Nothing}  # no change to lowercase
    _,e = splitext(x)
    e == ""  &&  return nothing
    @assert startswith(e, '.')
    return String(chop(e; head=1, tail=0))  # avoid keeping substring-refed string in mem
end




# This list of extension synonym was scraped from Phil Harvey's exiftool homepage: https://exiftool.org/ -- the respective license applies
include("ext.jl_data")


_SYM_EMPTY::Symbol = :_empty_
setsym_empty(sym::Symbol) = ( global _SYM_EMPTY = sym )
# _SYM_UNREG::Symbol = :_unreg_
# setsym_unreg(sym::Symbol) = ( global _SYM_UNREG = sym )




const _EXT2EXTY = OrderedDict{String, Symbol}();
function register_extgroups(extgroups::AbstractVector{<:AbstractVector{<:AbstractString}})
    global _EXT2EXTY
    empty!(_EXT2EXTY)

    for extgroup in extgroups
        isempty(extgroup)  &&  error("extension group is empty")

        group_exty = nothing
        for ext in extgroup
            ext = ext |> strip |> lowercase
            isempty(ext)  &&  error("empty-string extension in '$(extgroup)'")
            '.' in ext    &&  error("extension '$(ext)' contains '.'")
            ext == string(_SYM_EMPTY)  &&  error("extension '$(ext)' clashes with symbol name for empty extension; use 'set_symempty'")
            haskey(_EXT2EXTY, ext)  &&  error("duplicate extension '$(ext)'")

            group_exty === nothing  &&  (group_exty = Symbol(ext))  # first ext in extgroup           
            _EXT2EXTY[ext] = group_exty
        end
    end
    return nothing
end


function show_extgroups()
    lastexty = nothing
    for (ext,exty) in _EXT2EXTY
        if exty != lastexty
            println()
            print(":$(exty) <=> ")
            lastexty = exty
        end
        print(" :$(ext)")
    end
    println()
    println()
    println(""":$(_SYM_EMPTY) <=> from files like "foo." or "foo" (ext() returns "" or nothing)""")
    println()
end



# converts raw ext to a symbol
# - if registered, if returns its canonical, lowercased symbol form (e.g., "JPG" returns :jpeg)
# - if not, it returns a lowercased symbol (e.g., "FOO" returns :foo)
function ext2exty(sn::Union{AbstractString, Nothing})::Symbol
    sn === nothing  &&  return _SYM_EMPTY
    sn == ""        &&  return _SYM_EMPTY

    ext = lowercase(sn)
    haskey(_EXT2EXTY, ext)  &&  return _EXT2EXTY[ext]
    return Symbol(ext)
end

exty(x) = ext(x) |> ext2exty  # returns lowercased symbol




hasext(x, sn::Union{AbstractString, Nothing}) = ext(x) == sn
hasext(sn::Union{AbstractString, Nothing}) = x -> hasext(x, sn)


function hasext(x, sym::Symbol)::Bool
    sym === Symbol("")  &&  error("""invalid 'Symbol("")' used; use ':$(_SYM_EMPTY)' instead""")

    # special case first; later we want to find canonical form of unregistered symbol
    sym === _SYM_EMPTY  &&  return exty(x) === _SYM_EMPTY

    symcanon = ext2exty(string(sym))

    return exty(x) === symcanon
end
hasext(sym::Symbol) = x -> hasext(x, sym)








function __init__()
    # prepare defaults in vec-vec format
    for s in ___EXTGROUPS_DEFAULT_RAWSTRINGS
        ss = split(s, ",")
        ss = [ strip(s) for s in ss ]  # just for default convenience; lowercase will always be done later/during register
        push!(___EXTGROUPS_DEFAULT, ss)
    end

    register_extgroups(___EXTGROUPS_DEFAULT)
end



include("ext.jl_docs")
include("ext.jl_exports")
end # module

