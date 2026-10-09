### plot-recipes.jl
#
# Maintainer: Mosè Giordano <mose AT gnu DOT org>
# Keywords: uncertainty, error propagation, physics, plots
#
# This file is a part of Measurements.jl.
#
# License is MIT "Expat".
#
### Commentary:
#
# This file defines the recipes to plot Measurements vectors with Makie.jl package in 2D.
#
### Code:
module MeasurementsMakieExt

using Measurements: Measurement, value, uncertainty
using Makie: Makie, PointBased, Errorbars, Band

# PointBased plots
Makie.convert_arguments(P::PointBased, x::AbstractVector{<:Measurement}, y::AbstractVector{<:Measurement}) =
    Makie.convert_arguments(P, value.(x), value.(y))
Makie.convert_arguments(P::PointBased, x::AbstractVector{<:Real}, y::AbstractVector{<:Measurement}) =
    Makie.convert_arguments(P, x, value.(y))
Makie.convert_arguments(P::PointBased, x::AbstractVector{<:Measurement}, y::AbstractVector{<:Real}) =
    Makie.convert_arguments(P, value.(x), y)

# errorbars
Makie.convert_arguments(P::Type{<:Errorbars}, x::AbstractVector{<:Measurement}, y::AbstractVector{<:Measurement}, e::AbstractVector{<:Measurement}) =
    Makie.convert_arguments(P, value.(x), value.(y), uncertainty.(e))
Makie.convert_arguments(P::Type{<:Errorbars}, x::AbstractVector{<:Measurement}, y::AbstractVector{<:Real}) =
    Makie.convert_arguments(P, value.(x), y, uncertainty.(x))
Makie.convert_arguments(P::Type{<:Errorbars}, x::AbstractVector{<:Real}, y::AbstractVector{<:Measurement}) =
    Makie.convert_arguments(P, x, value.(y), uncertainty.(y))

Makie.@recipe MeasurementErrorbars (x, y) begin
    Makie.documented_attributes(Errorbars)...
end

function Makie.plot!(p::MeasurementErrorbars)
    x = p.arg1
    y = p.arg2
    direction = p.direction[]

    if direction == :x
        Makie.errorbars!(p, p.attributes, x, y, x; direction = :x,)
    elseif direction == :y
        Makie.errorbars!(p, p.attributes, x, y, y; direction = :y,)
    elseif direction == :both
        Makie.errorbars!(p, p.attributes, x, y, x; direction = :x,)
        Makie.errorbars!(p, p.attributes, x, y, y;direction = :y,)
    else
        throw(ArgumentError("Invalid direction: $direction. Accepted directions are :x, :y, or :both"))
    end

    return p
end

function Makie.errorbars(x::AbstractVector{<:Measurement}, y::AbstractVector{<:Measurement}; direction = :both,kwargs...,)
    return measurementerrorbars(x, y; direction = direction, kwargs...)
end

# band
Makie.convert_arguments(P::Type{<:Band}, x::AbstractVector{<:Measurement}, y::AbstractVector{<:Measurement}) =
    Makie.convert_arguments(P, value.(x), value.(y) - uncertainty.(y), value.(y) + uncertainty.(y))
Makie.convert_arguments(P::Type{<:Band}, x::AbstractVector{<:Real}, y::AbstractVector{<:Measurement}) =
    Makie.convert_arguments(P, x, value.(y) - uncertainty.(y), value.(y) + uncertainty.(y))

end #module
