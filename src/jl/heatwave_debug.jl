include("heatwave.jl")

module HeatwaveDebug

using Heatwave

print("Heatwave debugging session - enter tty name: ")

# redirect standard output to a terminal of choice
tty_name = STDIN |> readline |> chomp
tty = open(tty_name, "w")
redirect_stdout(tty)

# flush every now and then
@async begin
    while true
        sleep(0.2)
        flush(tty)
    end
end

config = Dict(
    :window_dims => (1280, 720),
    :window_title => b"Heatwave\0",
    :term_dims => (150, 50),
    :font_path => b"assets/FSEX300.ttf\0",
    :char_size => 15
)

config_print(x) = print(x)
config_print(x::Array{UInt8, 1}) = print(ASCIIString(x))

println("\nDEFAULT CONFIGURATION: \n")
for key in keys(config)
    print(string(key) * ": \t\t")
    config_print(config[key])
    print("\n")
end
print("\n")

game = Game(
    config[:window_dims], 
    config[:window_title], 
    config[:term_dims], 
    config[:font_path], 
    config[:char_size]
    )

term = get_terminal(game)

# now ...
start(game)

export game
export term

end

using Heatwave
using HeatwaveDebug
