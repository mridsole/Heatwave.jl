#== some utilities for interfacing with SFML types - where possible, I will 
    refrain from using SFML directly from Julia - but there are some elementary
    types that are useful to have.  ==# 

immutable Vector2{T}
    x::T
    y::T
end

# use these for ccalling sf::Vertex2<...>
typealias Vector2i Vector2{Int32}
typealias Vector2u Vector2{UInt32}
typealias Vector2f Vector2{Float32}

import Base.+
function +{T}(v1::Vector2{T}, v2::Vector2{T})
    return Vector2{T}(v1.x + v2.x, v1.y + v2.y)
end

import Base.-
function -{T}(v1::Vector2{T}, v2::Vector2{T})
    return Vector2{T}(v1.x - v2.x, v1.y - v2.y)
end

import Base.dot
function dot{T}(v1::Vector2{T}, v2::Vector2{T})
    return v1.x * v2.x + v1.y * v2.y
end

import Base.norm
function norm{T}(v1::Vector2{T})
    return sqrt(v1.x ^2 + v1.y ^2)
end

# use this for ccalling sf::Color
immutable Color
    r::UInt8
    g::UInt8
    b::UInt8
    a::UInt8

    Color(r::UInt8, g::UInt8, b::UInt8, a::UInt8) = new(r, g, b, a)
    Color(r::UInt8, g::UInt8, b::UInt8) = new(r, g, b, 0xFF)

    Color(r::Float64, g::Float64, b::Float64) =
        new(round(UInt8, r * 255), round(UInt8, g * 255), 
            round(UInt8, b * 255), 0xFF)

    Color(r::Float64, g::Float64, b::Float64, a::UInt8) = 
        new(round(UInt8, r * 255), round(UInt8, g * 255), 
            round(UInt8, b * 255), a)

    Color(r::Float64, g::Float64, b::Float64, a::Float64) = 
        new(round(UInt8, r * 255), round(UInt8, g * 255), 
            round(UInt8, b * 255), round(UInt8, a * 255))
end

import Base.+
function +(c::Color, x::Int)
    return Color(c.r + UInt8(x), c.g + UInt8(x), c.b + UInt8(x), c.a)
end

import Base.-
function -(c::Color, x::Int)
    return Color(c.r - UInt8(x), c.g - UInt8(x), c.b - UInt8(x), c.a)
end

import Base.*
function *(c::Color, x::Float64)
    return Color(round(UInt8, c.r * x), round(UInt8, c.g * x), 
        round(UInt8, c.b * x), c.a)
end

*(x::Float64, c::Color) = c * x
