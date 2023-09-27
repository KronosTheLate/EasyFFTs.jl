var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = EasyFFTs","category":"page"},{"location":"#EasyFFTs","page":"Home","title":"EasyFFTs","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for EasyFFTs.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [EasyFFTs]","category":"page"},{"location":"#EasyFFTs.EasyFFT","page":"Home","title":"EasyFFTs.EasyFFT","text":"EasyFFT(frequencies, response)\n\nA type to hold the response and corresponding frequencies of  a discrete fourier transform. Has the fields freq and resp, which can be accessed by dot syntax. Mainly intended to be constructed through easyfft.\n\n\n\n\n\n","category":"type"},{"location":"#EasyFFTs.domfreq-Tuple{EasyFFTs.EasyFFT}","page":"Home","title":"EasyFFTs.domfreq","text":"domfreq(ef)                                     -> Vector\ndomfreq(ef, n=5, t=0.1, window=length(ef)//50)  -> Vector\n\nFind and return a vector containing the dominant frequencies in ef.\n\nKeyword arguments\n\nn: The maximal of dominant peaks to find. Defaults to 5\nt: Minimal magnitude as fraction of maximal magnitude. Defaults to 0.1\nwindow: Minimal difference in index between any larger peak. Defaults to length(ef)//50\n\nSee also: finddomfreq\n\n\n\n\n\n","category":"method"},{"location":"#EasyFFTs.easyfft","page":"Home","title":"EasyFFTs.easyfft","text":"easyfft(s)     -> EasyFFT\neasyfft(s, fs) -> EasyFFT\n\nCompute the Discrete Fourier Transform (DFT) of the input vector s, scaling by 1/length(s) by default. This function uses FFTW.rfft if s has real elements, and FFTW.fft otherwise.\n\nNote that if s has real elements, the one-side spectrum  is returned. This means that the amplitude of the frequencies  is doubled, excluding the frequency=0 component. To get the full symmetric spectrum for real signals, use easymirror, or change the element type of the signal by something like easyfft(signal.|>ComplexF64).\n\nThe output is an EasyFFT object, with fields freq and resp containing the frequences and response respectivly.\n\nKeyword arguments\n\nscalebylength::Bool: determines if the response is scaled by its length. Defaults to true.\n\nExamples\n\njulia> using EasyFFTs\n\njulia> fs = 100;  # 100 samples per second\n\njulia> timestamps = range(0, 1, step = 1/fs);\n\njulia> s = sin.(2π * 2 * timestamps); # sine of frequency = 2 Hz\n\njulia> easyfft(s, fs)\nEasyFFT with 51 samples.\nDominant component(s):       \n   Frequency  │  Magnitude   \n╺━━━━━━━━━━━━━┿━━━━━━━━━━━━━╸\n    1.9802    │   0.98461    \n\njulia> easyfft(s)  # `fs` defaults to 1\nEasyFFT with 51 samples.\nDominant component(s):       \n   Frequency  │  Magnitude   \n╺━━━━━━━━━━━━━┿━━━━━━━━━━━━━╸\n   0.019802   │   0.98461    \n              ╵                      \n\n\n\n\n\n\n","category":"function"},{"location":"#EasyFFTs.easymirror","page":"Home","title":"EasyFFTs.easymirror","text":"easymirror(v::AbstractVector) -> Vector\neasymirror(ef::EasyFFT)       -> Vector\n\nGiven a one-sided spectrum, return a two-sided version by \"mirroring\" about 0. This convenience function also ajusts the amplitude of v, or the amplitudes of ef.resp appropriately.\n\nExamples\n\njulia> using EasyFFTs\n\njulia> fs = 100;  # 100 samples per second\n\njulia> timestamps = range(0, 1, step = 1/fs);\n\njulia> s = sin.(2π * 2 * timestamps); # sine of frequency = 2 Hz\n\njulia> easymirror(ef)\nEasyFFT with 101 samples.\nDominant component(s):              ╷              \n   Frequency  │  Magnitude   \n╺━━━━━━━━━━━━━┿━━━━━━━━━━━━━╸\n    -1.9802   │   0.4923     \n╶─────────────┼─────────────╴\n    1.9802    │   0.4923     \n\n\n\n\n\n","category":"function"},{"location":"#EasyFFTs.finddomfreq-Tuple{EasyFFTs.EasyFFT}","page":"Home","title":"EasyFFTs.finddomfreq","text":"finddomfreq(ef)                                     -> Vector\nfinddomfreq(ef; n=5, t=0.1, window=length(ef)//50)  -> Vector\n\nFind and return a vector containing the indices of the  dominant frequency components in ef.\n\nThis function is used internally in the show method for EasyFFT.\n\nKeyword arguments\n\nn: The maximal of dominant peaks to find. Defaults to 5\nt: Minimal magnitude as fraction of maximal magnitude. Defaults to 0.1\nwindow: Minimal difference in index between any larger peak. Defaults to length(ef)//50\n\nSee also: domfreq\n\n\n\n\n\n","category":"method"},{"location":"#EasyFFTs.magnitude-Tuple{EasyFFTs.EasyFFT}","page":"Home","title":"EasyFFTs.magnitude","text":"magnitude(ef::EasyFFT)\n\nThe absolute values of the response vector.\n\nSee also: phase, phased\n\n\n\n\n\n","category":"method"},{"location":"#EasyFFTs.phase-Tuple{EasyFFTs.EasyFFT}","page":"Home","title":"EasyFFTs.phase","text":"phase(ef::EasyFFT)\n\nThe phase of the response vector.\n\nSee also: magnitude, phased\n\n\n\n\n\n","category":"method"},{"location":"#EasyFFTs.phased-Tuple{EasyFFTs.EasyFFT}","page":"Home","title":"EasyFFTs.phased","text":"phased(ef::EasyFFT)\n\nThe phase of the response vector in degrees.\n\nSee also: phase, magnitude\n\n\n\n\n\n","category":"method"},{"location":"#EasyFFTs.response_at-Tuple{EasyFFTs.EasyFFT, Real}","page":"Home","title":"EasyFFTs.response_at","text":"response_at(ef, f)  -> NamedTuple\nresponse_at(ef, fs) -> NamedTuple\n\nFind the response at the frequency closest  to a number f, or closest to each frequency in the  vector fs. The first argument ef should be  of type EasyFFT, as returned by easyfft.\n\nThe returned object is a named tuple, fields \"freq\" and \"resp\".  The values match the type of the second argument (number for  f, vector for fs).\n\nThe reason for returning the frequencies is because they are  likely to differ from the given f (or values in fs), as  the discretized frequencies will often not match the given frequencies.\n\nExamples\n\nGetting the DC component of the spectrum:\n\njulia> response_at(easyfft(rand(1000)), 0)\n(freq = 0.0, resp = 0.49191028527567726 + 0.0im)\n\nThe requested frequency does not align  perfectly with discretized frequencies: ```` julia> response_at(easyfft(rand(1000)), 0.4415) (freq = 0.441, resp = 0.003584422218085957 - 0.0025392417679877704im)\n\n\nResponse at multiple frequencies (long output supressed):\n\njulia> response_at(easyfft(rand(1000)), [0, 0.1, 0.11, 0.111, 0.1111]); ```\n\n\n\n\n\n","category":"method"}]
}
