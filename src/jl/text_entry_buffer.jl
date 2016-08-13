#==
    Utility to capture text input from the user. Listens to a SFMLEventRouter
    and processes data accordingly.

    I'm going to change this to work with 1D buffers rather than 2D.
    Then if we're just entering text, make a renderer class. (using the cursor)
==#

type TextEntryBuffer{BufT}
    
    # the event dispatcher to listen to
    dispatcher::EventDispatcher

    # callback ID for the text event dispatcher
    text_entered_cid::Int64

    # the buffer to write the entered text to
    write_buffer::BufT

    # cursor for that buffer (stores position state)
    cursor::BufferCursor{BufT}

    # are we currently listening?
    listening::Bool

    # fire to this dispatcher whenever the buffer changes
    on_change_dispatcher::EventDispatcher
end

function TextEntryBuffer{BufT}(dispatcher::EventDispatcher, wbuf::BufT)

    # create the cursor
    cursor = BufferCursor(wbuf)
    
    # create the object
    teb = TextEntryBuffer(dispatcher, 0, wbuf, cursor, true, EventDispatcher())

    # bind to the dispatcher
    bind!(teb, dispatcher)

    return teb
end

function TextEntryBuffer{BufT}(router::SFMLEventRouter, wbuf::BufT)

    teb = TextEntryBuffer(router.dispatchers[EventType.TEXT_ENTERED], wbuf)
end

# check / start / stop listening
function listening(teb::TextEntryBuffer)
    return teb.listening
end

function listening!(teb::TextEntryBuffer, x::Bool)
    teb.listening = x
end

# bind to a different dispatcher
function bind!(teb::TextEntryBuffer, dispatcher::EventDispatcher)
    
    # unbind from the current router
    remove_callback!(dispatcher, teb.text_entered_cid)

    # bind to the new router
    teb.dispatcher = dispatcher
    teb.text_entered_cid = add_callback!(dispatcher, 
        ev -> on_text_entered(teb, ev))
end

function bind!(teb::TextEntryBuffer)
    bind!(teb, teb.dispatcher)
end

function unbind!(teb::TextEntryBuffer)
    
    remove_callback!(teb.dispatcher, teb.text_entered_cid)
end

function on_text_entered(teb::TextEntryBuffer, ev::TextEvent)

    if !teb.listening return end
    
    if ev.unicode == UInt32('\b')
        backspace!(teb.cursor)
        
    else
        write!(teb.cursor, ev.unicode)
    end

    # fire the on change dispatcher
    fire!(teb.on_change_dispatcher, teb)
end
