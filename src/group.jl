module Group


using OrderedCollections


using ..Iter




_ftrue(_) = true

function group(X;   fkey::Function = identity,
                    fvalue::Function = identity,
                    freduce::Function = identity,
                    fhaving::Function = _ftrue,
                    sort::Bool = false,
                    sort_byvalue::Bool = false,
                    sort_by::Function = identity,  # e.g., 'length' of vectors..
                    sort_rev = false
    )

    d = OrderedDict()
    for x in X
        key = fkey(x)
        value = fvalue(x)
        !haskey(d, key)  &&  ( d[key] = [] )
        push!(d[key], value)
    end

    d = freduce === identity  ?  d  :  OrderedDict( (k, freduce(v)) for (k,v) in d )
    d = fhaving === _ftrue  ?  d  :   flbyval(fhaving, d)  # rename to filterbyvalue

    if sort
        sort!(d; byvalue=sort_byvalue, by=sort_by, rev=sort_rev)
    end

    # cleaner types..
    RET = OrderedDict( (x,Base.map(identity, y)) for (x,y) in d )
    return RET
end


# function group(X;   fkey::Function=identity, Tkey::Type=Any,  
#                     fval::Function=identity, Tval::Type=Any,
#                     freduce::Function=identity, Treduce::Type=Any,
#                     fhaving=ftrue)

#     d = OrderedDict{Tkey, Vector{Tval}}()
#     for x in X
#         key = fkey(x)
#         value = fval(x)
#         !haskey(d, key)  &&  ( d[key] = Tval[] )
#         push!(d[key], value)
#     end

#     d = freduce === identity  ?  d  :  OrderedDict{Tkey, Treduce}( (k, freduce(v)) for (k,v) in d )
#     d = fhaving === ftrue     ?  d  :  flbyval(fhaving, d)

#     return d
# end




include("group.jl_exports")
end # module