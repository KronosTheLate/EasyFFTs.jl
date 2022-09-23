using EasyFFTs
using Documenter

DocMeta.setdocmeta!(EasyFFTs, :DocTestSetup, :(using EasyFFTs); recursive=true)

makedocs(;
    modules=[EasyFFTs],
    authors="KronosTheLate",
    repo="https://github.com/KronosTheLate/EasyFFTs.jl/blob/{commit}{path}#{line}",
    sitename="EasyFFTs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://KronosTheLate.github.io/EasyFFTs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/KronosTheLate/EasyFFTs.jl",
    devbranch="main",
)
