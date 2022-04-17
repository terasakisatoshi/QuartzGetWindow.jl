using QuartzGetWindow
using Documenter

DocMeta.setdocmeta!(QuartzGetWindow, :DocTestSetup, :(using QuartzGetWindow); recursive=true)

makedocs(;
    modules=[QuartzGetWindow],
    authors="SatoshiTerasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo="https://github.com/terasakisatoshi/QuartzGetWindow.jl/blob/{commit}{path}#{line}",
    sitename="QuartzGetWindow.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://terasakisatoshi.github.io/QuartzGetWindow.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/terasakisatoshi/QuartzGetWindow.jl",
    devbranch="main",
)
