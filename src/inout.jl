module InOut


using ..Str
using ..Iter




function fiter(f #=..can be IO=#; skip_comments::Bool=true, skip_emptylines::Bool=true, stateful::Bool=true)
    itr = (f == "-" )  ?  eachline(stdin)  :  eachline(f)
    if skip_comments    itr = ifilter(!iscomment, itr)  end
    if skip_emptylines  itr = ifilter(!isempty, itr)    end
    if stateful         itr = Iterators.Stateful(itr)   end
    return itr
end




save(io::IO, x::AbstractString) = println(io, x)
save(io::IO, x::AbstractFloat) = println(io, x)
save(io::IO, x::Integer) = println(io, x)
# iterables
save(io::IO, X) = for x in X  save(io, x)  end


save(fname::AbstractString, X) = open(fname, "w") do io  save(io, X)  end
save(fname::AbstractString) = X -> save(fname, X)


out(X) = save(stdout, X)




include("inout.jl_exports")
end # module