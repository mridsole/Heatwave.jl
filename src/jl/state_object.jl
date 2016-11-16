abstract StateObject

typealias StateGrid Array{StateObject, 2}

# some utilities

function pos_adj(pos::Tuple{Int, Int}, dir::Int)
    
    x, y = pos

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

function pos_adj{T<:StateObject}(sobj::T, dir::Int)
    
    pos_adj(pos(sobj), dir)
end

function dir_inv(dir::Int)

    @switch dir begin
        0; return 0
        1; return 3
        2; return 4
        3; return 1
        4; return 2
    end

    return -1
end

# some defaults
pos(sobj::StateObject) = (sobj.state.x, sobj.state.y)
ticked(sobj::StateObject) = sobj.ticked

# some StateObjects might have constant state - so do nothing by default
tick!(sobj::StateObject) = nothing
flush!(sobj::StateObject) = nothing

# make sure this one gets overridden
char(sobj::StateObject) = error("Need to override char set!")

pos{T<:StateObject}(sobj::T) = (sobj.state.x, sobj.state.y)

export pos_adj
export dir_inv
