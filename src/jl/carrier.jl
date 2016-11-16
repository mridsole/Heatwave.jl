#==
    Carries a charge, and annihilates with other charges on collision.
==#

typealias CarrierGrid Array{Nullable{StateObject}, 2}
export CarrierGrid
typealias CarrierList Array{StateObject, 1}
export CarrierList
typealias CarrierMoveMap Array{Int64, 2}
export CarrierMoveMap

bare_enum(
    :CarrierStatePhase, 0,
    :CHOOSE,
    :MOVE
) |> eval

export CarrierStatePhase

immutable CarrierState

    # global x and y coordinates, measured from top left corner
    x::Int
    y::Int
    
    # directions are measured counterclockwise from up - 1, 2, 3, 4 etc
    # direction of 0 means it's not going anywhere
    direction::Int
    
    # for now, either 1 or -1
    charge::Int

    # Which phase we're in.
    phase::Int
end

type Carrier <: StateObject

    # reference to the carrier grid
    carrier_grid::CarrierGrid

    # reference to the list of carriers
    carrier_list::CarrierList

    # reference to the carrier movement map
    carrier_move_map::CarrierMoveMap
    
    # Current state of the carrier
    state::CarrierState

    # Next state of the carrier - set as current when flush! is called
    state_next::CarrierState
    
    # Has the carrier ticked yet? (where it is in the tick/flush cycle)
    ticked::Bool

    # no memory pooling right now - if it exists, it exists
    function Carrier(
        cg::CarrierGrid, cl::CarrierList, cmm::CarrierMoveMap, 
        x::Int, y::Int, direction::Int, charge::Int, phase::Int
        )
        
        # some sanity checks
        @assert charge == 1 || charge == -1
        @assert direction == 0 ||
                direction == 1 || direction == 2 || 
                direction == 3 || direction == 4

        # make sure there's not something already at the given position
        @assert @> cg[x, y] isnull

        # make sure the carrier grid and the move map have the same dimension
        @assert size(cg) == size(cmm)

        carrier = new(cg, cl, cmm,
            CarrierState(x, y, direction, charge, phase),
            CarrierState(x, y, direction, charge, phase),
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

    print(io, "Carrier (charge: $(carrier.state.charge), dir: $(dir_str)) at " *
        "($(carrier.state.x), $(carrier.state.y))")
end

function char(carrier::Carrier)
    return carrier.state.charge == 1 ? UInt32('+') : UInt32('-')
end

# update the next state based on the current state
# (and the current states of the surrounding objects)
function tick!(carrier::Carrier)
    
    if carrier.state.phase == CarrierStatePhase.CHOOSE
    
        # some simple transition rule: move in a constant direction
        # now make the direction random!
        dir = rand(0:4)

        # next candidate position (in new direction)
        xn, yn = pos_adj(carrier, dir)
        
        # Filter out infeasible movements.
        if xn < 1 || yn < 1 || xn > 20 || yn > 20
            
            xn = carrier.state.x
            yn = carrier.state.y
            dir = 0
        end

        # If there's another carrier in the target position, don't move there.
        # TODO: make "pos_feasible" function or something.
        if  carrier.carrier_grid[xn, yn].isnull == false
            xn = carrier.state.x
            yn = carrier.state.y
            dir = 0
        end

        # Now, increment the target position on the movement map.
        carrier.carrier_move_map[xn, yn] += 1
        
        # modify the next state appropriately
        carrier.state_next = @imcp CarrierState carrier.state begin
            direction = dir
            phase = CarrierStatePhase.MOVE
        end

    elseif (carrier.state.phase == CarrierStatePhase.MOVE)

        dir = carrier.state.direction
        xn, yn = pos_adj(carrier, dir)
        
        # Only move if the move map value is not greater than one.
        # That is, if only this carrier wants to move there.
        if carrier.carrier_move_map[xn, yn] > 1

            xn, yn = carrier.state.x, carrier.state.y
            dir = 0
        end
        
        # modify the next state appropriately
        carrier.state_next = @imcp CarrierState carrier.state begin
            x = xn
            y = yn
            direction = dir
            phase = CarrierStatePhase.CHOOSE
        end
    end
        
    # now we have ticked for the current state
    carrier.ticked = true

    nothing
end

# set the next state to the current state
function flush!(carrier::Carrier)

    if carrier.state.phase == CarrierStatePhase.MOVE

        # Remove old grid position.
        oldx, oldy = pos_adj((carrier.state_next.x, carrier.state_next.y), 
            dir_inv(carrier.state_next.direction))
        
        # shouldn't have to clamp here ... TODO: figure this out
        carrier.carrier_grid[oldx, oldy] = Nullable{Carrier}()
        
        # Set new grid position.
        carrier.carrier_grid[carrier.state_next.x, carrier.state_next.y] = 
            Nullable{Carrier}(carrier)

        ## add to the new position - assume this won't be overwritten ...
        #let x = carrier.state_next.x, y = carrier.state_next.y
        #    carrier.carrier_grid[x, y] = Nullable(carrier)
        #end
        #
        ## remove from the old position
        ## but if this is the same as the new position ... whoops!
        ## if direction is zero, it didn't move
        #if carrier.state_next.direction != 0
        #    let x = carrier.state.x, y = carrier.state.y
        #        carrier.carrier_grid[x, y] = Nullable{Carrier}()
        #    end
        #end
    end

    # update the current state, forget the previous state
    carrier.state = carrier.state_next
    
    # now we haven't ticked for the current state
    carrier.ticked = false

    nothing
end
