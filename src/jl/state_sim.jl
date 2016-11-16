#==
    Stores the overall state of the simulation (including grids and lists etc)
    Defining methods on this like wall_at(::StateSim, ...) might be a good idea
    Also give state objects upward reference to this?
==#

typealias StateObjectArray Array{StateObject, 1}
typealias CarrierGrid Array{Nullable{StateObject}, 2}
typealias FloorGrid Array{Nullable{FloorObject}, 2}

type StateSim

    sobjs::StateObjectArray

    carrier_grid::
end

export StateSim
