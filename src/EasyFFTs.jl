# pkg"activate /home/dennishb/GeekyStuff/Julia/Packages/EasyFFTs"
module EasyFFTs

import FFTW

function fft(s::AbstractArray{<:Real})
    return FFTW.fft(s)
end

fft(sin.(1:10))
end
