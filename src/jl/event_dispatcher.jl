using DataStructures

type EventDispatcher
    callbacks::OrderedDict{Int64, Any}
    this_callback_id::Int64
end

EventDispatcher() = EventDispatcher(OrderedDict{Int64, Any}(), -1)

function fire!(ed::EventDispatcher, event)

    for callback in values(ed.callbacks)
        callback(event)
    end
end

function add_callback!(ed::EventDispatcher, callback)

    ed.this_callback_id += 1
    ed.callbacks[ed.this_callback_id] = callback
    return ed.this_callback_id
end

function remove_callback!(ed::EventDispatcher, callback_id::Int64)

    delete!(ed.callbacks, callback_id);
end

import Base.getindex
getindex(ed::EventDispatcher, i::Int64) = ed.callbacks[i]
