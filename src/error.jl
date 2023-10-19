module Error




struct EnduserError <: Exception
    msg::String
    exitcode::Int64
    EnduserError(msg::AbstractString, exitcode::Int64=99) = new(msg, exitcode)
end


erroruser(msg::AbstractString, exitcode::Int64=99) = throw(EnduserError(msg, exitcode))




include("error.jl_base")
include("error.jl_exports")
include("error.jl_docs")
end # module


# @kwdef mutable struct _Conf
#     backtrace_enduser = false
# end
# const CONF = _Conf()
# function Base.show(io::IO, ::MIME"text/plain", c::_Conf)
#     println(io, "Config of Error.EnduserError:")
#     print(  io, "   backtrace_enduser = $(CONF.backtrace_enduser)")
# end

