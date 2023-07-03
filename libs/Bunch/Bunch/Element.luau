export type Element = {
	result: (Element, any) -> any,
	equals: (Element, any) -> Element,
}

local module = {}
module.__index = module

local default = setmetatable({}, module)

local function new(parent)
	return setmetatable({ops = {}, parent = parent, indexSkip = false}, module)
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

function module:__tostring()
	return addOp(self, {"print"})
end

--NeonD00m: cancelled this approach since it forces the result to be a boolean afterwards
--function module:__eq(other)
function module:equals(other): Element
	--if rawequal(other, default) then
	--	print("rawequaling default")
	--	return rawequal(self, default)
	--end
	--print("adding equal op")
	return addOp(self, {"==", other})
end

--function module:__lt(value): Element
--	print("lt")
function module:lessThan(value): Element
	return addOp(self, {"<", value})
end

--function module:__le(value): Element
--	print("lt")
function module:lessThanOrEqualTo(value): Element
	return addOp(self, {"<=", value})
end

function module:moreThan(value): Element
	return addOp(
		addOp(
			self,
			{"<=", value}
		),
		{"not"}
	)
end

function module:moreThanorEqualTo(value): Element
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

--Methods
--function default:print(object)
--	print(object.ops)
--end

function module:result(x: any): any
	print("calling result with value:", x)
	for _, op in self.ops do
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
		else
			warn("[Bunch.Element] Unexpected operation data:", op)
		end
		print(" - did operation, now:", x)
	end
	print(" - returning:", x)
	return x
end

return default
