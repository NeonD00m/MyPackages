--[=[
    @class Throttle

    A timer function for intervals.
]=]
local systems: {[string]: number} = {}

--[=[
    @within Throttle
    @function __call

    Returns true based on if it has been 'time' since the last success.
    :::caution
    Throttles are saved based on the file name and file line they are called at.
    :::
    ```lua
    while task.wait(0.1) do --a loop of some sort or maybe in an event
        if Throttle(3) then
            print("3 seconds have passed")
        end
    end
    ```
]=]
return function(time: number): boolean
    assert(time, "[Throttle] No 'time' argument provided, please provide a number in seconds to wait.")
    local file, line = debug.info(2, "sl")
    local name = file .. ":" .. tostring(line)

    print("throttle debug: clock:", os.clock(), ", system:", systems[name])
    if systems[name] then
        print("    comparison:", systems[name] + time, "<", os.clock())
        print("    resulting boolean:", systems[name] + time < os.clock())
        if systems[name] + time < os.clock() then
            return false
        end
    end
    systems[name] = os.clock()
    return true
end