module Exe



### OLD
# function exe(cmd::Cmd#=scmd::String=#; fail=true, okexits=[], splitlines=true)
#     #cmd = Cmd(["bash", "-c", scmd])
#     bufout = IOBuffer()                                                     ; buferr = IOBuffer()
#     process = run(pipeline(ignorestatus(cmd), stdout=bufout, stderr=buferr))
#     exitcode = process.exitcode
    
#     sout = String(take!(bufout))                                            ; serr = String(take!(buferr))
#     close(bufout)                                                           ; close(buferr)

#     fail  &&  exitcode != 0  &&  !(exitcode in okexits)  &&  error("exe: OS system command failed: '$(join(cmd.exec, " "))'; stderr:\n$(serr)")

#     if splitlines
#         length(sout) > 0  &&  last(sout) == '\n'  &&  (sout = chop(sout))   ; length(serr) > 0  &&  last(serr) == '\n'  &&  (serr = chop(serr))
#         souts = sout != "" ? split(sout, '\n') : String[]                   ; serrs = serr != "" ? split(serr, '\n') : String[]
#         return (exitcode=exitcode, outs=souts, errs=serrs)
#     end
#     return (exitcode=exitcode, out=sout, err=serr)
# end

function exe(cmd::Cmd#=scmd::String=#; fail=true, okexits=[], splitlines=true)
    #cmd = Cmd(["bash", "-c", scmd])
    bufout = IOBuffer()                                                     ; buferr = IOBuffer()
    process = run(pipeline(ignorestatus(cmd), stdout=bufout, stderr=buferr))
    exitcode = process.exitcode
    
    sout = String(take!(bufout))                                            ; serr = String(take!(buferr))
    close(bufout)                                                           ; close(buferr)

    fail  &&  exitcode != 0  &&  !(exitcode in okexits)  &&  error("exe: OS system command failed: '$(join(cmd.exec, " "))'; stderr:\n$(serr)")

    !splitlines  &&  return (exitcode=exitcode, out=sout, err=serr)

    # split; use eachline for Windows and "\r\n" compatibility
    souts = eachline(IOBuffer(sout)) |> collect                             ; serrs = eachline(IOBuffer(serr)) |> collect
    return (exitcode=exitcode, outs=souts, errs=serrs)
end

exe(ss::AbstractVector{<:AbstractString}; fail=true, okexits=[], splitlines=true) = exe(Cmd(ss); fail=fail, okexits=okexits, splitlines=splitlines)
exe(s::AbstractString; fail=true, okexits=[], splitlines=true) = exe([s]; fail=fail, okexits=okexits, splitlines=splitlines)


# only works on Linux-y systems; to use pipes etc.
exebash(scmd; fail=true, okexits=[], splitlines=true) = exe(Cmd(["bash", "-c", scmd]); fail=fail, okexits=okexits, splitlines=splitlines)


include("exe.jl_exports")
include("exe.jl_docs")
end  # module
