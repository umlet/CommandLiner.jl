module ReverseAssign


# you could copy/paste this into REPL
#function (newvarname::Symbol)(value)  eval(:( $newvarname = $value ))  end

function (newvarname::Symbol)(value)  Base.eval(Main, :( $newvarname = $value ))  end

export (Symbol)


# dummy func for help
reverseassign() = nothing

include("reverseassign.jl_exports")
include("reverseassign.jl_docs")
end