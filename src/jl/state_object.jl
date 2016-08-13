abstract StateObject

typealias StateGrid Array{StateObject, 2}

# some utilities
function pos_adj(sobj::StateObject, dir::Int)
    @switch dir begin
        0; return (sobj.x, sobj.y - 1)
        1; return (sobj.x - 1, sobj.y)
        2; return (sobj.x, sobj.y + 1)
        3; return (sobj.x + 1, sobj.y)
    end
    return (0, 0)
end

# some defaults
pos(sobj::StateObject) = (sobj.x, sobj.y)

# make sure this one gets overridden
char(sobj::StateObject) = error("Need to override char set!")


