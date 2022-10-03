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

This function offers four main benefits to using the FFTW functions directly:
- The output is scaled by default, making the absolute value of the response 
correspond directly to the amplitude of the sinusoids that make up the signal.
- Simple and short syntax for getting the associated frequencies
- Freqiencies and response are sorted by increasing frequency
- `rfft` is automatically called for real element vectors, avoiding 
the common newbie mistake of always using `fft`. Benefits are faster computation 
and automtically discarding half of the symmetric spectrum. If you want both 
sides of the spectrum, see [`easymirror`](@ref).
"""
function easyfft end
export easyfft

function easyfft(s::AbstractVector; scalebylength=true, f::Function=identity)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    response = FFTW.fftshift(response)
    if f == identity
        return response
    else
        return f.(response)
    end
end
function easyfft(s::AbstractVector, fs::Real; scalebylength=true, f::Function=identity)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    if f == identity
        return response
    else
        return f.(response)
    end
    return (freqs=FFTW.fftshift(FFTW.fftfreq(length(s), fs)), resp=FFTW.fftshift(response))
end

function easyfft(s::AbstractVector{<:Real}; scalebylength=true, f::Function=identity)
    response = FFTW.rfft(s)
    if scalebylength
        response ./= length(response)
    end
    if f == identity
        return response
    else
        return f.(response)
    end
end
function easyfft(s::AbstractVector{<:Real}, fs::Real; scalebylength=true, f::Function=identity)
    response = FFTW.rfft(s)
    if scalebylength
        response ./= length(response)
    end
    if f == identity
        return response
    else
        return f.(response)
    end
    return (freqs=FFTW.rfftfreq(length(s), fs), resp=response)
end

"""
    easymirror(v::AbstractVector)
    easymirror(s::NamedTuple)

Given a one-sided spectrum, return a two-sided version 
by "mirroring" about 0. This convenience function also 
ajusts the amplitude of `v`, or the amplitudes of `s.resp`
apropriatly.
"""
function easymirror end
export easymirror

function easymirror(s::AbstractVector)
    mirrored = FFTW.fftshift(vcat(s ./ 2, reverse(s[begin+1:end] ./ 2)))
    mirrored[end÷2+1] *= 2
    return mirrored
end

function easymirror(input::NamedTuple)
    has_expected_keys = haskey(nt, :freq) && haskey(nt, :resp)
    if !has_expected_keys
        error("""
            Expected input to have keys `freq` and `resp`.
            The input has keys $(keys(input))
        """)
    end

    # If all freqiencies are non-negative, mirroring is appropriate.
    # If else, I am not sure.
    if input.resp.n != input.resp.n_nonnegative
        @warn "Based on the `freq` field of the input, it does not look 
        like it should be mirrored. Proceed at your own risk."
    end
    N = length(input.freq)

    # Constructing frequencies manually to avoid allocations
    freq = FFTW.Frequencies(N, N - 1, input.freq.multiplier)
    resp = easymirror(input.resp)

    return (; freq, resp)
end

end #module