# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW
using RecipesBase

import Base: iterate, getindex, firstindex, lastindex, length, show

"""
    easyfft(s)
    easyfft(s, fs)


# Keyword arguments
- `scalebylength::Bool`: determines if the response is scaled by its length. Defaults to `true`.

Compute the Discrete Fourier Transform (DFT) of the
input vector `s`, scaling by `length(s)` by default.
This function uses FFTW.rfft if `s` has real elements,
and FFTW.fft otherwise.

The output is an EasyFFT object, with fields `freq` and `resp` containing the frequences and
response respectivly.

See also [`easymirror`](@ref) to get a symestric spectrum.

# Examples
```jldoctest
julia> using EasyFFTs

julia> s = sin.(1:5);

julia> ef = easyfft(s)
EasyFFT with 3 samples, showing dominant frequencies f = [0.2, 0.4]

julia> ef.resp
3-element Vector{ComplexF64}:
  0.0587205499074596 + 0.0im
   0.441411013590527 - 0.76819000942203im
 0.23045453212899036 - 0.08137937206396029im


julia> ef = easyfft(s, 0.5)
EasyFFT with 3 samples, showing dominant frequencies f = [0.1, 0.2]

```
"""
function easyfft end
export easyfft

struct EasyFFT
    freq::Vector{Float64}
    resp::Vector{Complex{Float64}}
end

function easyfft(s::AbstractVector, fs::Real=1.0; scalebylength=true)
    resp = FFTW.fft(s)
    if scalebylength
        resp ./= length(resp)
    end

    freq = FFTW.fftshift(FFTW.fftfreq(length(s), fs))
    resp = FFTW.fftshift(resp)
    return EasyFFT(freq, resp)
end

function easyfft(s::AbstractVector{<:Real}, fs::Real=1.0; scalebylength=true)
    resp = FFTW.rfft(s)
    if scalebylength
        resp ./= length(resp)
    end

    freq = FFTW.rfftfreq(length(s), fs)
    return EasyFFT(freq, resp)
end

Base.getindex(ef::EasyFFT, i) = getindex(ef.resp, i)
firstindex(ef::EasyFFT) = firstindex(ef.resp)
lastindex(ef::EasyFFT) = lastindex(ef.resp)
length(ef::EasyFFT) = length(ef.resp)

"""
    easymirror(v::AbstractVector)
    easymirror(ef::EasyFFT)

Given a one-sided spectrum, return a two-sided version
by "mirroring" about 0. This convenience function also
ajusts the amplitude of `v`, or the amplitudes of `ef.resp`
appropriately.

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


julia> ef = EasyFFTs.EasyFFT([0, 0.2, 0.4], [1, 2, 3]);

julia> easymirror(ef)
EasyFFT with 5 samples, showing dominant frequencies f = [-0.4, 0.4]
```
"""
function easymirror end
export easymirror

function easymirror(s::AbstractVector)
    mirrored = FFTW.fftshift(vcat(s ./ 2, reverse(s[begin+1:end] ./ 2)))
    mirrored[end÷2+1] *= 2
    return mirrored
end

function easymirror(input::EasyFFT)
    freq = FFTW.fftshift(vcat(input.freq, reverse(input.freq[begin+1:end]) .* -1))
    resp = easymirror(input.resp)

    return EasyFFT(freq, resp)
end

"""
    magnitude(ef::EasyFFT)

The absolute values of the response vector.

See also: [`phase`](@ref)
"""
magnitude(ef::EasyFFT) = abs.(ef.resp)
export magnitude
"""
    phase(ef::EasyFFT)

The phase of the response vector.

See also: [`magnitude`](@ref)
"""
phase(ef::EasyFFT) = angle.(ef.resp)
export phase


# Allow (f, r) = easyfft(...)
Base.iterate(ef::EasyFFT, i=1) = iterate((;freq=ef.freq, resp=ef.resp), i)

# Plot recipe - so plot(easyfft(y, f)) does the right thing
@recipe function f(ef::EasyFFTs.EasyFFT)
    layout := (2, 1)
    link := :x
    if length(ef.freq) ≥ 100
        nothing # because stem plots are heavy/slow when having many points
    else
        seriestype --> :stem
        markershape --> :circle
    end
    @series begin
        yguide := "Magnitude"
        subplot := 1
        label := nothing
        ef.freq, magnitude(ef)
    end
    @series begin
        xguide := "Frequency"
        yguide := "Phase"
        subplot := 2
        label := nothing
        ef.freq, phase(ef)
    end
end

function show(io::IO, ef::EasyFFT)
    dominant = dominantfrequencies(ef)
    print(io, "EasyFFT with $(length(ef)) samples, showing dominant frequencies f = $(dominant)")
end

"""
    dominantfrequencies(ef, n=5, t=0.1, window=length(ef)//50)

Find the `n` or fewer dominant frequencies in `ef`, such that the corresponding magnitude is
larger than `t` times the maximum, and at least `window` indices away from any larger peaks.
"""
function dominantfrequencies(ef::EasyFFT, n=5, t=0.1, window=length(ef)//50)
    absresp = abs.(ef.resp)
    threshold = sum((1.0-t, t).*extrema(absresp))
    maxindices = sortperm(absresp; rev=true)
    peaks = Int64[]
    for i in maxindices
        length(peaks) >= n && break
        absresp[i] < threshold && break
        any(i-window < p < i+window for p in peaks) && continue
        push!(peaks, i)
    end
    return ef.freq[peaks]
end

end #module
