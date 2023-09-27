"""
    easymirror(v::AbstractVector) -> Vector
    easymirror(ef::EasyFFT)       -> Vector

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

julia> easymirror(ef)
EasyFFT with 101 samples.
Dominant component(s):              ╷              
   Frequency  │  Magnitude   
╺━━━━━━━━━━━━━┿━━━━━━━━━━━━━╸
    -1.9802   │   0.4923     
╶─────────────┼─────────────╴
    1.9802    │   0.4923     
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
    finddomfreq(ef)                                     -> Vector
    finddomfreq(ef; n=5, t=0.1, window=length(ef)//50)  -> Vector

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
    domfreq(ef)                                     -> Vector
    domfreq(ef, n=5, t=0.1, window=length(ef)//50)  -> Vector

Find and return a vector containing the
dominant frequencies in `ef`.

# Keyword arguments
- `n`: The maximal of dominant peaks to find. Defaults to `5`
- `t`: Minimal magnitude as fraction of maximal magnitude. Defaults to `0.1`
- `window`: Minimal difference in index between any larger peak. Defaults to `length(ef)//50`

See also: [`finddomfreq`](@ref)
"""
function domfreq(ef::EasyFFT; n=5, t=0.1, window=length(ef)//50)
    peaks = finddomfreq(ef; n, t, window)
    return ef.freq[peaks]
end
export domfreq

"""
    response_at(ef, f)  -> NamedTuple
    response_at(ef, fs) -> NamedTuple

Find the response at the frequency closest 
to a number `f`, or closest to each frequency in the 
vector `fs`. The first argument `ef` should be 
of type `EasyFFT`, as returned by `easyfft`.

The returned object is a named tuple, fields "freq" and "resp". 
The values match the type of the second argument (number for 
`f`, vector for `fs`).

The reason for returning the frequencies is because they are 
likely to differ from the given `f` (or values in `fs`), as 
the discretized frequencies will often not match the given frequencies.

# Examples

Getting the DC component of the spectrum:
```
julia> response_at(easyfft(rand(1000)), 0)
(freq = 0.0, resp = 0.49191028527567726 + 0.0im)
```

The requested frequency does not align 
perfectly with discretized frequencies:
````
julia> response_at(easyfft(rand(1000)), 0.4415)
(freq = 0.441, resp = 0.003584422218085957 - 0.0025392417679877704im)
```

Response at multiple frequencies (long output supressed):
```
julia> response_at(easyfft(rand(1000)), [0, 0.1, 0.11, 0.111, 0.1111]);
```
"""
function response_at(ef::EasyFFT, f::Real)
    i = firstindex(ef.freq)
    f ≤ first(ef.freq) && return (freq=first(ef.freq), resp=(first(ef.resp)))
    f ≥ last(ef.freq) && return (freq=last(ef.freq), resp=(last(ef.resp)))
    while ef.freq[i]<f
        i+=1
    end
    if abs(f-ef.freq[i]) < abs(f-ef.freq[i-1])
        return (freq=ef.freq[i], resp=ef.resp[i])
    else
        return (freq=ef.freq[i-1], resp=ef.resp[i-1])
    end
end
function response_at(ef::EasyFFT, fs::AbstractVector{<:Real})
    freq = Vector{Float64}(undef, length(fs))
    resp = Vector{ComplexF64}(undef, length(fs))
    for i in eachindex(fs)
        freq[i], resp[i] = response_at(ef, fs[i])
    end
    return (;freq, resp)
end
export response_at
