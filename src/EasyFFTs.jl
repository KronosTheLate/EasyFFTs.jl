# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW
using RecipesBase

import Base: iterate

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

See also [`easymirror`](@ref) to get a symestric spectrum.

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

struct EasyFFT
    freq::Vector{Float64}
    resp::Vector{Complex{Float64}}
end

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
    return EasyFFT(freq, resp)
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
    return EasyFFT(freq, resp)
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


julia> nt = (freq=[0, 0.2, 0.4], resp=[1, 2, 3]);

julia> easymirror(nt)
(freq = [0.4, 0.2, 0.0, 0.2, 0.4], resp = [1.5, 1.0, 1.0, 1.0, 1.5])
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

    return EasyFFT(freq, resp)
end

# Allow (f, r) = easyfft(...)
Base.iterate(f::EasyFFT, i=1) = iterate((;freq=f.freq, resp=f.resp), i)

# Plot recipe - so plot(easyfft(y, f)) does the right thing
@recipe function f(f::EasyFFT)
    layout := (2, 1)
    link := :x
    @series begin
        yguide := "Response"
        subplot := 1
        f.freq, abs.(f.resp)
    end
    @series begin
        xguide := "Frequency"
        yguide := "Phase"
        subplot := 2
        f.freq, angle.(f.resp)
    end
end

end #module
