# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

"""
Doctstring goes here
"""
function easyfft end
export easyfft
#! FFTSHIFT if doublesided
#! define easymirror, remember to halv response.
#! define for abstractarray, Frequencies and named tuple with keys "freq" and "resp".
function easyfft(s::AbstractArray; scalebylength=true)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    return FFTW.fftshift(response)
end
function easyfft(s::AbstractArray, fs::Real; scalebylength=true)
    response = FFTW.fft(s)
    if scalebylength
        response ./= length(response)
    end
    return (freqs=FFTW.fftshift(FFTW.fftfreq(length(s), fs)), resp=FFTW.fftshift(response))
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