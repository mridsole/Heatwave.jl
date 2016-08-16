#==
    Types for floors 
==#

typealias FloorGrid Array{Nullable{StateObject}, 2}

immutable EmptyState
    x::Int
    y::Int
end

type Empty
    
    floor_grid::FloorGrid
    state::WireState

    function Empty(grid::FloorGrid, x::Int, y::Int)
        
        obj = new(grid, EmptyState(x, y))
        grid[x, y] = Nullable(obj)

        return obj
    end
end

immutable WireState
    x::Int
    y::Int
end

type Wire

    floor_grid::FloorGrid
    state::WireState

    function Wire(grid::FloorGrid, x::Int, y::Int)
        
        obj = new(grid, WireState(x, y))
        grid[x, y] = Nullable(obj)

        return obj
    end
end
