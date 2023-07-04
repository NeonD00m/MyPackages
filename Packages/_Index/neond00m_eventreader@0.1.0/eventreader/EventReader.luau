--[=[
    @class EventReader

    A small system for using events in some other loop/event.

    Type:
    ```lua
    () -> (
        () -> () -> (number, ...any),
        (...any) -> nil
    )
    ```

    Example code:
    ```lua
    local read, onEvent = EventReader()

    someRemoteEventOrLibrary:Connect(onEvent)

    while task.wait(1) do
        for i, argument1, argument2 ... in read() do
            --do something
        end
    end
    ```
]=]
local function Constructor(): (() -> () -> (number, ...any), (...any) -> nil)
    local storage = {}
    
    return function() --read (iterator
        local index = 0
        return function()
            index += 1
            local value = storage[1]
            if value then
                table.remove(storage, 1)
                return index, unpack(value)
            end
            return
        end
    end, function(...) --write? (connection)
        table.insert(storage, {...})
    end
end

return Constructor