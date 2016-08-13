#==
    Carries a charge, and annihilates with other charges on collision.
==#

# no circular types available yet ...
# i'm not THAT worried about performance here though.
typealias CarrierGrid Array{Nullable{StateObject}, 2}
typealias CarrierList Array{StateObject, 1}

type Carrier <: StateObject

    # reference to the carrier grid
    carrier_grid::CarrierGrid

    # reference to the list of carriers
    carrier_list::CarrierList

    # global x and y coordinates, measured from top left corner
    x::Int
    y::Int
    
    # directions are measured counterclockwise from up - 0, 1, 2, 3 etc
    direction::Int
    
    # for now, either 1 or -1
    charge::Int

    # don't worry about memory pooling for now - let's just say that if it exists,
    # then it exists! but pooling should not be too difficult to implement.
    function Carrier(cg::CarrierGrid, cl::CarrierList, x::Int, y::Int, 
        direction::Int, charge::Int)
        
        # some sanity checks
        @assert charge == 1 || charge == -1
        @assert direction == 0 || direction == 1 ||
                direction == 2 || direction == 3

        # make sure there's not something already at the given position
        @assert @> cg[x, y] isnull

        carrier = new(cg, x, y, direction, charge)

        # if it's ok, set the position
        cg[x, y] = Nullable(carrier)

        # add in to the list of existing carriers
        push!(cl, carrier)
    end
end

import Base.show
function Base.show(io::IO, carrier::Carrier)
    
    dir = @switch carrier.direction begin
        0; "up"
        1; "left"
        2; "down"
        3; "right"
    end

    println(io, "Carrier (charge: $(carrier.charge), dir: $(dir)) at " *
        "($(carrier.x), $carrier.y))")
end

function pos!(carrier::Carrier, x::Int, y::Int)
    
    # remove the old position
    carrier.carrier_grid[x, y] = Nullable{Carrier}()

    # add in new position
    carrier.carrier_grid[x, y] = Nullable(carrier)

    # change locally stored position
    carrier.x = x; carrier.y = y;
end

function pos(carrier::Carrier) = (carrier.x, carrier.y)
