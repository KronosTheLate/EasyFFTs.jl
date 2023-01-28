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
- Frequencies and response are sorted by increasing frequency (if you have ever used `fftshift` you know what I am talking about)
- `rfft` is automatically called for real input signals, avoiding 
the common mistake of always using `fft`. This makes it so that half of the symmetric 
spectrum is not computed, and not returned. This reduces computation and allocations, without loss of information. 
If you want both sides of the spectrum, use `easymirror`, with usage demonstrated in the docstring.

# Examples
It is much easier to explain by example, so let's show some examples of how to use this package.

## Setup
First, we need something to analyze. Let's define some sample-timestamps:
```julia
julia> using EasyFFTs

julia> fs = 100;  # sampling frequency

julia> duration = 1;  # signal period

julia> timestamps = range(0, duration, step = 1 / fs);
```

We then make a signal `s` composed of 2 pure sinusoids with frequencies of 5 Hz and 10 Hz, sampled at `timestamps`:
```julia
julia> f1 = 5;

julia> A1 = 2;

julia> f2 = 10;

julia> A2 = 3;

julia> s = @. A1 * sin(f1 * 2π * timestamps) + A2 * sin(f2 * 2π * timestamps);
```

Lets new use `easyfft`, and bind the output to `ef`:
```julia
julia>  ef = easyfft(s, fs)
EasyFFT with 51 samples, showing dominant frequencies f = [9.900990099009901, 4.9504950495049505]
```
And just like that, we have have the frequency response! The best part is that the amplitudes and frequencies correspond directly to the sines 
that make up the signal, no preprocessing needed. Note that the sampling frequency `fs` defaults to `1`, giving a [Nyquist frequency](https://en.wikipedia.org/wiki/Nyquist_frequency) of `0.5`.

Now let's get into a little more detail about this `EasyFFT` object that is returned by `easyfft`.

## The `EasyFFT` type
`ef` is of the type `EasyFFT`. The reason for wrapping the output in a custom type (unlike `FFTW.fft`) 
is mainly that it allows automatic plotting of the output. A secondary benefit is that custom show methods can be defined, 
which is what allows the easily interpretable output seen above.

The type `EasyFFT` has two properties:
```julia
julia> propertynames(ef)
(:freq, :resp)
```

This means that one can access the frequencies and response of `ef` as if it was a named tuple:
```julia
 julia> ef.freq
51-element Vector{Float64}:
  0.0
  0.9900990099009901
  ⋮
 48.51485148514851
 49.504950495049506
```

```julia
 julia> ef.resp
51-element Vector{ComplexF64}:
 -9.578394722256253e-17 + 0.0im
 0.00042622566734221867 - 0.013698436692159435im
                        ⋮
  -0.025328817492520122 + 0.0011826329422999651im
   -0.02532460367843232 + 0.00039389110927144075im
```

You can index `ef` to index the response directly:
```julia
julia>  ef[1:10] == ef.resp[1:10]
true
```

Convenience functions are defined to extract the magnitude and phase of the response:
```julia
julia> magnitude(ef) == abs.(ef.resp)
true

julia> phase(ef) == angle.(ef.resp)
true
```

Finally, the frequencies and response can be iterated. This allows [destructuring by iteration](https://docs.julialang.org/en/v1/manual/functions/#destructuring-assignment), if you prefer separating the frequencies and response:
```julia
julia> frequencies, response = easyfft(s, fs);

julia> frequencies == ef.freq
true

julia> response == ef.resp
true
```

## Plotting
Because the returned value is of a custom type, automatic plot recipes can be defined. This has beed done for [Plots.jl](https://github.com/JuliaPlots/Plots.jl):
```julia
using Plots
plot(ef)
```
![Visualization of FFT](assets/s_fft.png)  
For less than 100 datapoints, the plot default to a stem plot, which is the most appropriate for showing discrete quantities. 
However, stem plots get messy and slow with too many points, which is why the default changes to a line plot if there 
are 100 datapoints or more.

In the final demonstration, let's get the indices of 5 largest amplitude components, using `partialsortperm` from Julia Base:
```julia
julia> inds_sorted_by_magnitude = partialsortperm(magnitude(ef), 1:5, rev=true)
5-element view(::Vector{Int64}, 1:5) with eltype Int64:
 11
  6
 12
 10
 13
```

We can then visualize the result as frequency => magnitude pairs:
```julia
julia> ef.freq[inds_sorted_by_magnitude] .=> magnitude(ef)[inds_sorted_by_magnitude]
5-element Vector{Pair{Float64, Float64}}:
  9.900990099009901 => 2.8796413948481443
 4.9504950495049505 => 1.9997385273893282
  10.89108910891089 => 0.3626753646683912
  8.910891089108912 => 0.21717288162592593
 11.881188118811881 => 0.18856450061284216
```

Note that the 9.9 Hz corresponds to a 2.88 magnitude. If the discrete 
frequencies lined up perfectly with the actual frequencies, we would get the actual
magnitude of 3 at 10 Hz. This is almost the case at 5 Hz, where the discrete frequency of 4.95 
lines up almost perfectly with the frequency of the second sinusoid.

That wraps up the basic usage, and there really is not much more to it. 
Check out the docstrings and/or source code for more detail.
