local Element = require(script.Element)

export type Bunch<T> = {
	--new: ({[any]: T}, {}?) -> Bunch<T>,
	map: (Bunch<T>, Element.Element) -> nil,
	mapCall: (Bunch<T>, (number, T, ...any) -> nil, ...any) -> nil,
	filter: (Bunch<T>, Element.Element) -> Bunch<T>,
	filterPairs: (Bunch<T>, Element.Element) -> Bunch<T>
}

local module = {
	Element = Element
}
module.__index = module

function module.new<T>(data: {[any]: T})
	return setmetatable(data, module)
end

function module:map(operations: Element.Element)
	for _, v in self do
		operations:result(v)
	end
	return self
end

function module:mapCall<T>(func: (i: number, v: T, ...any) -> nil, ...: any)
	for i, v in self do
		func(i, v, ...)
	end
	return self
end

function module:filter<T>(operations: Element.Element): Bunch<T>
	for i, v in self do
		if operations:result(v) then
			continue
		end
		table.remove(self, i)
	end
	return self
end

function module:filterPairs<T>(operations: Element.Element): Bunch<T>
	for i, v in self do
		if operations:result({i, v}) then
			continue
		end
		table.remove(self, i)
	end
	return self
end

return module
