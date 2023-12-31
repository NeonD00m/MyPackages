--[=[
	@class Richify

	A rich-text customizer library.
	To see all the rich-text tags [here](https://create.roblox.com/docs/ui/rich-text).
]=]

-- current example below
-- 	concepts (sections have not been successfully implemented yet):
-- 	```lua
-- 	--                                \/(create object)\/   \/edit section
-- 	local result: {string: string} = richify "hello world" {0, 5} "stroke"(Color3.new(1, 0, 0))
-- 	--or non-fusion-style:                                          /\ edit stroke with /\ the color of Red
-- 	local result: {string: string} = richify("hello world")({0, 5})("stroke")(Color3.new(1, 0, 0))

-- 	--MORE fusion-style:
-- 	local result: string = richify "hello" {
-- 		"bold",
-- 		{
-- 			"stroke",
-- 			Color3.new(1, 0, 0)
-- 		}
-- 	}
-- 	```

local meta = {}
meta.index = meta

export type RichifyInputType = {number} | "color" | "size" | "stroke" | "insert" | "b" | "i" | Color3 | number

--[=[
	@within Richify
	@type Richify { string: string, __call: (InputType) -> Richify }

	The type for the richify object after initializing one with a string.
]=]
export type Richify = {
    string: string,
    __call: (RichifyInputType) -> Richify
}

--[=[
	@within Richify
	@type Tags { bold = "b", italic = "i", }

	Just some shortened tag names for ease of use.
	Example: turns "bold" into the rich text tag "b" here:
	```lua
	local boldHelloWorld = richify "hello world" "bold"
	```
]=]
local tagsToRich = {
	bold = "b",
	italic = "i",
}


local function actual(str: string, index: number) : number
	local inTag = false
	local direction = if index < 0 then -1 else 1
	for i = if index < 0 then str:len() else 1,
		if index < 0 then 1 else str:len(), direction do

		local ch = str:sub(i, i)
		if inTag then
			if ch == ">" then
				index -= 1
				inTag = false
			end
			-- index -= 1
		elseif ch == "<" then
			inTag = true
		else
			index -= direction
		end

		if index == 0 and inTag == false then
			return i
		end
	end
	return index--actual(str, index) --loo (Does that mean loop?)
end

local function split(self, index: number | nil) --split self.str in half
	--print("split:", self)
	local len = self.string:len()
	if index then --splitting at one specific index
		index = actual(self.str, index)
		return {
			self.string:sub(1, index),
			self.string:sub(index, len)
		}
	end
	--need to return 3 pieces: before self.s, in between, after self.e

	local divider1 = actual(self.string, (self.s or 0))
	local divider2 = actual(self.string, (self.e or len))

	return {"", self.string, ""} --[[{
		--what if self.s < 0
		self.string:sub(0, divider1 - 1) or "",
		--
		self.string:sub(divider1, divider2), --GOAL: between string, whole if no start and no end
		--
		self.string:sub(divider2 + 1, len) or "",
	}]]
end

local function clr_tostring(color: Color3): string
	return tostring(math.round(color.R * 255)) .. "," .. tostring(math.round(color.G * 255)) .. "," .. tostring(math.round(color.B * 255))
end

--[=[
	@within Richify
	@function __call

	The initiator/constructor of a Richify object.
	```lua
	local result: Richify = richify "hello world"
	```
]=]
local function richify(string): Richify
	return setmetatable({
		string = string,
		-- edit = nil,
		-- s = nil,
		-- e = nil,
	}, meta)
end

--[=[
	@within Richify
	@function __call

	Richify only has one method which is calling the Richify object.

	```lua
	--                         			\/ create object
	local result: string = (richify "hello" "stroke"(Color3.new(1, 0, 0))).string
	--                                          /\ edit stroke with the color of Red
	local result: Richify = richify("world")("stroke")(Color3.new(1, 0, 0))
	```

	| InputType | Description | Next Parameters
	| -- | -- | -- |
	| {number} (NOT IMPLEMENTED) | Edit a section of the string | none |
	| "color" | Edit the color of the section | (color: Color3) |
	| "size" | Edit the font size of the section | (size: number) |
	| "stroke" | Edit the stroke of the section | (color: Color3, joins: string, thickness: number, transparency: number) |
	| "insert" | Insert a string at a specific spot | {[1]: number, [2]: string} |
	| (any rich text tag or shortened tag) | Add a rich text tag to the section | none |
]=]
meta.__call = function(self, value: RichifyInputType)
	if self.edit then --if previous statement requires another parameter
		local result = self:edit(value)
		return result
	else
		--THE SECTION FEATURE IS BROKEN
		-- if type(value) == "table" then --edit section of string
		-- 	self.s = value[1]
		-- 	self.e = value[2]
		-- else
		if value == "color" then
			self.edit = function(self, color)
				local pieces = split(self)
				self.string = pieces[1] .. '<font color="rgb(' .. clr_tostring(color) .. ')">' .. pieces[2]
					.. "</font>" .. pieces[3]
				self.edit = nil
				return self
			end
		elseif value == "size" then
			self.edit = function(self, size)
				local pieces = split(self)
				self.string = pieces[1] .. '<font size="' .. tostring(size) .. '">' .. pieces[2]
					.. "</font>" .. pieces[3]
				self.edit = nil
				return self
			end
		elseif value == "stroke" then
			self.edit = function(self, color, joins, thickness, transparency)
				local pieces = split(self)
				self.string = pieces[1] .. '<stroke color="rgb(' .. tostring(color) .. ')" joins ="' ..
					(joins or 'miter') .. '" thickness ="' .. (tostring(thickness or 2)) .. '" transparency ="' ..
					(tostring(transparency or 0.25)) .. '">' .. pieces[2] .. "</stroke>" .. pieces[3]
				self.edit = nil
				return self
			end
		elseif value == "insert" then
			self.edit = function(self, info: {number | string})
				local pieces = split(self, info[1])
				self.string = pieces[1] .. info[2] .. pieces[2]
				self.edit = nil
				return self
			end
		else --assume it is a rich text tag?
			if tagsToRich[value] then --correct tag, ex: 'bold' to 'b'
				value = tagsToRich[value]
			end
			local pieces = split(self)
			self.string = pieces[1] .. "<" .. value .. ">" .. pieces[2] .. "</" .. value .. ">" .. pieces[3]
		end
	end
	return self
end

return richify