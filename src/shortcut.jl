module Shortcut


using ..Exe
using ..Iter


abstract type AbstractShortcut end
_show(io::IO, x::AbstractShortcut) = atshow(x)


struct ShortcutLs <: AbstractShortcut end
function atshow(x::ShortcutLs)
    if Sys.iswindows()
        R = exe(["cmd", "/C", "dir"])
        R.outs |> apply(println)
        return nothing
    end

    R = exe(["ls", "-l", "-A"])     # A suppresses '.' and '..'
    R.outs |> fl(!startswith("total ")) |> apply(println)
    return nothing
end


include("shortcut.jl_base")
include("shortcut.jl_exports")
end