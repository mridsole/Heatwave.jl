# requires EventDispatcher and the list of SFML events
# what do we need to do here? need to listen for SFML events
# so really, we need some kind of event dispatcher that accepts SFML events
# but we should have a different dispatcher for each type of event?
# so really, this'll be an event ROUTER, not a dispatcher!

# some metaprogramming stuff for better runtime performance
# ("compiles" down to just an if statement)

const ed_symbols = (() -> begin 

    et_enum_names = filter(name -> name != :EventType, names(EventType, true))
    ed_symbols = Dict{Int64, Any}()
    
    for name in et_enum_names
        ed_symbols[getfield(EventType, name)] = Symbol(lowercase(string(name)))
    end

    return ed_symbols
end)()

# macro for constructing the big if statement for dispatching events
#macro (router_expr)
#
#    expr = quote if false end end
#
#    et_enum_names = filter(name -> name != :EventType, names(EventType, true))
#    
#    # every case will be an "else if" statement
#    for name in et_enum_names
#        
#    end
#end

# all this is just ... ugh. just store the dispatchers in a Di
type SFMLEventRouter

    dispatchers::Dict{Int64, Any}
end

function SFMLEventRouter()
    
    #@sfml_router_construct
    dispatchers = Dict{Int64, Any}(
        EventType.CLOSED => EventDispatcher(),
        EventType.RESIZED => EventDispatcher(),
        EventType.LOST_FOCUS => EventDispatcher(),
        EventType.GAINED_FOCUS => EventDispatcher(),
        EventType.TEXT_ENTERED => EventDispatcher(),
        EventType.KEY_PRESSED => EventDispatcher(),
        EventType.KEY_RELEASED => EventDispatcher(),
        EventType.MOUSE_WHEEL_MOVED => EventDispatcher(),
        EventType.MOUSE_BUTTON_PRESSED => EventDispatcher(),
        EventType.MOUSE_BUTTON_RELEASED => EventDispatcher(),
        EventType.MOUSE_MOVED => EventDispatcher(),
        EventType.MOUSE_ENTERED => EventDispatcher(),
        EventType.MOUSE_LEFT => EventDispatcher(),
        EventType.JOYSTICK_BUTTON_PRESSED => EventDispatcher(),
        EventType.JOYSTICK_BUTTON_RELEASED => EventDispatcher(),
        EventType.JOYSTICK_MOVED => EventDispatcher(),
        EventType.JOYSTICK_CONNECTED => EventDispatcher(),
        EventType.JOYSTICK_DISCONNECTED => EventDispatcher(),
        EventType.TOUCH_BEGAN => EventDispatcher(),
        EventType.TOUCH_MOVED => EventDispatcher(),
        EventType.TOUCH_ENDED => EventDispatcher(),
        EventType.SENSOR_CHANGED => EventDispatcher()
    )
    
    SFMLEventRouter(dispatchers)
end

function fire!(router::SFMLEventRouter, event::Event)
    
    # dispatch based on the type of the event
    etype = Int64(get_type(event))

    # use a macro to generate a big if statement here
    #SFMLEventRouter_macros.@sfml_router_dispatch 

    # performance ... ? could use a macro here
    typed_event = event_data_map[etype](event)

    # this is probably fine
    fire!(router.dispatchers[etype], typed_event)
end


