module HeatwaveDebug

using Reactive

function tick_game(dt)
    
    println("hey: ", dt)
end

# don't worry about type stability for now ..
ticks = fps(60)
game_signal = map(tick_game, ticks)

end

# represents the overall game window etc
type Game

    # signals controlling the game flow
    fps_signal::Reactive.Signal{Float64}
    game_signal::Reactive.Signal{nothing}

    ptr::Ptr{Void}

    Game()
end

stop(game
