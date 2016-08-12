using Reactive
using Lazy

# testing TextEntryBuffer
buf = Array{UInt32, 1}(20)
fill!(buf, 0x00000000)

teb = TextEntryBuffer(
    game.sfevent_router.dispatchers[EventType.TEXT_ENTERED], 
    buf
)

on_change_sig = Reactive.Signal(nothing)
cid = add_callback!(teb.on_change_dispatcher, let 
    on_change_sig = on_change_sig
    _ -> push!(on_change_sig, nothing)
end)

print_sig = @>> begin 

    game.tick_signal

    map(let buf = buf
        _ -> buf
    end)

    sampleon(on_change_sig)
    map(buf -> reinterpret(Char, buf))
    map(bch -> convert(String, bch))
    map(println)
end
