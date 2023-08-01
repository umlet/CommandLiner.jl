module Error




@kwdef mutable struct _Conf
    showfullbt = false
end
const CONF = _Conf()




struct EnduserError <: Exception
    msg::String
    exitcode::Int64
    EnduserError(msg::AbstractString, exitcode::Int64=99) = new(msg, exitcode)
end

function erroruser(msg::AbstractString, exitcode::Int64=99)
    !CONF.showfullbt  &&  throw(EnduserError(msg, exitcode))
    error(msg)
end




function tameerror(f::Function)
    # makes sure that InterruptException is thrown instead of the usual messy shutdown
    Base.exit_on_sigint(false)

    try
        f()
    catch e
        # suppress backtrace and non-zero exit for SIGPIPE in pipeline
        isa(e, Base.IOError)  &&  e.code == Base.UV_EPIPE  &&  exit(0)

        # suppress backtrace on interrupt; exit with usual interrupt exit code 130; (println for fresh prompt)
        isa(e, InterruptException)  &&  ( println(stderr);  exit(130) )

        # suppress backtrace on erroruser/EnduserError
        isa(e, EnduserError)  &&  ( println(stderr, "ERROR: ", e.msg);  exit(e.exitcode) )

        rethrow()
    end
end




include("error.jl_base")
include("error.jl_exports")
include("error.jl_docs")
end # module

