module Group


using OrderedCollections


using ..Iter




ftrue(_) = true


function group(X;   fkey::Function=identity, Tkey::Type=Any,  
                    fval::Function=identity, Tval::Type=Any,
                    freduce::Function=identity, Treduce::Type=Any,
                    fhaving=ftrue)

    d = OrderedDict{Tkey, Vector{Tval}}()
    for x in X
        key = fkey(x)
        value = fval(x)
        !haskey(d, key)  &&  ( d[key] = Tval[] )
        push!(d[key], value)
    end

    d = freduce === identity  ?  d  :  OrderedDict{Tkey, Treduce}( (k, freduce(v)) for (k,v) in d )
    d = fhaving === ftrue     ?  d  :  flbyval(fhaving, d)

    return d
end




include("group.jl_exports")
end # module