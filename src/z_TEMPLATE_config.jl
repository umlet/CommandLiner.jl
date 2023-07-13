module Config

using OrderedCollections
using JSON

let _CONFIGURATION_DEFAULT = nothing, _CONFIGURATION_FNAME = nothing
    global setdefault(s::AbstractString) = ( _CONFIGURATION_DEFAULT = s )
    global getdefault() = _CONFIGURATION_DEFAULT

    global setfname(s::AbstractString)= ( _CONFIGURATION_FNAME = s )
    global getfname()= _CONFIGURATION_FNAME
end

struct Configuration
    d::OrderedDict
    function Configuration()
        s = getdefault()
        if s !== nothing
            println("PARSING")
            #JSON.parse(s, dicttype=()->RET.d)
            d = JSON.parse(s, dicttype=OrderedDict)
            return new(d)
        end
        return new(OrderedDict())
    end
end

let _CONFIGURATION = Ref{Configuration}(), _CONFIGURATION_LOCK = Ref(ReentrantLock())
    global function getinstance()
        isassigned(_CONFIGURATION)  &&  ( return _CONFIGURATION[] )
        @lock _CONFIGURATION_LOCK[] ( _CONFIGURATION[] = Configuration() )
        return _CONFIGURATION[]
    end
end

end