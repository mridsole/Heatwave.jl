#== 
    For using SFML's events directly. The event types here are taken from
    SFML.jl - the C and C++ versions have the same memory layouts, I think 
==#

immutable Event
    ptr::Ptr{Void}
end

function get_type(event::Event)
    return ccall((:sfjlEvent_getType, "lib/libchw"), Cint, (Ptr{Void},), event.ptr)
end

# type for no event data
immutable NoDataEvent

end

# TODO: in C++, an enum is used for code, and bools are used
# for the other four members. the standard doesn't guarentee the
# size of these so this is dangerous - fix it
immutable KeyEvent
    code::Cint
    alt::Cchar
    control::Cchar
    shift::Cchar
    system::Cchar
end

immutable TextEvent
    unicode::UInt32
end

immutable MouseMoveEvent
    x::Cint
    y::Cint
end

immutable MouseButtonEvent
    button::Cint
    x::Cint
    y::Cint
end

immutable MouseWheelEvent
    delta::Cint
    x::Cint
    y::Cint
end

# nah
#type JoystickMoveEvent
#    etype::Cint
#    joystick_id::UInt32
#    axis::JoystickAxis
#    position::Cfloat
#end

immutable JoystickButtonEvent
    joystick_id::UInt32
    button::UInt32
end

immutable JoystickConnectEvent
    joystick_id::UInt32;
end

immutable SizeEvent
    width::UInt32
    height::UInt32
end

function NoDataEvent(event::Event)
    NoDataEvent()
end

function KeyEvent(event::Event)
    ccall((:sfjlEvent_getKeyEvent, "lib/libchw"), KeyEvent, (Ptr{Void},), event.ptr)
end

function TextEvent(event::Event)
    ccall((:sfjlEvent_getTextEvent, "lib/libchw"), TextEvent, (Ptr{Void},), event.ptr)
end

function MouseMoveEvent(event::Event)
    ccall((:sfjlEvent_getMouseMoveEvent, "lib/libchw"), MouseMoveEvent, 
        (Ptr{Void},), event.ptr)
end

function MouseButtonEvent(event::Event)
    ccall((:sfjlEvent_getMouseButtonEvent, "lib/libchw"), MouseButtonEvent, 
        (Ptr{Void},), event.ptr)
end

function MouseWheelEvent(event::Event)
    ccall((:sfjlEvent_getMouseWheelEvent, "lib/libchw"), MouseWheelEvent, 
        (Ptr{Void},), event.ptr)
end

function JoystickButtonEvent(event::Event)
    ccall((:sfjlEvent_getJoystickButtonEvent, "lib/libchw"), JoystickButtonEvent, 
        (Ptr{Void},), event.ptr)
end

function JoystickConnectEvent(event::Event)
    ccall((:sfjlEvent_getJoystickConnectEvent, "lib/libchw"), JoystickConnectEvent,
        (Ptr{Void},), event.ptr)
end

function SizeEvent(event::Event)
    ccall((:sfjlEvent_getSizeEvent, "lib/libchw"), SizeEvent, (Ptr{Void},), event.ptr)
end

# generate expression for an enum type
# this can't be a macro because module definitions must be at the top level
function bare_enum(name, start, args...)
    
    module_body = quote end

    i = Int64(start)
    
    for arg in args
        push!(module_body.args, :(const $(arg) = $(i)))
        i += 1
    end

    Expr(:module, false, name, module_body)
end

bare_enum(:EventType, 0,
    :CLOSED,
    :RESIZED,
    :LOST_FOCUS,
    :GAINED_FOCUS,
    :TEXT_ENTERED,
    :KEY_PRESSED,
    :KEY_RELEASED,
    :MOUSE_WHEEL_MOVED,
    :MOUSE_WHEEL_SCROLLED,
    :MOUSE_BUTTON_PRESSED,
    :MOUSE_BUTTON_RELEASED,
    :MOUSE_MOVED,
    :MOUSE_ENTERED,
    :MOUSE_LEFT,
    :JOYSTICK_BUTTON_PRESSED,
    :JOYSTICK_BUTTON_RELEASED,
    :JOYSTICK_MOVED,
    :JOYSTICK_CONNECTED,
    :JOYSTICK_DISCONNECTED,
    :TOUCH_BEGAN,
    :TOUCH_MOVED,
    :TOUCH_ENDED,
    :SENSOR_CHANGED
) |> eval

# for convenience - map event types to the corresponding event data
event_data_map = Dict{Int64, Any}(
    EventType.CLOSED => NoDataEvent,
    EventType.RESIZED => SizeEvent,
    EventType.LOST_FOCUS => NoDataEvent,
    EventType.GAINED_FOCUS => NoDataEvent,
    EventType.TEXT_ENTERED => TextEvent,
    EventType.KEY_PRESSED => KeyEvent,
    EventType.KEY_RELEASED => KeyEvent,
    EventType.MOUSE_WHEEL_MOVED => MouseWheelEvent,
    EventType.MOUSE_WHEEL_SCROLLED => MouseWheelEvent,
    EventType.MOUSE_BUTTON_PRESSED => MouseButtonEvent,
    EventType.MOUSE_BUTTON_RELEASED => MouseButtonEvent,
    EventType.MOUSE_MOVED => MouseMoveEvent,
    EventType.MOUSE_ENTERED => NoDataEvent,
    EventType.MOUSE_LEFT => NoDataEvent,
    EventType.JOYSTICK_BUTTON_PRESSED => JoystickButtonEvent,
    EventType.JOYSTICK_BUTTON_RELEASED => JoystickButtonEvent,
    #EventType.JOYSTICK_MOVED => JoystickMoveEvent,
    EventType.JOYSTICK_CONNECTED => JoystickConnectEvent,
    EventType.JOYSTICK_DISCONNECTED => JoystickConnectEvent,
    #EventType.TOUCH_BEGAN => TouchEvent,
    #EventType.TOUCH_MOVED => TouchEvent,
    #EventType.TOUCH_ENDED => TouchEvent,
    #EventType.SENSOR_CHANGED => SensorEvent
)

# enum for key codes (in KeyEvent)
bare_enum(:KeyCodes, -1,
    :Unknown,
    :A, :B, :C, :D, :E, :F, :G, :H, :I, :J,
    :K, :L, :M, :N, :O, :P, :Q, :R, :S, :T,
    :U, :V, :W, :X, :Y, :Z,
    :Num0, :Num1, :Num2, :Num3, :Num4,
    :Num5, :Num6, :Num7, :Num8, :Num9,
    :Escape, :LControl, :LShift,
    :LAlt, :LSystem, :RControl, :RShift,
    :RAlt, :RSystem, :Menu, :LBracket,
    :RBracket, :SemiColon, :Comma,
    :Period, :Quote, :Slash, :BackSlash,
    :Tilde, :Equal, :Dash, :Space, :Return,
    :BackSpace, :Tab, :PageUp, :PageDown,
    :End, :Home, :Insert, :Divide,
    :Left, :Right, :Up, :Down,
    :Numpad0, :Numpad1, :Numpad2, :Numpad3,
    :Numpad4, :Numpad5, :Numpad6, :Numpad7,
    :Numpad8, :Numpad9, :F1, :F2,
    :F3, :F4, :F5, :F6, :F7, :F8, :F9,
    :F10, :F11, :F12, :F13, :F14, :F15,
    :Pause, :KeyCount
) |> eval
