import Base: iterate, getindex, firstindex, lastindex, length, show

"""
    EasyFFT(frequencies, response)

A type to hold the response and corresponding frequencies of 
a discrete fourier transform.
Has the fields `freq` and `resp`, which can be accessed by dot syntax.
Mainly intended to be constructed through [`easyfft`](@ref).
"""
struct EasyFFT
    freq::Vector{Float64}
    resp::Vector{Complex{Float64}}
end

length(ef::EasyFFT) = length(ef.resp)
Base.getindex(ef::EasyFFT, i) = getindex((ef.freq, ef.resp), i)
firstindex(ef::EasyFFT) = 1
lastindex(ef::EasyFFT) = 2

# Allow (f, r) = easyfft(...)
Base.iterate(ef::EasyFFT, i=1) = iterate((;freq=ef.freq, resp=ef.resp), i)

function show(io::IO, ef::EasyFFT)
    dominant = dominantfrequencies(ef)
    print(io, "EasyFFT with $(length(ef)) samples, showing dominant frequencies f = $(dominant)")
end


# Convenience functions:
"""
    magnitude(ef::EasyFFT)

The absolute values of the response vector.

See also: [`phase`](@ref), [`phased`](@ref)
"""
magnitude(ef::EasyFFT) = abs.(ef.resp)
export magnitude

"""
    phase(ef::EasyFFT)

The phase of the response vector.

See also: [`magnitude`](@ref), [`phased`](@ref)
"""
phase(ef::EasyFFT) = angle.(ef.resp)
export phase

"""
    phased(ef::EasyFFT)

The phase of the response vector in degrees.

See also: [`phase`](@ref), [`magnitude`](@ref)
"""
phased(ef::EasyFFT) = rad2deg.(angle.(ef.resp))
export phased
