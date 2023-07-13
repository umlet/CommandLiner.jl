module Conv


import Printf: format, Format


using ..Iter
using ..Str


toint(x) = parse(Int64, x)
tofloat(x) = parse(Float64, x)


tostr(x::Integer) = string(x)

function tostr´(i::Int64, sep=",")  # atrocious! hope for future printf rescue
    # s = i |> abs |> string |> reverse |> pt(3) .|> x->join(x, "") |> jn(',') |> reverse
    # sign(i) == -1  &&  return "-" * s
    # return s

    s = i |> abs |> string |> reverse
    cs = Char[];  j = 1
    for c in s
        push!(cs, c)
        j < length(s)  &&  j % 3 == 0  &&  ( push!(cs, ',') )
        j += 1
    end
    s2 = String(cs) |> reverse
    sign(i) == -1  &&  return "-" * s2
    return s2
end

tostr(x::AbstractFloat) = format(Format("%.6g"), x)

tostr0(x::AbstractFloat) = format(Format("%.0f"), x)
tostr1(x::AbstractFloat) = format(Format("%.1f"), x)
tostr2(x::AbstractFloat) = format(Format("%.2f"), x)
tostr3(x::AbstractFloat) = format(Format("%.3f"), x)
tostr4(x::AbstractFloat) = format(Format("%.4f"), x)
tostr5(x::AbstractFloat) = format(Format("%.5f"), x)
tostr6(x::AbstractFloat) = format(Format("%.6f"), x)
tostr7(x::AbstractFloat) = format(Format("%.7f"), x)
tostr8(x::AbstractFloat) = format(Format("%.8f"), x)

tostrf(fmt::AbstractString, x) = format(Format(fmt), x)


function sizehuman(x::Int64)
    RET = Base.format_bytes(x)
    RET = replace(RET, "i" => "")
    RET = replace(RET, "B" => "b")
    return RET
end


isint(x) = tryparse(Int64, x) !== nothing
isfloat(x) = tryparse(Float64, x) !== nothing


trytoint(x) = tryparse(Int64, x)
trytofloat(x) = tryparse(Float64, x)




include("convert.jl_exports")
end # module