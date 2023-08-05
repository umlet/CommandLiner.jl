module InOut


using ..Str
using ..Iter




function eachln(f #=..can be IO=#; skipcomments::Bool=true, skipempty::Bool=true, stateful::Bool=false)
    itr = (f == "-" )  ?  eachline(stdin)  :  eachline(f)
    if skipcomments     itr = filter_(!iscomment, itr)  end
    if skipempty        itr = filter_(!isempty, itr)    end
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