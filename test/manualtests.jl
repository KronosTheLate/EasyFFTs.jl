using EasyFFTs

fs = 100;
duration = 1;
timestamps = range(0, duration, step=1 / fs);
f1 = 5 ; A1 = 2;
f2 = 10; A2 = 3;
s = @. A1 * sin(f1 * 2π * timestamps) + A2 * sin(f2 * 2π * timestamps);

ef = easyfft(s, fs)

ef.freq
ef.resp

frequencies, response = easyfft(s, fs);

frequencies == ef.freq == ef[1]
response == ef.resp == ef[2]

ef[1]
ef[2]
ef[begin]
a, b = ef

fs = 100;  # 100 samples per second
timestamps = range(0, 1, step = 1/fs);
s = sin.(2pi * 2 * timestamps); # sine of frequency = 2 Hz
easyfft(s, fs)

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
