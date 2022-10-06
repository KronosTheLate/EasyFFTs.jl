# EasyFFTs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://KronosTheLate.github.io/EasyFFTs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://KronosTheLate.github.io/EasyFFTs.jl/dev/)
[![Build Status](https://github.com/KronosTheLate/EasyFFTs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/KronosTheLate/EasyFFTs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/KronosTheLate/EasyFFTs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/KronosTheLate/EasyFFTs.jl)

##
The main workhorse of this package is a very simple function `easyfft` that modifies the output of `fft` and `rfft` from [FFTW.jl](https://github.com/JuliaMath/FFTW.jl) slightly.  

This function offers four main benefits to using the FFTW functions directly:
- The output is scaled by default, making the absolute value of the response 
correspond directly to the amplitude of the sinusoids that make up the signal.
- Simple and short syntax for getting the associated frequencies
- Freqiencies and response are sorted by increasing frequency
- `rfft` is automatically called for real element vectors, avoiding 
the common newbie mistake of always using `fft`. Benefits are faster computation 
and automtically discarding half of the symmetric spectrum. If you want both 
sides of the spectrum, see the only other exported function `easymirror`.

## Introductary example
Input:
```
using EasyFFTs
using UnicodePlots
let
    fs = 1000
    duration = 1
    timestamps = range(0, duration, step=1 / fs)

    f = 5
    A = 2
    s = @. A * sin(f * 2π * timestamps)

    plt1 = scatterplot(timestamps, s)

    s_fft = easyfft(s, fs, f=abs)
    plt2 = scatterplot(s_fft.freq, s_fft.resp)
    display(plt1)
    display(plt2)
end
```
Output:
```

      ┌────────────────────────────────────────┐ 
    2 │⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀│ 
      │⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀│ 
      │⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀│ 
      │⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀│ 
      │⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀│ 
      │⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀│ 
      │⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀│ 
      │⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤│ 
      │⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸│ 
      │⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸│ 
      │⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞│ 
      │⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇│ 
      │⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇│ 
      │⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀│ 
   -2 │⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀│ 
      └────────────────────────────────────────┘ 
      ⠀0⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀ 
     ┌────────────────────────────────────────┐ 
   2 │⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
   0 │⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀│ 
     └────────────────────────────────────────┘ 
     ⠀0⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀500⠀ 
```
