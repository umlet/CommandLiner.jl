module Main


using ..Error




macro main()
    FILE = string(__source__.file)
    expr = quote
        abspath(PROGRAM_FILE) == $(FILE)  &&  $(esc(:(tameerror(main))))
    end
    return expr
end



include("main.jl_exports")
include("main.jl_docs")
end # module


