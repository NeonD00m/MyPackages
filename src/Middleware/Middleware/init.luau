--[=[
    @class Middleware

    A small library for creating middleware that can work anywhere. This was originally from NeoNet but since more advanced networking libraries exist now and
    middleware may be something you want in other circumstances, I decided to turn this into its own package.
]=]
local RateLimiter: RemoteClientMiddleware & RemoteServerMiddleware = require(script:WaitForChild("RateLimiter"))
local TypeChecker: RemoteClientMiddleware & RemoteServerMiddleware = require(script:WaitForChild("TypeChecker"))

--[=[
    @prop RateLimiter
    @within Middleware

    For access to the built-in RateLimiter.
]=]

--[=[
    @prop TypeChecker
    @within Middleware

    For access to the built-in TypeChecker.
]=]

local module = {
    RateLimiter = RateLimiter,
    TypeChecker = TypeChecker,
}

--[=[
    @within Middleware
    @type RemoteClientMiddleware (Parameters: {number: any},) -> (boolean, {number: any})

    Type for client middleware. [See how to create your own middleware here.](/docs/customMiddleware)
]=]
export type RemoteClientMiddleware = (
    Parameters: {any}?
) -> (boolean, {any}?)

--[=[
    @within Middleware
    @type RemoteServerMiddleware (Player: Player,Parameters: {number: any}) -> (boolean, {number: any})

    Type for server middleware. [See how to create your own middleware here.](/docs/customMiddleware)
]=]
export type RemoteServerMiddleware = (
    Player: Player,
    Parameters: {any}?
) -> (boolean, {any}?)

--[=[
	@within Middleware
	Returns the result of either Middleware.Server or Middleware.Client depending on RunService:IsStudio().
	```lua
	Event:Connect(Middleware.auto(someFunc, someMiddleware))
	```
]=]
function module.auto(...): () -> nil
    return if game:GetService("RunService"):IsServer() then module.Server(...) else module.Client(...)
end

--[=[
	@within Middleware
	Returns a function that tests the parameters through the middleware before running the handler.
	```lua
	Event:Connect(Middleware.Server(someFunc, someMiddleware))
	```
]=]
function module.Server(handler: (Player, ...any) -> nil, ...: RemoteServerMiddleware): () -> nil
    local middle = {...}
    return function(plr, ...)
        local result = true
        local params = {...}

        --loop through middleware to check
        for _, ware: RemoteServerMiddleware in middle do
            result, params = ware(plr, params)
            if not result then
                return
            end
        end

        --passed middleware
        return handler(plr, unpack(params))
    end
end

--[=[
	@within Middleware
	Returns a function that tests the parameters through the middleware before running the handler.
	```lua
	Event:Connect(Middleware.Client(someFunc, someMiddleware))
	```
]=]
function module.Client(handler: (...any) -> nil, ...: RemoteClientMiddleware): () -> nil
    local middle = {...}
    return function(...)
        local result = true
        local params = {...}

        --loop through middleware to check
        for _, ware: RemoteClientMiddleware in middle do
            result, params = ware(params)
            if not result then
                return
            end
        end

        --passed middleware
        return handler(unpack(params))
    end
end

return module