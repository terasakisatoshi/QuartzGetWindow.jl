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
