Libdl.dlopen("libsfml-system", Libdl.RTLD_GLOBAL)
Libdl.dlopen("libsfml-window", Libdl.RTLD_GLOBAL)
Libdl.dlopen("libsfml-graphics", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libchw", Libdl.RTLD_GLOBAL)

immutable Vector2u
    x::UInt32
    y::UInt32
end

immutable Vector2i
    x::Int32
    y::Int32
end

immutable Color
    r::UInt8
    g::UInt8
    b::UInt8
    a::UInt8

    Color(r::UInt8, g::UInt8, b::UInt8, a::UInt8) = new(r, g, b, a)
    Color(r::UInt8, g::UInt8, b::UInt8) = new(r, g, b, 0xFF)

    Color(r::Float64, g::Float64, b::Float64) =
        new(round(UInt8, r * 255), round(UInt8, g * 255), round(UInt8, b * 255), 0xFF)

    Color(r::Float64, g::Float64, b::Float64, a::UInt8) = 
        new(round(UInt8, r * 255), round(UInt8, g * 255), round(UInt8, b * 255), a)

    Color(r::Float64, g::Float64, b::Float64, a::Float64) = 
        new(round(UInt8, r * 255), round(UInt8, g * 255), round(UInt8, b * 255), round(UInt8, a * 255))
end

const hwgame = ccall((:hwGame_create, "lib/libchw"), Ptr{Void}, (Vector2u, Cstring, Vector2i, Cstring, Cint), 
    Vector2u(1280, 720), pointer(b"yer\0"), Vector2i(150, 50), pointer(b"assets/FSEX300.ttf\0"), Cint(16))

const hwterm = ccall((:hwGame_getTerminal, "lib/libchw"), Ptr{Void}, (Ptr{Void},), hwgame)

const term_chars = Array{UInt32, 2}(150, 50)
fill!(term_chars, 0x00000000)

const term_char_colors = Array{Color, 2}(150, 50)
fill!(term_char_colors, Color(0x00, 0xF0, 0x00, 0xFF))

const term_bg_colors = Array{Color, 2}(150, 50)
fill!(term_bg_colors, Color(0x00, 0x40, 0x00, 0xFF))

function tick_game(x)
    
    # set the characters, background colors and char colors
    ccall((:hwTerminal_setAllChars, "lib/libchw"), Void, (Ptr{Void}, Ptr{UInt32}), hwterm, pointer(term_chars))
    ccall((:hwTerminal_setAllCharColors, "lib/libchw"), Void, (Ptr{Void}, Ptr{Color}), hwterm, pointer(term_char_colors))
    ccall((:hwTerminal_setAllBgColors, "lib/libchw"), Void, (Ptr{Void}, Ptr{Color}), hwterm, pointer(term_bg_colors))

    # performance test
    for i = 20:150, j = 1:50
        ccall((:hwTerminal_setBgColor, "lib/libchw"), Void, (Ptr{Void}, Color, Cuint, Cuint), 
            hwterm, Color(0., 0.1, 0.9, 1.0), Cuint(i - 1), Cuint(j - 1))
    end

    # tick the game
    ccall((:hwGame_tick, "lib/libchw"), Void, (Ptr{Void},), hwgame)
end

using Reactive
ticks = fps(60)
game_signal = map(tick_game, ticks)

# ccall((:hwTerminal_setChar, "lib/libchw"), Void, (Ptr{Void}, Cchar, UInt32, UInt32), term, UInt8('a'), UInt32(10), UInt32(10))
