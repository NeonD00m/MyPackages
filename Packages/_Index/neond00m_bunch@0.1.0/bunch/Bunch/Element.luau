--[=[
	@class Element

	An object to replicate the conciseness of lambda functions even if not all the capabilities are achieved.
	An Element object is automatically created when an operator is used on it.
]=]

export type Element = {
	ops: {},
	result: (Element, any) -> any,
	equals: (Element, any) -> Element,
	lessThan: (Element, any) -> Element,
	lessThanOrEqualTo: (Element, any) -> Element,
	moreThan: (Element, any) -> Element,
	moreThanorEqualTo: (Element, any) -> Element,
}

local module = {}
module.__index = module

local default = setmetatable({}, module)

local function new(parent)
	local self = nil
	self = setmetatable({
		ops = {},
		parent = parent
	}, module)

	return self
end

local function addOp(self, opData)
	--print("addOp:", opData)
	if self == default then
		self = new()
	end
	table.insert(self.ops, opData)
	return self
end

function module:__index(index): Element
	--print("__index:", index)
	--print("rawget:", rawget(self, index))
	if module[index] ~= nil then
		--print("rawgetting:", index)
		--return rawget(self, index)
		return module[index]
	end
	return addOp(self, {".", index})
	
	--do I want to create a new X object at the risk of increasing complexity?
	
	--local child = new(self)
	--addOp(self, {".", child})
	--return child
end

function module:__newindex(index, value): Element
	if --[[rawequal(self, default) and ]]index == "result" then
		rawset(self, index, value)
	end
	--print("__newindex:", index, value)
	return addOp(self, {".=", index, value})
end

function module:__call(...): Element
	return addOp(self, {"()", {...}})
end

function module:__concat(value): Element
	return addOp(self, {"..", value})
end

function module:__unm(): Element
	return addOp(self, {"--"})
end

function module:__add(value): Element
	return addOp(self, {"+", value})
end

function module:__sub(value): Element
	return addOp(self, {"-", value})
end

function module:__mul(value): Element
	return addOp(self, {"*", value})
end

function module:__div(value): Element
	return addOp(self, {"/", value})
end

function module:__mod(value): Element
	return addOp(self, {"%", value})
end

function module:__pow(value): Element
	return addOp(self, {"^", value})
end

-- function module:__tostring()
-- 	return addOp(self, {"print"})
-- end

--NeonD00m: cancelled this approach since it forces the result to be a boolean afterwards
--function module:__eq(other)
--[=[
	@within Element
	Replacement for the '==' operator.
	```lua
	local evenOnly = someBunch:filter((Element % 2):equals(0))
	```
]=]
function module:equals(other: any): Element
	--if rawequal(other, default) then
	--	print("rawequaling default")
	--	return rawequal(self, default)
	--end
	--print("adding equal op")
	return addOp(self, {"==", other})
end

--function module:__lt(value): Element
--	print("lt")
--[=[
	@within Element
	Replacement for the '<' operator.
	```lua
	local negativeOnly = someBunch:filter(Element:lessThan(0))
	```
]=]
function module:lessThan(value: any): Element
	return addOp(self, {"<", value})
end

--function module:__le(value): Element
--	print("lt")
--[=[
	@within Element
	Replacement for the '<=' operator.
	```lua
	local negativeOrZero = someBunch:filter(Element:lessThanorEqualTo(0))
	```
]=]
function module:lessThanOrEqualTo(value: any): Element
	return addOp(self, {"<=", value})
end

--[=[
	@within Element
	Replacement for the '>' operator.
	```lua
	local positiveOnly = someBunch:filter(Element:moreThan(0))
	```
]=]
function module:moreThan(value: any): Element
	return addOp(
		addOp(
			self,
			{"<=", value}
		),
		{"not"}
	)
end

--[=[
	@within Element
	Replacement for the '>' operator.
	```lua
	local positiveOrZero = someBunch:filter(Element:moreThanOrEqualTo(0))
	```
]=]
function module:moreThanorEqualTo(value: any): Element
	return addOp(
		addOp(
			self,
			{"<", value}
		),
		{"not"}
	)
end

function module:__len(): Element
	return addOp(self, {"#"})
end

--[=[
	@within Element
	Stores the operations of calling the specified function on the Element.
	The position parameter controls what place the Element's value is in the parameters specified after.
	```lua
	someBunch:filter(Element:call(print))

	someBunch:filter(Element:call(isValid, 2, "something") --wherethe type looks like isValid: (string, T) -> boolean
	```
]=]
function module:call(func: () -> any, position: number, ...: any): Element
	return addOp(self, {"call", func, position or 0, {...}})
end

--Methods
--[=[
	@within Element
	Returns the resulting value after completing the operations on it.
	```lua
	local doubled = (Element * 2):result(someNumber)
	```
]=]
function module.result(e: Element, x: any)
	for _, op in e.ops do
		if op[1] == "." then
			x = x[op[2]]
		elseif op[1] == ".=" then
			x[op[2]] = op[3]
		elseif op[1] == "()" then
			x(unpack(op[2]))
		elseif op[1] == ".." then
			x ..= op[2]
		elseif op[1] == "--" then
			x = -x
		elseif op[1] == "+" then
			x += op[2]
		elseif op[1] == "-" then
			x -= op[2]
		elseif op[1] == "*" then
			x *= op[2]
		elseif op[1] == "/" then
			x /= op[2]
		elseif op[1] == "%" then
			x %= op[2]
		elseif op[1] == "^" then
			x ^= op[2]
		elseif op[1] == "print" then
			x = x.__tostring()
		elseif op[1] == "==" then
			x = x == op[2]
		elseif op[1] == "<" then
			x = x < op[2]
		elseif op[1] == "<=" then
			x = x <= op[2]
		elseif op[1] == "#" then
			x = #x
		elseif op[1] == "not" then
			x = not x
		elseif op[1] == "call" then
			local params = table.clone(op[4])
			table.insert(params, op[3], x)
			x = op[2](unpack(params))
		else
			warn("[Bunch.Element] Unexpected operation data:", op)
		end
	end
	return x
end

return default
