# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

using Reexport
@reexport using FFTW

include("EasyFFT_type.jl")
include("plotting.jl")
include("utils.jl")

"""
    easyfft(s)     -> EasyFFT
    easyfft(s, fs) -> EasyFFT


Compute the Discrete Fourier Transform (DFT) of the
input vector `s`, scaling by `1/length(s)` by default.
This function uses FFTW.rfft if `s` has real elements,
and FFTW.fft otherwise.

Note that if `s` has real elements, the one-side spectrum 
is returned. This means that the amplitude of the frequencies 
is doubled, excluding the frequency=0 component. To get the full symmetric spectrum for real signals, use [`easymirror`](@ref), or change the element type of the signal by something like `easyfft(signal.|>ComplexF64)`.

The output is an `EasyFFT` object, with fields `freq` and `resp` containing the frequences and
response respectivly.

# Keyword arguments
- `scalebylength::Bool`: determines if the response is scaled by its length. Defaults to `true`.

# Examples
```jldoctest
julia> using EasyFFTs

julia> fs = 100;  # 100 samples per second

julia> timestamps = range(0, 1, step = 1/fs);

julia> s = sin.(2π * 2 * timestamps); # sine of frequency = 2 Hz

julia> easyfft(s, fs)
EasyFFT with 51 samples.
Dominant component(s):       
   Frequency  │  Magnitude   
╺━━━━━━━━━━━━━┿━━━━━━━━━━━━━╸
    1.9802    │   0.98461    

julia> easyfft(s)  # `fs` defaults to 1
EasyFFT with 51 samples.
Dominant component(s):       
   Frequency  │  Magnitude   
╺━━━━━━━━━━━━━┿━━━━━━━━━━━━━╸
   0.019802   │   0.98461    
              ╵                      

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
    resp[1] /= 2
    if scalebylength
        resp ./= length(resp)
    end

    freq = FFTW.rfftfreq(length(s), fs)
    return EasyFFT(freq, resp)
end

end #module
