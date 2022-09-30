# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

"""
Doctstring goes here
"""
function easyfft end
export easyfft

function easyfft(s::AbstractArray; scalebylength=true)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    return response
end
function easyfft(s::AbstractArray, fs::Real; scalebylength=true)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    return (freqs=FFTW.fftfreq(length(s), fs), resp=response)
end

function easyfft(s::AbstractArray{<:Real}; scalebylength=true)
    response = FFTW.rfft(s)
    response = vcat(response[1], response[2:end])
    if scalebylength
        response ./= length(response)
    end
    return response
end
function easyfft(s::AbstractArray{<:Real}, fs::Real; scalebylength=true)
    response = FFTW.rfft(s)
    response = vcat(response[1], response[2:end])
    if scalebylength
        response ./= length(response)
    end
    return (freqs=FFTW.rfftfreq(length(s), fs), resp=response)
end

end #module

using EasyFFTs

easyfft(sin.(1:10))
easyfft(sin.(1:10), 1)

##? Internal testing
using WGLMakie
##! Make easyfft function
##! Make _easyfft_withfreq,
##! and _easyfft_withoutfreq. Or internal helper functions?
##! kwarg f, default to identity, applies to response.
let  #! Why is amp off by faactor of 2?
    fs = 1000
    duration = 1
    ts = range(0, duration, step=1 / fs)

    f = 5
    A = 2
    s1 = @. A * sin(f * 2π * ts)
    s2 = @. 1 * sin(2f * 2π * ts)
    s = s1 .+ s2
    fig, ax, _ = stem(ts, s, axis=(title="Signal",))

    s_fft = easyfft(s, fs)
    stem(fig[2, 1], s_fft.freqs, s_fft.resp .|> abs, axis=(title="FFT of signal",))

    freqs, resp = easyfft(s, fs)
    stem(fig[3, 1], freqs, resp .|> abs, axis=(title="FFT of signal",))

    fig

end
