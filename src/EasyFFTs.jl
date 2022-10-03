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

"""
function easymirror end
export easymirror


function easymirror(input::AbstractVector)

end

function easymirror(input::NamedTuple)

end

#! define easymirror, remember to halv response.
#! define for AbstractVector, Frequencies and named tuple with keys "freq" and "resp".

end #module