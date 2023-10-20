module ColorBox

_colors = [
:reverse,       # !     (also as keyword)
:underline,     # _     (also as keyword)
:bold,          # *     (also as keyword)     *not in WinTerm
:blink,         #       (also as keyword)     *not in WinTerm
:hidden,        #       (also as keyword)

:normal,
:default,
:nothing,

:red,           # R
:green,         # G
:blue,          # B
:yellow,        # Y
:cyan,          # C
:magenta,       # M
:white,         # W
:black,         # P = pitch

:light_red,     # r (use lower case for more common use)
:light_green,   # g
:light_blue,    # b
:light_yellow,  # y
:light_cyan,    # c
:light_magenta, # m
:light_white,   # w
:light_black    # g or p .. grAy (USA)
]


#topairs(; kwargs...) = kwargs


struct Cbx
    x::Any
    psargs::Any
    Cbx(x; psargs...) = new(x, psargs)
end

style(x) = "r"  # override this method for your values/types

Cbx(x, what) = Cbx(x, style(what))

function Cbx(x, s::AbstractString)
    dlookup = Dict{Char, Symbol}(
                                    'r'=>:light_red,    'g'=>:light_green,  'b'=>:light_blue,
                                    'y'=>:light_yellow, 'c'=>:light_cyan,   'm'=>:light_magenta,
                                    'w'=>:light_white,  'p'=>:light_black,

                                    'R'=>:red,          'G'=>:green,        'B'=>:blue,
                                    'Y'=>:yellow,       'C'=>:cyan,         'M'=>:magenta,
                                    'W'=>:white,        'P'=>:black
                                )

    d = Dict{Symbol, Union{Symbol, Bool}}()
    cs = collect(s)
    colordone = false
    for c in cs
        if c == '!'  d[:reverse] = true
        elseif c == '*'  d[:bold] = true
        elseif c == '_'  d[:underline] = true
        elseif haskey(dlookup, c)
            colordone  &&  error("multiple colors specified")
            d[:color] = dlookup[c]
        else error("invalid charcter '$(c)' in colorbox style")
        end
    end
    kwargs = pairs(d)
    return Cbx(x; kwargs...)
end


function test()
    for color in _colors
        printstyled(string(color); color=color)
        println()
    end
end


include("colorbox.jl_base")
include("colorbox.jl_exports")
end # module