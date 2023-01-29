
## Below is quick-and-dirty code for testing by manually running it and inspecting output:
# using Pkg
# pkg"activate --temp"
# pkg"add https://github.com/KronosTheLate/EasyFFTs.jl"
using EasyFFTs
using EasyFFTs
##


##
nt = (freq=[0, 0.2, 0.4], resp=[1, 2, 3]);
easymirror(nt)
##

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

    s_fft = easyfft(s, fs)
    plt2 = scatterplot(s_fft.freq, s_fft.resp .|> abs)
    display(plt1)
    display(plt2)
end

let
    fs = 1000
    duration = 1
    timestamps = range(0, duration, step=1 / fs)

    f = 50
    A = 2
    s1 = @. A * sin(f * 2π * timestamps)
    s2 = @. 1 * sin(2f * 2π * timestamps)
    s = s1 .+ s2
    plt1 = scatterplot(timestamps, s, axis=(title="Signal",))

    s_fft = easyfft(s, fs)
    plt2 = scatterplot(s_fft.freq, s_fft.resp .|> abs)
    display(plt1)
    display(plt2)
end

##? Internal testing
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
