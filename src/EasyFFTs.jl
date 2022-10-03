# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

"""
    easyfft(s)
    easyfft(s, fs)


# Keyword arguments
- `scalebylength::Bool`: determines if the response is scaled by its length. Defaults to `true`.
- `f::Function`: an optional function to apply elementwise to the response.

Compute the Discrete Fourier Transform (DFT) of the 
input vector `s`, scaling by `length(s)` by default. 
This function uses FFTW.rfft if `s` has real elements, 
and FFTW.fft otherwise.

If a sampling frequency `fs` is supplied, the output becomes 
a NamedTuple with keys `freq` and `resp`, containing the 
freqiencues and response respectivly.

The optional function `f` allows the user to pass `abs` or `angle` 
to get only the amplitude or phase of the response directly.

This function offers four main benefits to using the FFTW functions directly:
- The output is scaled by default, making the absolute value of the response 
correspond directly to the amplitude of the sinusoids that make up the signal.
- Simple and short syntax for getting the associated frequencies
- Freqiencies and response are sorted by increasing frequency
- `rfft` is automatically called for real element vectors, avoiding 
the common newbie mistake of always using `fft`. Benefits are faster computation 
and automtically discarding half of the symmetric spectrum. If you want both 
sides of the spectrum, see [`easymirror`](@ref).

# Examples
```jldoctest
julia> using EasyFFTs

julia> s = sin.(1:5);

julia> easyfft(s)
3-element Vector{ComplexF64}:
  0.0587205499074596 + 0.0im
   0.441411013590527 - 0.76819000942203im
 0.23045453212899036 - 0.08137937206396029im

julia> easyfft(s, f=abs)
3-element Vector{Float64}:
 0.0587205499074596
 0.8859794430430284
 0.24440109160213735

julia> easyfft(s, 1, f=abs)
(freq = [0.0, 0.2, 0.4], resp = [0.0587205499074596, 0.8859794430430284, 0.24440109160213735])
```
"""
function easyfft end
export easyfft

function easyfft(s::AbstractVector; scalebylength=true, f::Function=identity)
    resp = FFTW.fft(s)
    if scalebylength
        resp ./= length(resp)
    end

    resp = FFTW.fftshift(resp)

    if f != identity
        resp = f.(resp)
    end
    return resp
end
function easyfft(s::AbstractVector, fs::Real; scalebylength=true, f::Function=identity)
    resp = FFTW.fft(s)
    if scalebylength
        resp ./= length(resp)
    end

    if f != identity
        resp = f.(resp)
    end

    freq = FFTW.fftshift(FFTW.fftfreq(length(s), fs))
    resp = FFTW.fftshift(resp)
    return (; freq, resp)
end

function easyfft(s::AbstractVector{<:Real}; scalebylength=true, f::Function=identity)
    resp = FFTW.rfft(s)
    if scalebylength
        resp ./= length(resp)
    end

    if f != identity
        resp = f.(resp)
    end

    return resp
end
function easyfft(s::AbstractVector{<:Real}, fs::Real; scalebylength=true, f::Function=identity)
    resp = FFTW.rfft(s)
    if scalebylength
        resp ./= length(resp)
    end

    if f != identity
        resp = f.(resp)
    end

    freq = FFTW.rfftfreq(length(s), fs)
    return (; freq, resp)
end

"""
    easymirror(v::AbstractVector)
    easymirror(s::NamedTuple)

Given a one-sided spectrum, return a two-sided version 
by "mirroring" about 0. This convenience function also 
ajusts the amplitude of `v`, or the amplitudes of `s.resp`
apropriatly.

# Examples
```jldoctest
julia> easymirror(0:3)   # Mirroring the amplitudes
7-element Vector{Float64}:
 1.5
 1.0
 0.5
 0.0
 0.5
 1.0
 1.5

julia> easymirror(fill(1, 4))   # Not halving the zero frequency component
7-element Vector{Float64}:
 0.5
 0.5
 0.5
 1.0
 0.5
 0.5
 0.5
```
"""
function easymirror end
export easymirror

function easymirror(s::AbstractVector)
    mirrored = FFTW.fftshift(vcat(s ./ 2, reverse(s[begin+1:end] ./ 2)))
    mirrored[end÷2+1] *= 2
    return mirrored
end

function easymirror(input::NamedTuple)
    has_expected_keys = haskey(input, :freq) && haskey(input, :resp)
    if !has_expected_keys
        error("""
            Expected input to have keys `freq` and `resp`.
            The input has keys $(keys(input))
        """)
    end

    freq = FFTW.fftshift(vcat(input.freq, reverse(input.freq[begin+1:end]) .* 1))
    resp = easymirror(input.resp)

    return (; freq, resp)
end

end #module