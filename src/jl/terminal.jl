#== Utilities for managing the char, char color and bg color buffers used when
    rendering the terminals. ==#

# main terminal type, 'owns' the memory etc
type Terminal

    chs::Array{UInt32, 2}
    ch_colors::Array{Color, 2}
    bg_colors::Array{Color, 2}

    ptr::Ptr{Void}
end

function Terminal(ptr::Ptr{Void})

    term_dims = ccall((:hwTerminal_getDims, "lib/libchw"), Vector2i, 
        (Ptr{Void},), ptr)

    x = term_dims.x
    y = term_dims.y

    this = Terminal(Array{UInt32, 2}(x, y), Array{Color, 2}(x, y), 
        Array{Color, 2}(x, y), ptr)

    # some reasonable defaults
    fill!(this.chs, '+')
    fill!(this.ch_colors, Color(0xFF, 0xFF, 0xFF, 0xFF))
    fill!(this.bg_colors, Color(0x00, 0x00, 0x00, 0xFF))

    return this
end

import Base.show
function Base.show(io::IO, x::Terminal)
    println(io, "Terminal(", size(x.chs)[1], ", ", size(x.chs)[2], ")")
end

import Base.size
Base.size(term::Terminal) = size(term.chs)

import Base.length
Base.length(term::Terminal) = length(term.chs)

# updates the internal display mechanisms to match the buffered data
# TODO: this isn't cheap on slower CPUs! find some other way
function update(term::Terminal)

    ccall((:hwTerminal_setAllChars, "lib/libchw"), Void, 
        (Ptr{Void}, Ptr{UInt32}), term.ptr, pointer(term.chs))
    ccall((:hwTerminal_setAllCharColors, "lib/libchw"), Void, 
        (Ptr{Void}, Ptr{Color}), term.ptr, pointer(term.ch_colors))
    ccall((:hwTerminal_setAllBgColors, "lib/libchw"), Void, 
        (Ptr{Void}, Ptr{Color}), term.ptr, pointer(term.bg_colors))
end

# parameterized abbreviations for rectangular sub arrays
typealias TermSubArray{T} SubArray{T, 2, Array{T, 2}, Tuple{UnitRange{Int64}, 
    UnitRange{Int64}}, false}

# utility type for viewing a portion of a terminal, or another view
# the views are with respect to the parent's views
type TerminalView
    
    chs::TermSubArray{UInt32}
    ch_colors::TermSubArray{Color}
    bg_colors::TermSubArray{Color}
end

function TerminalView(term, i::UnitRange{Int64}, j::UnitRange{Int64})

    return TerminalView(view(term.chs, i, j), view(term.ch_colors, i, j), 
        view(term.bg_colors, i, j))
end

import Base.size
Base.size(tv::TerminalView) = size(tv.chs)

import Base.length
Base.length(tv::TerminalView) = length(tv.chs)

function write!(term::Union{Terminal, TerminalView}, data, i::Int,
    wrap::Bool = false)
    
    if wrap
        # if we overflow then start writing at the beginning too
        for k = 1:length(data)
            term.chs[mod1(k + i - 1, length(term))] = data[k]
        end
    else
        # if we reach the end do nothing
        write_range = i:min(length(term), length(data) + i - 1)
        for k in write_range term.chs[k] = data[k - i + 1] end
    end
end

function write!(term::Union{Terminal, TerminalView}, data, i::Int, 
    j::Int, wrap::Bool = false)
    
    write!(term, data, (j - 1) * size(term)[1] + i, wrap)
end

function write!(term::Union{Terminal, TerminalView}, data, wrap::Bool = false)
    
    write!(term, data, 1, wrap)
end

function write!{T}(dst::Union{Array{T, 2}, TermSubArray{T}}, data::Array{T, 1}, 
    i::Int, wrap::Bool = false)
    
    if wrap
        # if we overflow then start writing at the beginning too
        for k = 1:length(data)
            dst[mod1(k + i - 1, length(dst))] = data[k]
        end
    else
        # if we reach the end do nothing
        write_range = i:min(length(dst), length(data) + i - 1)
        for k in write_range
            dst[k] = data[k - i + 1]
        end

        println(write_range)
    end
end

function write!{T}(dst::Union{Array{T, 2}, TermSubArray{T}}, data::Array{T, 1}, 
    i::Int, j::Int, wrap::Bool = false)
    
    write!(dst, data, (j - 1) * size(dst)[1] + i, wrap)
end

function write!{T}(dst::Union{Array{T, 2}, TermSubArray{T}}, data::Array{T, 1}, 
    wrap::Bool = false)
    
    write!(dst, data, 1, wrap)
end
