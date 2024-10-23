using Pkg
Pkg.activate(joinpath(homedir(), ".julia", "environments", "v1.8"))
using EasyFFTs
Pkg.status("EasyFFTs")

fs = 100;
duration = 1;
timestamps = range(0, duration, step=1 / fs);
f1 = 5 ; A1 = 2;
f2 = 10; A2 = 3;
s = @. A1 * sin(f1 * 2π * timestamps) + A2 * sin(f2 * 2π * timestamps);

ef = easyfft(s, fs)


Pkg.offline(true)
try
    using MakieCore
catch e
    Pkg.add("MakieCore")
    using MakieCore
end

using GLMakie

Makie.convert_arguments(P::MakieCore.PointBased, ef::EasyFFTs.EasyFFT) = (decompose(Point2f, ef.freq), decompose(Point2f, magnitude(ef)))
Makie.convert_arguments(P::MakieCore.PointBased, ef::EasyFFTs.EasyFFT) = (ef.freq, magnitude(ef))
plottype(::EasyFFTs.EasyFFT) = Stem
plot(ef)
##
using Plots

plot(ef)


##? Makie
using WGLMakie

let
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

    # DataInspector()
    fig

end
