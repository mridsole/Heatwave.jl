#== For using SFML's events directly. The event types here are taken from
    SFML.jl - the C and C++ versions have the same memory layouts, I think ==#

immutable Event
    ptr::Ptr{Void}
end

function get_type(event::Event)
    return ccall((:sfjlEvent_getType, "lib/libchw"), Cint, (Ptr{Void},), event.ptr)
end

# from SFML.jl - nice way of emulating a C enum
baremodule EventType

    const CLOSED = 0
    const RESIZED = 1
    const LOST_FOCUS = 2
    const GAINED_FOCUS = 3
    const TEXT_ENTERED = 4
    const KEY_PRESSED = 5
    const KEY_RELEASED = 6
    const MOUSE_WHEEL_MOVED = 7
    const MOUSE_WHEEL_SCROLLED = 8
    const MOUSE_BUTTON_PRESSED = 9
    const MOUSE_BUTTON_RELEASED =10 
    const MOUSE_MOVED = 11
    const MOUSE_ENTERED = 12
    const MOUSE_LEFT = 13
    const JOYSTICK_BUTTON_PRESSED = 14
    const JOYSTICK_BUTTON_RELEASED = 15
    const JOYSTICK_MOVED = 16
    const JOYSTICK_CONNECTED = 17
    const JOYSTICK_DISCONNECTED = 18
    const TOUCH_BEGAN = 19
    const TOUCH_MOVED = 20
    const TOUCH_ENDED = 21
    const SENSOR_CHANGED = 22
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
