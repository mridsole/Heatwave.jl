# represents the overall game window etc

type Game

    # signals controlling the game flow
    fps_signal::Reactive.Signal{Float64}
    game_tick_signal::Reactive.Signal{Void}

    # only have this as Game for multiple dispatch purposes
    ptr::Ptr{Game}

    # really should check the types of these
    function Game(window_size, window_name, term_dims, font_dir, font_size, fps=60)

        fps_signal = Reactive.fps(60)

        # we'll configure this properly after we get the game object
        game_tick_signal = map(dt -> nothing, fps_signal)

        ptr = ccall(
            (:hwGame_create, "lib/libchw"), Ptr{Void},
            (Vector2u, Cstring, Vector2i, Cstring, Cint),
            Vector2u(window_size[1], window_size[2]), pointer(window_name),
            Vector2i(term_dims[1], term_dims[2]),
            pointer(font_dir), Cint(font_size)
            ) |> Ptr{Game}

        game = new(fps_signal, game_tick_signal, ptr)

        # wait for the user to actually start the game
        Reactive.close(game.game_tick_signal)

        return game
     end
end

function tick(ptr::Ptr{Game})
    ccall((:hwGame_tick, "lib/libchw"), Void, (Ptr{Void},), ptr)
end

function tick(ptr::Ptr{Game}, dt::Float64)
    tick(ptr)
end

function tick(game::Game, dt::Float64)
    tick(game.ptr)
end

function stop(game::Game)
    Reactive.close(game.game_tick_signal)
end

function close(game::Game)

    # stop ticking the game asynchronously
    stop(game)

    # send the close signal to C++
end

import Base.start
function start(game::Game)
    game.game_tick_signal = map(dt -> tick(game, dt), game.fps_signal)
end

function get_term_dims(game::Game)

end

# currently in C++ a Terminal must be obtained from a Game
# this will probably change, but for now ...
function get_terminal(game::Game)
    
    term_ptr = ccall((:hwGame_getTerminal, "lib/libchw"), Ptr{Void}, (Ptr{Void},), game.ptr)
    Terminal(term_ptr)
end
