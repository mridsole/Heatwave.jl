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

# wow
print_sig = @>> begin 

    game.tick_signal

    map(let buf = buf
        _ -> buf
    end)

    Reactive.sampleon(on_change_sig)
    map(buf -> reinterpret(Char, buf))
    map(bch -> convert(String, bch))
    map(println)
end

# now test some state transistion
grid_dims = (30, 30)
cg = CarrierGrid(grid_dims...)
fill!(cg, Nullable{Carrier}())
cl = CarrierList()
carrier = Carrier(cg, cl, 5, 5, 1, 1)
srg = StateRenderGrid(grid_dims...)
@> srg.generators push!(cg)
tv = TerminalView(term, 1:grid_dims[1], 1:grid_dims[2])

function tick()
    
    foreach(tick!, cl)
    foreach(flush!, cl)
    generate!(srg)
    write!(tv, srg.chs)
end
