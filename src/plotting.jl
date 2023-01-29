using RecipesBase

# Plot recipe - so plot(easyfft(y, f)) does the right thing
@recipe function f(ef::EasyFFTs.EasyFFT)
    layout := (2, 1)
    link := :x
    if length(ef.freq) ≥ 100
        nothing # because stem plots are heavy/slow when having many points
    else
        seriestype --> :stem
        markershape --> :circle
    end
    @series begin
        yguide := "Magnitude"
        subplot := 1
        label := nothing
        ef.freq, magnitude(ef)
    end
    @series begin
        xguide := "Frequency"
        yguide := "Phase"
        subplot := 2
        label := nothing
        ef.freq, phase(ef)
    end
end