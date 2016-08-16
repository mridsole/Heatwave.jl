abstract StateObject

typealias StateGrid Array{StateObject, 2}

# some utilities
function pos_adj{T<:StateObject}(sobj::T, dir::Int)

    x = sobj.state.x
    y = sobj.state.y

    @switch dir begin
        0; return (x, y)
        1; return (x, y - 1)
        2; return (x - 1, y)
        3; return (x, y + 1)
        4; return (x + 1, y)
    end
    
    # error state ...
    return (0, 0)
end

# some defaults
pos(sobj::StateObject) = (sobj.state.x, sobj.state.y)
ticked(sobj::StateObject) = sobj.ticked

# make sure this one gets overridden
char(sobj::StateObject) = error("Need to override char set!")

pos{T<:StateObject}(sobj::T) = (sobj.state.x, sobj.state.y)
