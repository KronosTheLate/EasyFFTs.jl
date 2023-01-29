# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

include("EasyFFT_type.jl")
include("plotting.jl")

"""
    easyfft(s)
    easyfft(s, fs)


Compute the Discrete Fourier Transform (DFT) of the
input vector `s`, scaling by `1/length(s)` by default.
This function uses FFTW.rfft if `s` has real elements,
and FFTW.fft otherwise.

The output is an `EasyFFT` object, with fields `freq` and `resp` containing the frequences and
response respectivly.

# Keyword arguments
- `scalebylength::Bool`: determines if the response is scaled by its length. Defaults to `true`.

See also [`easymirror`](@ref) to get the full symmetric spectrum of real signals.

# Examples
```jldoctest
julia> using EasyFFTs

julia> fs = 100;  # 100 samples per second

julia> timestamps = range(0, 1, step = 1/fs);

julia> s = sin.(2π * 2 * timestamps); # sine of frequency = 2 Hz

julia> easyfft(s, fs)
EasyFFT with 51 samples, showing dominant frequencies f = [1.9801980198019802]

julia> easyfft(s)  # fs defaults to 1
EasyFFT with 51 samples, showing dominant frequencies f = [0.019801980198019802]
```
"""
function easyfft end
export easyfft

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

"""
    easymirror(v::AbstractVector)
    easymirror(ef::EasyFFT)

Given a one-sided spectrum, return a two-sided version
by "mirroring" about 0. This convenience function also
ajusts the amplitude of `v`, or the amplitudes of `ef.resp`
appropriately.

# Examples
```jldoctest
julia> using EasyFFTs

julia> fs = 100;  # 100 samples per second

julia> timestamps = range(0, 1, step = 1/fs);

julia> s = sin.(2π * 2 * timestamps); # sine of frequency = 2 Hz

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
    finddomfreq(ef)
    finddomfreq(ef; n=5, t=0.1, window=length(ef)//50)

Find and return a vector containing the indices of the 
dominant frequency components in `ef`.

This function is used internally in the `show` method for `EasyFFT`.

# Keyword arguments
- `n`: The maximal of dominant peaks to find. Defaults to `5`
- `t`: Minimal magnitude as fraction of maximal magnitude. Defaults to `0.1`
- `window`: Minimal difference in index between any larger peak. Defaults to `length(ef)//50`

See also: [`domfreq`](@ref)
"""
function finddomfreq(ef::EasyFFT; n=5, t=0.1, window=length(ef)//50)
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
    return peaks
end
export finddomfreq

"""
    domfreq(ef)
    domfreq(ef, n=5, t=0.1, window=length(ef)//50)

Find and return a vector containing the
dominant frequencies in `ef`.

# Keyword arguments
- `n`: The maximal of dominant peaks to find. Defaults to `5`
- `t`: Minimal magnitude as fraction of maximal magnitude. Defaults to `0.1`
- `window`: Minimal difference in index between any larger peak. Defaults to `length(ef)//50`

See also: [`finddomfreq`](@ref)
"""
function domfreq(ef::EasyFFT, n=5, t=0.1, window=length(ef)//50)
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
export domfreq

end #module
