module Mainy


using ..Error




function hushexit(f::Function)
    # makes sure that InterruptException is thrown instead of the usual shutdown
    Base.exit_on_sigint(false)

    try
        f()
    catch ex
        # suppress backtrace and non-zero exit for SIGPIPE in pipeline
        isa(ex, Base.IOError)  &&  ex.code == Base.UV_EPIPE     &&  ( exit(0) )

        # suppress backtrace on interrupt; exit with usual interrupt exit code 130; (println for fresh prompt)
        isa(ex, InterruptException)                             &&  ( println(stderr);  exit(130) )

        # suppress backtrace on erroruser/EnduserError; suppress which-error-line info
        isa(ex, EnduserError)                                   &&  ( println(stderr, "ERROR: ", ex.msg);  exit(ex.exitcode) )

        rethrow()
    end
end


macro main()
    FILE = string(__source__.file)
    expr = quote
        abspath(PROGRAM_FILE) == $(FILE)  ?  hushexit($(esc(:main)))  :  nothing
    end
    return expr
end


macro mn()  # for later compat, once main() is recognized by Julia itself
    FILE = string(__source__.file)
    expr = quote
        abspath(PROGRAM_FILE) == $(FILE)  ?  hushexit($(esc(:mn)))  :  nothing
    end
    return expr
end


macro ismain()
    FILE = string(__source__.file)
    expr = quote
        ( abspath(PROGRAM_FILE) == $(FILE)  ?  true  :  false )
    end
    return expr
end


macro guard(expr)
    FILE = string(__source__.file)
    expr = quote
        abspath(PROGRAM_FILE) == $(FILE)  ?  $(esc(expr))  :  nothing
    end
    return expr
end




include("mainy.jl_exports")
include("mainy.jl_docs")
end # module

