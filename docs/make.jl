using AdaptiveStepSize
using Documenter

DocMeta.setdocmeta!(AdaptiveStepSize, :DocTestSetup, :(using AdaptiveStepSize); recursive=true)

makedocs(;
    modules=[AdaptiveStepSize],
    authors="pmc4 <117096890+pmc4@users.noreply.github.com> and contributors",
    sitename="AdaptiveStepSize.jl",
    format=Documenter.HTML(;
        canonical="https://pmc4.github.io/AdaptiveStepSize.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pmc4/AdaptiveStepSize.jl",
    devbranch="main",
)
