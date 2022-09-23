# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

"""
Doctstring goes here
"""
function fft end
export fft

function fft(s::AbstractArray; scalebylength=true)
    if scalebylength
        return FFTW.fft(s) ./ length(s)
    else
        return FFTW.fft(s)
    end
end
function fft(s::AbstractArray, fs::Real; scalebylength=true)
    N = length(s)
    if scalebylength
        return (freq=FFTW.fftfreq(N, fs), resp=FFTW.fft(s) ./ N)
    else
        return (freq=FFTW.fftfreq(N, fs), resp=FFTW.fft(s))
    end
end

function fft(s::AbstractArray{<:Real}; scalebylength=true)
    if scalebylength
        return FFTW.rfft(s) ./ length(s)
    else
        return FFTW.rfft(s)
    end
end
function fft(s::AbstractArray{<:Real}, fs::Real; scalebylength=true)
    N = length(s)
    if scalebylength
        return (freqs=FFTW.rfftfreq(N, fs), resp=FFTW.rfft(s) ./ N)
    else
        return (freqs=FFTW.rfftfreq(N, fs), resp=FFTW.rfft(s))
    end
end


fft(sin.(1:10))
fft(sin.(1:10), 1)

##? Internal testing
using WGLMakie
let
    fs = 100
    duration = 1
    ts = range(0, duration, step=1 / fs)

    f = 50
    A = 2
    s = @. A * sin(f * 2π * ts)
    fig, ax, _ = stem(ts, s, axis=(label="Signal",))

    s_fft = fft(s, fs)
    stem(fig[2, 1], s_fft.freqs, s_fft.resp .|> abs, axis=(label="FFT of signal",))

    resp, freqs = fft(s, fs)
    stem(fig[3, 1], freqs, resp .|> abs, axis=(label="FFT of signal",))

    fig

end

end
