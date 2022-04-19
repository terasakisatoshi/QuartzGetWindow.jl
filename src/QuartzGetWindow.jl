module QuartzGetWindow

export screensize, getActiveWindow, getWindowGeometry

using Libdl

const CFArrayRef = Ptr{Cvoid}
const CFDictionaryRef = Ptr{Cvoid}

const foundation = Libdl.find_library([
    "/System/Library/Frameworks/Foundation.framework/Resources/BridgeSupport/Foundation",
])
const coregraphics = Libdl.find_library([
    "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics",
])

include("CG_const.jl")

# CFNumber
function CFNumberGetValue(CFNum::Ptr{Cvoid}, numtype)
    CFNum == C_NULL && return nothing
    out = Cint[0]
    ccall(:CFNumberGetValue, Bool, (Ptr{Cvoid}, Cint, Ptr{Cint}), CFNum, numtype, out)
    out[1]
end

const kCFNumberSInt8Type = 1
const kCFNumberSInt16Type = 2
const kCFNumberSInt32Type = 3
const kCFNumberSInt64Type = 4
const kCFNumberFloat32Type = 5
const kCFNumberFloat64Type = 6
const kCFNumberCharType = 7
const kCFNumberShortType = 8
const kCFNumberIntType = 9
const kCFNumberLongType = 10
const kCFNumberLongLongType = 11
const kCFNumberFloatType = 12
const kCFNumberDoubleType = 13
const kCFNumberCFIndexType = 14
const kCFNumberNSIntegerType = 15
const kCFNumberCGFloatType = 16
const kCFNumberMaxType = 16

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Int8})
    CFNumberGetValue(CFNum, kCFNumberSInt8Type)
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Int16})
    CFNumberGetValue(CFNum, kCFNumberSInt16Type)
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Int32})
    CFNumberGetValue(CFNum, kCFNumberSInt32Type)
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Int64})
    CFNumberGetValue(CFNum, kCFNumberSInt64Type)
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Float32})
    CFNumberGetValue(CFNum, kCFNumberFloat32Type)
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{Float64})
    CFNumberGetValue(CFNum, kCFNumberFloat64Type)
end

function CFNumberGetValue(CFNum::Ptr{Cvoid}, ::Type{UInt8})
    CFNumberGetValue(CFNum, kCFNumberCharType)
end

# Objective-C and NS wrappers
function oms(id, uid)
    ccall(:objc_msgSend, Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), id, selector(uid))
end

function ogc(id)
    ccall((:objc_getClass, "Cocoa.framework/Cocoa"), Ptr{Cvoid}, (Ptr{UInt8},), id)
end

selector(sel::String) = ccall(:sel_getUid, Ptr{Cvoid}, (Ptr{UInt8},), sel)

function NSString(init::String)
    ccall(:objc_msgSend, Ptr{Cvoid},
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{UInt8}, UInt64),
        oms(ogc("NSString"), "alloc"),
        selector("initWithCString:encoding:"), init, 4)
end

function CFDictionaryGetValue(CFDictionaryRef::Ptr{Cvoid}, key)
    CFDictionaryRef == C_NULL && return C_NULL
    ccall(:CFDictionaryGetValue, Ptr{Cvoid},
        (Ptr{Cvoid}, Ptr{Cvoid}), CFDictionaryRef, key)
end

function CFDictionaryGetValue(CFDictionaryRef::Ptr{Cvoid}, key::String)
    CFDictionaryGetValue(CFDictionaryRef::Ptr{Cvoid}, NSString(key))
end

function CFStringGetCString(CFStringRef::Ptr{Cvoid})
    CFStringRef == C_NULL && return ""
    buffer = Array{UInt8}(undef, 1024)  # does this need to be bigger for Open Microscopy TIFFs?
    res = ccall(:CFStringGetCString, Bool, (Ptr{Cvoid}, Ptr{UInt8}, UInt, UInt16),
        CFStringRef, buffer, length(buffer), 0x0600)
    res == C_NULL && return ""
    return unsafe_string(pointer(buffer))
end

"""
Returns a Window object of the currently active Window.
"""
function getActiveWindow()
    windows =
        ccall((:CGWindowListCopyWindowInfo, coregraphics), CFArrayRef, (Cint, Cint),
            kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly,
            kCGNullWindowID,
        )
    len = ccall((:CFArrayGetCount, foundation), Cint, (CFArrayRef,), windows)
    for i in 0:(len-1)
        win = ccall(
            :CFArrayGetValueAtIndex,
            CFDictionaryRef,
            (CFArrayRef, Cint),
            windows,
            i,
        )
        if CFNumberGetValue(CFDictionaryGetValue(win, "kCGWindowLayer"), Cint) == 0
            a = CFStringGetCString(CFDictionaryGetValue(win, "kCGWindowOwnerName"))
            b = CFStringGetCString(CFDictionaryGetValue(win, "kCGWindowName"))
            return "$a $b"
        end
    end
    return nothing
end

function getWindowGeometry(title)
    windows =
        ccall((:CGWindowListCopyWindowInfo, coregraphics), CFArrayRef, (Cint, Cint),
            kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly,
            kCGNullWindowID,
        )

    len = ccall((:CFArrayGetCount, foundation), Cint, (CFArrayRef,), windows)

    for i in 0:(len-1)
        win = ccall(
            :CFArrayGetValueAtIndex,
            CFDictionaryRef,
            (CFArrayRef, Cint),
            windows,
            i,
        )
        if CFNumberGetValue(CFDictionaryGetValue(win, "kCGWindowLayer"), Cint) == 0
            a = CFStringGetCString(CFDictionaryGetValue(win, "kCGWindowOwnerName"))
            b = CFStringGetCString(CFDictionaryGetValue(win, "kCGWindowName"))
            if occursin(title, "$(a) $(b)")
                windowbounds = CFDictionaryGetValue(win, "kCGWindowBounds")
                x = CFDictionaryGetValue(windowbounds, "X")
                y = CFDictionaryGetValue(windowbounds, "Y")
                w = CFDictionaryGetValue(windowbounds, "Width")
                h = CFDictionaryGetValue(windowbounds, "Height")
                return CFNumberGetValue(x, Cint),
                CFNumberGetValue(y, Cint),
                CFNumberGetValue(w, Cint),
                CFNumberGetValue(h, Cint)
            end
        end
    end
    return nothing
end

"""
Returns the width and height of the screen as a two-integer tuple.
    Returns:
      (width, height) tuple of the screen size, in pixels.
"""
function screensize()
    displayid = ccall((:CGMainDisplayID, coregraphics), Cuint, ())
    w = ccall((:CGDisplayPixelsWide, coregraphics), Cint, (Cuint,), displayid)
    h = ccall((:CGDisplayPixelsHigh, coregraphics), Cint, (Cuint,), displayid)
    return (w, h)
end

end
