module ReverseAssign




# original function definition
# but as this Symbol-call is auto-exported (no need for "export (Symbol)"),
# we use a dynamic activation below

#function (newvarname::Symbol)(value)  Base.eval(Main, :( $newvarname = $value ))  end

# (you could also copy/paste the code above into the REPL)




# makes the Symbol-call function available dynamically
# (same expression as code above, but '$' is escaped)
function enable()
    s = """function (newvarname::Symbol)(value)  Base.eval(Main, :( \$newvarname = \$value ))  end"""
    eval(Meta.parse(s))
end




# dummy function for help
reverseassign() = nothing




include("reverseassign.jl_exports")
include("reverseassign.jl_docs")
end