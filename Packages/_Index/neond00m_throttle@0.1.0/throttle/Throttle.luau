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
    local file, line = debug.info(2, "sl")
    local name = file .. ":" .. tostring(line)

    if systems[name] ~= nil or systems[name] + time < os.clock() then
        return false
    end
    systems[name] = os.clock()
    return true
end