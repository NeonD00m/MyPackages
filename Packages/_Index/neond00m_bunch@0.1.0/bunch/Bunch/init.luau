--[=[
    @class Bunch

    A Collection/List/Table object with some nice utilities.
]=]

local Element = require(script.Element)

export type Bunch<T> = {
	--new: ({[any]: T}, {}?) -> Bunch<T>,
	map: (Bunch<T>, Element.Element) -> nil,
	mapCall: (Bunch<T>, (number, T, ...any) -> nil, ...any) -> nil,
	filter: (Bunch<T>, Element.Element) -> Bunch<T>,
	filterPairs: (Bunch<T>, Element.Element) -> Bunch<T>
}

--[=[
	@prop Element Element
	@within Bunch

	For access to the [Element] module.
]=]

local Bunch = {
	Element = Element
}
Bunch.__index = Bunch

--[=[
	Creates a new Bunch object from the given set of data.
	```lua
	local list = Bunch.new({1, 2, 3, 4, 5})
	```
]=]
function Bunch.new<T>(data: {[any]: T})
	return setmetatable(data, Bunch)
end

--[=[
	@within Bunch
	Returns a boolean describing whether the Bunch object contains at least one of more numeric indexes.
	```lua
	local isList = someBunch:isList()
	```
]=]
function Bunch:isList(): boolean
	return table.maxn(self) > 0 
end

--[=[
	@within Bunch
	Returns a new bunch object and uses the operations on each value.
	```lua
	local doubled = someBunch:map(Element * 2)
	```
]=]
function Bunch:map<T>(operations: Element.Element): Bunch<T>
	local result = {}
	for i, v in self do
		result[i] = operations:result(v)
	end
	return Bunch.new(result)
end

--[=[
	@within Bunch
	Returns a new bunch object and uses the given function on each value.
	```lua
	local doubled = someBunch:map(function(v)
		return v * 2
	end)
	```
]=]
function Bunch:mapCall<T>(func: (v: T, ...any) -> T, ...: any): Bunch<T>
	local result = {}
	for i, v in self do
		result[i] = func(v, ...)
	end
	return Bunch.new(result)
end

--[=[
	@within Bunch
	Returns a new bunch object that is filtered by the operations given.

	:::caution
	The Element object should return a boolean value at the end.
	If the value is false or nil, the element will be removed from the Bunch.
	:::
	```lua
	local evenOnly = someBunch:filter((Element % 2):equals(0))

	local moduleScripts = Bunch.new(someInstance:GetChildren()):filter(Element.ClassName:equals("ModuleScript"))
	```
]=]
function Bunch:filter<T>(operations: Element.Element): Bunch<T>
	for i, v in self do
		if operations:result(v) then
			continue
		end
		if self:isList() then
			table.remove(self, i)
		else
			self[i] = nil
		end
	end
	return self
end

--[=[
	@within Bunch
	Returns the value at the index after removing it from the bunch object.
	```lua
	local removed = someBunch:remove("someProperty")
	```
]=]
function Bunch:remove<T>(index: any): T
	local value = self[index]
	if table.maxn(self) > 0 then
		table.remove(self, index)
	else
		self[index] = nil
	end
	return value
end

--[=[
	@within Bunch
	Returns the value at the index after removing it from the bunch object.
	```lua
	local first3Values = someBunch:range(1, 3)
	```
]=]
function Bunch:range<T>(from: number, to: number?): Bunch<T>?
	if not self:isList() then
		warn("[Bunch] Attempted to use Bunch:range on a non-list object. Consider making sure the Bunch is a list.")
		return
	end

	local result = table.create(to - from)
	for i = from, to or table.maxn(self) do
		table.insert(result, self[i])
	end
	return Bunch.new(result)
end

return Bunch
