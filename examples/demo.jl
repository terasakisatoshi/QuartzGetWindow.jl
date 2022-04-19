using Dates

using QuartzGetWindow

function takemov()
    x, y, w, h = getWindowGeometry(getActiveWindow())
    file = "$(Dates.now()).mov"

    p = run(`screencapture -R$(x),$(y),$(w),$(h) -v $(file)`)
end

using Replay

function dosomething()
    instructions = [
        "println(\"Hello\")",
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
