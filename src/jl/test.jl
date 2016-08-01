Libdl.dlopen("libsfml-system", Libdl.RTLD_GLOBAL)
Libdl.dlopen("libsfml-window", Libdl.RTLD_GLOBAL)
Libdl.dlopen("libsfml-graphics", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libchw", Libdl.RTLD_GLOBAL)

include("sfml.jl")
include("terminal.jl")

const term_dims = (160, 40)

# TODO: make some kind of julia wrapper for this
const hwgame = ccall((:hwGame_create, "lib/libchw"), Ptr{Void}, (Vector2u, Cstring, Vector2i, Cstring, Cint), 
    Vector2u(1280, 720), pointer(b"yer\0"), Vector2i(term_dims[1], term_dims[2]), pointer(b"assets/FSEX300.ttf\0"), Cint(16))

const term = Terminal(term_dims[1], term_dims[2], hwgame)

const term_chars = Array{UInt32, 2}(term_dims[1], term_dims[2])
fill!(term_chars, 0x00000000)

const term_char_colors = Array{Color, 2}(term_dims[1], term_dims[2])
fill!(term_char_colors, Color(0x00, 0xF0, 0x00, 0xFF))

const term_bg_colors = Array{Color, 2}(term_dims[1], term_dims[2])
fill!(term_bg_colors, Color(0x00, 0x40, 0x00, 0xFF))

function tick_game(x)
    
    # set the characters, background colors and char colors
    update(term)

    # slightly darken
    #for i = 1:term_dims[1], j = 1:term_dims[2]
    #    term_char_colors[i, j] = 0.95 * term_char_colors[i, j]
    #    term_bg_colors[i, j] = 0.97 * term_bg_colors[i, j]
    #end

    # tick the game
    ccall((:hwGame_tick, "lib/libchw"), Void, (Ptr{Void},), hwgame)
end

using Reactive
ticks = fps(60)
game_signal = map(tick_game, ticks)
