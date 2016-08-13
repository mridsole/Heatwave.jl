#==
    Utility for keeping track of position within a buffer (for example 
    when writing user input to some part of the terminal)

    Not intended for high performance writing!

    Further note: this is not intended to be used directly with input -
    this is just a tool for moving around the 2D terminal. 

    (Can also be used for one dimensional buffers.)
==#

type BufferCursor{BufferT}

    buf::BufferT
    pos::Int64
end

# 2 pm ...
function BufferCursor{BufT}(buf::BufT)
    
    BufferCursor(buf, 1)
end

function advance!{T}(cursor::BufferCursor{T}, i::Int64, wrap::Bool = false)
    
    if wrap
        cursor.pos = mod1(cursor.pos + i, length(cursor.buf))
    else
        cursor.pos = max(min(length(cursor.buf) + 1, cursor.pos + i), 1)
    end
end

function advance_line!{T}(cursor::BufferCursor{T}, i::Int64, wrap::Bool = false)
    
    line_length = size(cursor.buf)[1]
    line_pos = mod1(cursor.pos, line_length)

    if wrap
        cursor.pos = mod1(cursor.pos + (line_length - line_pos + 1), line_length)
    else
        cursor.pos = min(length(cursor.buf) - line_length + 1, cursor.pos + 
            (line_length - line_pos + 1))
    end
end

function backspace!{T}(cursor::BufferCursor{T})
    
    # delete the previous character and shift everything in front back one space
    # by 'delete', I mean replace with the null character. 

    # if we're at the start, do nothing
    if cursor.pos == 1 return end

    # move back one position
    cursor.pos -= 1

    # bring every character backwards by one
    for i = cursor.pos : (length(cursor.buf) - 1)
        cursor.buf[i] = cursor.buf[i + 1]
    end

    # zero out last character
    cursor.buf[end] = UInt32(0)
end

# write and advance
function write!{T}(cursor::BufferCursor{T}, ch, wrap::Bool = false)

    # just write the data in and advance
    at!(cursor, ch)
    advance!(cursor, 1, wrap)
end

# write a string (just call advance a few times)
function write!{T}(cursor::BufferCursor{T}, chs::Array, wrap::Bool = false)
    
    for ch in chs
        write!(cursor, ch, wrap)
    end
end

# get the character under the cursor
function at{T}(cursor::BufferCursor{T}, offset::Int = 0)
    return (cursor.pos + offset) in 1:length(cursor.buf) ? 
        cursor.buf[cursor.pos + offset] : UInt32(0)
end

# set with bounds checking
function at!{T}(cursor::BufferCursor{T}, ch)
    if cursor.pos in 1:length(cursor.buf)
        cursor.buf[cursor.pos] = ch
    end
end
