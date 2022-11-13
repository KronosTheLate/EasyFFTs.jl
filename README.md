# EasyFFTs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://KronosTheLate.github.io/EasyFFTs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://KronosTheLate.github.io/EasyFFTs.jl/dev/)
[![Build Status](https://github.com/KronosTheLate/EasyFFTs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/KronosTheLate/EasyFFTs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/KronosTheLate/EasyFFTs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/KronosTheLate/EasyFFTs.jl)

##
Are you sick and tired of always doing the same preprocessing before you can visualize your fft? Look no further. EasyFFTs aims to automate common preprocessing of fft's, aimed at visual inspection of the frequency spectrum. The main workhorse of this package is a very simple function `easyfft` that modifies the output of `fft` and `rfft` from [FFTW.jl](https://github.com/JuliaMath/FFTW.jl) slightly.  

This function offers four main benefits to using the FFTW functions directly:
- The output is scaled by default, making the absolute value of the response 
correspond directly to the amplitude of the sinusoids that make up the signal.
- Simple and short syntax for getting the associated frequencies
- Frequencies and response are sorted by increasing frequency (if you have ever used fftshift you know what I am talking about)
- `rfft` is automatically called for real element vectors, avoiding 
the common newbie mistake of always using `fft`. Benefits are faster computation 
and automatically discarding half of the symmetric spectrum. If you want both 
sides of the spectrum, see the only other exported function `easymirror`.

## Introductory examples
First, we need something to analyze:
```julia
julia> using EasyFFTs

julia> fs = 100;

julia> duration = 1;

julia> timestamps = range(0, duration, step=1 / fs);

julia> f1 = 5;

julia> A1 = 2;

julia> f2 = 10;

julia> A2 = 3;
```

We then make a signal consisting of 2 pure sinusoids:
```julia
julia> s = @. A1 * sin(f1 * 2π * timestamps) + A2 * sin(f2 * 2π * timestamps);
```

`easyfft` acts much like a normal `fft`
```julia
julia> easyfft(s)[1:5]
5-element Vector{ComplexF64}:
 -9.578394722256253e-17 + 0.0im
 0.00042622566734221867 - 0.013698436692159435im
   0.001865726219729817 - 0.029952195806767286im
   0.005060926454320235 - 0.05407756747203356im
   0.013611028457149094 - 0.10883117827942629im
```
, but the input is scaled by the length of the signal (to get the right magnitudes), and 
only the positive-frequency part of the spectrum is calculated for real signals by default. This gives a better visual 
resolution when plotting, as you do not use half the space on repeating the signal, and also saves computations.

When the sample frequency is passed as the second argument, you get a named tuple with the frequencies and response:
```julia
julia> s_fft = easyfft(s, fs);

julia> typeof(s_fft)
NamedTuple{(:freq, :resp), Tuple{AbstractFFTs.Frequencies{Float64}, Vector{ComplexF64}}}
```

You can directly destructure named tuples into variables if preferred:
```julia
julia> s_freq, s_resp = easyfft(s, fs); 

julia> s_freq == s_fft.freq
true

julia> s_resp == s_fft.resp
true
```

For demonstration, lets get the indices of 5 highest amplitude components:
```julia
julia> inds_sorted_by_magnitude = sortperm(abs.(s_resp), rev=true)[1:5]
5-element Vector{Int64}:
 11
  6
 12
 10
 13
```

We can then visualize the result as frequency => magnitude pairs:
```julia
julia> s_freq[inds_sorted_by_magnitude] .=> abs.(s_resp)[inds_sorted_by_magnitude]
5-element Vector{Pair{Float64, Float64}}:
  9.900990099009901 => 2.8796413948481443
 4.9504950495049505 => 1.9997385273893282
  10.89108910891089 => 0.3626753646683912
  8.910891089108912 => 0.21717288162592593
 11.881188118811881 => 0.18856450061284216
```

Note that the 9.9 Hz corresponds to a 2.88 amplitude. If the discrete 
frequencies lined up perfectly with the actual signal, we would get amplitude 3 at 10 Hz.
This is almost the case at 5 Hz.

You can also supply a keyword argument `f` to pass a function that you 
want to apply directly to the response. This can be useful if the phase is 
not of interest, and you do not want the extra lines or variables to 
extract the response after calculating the `easyfft`:
```julia
julia> easyfft(s, fs, f=abs).resp == abs.(s_resp)
true
```
That wraps up the basic usage. And that is all the usage there is, as this is a simple package.

## Simple plotting
If you are more visual, here is a little plot, essentially showing the same things. Input:
```julia
using EasyFFTs
using UnicodePlots
let
    fs = 1000
    duration = 1
    timestamps = range(0, duration, step=1 / fs)

    f = 5
    A = 2
    s = @. A * sin(f * 2π * timestamps)

    plt1 = scatterplot(timestamps, s; xlabel="t", ylabel="s(t)", border=:dotted)

    s_fft = easyfft(s, fs, f=abs)
    plt2 = scatterplot(s_fft.freq, s_fft.resp; xlabel="frequencies", ylabel="amplitude", border=:dotted)
    display(plt1)
    display(plt2)
end
```
Output:
```julia
           ⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢤ 
         2 ⡇⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⠀⡼⢧⠀⠀⠀⠀⠀⢸ 
           ⡇⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⢸ 
           ⡇⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢰⠁⠈⡇⠀⠀⠀⠀⢸ 
           ⡇⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸ 
           ⡇⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⡼⠀⠀⢧⠀⠀⠀⠀⢸ 
           ⡇⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⢸ 
           ⡇⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⢸ 
   s(t)    ⡇⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⠧⠤⠤⠼⡦⠤⠤⢤⢸ 
           ⡇⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⢸ 
           ⡇⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⠀⠀⠀⠀⡇⠀⠀⢸⢸ 
           ⡇⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⠀⠀⠀⠀⢳⠀⠀⡞⢸ 
           ⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⡇⢸ 
           ⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⠀⠀⠀⠀⠸⡀⢀⡇⢸ 
           ⡇⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⠀⠀⠀⠀⠀⡇⢸⠀⢸ 
        -2 ⡇⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⠀⠀⠀⠀⠀⢳⡞⠀⢸ 
           ⠓⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠚ 
           ⠀0⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀ 
           ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀t⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
               ⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢤ 
             2 ⡇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
   amplitude   ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
               ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸ 
             0 ⡇⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⢸ 
               ⠓⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠚ 
               ⠀0⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀500⠀ 
               ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀frequencies⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
```
