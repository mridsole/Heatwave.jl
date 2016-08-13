#==
    Wow it's empty space
==#

type EmptySpace <: StateObject
    
    # reference to the state grid
    state_grid::StateGrid

    # global x and y coordinates, measured from top left corner
    x::Int
    y::Int
end

char(x::EmptySpace) = ' '
