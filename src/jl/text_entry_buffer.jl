#==
    Utility to capture text input from the user. Listens to a SFMLEventRouter
    and processes data accordingly.
==#

type TextEntryBuffer{BufT}
    
    # the event dispatcher to listen to
    dispatcher::EventDispatcher
    text_entered_cid::Int64
    write_buffer::BufT
    cursor::BufferCursor{BufT}
end

function TextEntryBuffer{BufT}(dispatcher::EventDispatcher, wbuf::BufT)

    # create the cursor
    cursor = BufferCursor(wbuf)
    
    # create the object
    teb = TextEntryBuffer(dispatcher, 0, wbuf, cursor)

    # bind to the dispatcher
    bind!(teb, dispatcher)

    return teb
end

function TextEntryBuffer(router::SFMLEventRouter)

    teb = TextEntryBuffer(router.dispatchers[EventType.TEXT_ENTERED])
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

function on_text_entered(teb::TextEntryBuffer, ev::TextEvent)
    
    # process the data here 
    # for now just write the data in directly
    #if ev.unicode == UInt32('\b')
    #    println("remove a char now!")
    #end

    write!(teb.cursor, ev.unicode)
end
