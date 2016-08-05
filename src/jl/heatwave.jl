#== 
    Module for heatwave
==#

module Heatwave

# link up these bad boys
Libdl.dlopen("lib/libsfml-system", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libsfml-window", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libsfml-graphics", Libdl.RTLD_GLOBAL)
Libdl.dlopen("lib/libchw", Libdl.RTLD_GLOBAL)

using Reactive

include("sfml.jl")

export Vector2, Vector2i, Vector2u, Vector2f
export +, -, dot, norm

export Color
export +, -, *

include("sfml_events.jl")

export Event, EventType
export KeyEvent
export TextEvent
export MouseMoveEvent
export MouseButtonEvent
export MouseWheelEvent
export JoystickButtonEvent
export JoystickConnectEvent
export SizeEvent

include("terminal.jl")

export Terminal
export show, size, length, update
export TermSubArray

export TerminalView
export show, size, length, write

include("game.jl")

export Game
export tick, stop, start, get_term_dims, get_terminal

end
