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
cmm = CarrierMoveMap(grid_dims...)
fill!(cmm, 0)
cl = CarrierList()
carrier = Carrier(cg, cl, cmm, 5, 5, 1, 1, CarrierStatePhase.CHOOSE)
srg = StateRenderGrid(grid_dims...)
@> srg.generators push!(cg)
tv = TerminalView(term, 1:grid_dims[1], 1:grid_dims[2])

function try_make_carrier()
    xn, yn = (rand(1:20), rand(1:20))
    if cg[xn, yn].isnull
        Carrier(cg, cl, cmm, xn, yn, rand(0:4), 1, CarrierStatePhase.CHOOSE)
    end
    return cg[xn, yn]
end

for i = 1:2000 try_make_carrier() end

function tick()
    
    # We only want to reset the move map at the start of the choose phase
    # this is really a hack for now
    if cl[1].state.phase == CarrierStatePhase.CHOOSE
        fill!(cmm, 0)
    end
    foreach(tick!, cl)
    foreach(flush!, cl)
    generate!(srg)
    write!(tv, srg.chs)
end

map(dt->begin tick(); println(dt) end, fps(10))
