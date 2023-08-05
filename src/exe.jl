module Exe



### OLD
# function exe(cmd::Cmd; fail=true, okexits=[], splitlines=true)
#     bufout = IOBuffer()                                                     ; buferr = IOBuffer()
#     process = run(pipeline(ignorestatus(cmd), stdout=bufout, stderr=buferr))
#     exitcode = process.exitcode
    
#     sout = String(take!(bufout))                                            ; serr = String(take!(buferr))
#     close(bufout)                                                           ; close(buferr)

#     fail  &&  exitcode != 0  &&  !(exitcode in okexits)  &&  error("exe: OS system command failed: '$(join(cmd.exec, " "))'; stderr:\n$(serr)")

#     !splitlines  &&  return (exitcode=exitcode, out=sout, err=serr)

#     # split; using eachline for Windows and "\r\n" compat..
#     souts = eachline(IOBuffer(sout)) |> collect                             ; serrs = eachline(IOBuffer(serr)) |> collect
#     return (exitcode=exitcode, outs=souts, errs=serrs)
# end


function exe(cmd::Cmd; fail=true, okexits=[], onlystdout=true, splitlines=true)
    bufout = IOBuffer()                                                     ; buferr = IOBuffer()
    process = run(pipeline(ignorestatus(cmd), stdout=bufout, stderr=buferr))
    exitcode = process.exitcode
    
    retout = String(take!(bufout))                                          ; reterr = String(take!(buferr))
    close(bufout)                                                           ; close(buferr)

    exitcode != 0  &&  fail  &&  !(exitcode in okexits)  &&  error("exe: OS system command failed: '$(join(cmd.exec, " "))'; stderr:\n$(reterr)")

    if splitlines
        retout = eachline(IOBuffer(retout)) |> collect                      ; reterr = eachline(IOBuffer(reterr)) |> collect
    end

    onlystdout  &&  return retout
    splitlines  &&  return (rc=exitcode, outs=retout, errs=reterr)
    return (rc=exitcode, out=retout, err=reterr)
end


# does not work yet.. ???
# function exe(cmd::Cmd; fail=true, okexits=[], onlystdout=true, splitlines=true)
#     bufout = IOBuffer()                                                         ; buferr = IOBuffer()
#     process = run(pipeline(ignorestatus(cmd), stdout=bufout, stderr=buferr))
#     exitcode = process.exitcode

#     exitcode != 0  &&  fail  &&  !(exitcode in okexits)  &&  error("exe: OS system command failed: '$(join(cmd.exec, " "))'; stderr:\n$(serr)")
    
#     if splitlines
#         retout = eachline(bufout) |> collect                                    ; reterr = eachline(buferr) |> collect
#     else
#         retout = String(take!(bufout))                                          ; reterr = String(take!(buferr))
#     end
#     close(bufout)                                                               ; close(buferr)

#     onlystdout  &&  return retout

#     splitlines  &&  return (rc=exitcode, outs=retout, errs=reterr)

#     return (rc=exitcode, out=retout, err=reterr)
# end


exe(ss::AbstractVector{<:AbstractString}; fail=true, okexits=[], onlystdout=true, splitlines=true) = exe(Cmd(ss); fail=fail, okexits=okexits, onlystdout=onlystdout, splitlines=splitlines)
exe(s::AbstractString; fail=true, okexits=[], onlystdout=true, splitlines=true) = exe([s]; fail=fail, okexits=okexits, onlystdout=onlystdout, splitlines=splitlines)


# only works on Linux-y systems; to use pipes etc.
exebash(scmd; fail=true, okexits=[], onlystdout=true, splitlines=true) = exe(Cmd(["bash", "-c", scmd]); fail=fail, okexits=okexits, onlystdout=onlystdout, splitlines=splitlines)




include("exe.jl_exports")
include("exe.jl_docs")
end  # module

