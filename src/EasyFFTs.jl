# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

"""
Doctstring goes here
"""
function easyfft end
export easyfft

function easyfft(s::AbstractVector; scalebylength=true)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    return FFTW.fftshift(response)
end
function easyfft(s::AbstractVector, fs::Real; scalebylength=true)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    return (freqs=FFTW.fftshift(FFTW.fftfreq(length(s), fs)), resp=FFTW.fftshift(response))
end

function easyfft(s::AbstractVector{<:Real}; scalebylength=true)
    response = FFTW.rfft(s)
    response = vcat(response[1], response[2:end])
    if scalebylength
        response ./= length(response)
    end
    return response
end
function easyfft(s::AbstractVector{<:Real}, fs::Real; scalebylength=true)
    response = FFTW.rfft(s)
    response = vcat(response[1], response[2:end])
    if scalebylength
        response ./= length(response)
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


function easymirror(input::AbstractVector)
    mirrored = fftshift(vcat(input, reverse(s[begin+1:end])))
    mirrored ./= 2
    mirrored[end÷2+1] *= 2
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