Libdl.dlopen("lib/libsfml-system", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libsfml-window", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libsfml-graphics", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libchw", Libdl.RTLD_GLOBAL)

include("sfml.jl")
include("sfml_events.jl")
include("terminal.jl")

const term_dims = (160, 140)

# TODO: make some kind of julia wrapper for this
const hwgame = ccall(
    (:hwGame_create, "lib/libchw"), Ptr{Void}, 
    (Vector2u, Cstring, Vector2i, Cstring, Cint), 
    Vector2u(1280, 720), pointer(b"yer\0"), 
    Vector2i(term_dims[1], term_dims[2]), 
    pointer(b"assets/FSEX300.ttf\0"), Cint(15)
    )

const term = Terminal(term_dims[1], term_dims[2], hwgame)

# set random colors
for i in eachindex(term.bg_colors) 
    term.bg_colors[i] = Color(rand(UInt8), rand(UInt8), rand(UInt8)) 
end

r_factor = 1.0
g_factor = 1.0
b_factor = 1.0

function tick_game(x)

    for i in eachindex(term.bg_colors) 
        term.bg_colors[i] = Color(round(UInt8, rand(UInt8) * r_factor), 
            round(UInt8, rand(UInt8) * g_factor), round(UInt8, rand(UInt8) * b_factor))
        term.chs[i] = rand(UInt8)
    end
    
    # set the characters, background colors and char colors
    update(term)

    # test event polling
    n_events = ccall((:hwGame_getNumEvents, "lib/libchw"), Cuint, (Ptr{Void},), hwgame)
    for i = 0 : n_events - 1
        event = ccall((:hwGame_getEvent, "lib/libchw"), Ptr{Void}, (Ptr{Void}, Cuint), hwgame, i)
        event_type = ccall((:sfjlEvent_getType, "lib/libchw"), Cuint, (Ptr{Void},), event)

        if event_type == EventType.KEY_PRESSED 
            key_event = ccall((:sfjlEvent_getKeyEvent, "lib/libchw"), KeyEvent, (Ptr{Void},), event)
            println(key_event)

        elseif event_type == EventType.TEXT_ENTERED
            textEvent = ccall((:sfjlEvent_getTextEvent, "lib/libchw"), TextEvent, (Ptr{Void},), event)
            println(textEvent)
        end
    end

    # tick the game
    ccall((:hwGame_tick, "lib/libchw"), Void, (Ptr{Void},), hwgame)
end

using Reactive
ticks = fps(60)
game_signal = map(tick_game, ticks)
