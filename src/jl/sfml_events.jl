#== For using SFML's events directly. The event types here are taken from
    SFML.jl - the C and C++ versions have the same memory layouts, I think ==#

type Event
    ptr::Ptr{Void}
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
    const MOUSE_BUTTON_PRESSED = 8
    const MOUSE_BUTTON_RELEASED = 9
    const MOUSE_MOVED = 10
    const MOUSE_ENTERED = 11
    const MOUSE_LEFT = 12
    const JOYSTICK_BUTTON_PRESSED = 13
    const JOYSTICK_BUTTON_RELEASED = 14
    const JOYSTICK_MOVED = 15
    const JOYSTICK_CONNECTED = 16
    const JOYSTICK_DISCONNECTED = 17
    const TOUCH_BEGAN = 18
    const TOUCH_MOVED = 19
    const TOUCH_ENDED = 20
    const SENSOR_CHANGED = 21
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

type TextEvent
    etype::Cint
    unicode::UInt32
end

type MouseMoveEvent
    etype::Cint
    x::Cint
    y::Cint
end

type MouseButtonEvent
    etype::Cint
    button::Cint
    x::Cint
    y::Cint
end

type MouseWheelEvent
    etype::Cint
    delta::Cint
    x::Cint
    y::Cint
end

#type JoystickMoveEvent
#    etype::Cint
#    joystick_id::UInt32
#    axis::JoystickAxis
#    position::Cfloat
#end

type JoystickButtonEvent
    etype::Cint
    joystick_id::UInt32
    button::UInt32
end

type JoystickConnectEvent
    etype::Cint
    joystick_id::UInt32;
end

type SizeEvent
    etype::Cint
    width::UInt32
    height::UInt32
end
