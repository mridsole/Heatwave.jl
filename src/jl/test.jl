Libdl.dlopen("libsfml-system", Libdl.RTLD_GLOBAL)
Libdl.dlopen("libsfml-window", Libdl.RTLD_GLOBAL)
Libdl.dlopen("libsfml-graphics", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libchw", Libdl.RTLD_GLOBAL)

include("sfml.jl")
include("terminal.jl")

const term_dims = (160, 140)

# TODO: make some kind of julia wrapper for this
const hwgame = ccall((:hwGame_create, "lib/libchw"), Ptr{Void}, (Vector2u, Cstring, Vector2i, Cstring, Cint), 
    Vector2u(1280, 720), pointer(b"yer\0"), Vector2i(term_dims[1], term_dims[2]), pointer(b"assets/FSEX300.ttf\0"), Cint(15))

const term = Terminal(term_dims[1], term_dims[2], hwgame)

# set random colors
for i in eachindex(term.bg_colors) 
    term.bg_colors[i] = Color(rand(UInt8), rand(UInt8), rand(UInt8)) 
end

function tick_game(x)

    for i in eachindex(term.bg_colors) 
        term.bg_colors[i] = Color(0x00, rand(UInt8), 0x00) * 0.4
        term.chs[i] = rand(UInt8)
    end

    # slightly darken
    #for i = 1:term_dims[1], j = 1:term_dims[2]
    #    term.bg_colors[i, j] -= 8
    #end
    
    # set the characters, background colors and char colors
    update(term)

    # tick the game
    ccall((:hwGame_tick, "lib/libchw"), Void, (Ptr{Void},), hwgame)
end

using Reactive
ticks = fps(60)
game_signal = map(tick_game, ticks)
