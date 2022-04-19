# QuartzGetWindow [![Build Status](https://github.com/terasakisatoshi/QuartzGetWindow.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/terasakisatoshi/QuartzGetWindow.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://terasakisatoshi.github.io/QuartzGetWindow.jl/stable) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://terasakisatoshi.github.io/QuartzGetWindow.jl/dev)

# About this repository 

- This repository [QuartzGetWindow.jl](https://github.com/terasakisatoshi/QuartzGetWindow.jl) gives a julia package for obtaining GUI information for macOS users.
	- For example we can use `getActiveWindow` function to get the name of currently active window. The result should be same as [pygetwindow.getActiveWindow](https://github.com/asweigart/PyGetWindow/blob/c5f3070324609e682d082ed53122a36002a3e293/src/pygetwindow/_pygetwindow_macos.py#L14-L22)
	- We also provide `getWindowGeometry` function to get window position and size. The result should be same as [pygetwindow.getWindowGeometry](https://github.com/asweigart/PyGetWindow/blob/c5f3070324609e682d082ed53122a36002a3e293/src/pygetwindow/_pygetwindow_macos.py#L44-L50)

- Note that our pacakge [QuartzGetWindow.jl](https://github.com/terasakisatoshi/QuartzGetWindow.jl) uses native libraries on macOS. This approach is similar to [QuartzImageIO.jl](https://github.com/JuliaIO/QuartzImageIO.jl).

# Usage & application

## Installation

Just run the following script with Julia package REPL

```julia
% julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.7.2 (2022-02-06)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

(@v1.7) pkg> add https://github.com/terasakisatoshi/QuartzGetWindow.jl
  Installing known registries into `~/.julia`
     Cloning git-repo `https://github.com/terasakisatoshi/QuartzGetWindow.jl`
    Updating git-repo `https://github.com/terasakisatoshi/QuartzGetWindow.jl`
    Updating registry at `~/.julia/registries/General.toml`
   Resolving package versions...
   Installed Crayons ─ v4.1.1
   Installed Replay ── v0.4.2
    Updating `~/.julia/environments/v1.7/Project.toml`
  [400ccb3a] + QuartzGetWindow v0.1.0 `https://github.com/terasakisatoshi/QuartzGetWindow.jl#main`
    Updating `~/.julia/environments/v1.7/Manifest.toml`
  [a8cc5b0e] + Crayons v4.1.1
  [400ccb3a] + QuartzGetWindow v0.1.0 `https://github.com/terasakisatoshi/QuartzGetWindow.jl#main`
  [dd78c5bf] + Replay v0.4.2
  [8f399da3] + Libdl
  [6462fe0b] + Sockets
Precompiling project...
  3 dependencies successfully precompiled in 2 seconds
pkg> add https://github.com/terasakisatoshi/QuartzGetWindow.jl
pkg> add Replay
```

You can remove `QuartzGetWindow` anytime via `pkg> rm QuartzGetWindow`.

## Running script

This pacakge may partially solve [this issue](https://github.com/AtelierArith/Replay.jl/issues/23). To prove that, We provided [examples/demo.jl](https://github.com/terasakisatoshi/QuartzGetWindow.jl/blob/main/examples/demo.jl).

```console
% git clone https://github.com/terasakisatoshi/QuartzGetWindow.jl.git
% cd QuartzGetWindow
% cat examples/demo.jl
using Dates

using Replay

using QuartzGetWindow

function takemov()
    x, y, w, h = getWindowGeometry(getActiveWindow())
    file = "$(Dates.now()).mov"
    run(`screencapture -R$(x),$(y),$(w),$(h) -v $(file)`)
end

function record()
    instructions = [
        "println(\"Hello QuartzGetWindow!!!\")",
        """
        for i in 1:5
            sleep(0.1)
            println(i)
        end
        println("Done")
        """,
    ]
    @async takemov()
    replay(instructions)
    exit()
end

record()
% julia examples/demo.jl
```

This will record a screen running julia instructions within your terminal and store the recording to a video file with `mov` format e.g. `2022-04-19T22:19:24.344.mov`.

https://user-images.githubusercontent.com/16760547/164014359-257d6c48-a952-4a9a-8568-6b16d6bfe0ab.mov

