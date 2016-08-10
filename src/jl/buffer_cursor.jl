#==
    Utility for keeping track of position within a buffer (for example 
    when writing user input to some part of the terminal)

    Not intended for high performance writing!

    Further note: this is not intended to be used directly with input -
    this is just a tool for moving around the 2D terminal. 
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
        cursor.pos = max(min(length(cursor.buf), cursor.pos + i), 1)
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

# write and advance
function write!{T}(cursor::BufferCursor{T}, ch, wrap::Bool = false)

    # some certain special cases
    if ch == UInt32('\b')
        advance!(cursor, -1, wrap)
        cursor.buf[cursor.pos] = UInt32(' ')

    elseif ch == UInt32('\r')
        advance_line!(cursor, 1, wrap)
    
    else
        cursor.buf[cursor.pos] = UInt32(ch)
        advance!(cursor, 1, wrap)
    end
end
