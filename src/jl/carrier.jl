#==
    Carries a charge, and annihilates with other charges on collision.
==#

# no circular types available yet ...
# i'm not THAT worried about performance here though.
typealias CarrierGrid Array{Nullable{StateObject}, 2}
typealias CarrierList Array{StateObject, 1}

immutable CarrierState

    # global x and y coordinates, measured from top left corner
    x::Int
    y::Int
    
    # directions are measured counterclockwise from up - 1, 2, 3, 4 etc
    # direction of 0 means it's not going anywhere
    direction::Int
    
    # for now, either 1 or -1
    charge::Int
end

type Carrier <: StateObject

    # reference to the carrier grid
    carrier_grid::CarrierGrid

    # reference to the list of carriers
    carrier_list::CarrierList

    state::CarrierState
    state_next::CarrierState

    ticked::Bool

    # no memory pooling right now - if it exists, it exists
    function Carrier(cg::CarrierGrid, cl::CarrierList, x::Int, y::Int, 
        direction::Int, charge::Int)
        
        # some sanity checks
        @assert charge == 1 || charge == -1
        @assert direction == 0 ||
                direction == 1 || direction == 2 || 
                direction == 3 || direction == 4

        # make sure there's not something already at the given position
        @assert @> cg[x, y] isnull

        carrier = new(cg, cl,
            CarrierState(x, y, direction, charge),
            CarrierState(x, y, direction, charge),
            false)

        # if it's ok, set the position
        cg[x, y] = Nullable(carrier)

        # add in to the list of existing carriers
        push!(cl, carrier)

        return carrier
    end
end

import Base.show
function Base.show(io::IO, carrier::Carrier)
    
    dir = carrier.state.direction
    dir_str = @switch dir begin
        0; "stationary"
        1; "up"
        2; "left"
        3; "down"
        4; "right"
    end

    println(io, "Carrier (charge: $(carrier.state.charge), dir: $(dir_str)) at " *
        "($(carrier.state.x), $(carrier.state.y))")
end

function char(carrier::Carrier)
    return carrier.state.charge == 1 ? UInt32('+') : UInt32('-')
end

# update the next state based on the current state
# (and the current states of the surrounding objects)
function tick!(carrier::Carrier)
    
    # some simple transition rule: move in a constant direction
    st = carrier.state

    # next candidate position (in same direction)
    xn, yn = pos_adj(carrier, carrier.state.direction)

    carrier.state_next = CarrierState(xn, yn, st.direction, st.charge)
    
    # now we have ticked for the current state
    carrier.ticked = true

    nothing
end

# set the next state to the current state
function flush!(carrier::Carrier)
    
    # add to the new position - assume this won't be overwritten ...
    let x = carrier.state_next.x, y = carrier.state_next.y
        carrier.carrier_grid[x, y] = Nullable(carrier)
    end
    
    # remove from the old position
    let x = carrier.state.x, y = carrier.state.y
        carrier.carrier_grid[x, y] = Nullable{Carrier}()
    end

    # update the current state, forget the previous state
    carrier.state = carrier.state_next
    
    # now we haven't ticked for the current state
    carrier.ticked = false

    nothing
end
