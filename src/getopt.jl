module Getopt


using ..Error
using ..Conv




function isopt(s::AbstractString)
    s == "--"               &&  return true         # caller should handle this
    startswith(s, "--")     &&  return true
    s == "-"                &&  return false        # for 'stdin' convention
    startswith(s, "-")      &&  return !isfloat(s)  # treats negative numbers as arguments, not options (.e., '-1' is not a valid option)
    return false
end


_lastopt = undef
function getopt(;from=ARGS)::Union{String, Nothing}
    RET = nothing
    length(from) == 0  &&  error("attempt to read option on empty args")

    isopt(from[1])  &&  ( RET = popfirst!(from) )
    global _lastopt = RET
    return RET
end


function getargs(stypes::AbstractString="ss*"; from=ARGS, stopatopt=true, must_exhaust=true, opt=:auto)  # opt ist just used for error msgs
    RET = []
    tryto = Dict('s'=>identity, 'i'=>trytoint, 'f'=>trytofloat)
    typenames = Dict('i'=>"integer", 'f'=>"float")

    opt === :auto  &&  ( opt = _lastopt )
    if opt === nothing    errmsgprefix = "in option-less arguments: "
    elseif opt === undef  errmsgprefix = "(no option processed yet): "
    else                  errmsgprefix = "in arguments of '$(opt)': "
    end
    #OLD: errmsgprefix = opt !== nothing  ?  "at option '$(opt)': "  :  ""

    length(stypes) == 0  &&  error("getargs: stypes empty")
    # '^' and '$' match full string  ||  's', 'i', or f, at least once: [s|i|f]+  ||  one '*' optionally: \*?
    !occursin(r"^[s|i|f]+\*?$", stypes)  &&  error("getargs: invalid stypes '$(stypes)'")

    types = collect(stypes);  typerest = nothing
    types[end] == '*'  &&  ( pop!(types);  typerest = pop!(types) )

    for type in types
        length(from) == 0  &&  erroruser(errmsgprefix * "not enough arguments; at least $(length(types)) required")
        s = popfirst!(from)
        ( stopatopt && isopt(s) )  &&  erroruser(errmsgprefix * "argument list contains the option '$(s)'")
        ( tmp = tryto[type](s) ) !== nothing  ?  push!(RET, tmp)  :  erroruser(errmsgprefix * "argument '$(s)' not of type $(typenames[type])")
    end
    if typerest !== nothing
        while length(from) > 0
            ( stopatopt && isopt(from[1]) )  &&  break
            s = popfirst!(from)
            (tmp = tryto[typerest](s)) !== nothing  ?  push!(RET, tmp)  :  erroruser(errmsgprefix * "argument '$(s)' not of type $(typenames[typerest])")
        end
    end

    !must_exhaust  &&  ( return RET )
    length(from) == 0  &&  ( return RET )
    isopt(first(from))  &&  ( return RET )
    erroruser("too many arguments given")
end
getargs0(; from=ARGS, stopatopt=true, opt=_lastopt) = getargs("s*"; from=from, stopatopt=stopatopt, opt=opt)
function getarg(stype::Union{AbstractString, Char}="s"; from=ARGS, stopatopt=true, opt=_lastopt)
    length(stype) != 1  &&  error("getarg: invalid stype '$(stype)': only single type specifier allowed")
    return getargs(string(stype); from=from, stopatopt=stopatopt, opt=opt)[1]
end




include("getopt.jl_exports")
include("getopt.jl_docs")
end  # module