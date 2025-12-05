# v0.1 2025-12-05  REPLACES getopt

___getopt_ARGS = nothing
function OptArgs(args::Vector{String})
    global ___getopt_ARGS
    ___getopt_ARGS === nothing  &&  ( ___getopt_ARGS = args )
    return !isempty(___getopt_ARGS)
end


function isopt(s::AbstractString)::Bool
    isfloat = s -> tryparse(Float64, s) !== nothing

    s == "--"               &&  return true         # caller should handle rest of args
    startswith(s, "--")     &&  return true
    s == "-"                &&  return false        # for 'stdin' convention
    startswith(s, "-")      &&  return !isfloat(s)  # negative numbers are args, not opts
    return false
end


___getopt_lastopt = undef
function getopt(;from=ARGS)::Union{String, Nothing}
    RET = nothing
    length(from) == 0  &&  error("attempt to read option on empty args")

    isopt(from[1])  &&  ( RET = popfirst!(from) )
    global ___getopt_lastopt = RET
    return RET
end
function errmsgprefix()
    ___getopt_lastopt === undef      &&  return "(no option processed yet):"
    ___getopt_lastopt === nothing    &&  return "in option-less/naked args:"
    return "in args of option '$(___getopt_lastopt)':"
end




function _getargs(n::Int64)::Vector{String}  # n=0..all up to next opt;  n>0..first n, not exhaust;  n<0..stingy: must exhaust
    ARGS = ___getopt_ARGS

    RET = Vector{String}()
    if n == 0
        length(ARGS) == 0  &&  return RET
        while !isempty(ARGS)  &&  !isopt(ARGS[1])
            push!(RET, popfirst!(ARGS))
        end
        return RET
    end

    # n!= 0
    for i in 1:abs(n)
        ( isempty(ARGS)  ||  isopt(ARGS[1]) )  &&  error("$(errmsgprefix()) not enough arguments; $(abs(n)) expected")
        push!(RET, popfirst!(ARGS))
    end
    n > 0  &&  return RET

    ( isempty(ARGS)  ||  isopt(ARGS[1]) )  &&  return RET
    error("$(errmsgprefix()) args not exhausted before next opt; naked args left")
end

function _convert(ss, types::AbstractString)
    RET = []
    for (s,type) in zip(ss, types)
        tmp = s
        if type == 'i'      tmp = tryparse(Int64, s);    tmp === nothing  &&  error("$(errmsgprefix()) arg '$(s)' not a valid integer")
        elseif type == 'f'  tmp = tryparse(Float64, s);  tmp === nothing  &&  error("$(errmsgprefix()) arg '$(s)' not a valid float")
        end
        push!(RET, tmp)
    end
    return RET
end

function getargs(types="ss*")
    occursin(r"^[sif]+[.*]?$", types)  ||  error("getargs: invalid types spec for args: '$(types)'")

    if endswith(types, "*")
        args = _getargs(0)
        nrest = length(args) - length(types[1:end-2])
        types = types[1:end-2] * ( types[end-1] ^ nrest )
    else
        if !endswith(types, ".")
            n = length(types)
        else
            types = types[1:end-1]
            n = -length(types)
        end
        args = _getargs(n)
    end
    @assert length(args) == length(types)
    return _convert(args, types)
end

function getargs0()
    return getargs("s*")
end

function getarg(types="s")
    occursin(r"^[sif][.]?$", types)  ||  error("getarg: invalid types spec for args: '$(types)'")
    return getargs(types)[1]
end

function nargs()
    RET
end