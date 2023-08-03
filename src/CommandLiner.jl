

"""
    CommandLiner

Module with helpers:
- option parsing; SIGPIPE; user-facing exceptions..
- currying `map` and `filter` overrides
- hack for reverse assignment at end of pipe chain

See: `getopt` `erroruser` `@main` `tameerror` `reverseassign` `ext` `exe`
"""
module CommandLiner




# _ = n/a; code in pctg; <empty> = to do
# status    code    base    exports     test    doc
# Err       100     x       x           x       x
# Str       50      _       x           x       
# Iter      100     _       x           x
# Exe
# Group
# Convert
# InOut
# Getopt    100     _       x           x       x
# Main      100     _       x           _       x
# RevAss
#
# README.md 50


# zero deps
include("error.jl")
using .Error
include("error.jl_exports")

include("str.jl")
using .Str
include("str.jl_exports")

include("iter.jl")
using .Iter
include("iter.jl_exports")

include("exe.jl")
using .Exe
include("exe.jl_exports")




include("group.jl")  # dep on Iter
using .Group
include("group.jl_exports")




include("convert.jl")  # dep on Str, Iter
using .Conv
include("convert.jl_exports")

include("inout.jl")  # dep on Str, Iter
using .InOut
include("inout.jl_exports")




include("getopt.jl")  # dep on Convert, Error
using .Getopt
include("getopt.jl_exports")




include("main.jl")
using .Main
include("main.jl_exports")




include("reverseassign.jl")  # inner function not exported; for "using" it in REPL
import .ReverseAssign: reverseassign
include("reverseassign.jl_exports")




end # module CommandLiner
