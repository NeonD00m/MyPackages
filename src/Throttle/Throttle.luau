--[=[
    @class Throttle

    A timer function for intervals.
]=]
local systems: {[string]: number} = {}

--[=[
    @within Throttle
    @function __call
    @param timeOrName: number | string, time: number?
    @return boolean

    Returns true based on if it has been 'time' since the last success.
    :::caution
    Throttles are saved based on the file name and file line they are called at by default, include an identifier to use the same throttle in multiple places a shown below:
    :::
    ```lua
    while task.wait(0.1) do --a loop of some sort or maybe in an event
        if Throttle(3) then
            print("3 seconds have passed")
        end
    end
    --Or if you want to use the same debounce/cooldown in multiple places:
    Throttle("someUniqueIdentifier", 3)
    ```
]=]
return function(timeOrName: number | string, time: number?): boolean
    local name = timeOrName
    if time == nil then
        local file, line = debug.info(2, "sl")
        name = file .. ":" .. tostring(line)
        time = timeOrName
    end
    assert(time, "[Throttle] No 'time' argument provided, please provide a number in seconds to wait.")

    if systems[name] then
        if systems[name] + time > os.clock() then
            return false
        end
    end
    systems[name] = os.clock()
    return true
end