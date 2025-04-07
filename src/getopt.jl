module Getopt

# NOTE: REAFCTOR FROM PYTHON CODE BELOW !!!


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


function getargs(stypes::AbstractString="ss*"; from=ARGS, stopatopt=true, mustexhaust=true, opt=:auto)  # opt ist just used for error msgs
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

    !mustexhaust  &&  ( return RET )
    length(from) == 0  &&  ( return RET )
    isopt(first(from))  &&  ( return RET )
    erroruser("too many arguments given")
end
getargs0(; from=ARGS, stopatopt=true, opt=:auto) = getargs("s*"; from=from, stopatopt=stopatopt, opt=opt)
function getarg(stype::Union{AbstractString, Char}="s"; from=ARGS, stopatopt=true, opt=:auto)
    length(stype) != 1  &&  error("getarg: invalid stype '$(stype)': only single type specifier allowed")
    return getargs(string(stype); from=from, stopatopt=stopatopt, opt=opt)[1]
end




include("getopt.jl_exports")
include("getopt.jl_docs")
end  # module





# #!/usr/bin/env python3


# # Simple command line option handler.
# # - getopt() return an option like "-x" or "--xtra", or None (for naked/optionless args).
# # - getargs(mystr) returns the option's *type-converted* arguments.
# #   mystr describes the options' count and types:
# #     "ss*"  .. 1 string and 0+ strings (default)
# #     "iif"  .. 2 ints and 1 float (naked/optionless args allowed afterwards)
# #     "is."  .. 1 int and 1 string, but must exhaust => no naked args allowed afterwards


# import sys
# import re


# from .convert import trytofloat, trytoint, isfloat
# from .error import error, erroruser




# def isopt(s):
#     if s.startswith("--"):                      return True
#     if s == "-":                                return False    # stdin convention
#     if s.startswith("-") and not isfloat(s):    return True
#     return False


# _lastopt = 0  # 0=undef; None or strings later
# def getopt():
#     global _lastopt
#     if len(sys.argv) == 0:  error("getopt: attempt to read option from empty args")
#     RET = None  if not isopt(sys.argv[0])  else  sys.argv.pop(0)
#     _lastopt = RET
#     return RET
# def geterrprefix():
#     if _lastopt == 0:       return "(no option processed yet): "
#     if _lastopt == None:    return "in option-less/naked args: "
#     return                        f"in args of option '{_lastopt}': "


# def _getargs(n):  # n=0..all up to next opt;  n>0..first n, not exhaust;  n<0..stingy: must exhaust
#     RET = []
#     if n == 0:
#         if len(sys.argv) == 0:  return []
#         while len(sys.argv) > 0 and not isopt(sys.argv[0]):
#             RET.append(sys.argv.pop(0))
#         return RET

#     # n!=0
#     for i in range(abs(n)):
#         if len(sys.argv) == 0  or  isopt(sys.argv[0]):  erroruser(f"{geterrprefix()}not enough args; {abs(n)} expected")
#         RET.append(sys.argv.pop(0))
#     if n > 0:  return RET

#     # check if args were exhausted (no naked args left)
#     if len(sys.argv) == 0  or  isopt(sys.argv[0]):  return RET
#     erroruser(f"{geterrprefix()}naked args left before next option")  # TODO opt


# def _check_stypes(s):
#     pattern = r'^[sif]+[.*]?$'
#     return re.match(pattern, s) is not None


# def _convert(ls, stypes):
#     RET = []
#     dfunc = {"s": lambda x: x, "i": trytoint, "f": trytofloat}
#     for s,stype in zip(ls, stypes):
#         x = dfunc[stype](s)
#         if x == None:  erroruser(f"{geterrprefix()}argument '{s}' not of type '{stype}'")
#         RET.append(x)
#     return RET


# def getargs(stypes="ss*"):
#     if not _check_stypes(stypes):  error(f"getargs: invalid arg-types string '{stypes}'")

#     if stypes.endswith("*"):
#         tmp_args = _getargs(0)
#         tmp_stypes = stypes[:-2] + stypes[-2] * (len(tmp_args)-len(stypes[:-2]))

#     else:
#         if not stypes.endswith("."):
#             n = len(stypes)
#         else:
#             stypes = stypes[:-1]
#             n = -len(stypes)

#         tmp_args = _getargs(n)
#         tmp_stypes = stypes

#     assert len(tmp_args) == len(tmp_stypes)
#     return _convert(tmp_args, tmp_stypes)


# def hasopt():  return len(sys.argv) > 0


# def getarg(stype="s", **kwargs):
#     if stype not in ["s", "i", "f", "s.", "i.", "f."]:  error(f"getarg: invalid stype '{stype}'")
#     return getargs(stype, **kwargs)[0]


# def getargs0(**kwargs):  return getargs("s*", **kwargs)








# if __name__ == "__main__":
#     pass

