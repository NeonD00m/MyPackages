--!strict
--Inp(ut)Act(ion) by NeonD00m
--Version 0.3

--GOALS:
--  -  Add thumbsticks?
--[=[
    @class InpAct

    A full Input Manager for:
    - Mobile Support with easy touch controls (soon: thumbsticks, default edit gui)
    - Keybind Support with two easy methods
    - And Easy To Use Methods
]=]

--[=[
    @within InpAct
    @type InputType Enum.UserInputType | Enum.KeyCode

    General type for any input object.
]=]
type InputType = Enum.UserInputType | Enum.KeyCode

--[=[
    @within InpAct
    @type InputAxis = {
        --Name: string,
        Inputs: {[InputType]: true},
        DefaultInputs: {InputType},
        OnInput: (InputObject) -> nil,
        InputState: boolean,

        TouchParent: GuiObject?,
        TouchButton: GuiButton?,
        TouchInput: InputObject?,
    }

    General type for any input object.
]=]
type InputAxis = {
	--Name: string,
	Inputs: {[InputType]: true},
	DefaultInputs: {InputType},
	OnInput: (InputObject) -> nil,
	InputState: boolean,

	TouchParent: GuiObject?,
	TouchButton: GuiButton?,
	TouchInput: InputObject?,
}

-- type TouchOptions = {
-- 	CustomButton: GuiButton?,
-- 	DefaultPosition: UDim2,
-- 	Thumbstick: boolean?,
-- 	DefaultSize: UDim2?,
-- 	Draggable: boolean?,
-- 	Icon: number?,
-- }

local UserInputService = game:GetService("UserInputService")

local library = {}
local inputAxes: {[string]: InputAxis} = {}
local history: {[string]: boolean?} = {}

--STATE
local editMode = false

--GUI
local UI = Instance.new("ScreenGui")
UI.Name = "InpActGui"
UI.IgnoreGuiInset = true
UI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
UI.Enabled = true
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

--CONSTANTS
local MouseButton1 = Enum.UserInputType.MouseButton1
local MouseMoved = Enum.UserInputType.MouseMovement
local Touch = Enum.UserInputType.Touch

--PRIVATE METHODS
local function interpret(input): InputType
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		return input.KeyCode
	else--if input.UserInputType ~= Enum.UserInputType.None then
		return input.UserInputType
	end
end

local function newButton(name: string, options: {
	CustomButton: GuiButton?,
	DefaultPosition: UDim2,
	Thumbstick: boolean?,
	DefaultSize: UDim2?,
	Draggable: boolean?,
	Icon: number?,
}?): GuiButton?
	if options and not options.CustomButton then
		if not options.Thumbstick then
			local test = Instance.new("ImageButton")
			test.Name = name
			test.Active = not options.Draggable
			test:SetAttribute("Draggable", options.Draggable)
			test.Image = `http://www.roblox.com/asset/?id={options.Icon or 9808871841}`
			test.AnchorPoint = Vector2.new(0.5, 0.5)
			test.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			test.BackgroundTransparency = 0.5
			test.Position = options.DefaultPosition or UDim2.fromOffset(824, 352)
			test.Size = options.DefaultSize or UDim2.fromOffset(50, 50)

			local UICorner = Instance.new("UICorner")
			UICorner.Name = "UICorner"
			UICorner.CornerRadius = UDim.new(1, 0)
			UICorner.Parent = test

			test.Parent = UI
			return test
		else
			--create a gui thumbstick
			warn("Thumbsticks have not been implemented yet")
		end
	end
	return if options then options.CustomButton else nil
end

--STATIC METHODS
--[=[
	@within InpAct
	Creates an Input Axis.
	```lua
	InpAct:CreateAxis("ShootGun", {Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2}, function(input: InputObject)
        print("pow")
    end)
	```
]=]
function library:CreateAxis(name: string, options: {InputType}?, onInput: (InputObject) -> nil)
	inputAxes[name] = {
		Inputs = {},
		DefaultInputs = options or {},
		OnInput = onInput,
		InputState = false,
		TouchButton = nil
	}
	if options then
		library:AddInputs(name, options)
	end
end

--[=[
	@within InpAct
	Adds InputTypes to an Axis. This doesn't remove previous InputTypes, to set the InputTypes use InpAct:SetInputs.
	```lua
	InpAct:AddInputs("Reload", {Enum.KeyCode.R})
	```
]=]
function library:AddInputs(name: string, newInputs: {InputType})
	for _, input: InputType in newInputs do
		inputAxes[name].Inputs[input] = true
	end
end

--[=[
	@within InpAct
	Sets all the InputTypes to an Input Axis.
	```lua
	InpAct:SetInputs("Reload", {Enum.KeyCode.R})
	```
]=]
function library:SetInputs(name, ...)
	inputAxes[name].Inputs = {}
	library:AddInputs(name, ...)
end

--[=[
	@within InpAct
	Resets all the InputTypes to the ones originally defined with the Input Axis.
	```lua
    InpAct:CreateAxis("Reload", {Enum.KeyCode.R}, someFunction)
    ...
	InpAct:ResetInputs("Reload")
	```
]=]
function library:ResetInputs(name: string)
	library:SetInputs(name, inputAxes[name].DefaultInputs)
end

--[=[
	@within InpAct
	Gets all the current InputTypes of an Input Axis.
	```lua
	local currentInputTypes = InpAct:SetInputs("Reload")
	```
]=]
function library:GetInputs(name: string): {InputType}
	local list = table.create(#inputAxes[name].Inputs)
	for input: InputType, value: boolean in inputAxes[name].Inputs do
		if value then --should be true but maybe in the future that will change?
			table.insert(list, input)
		end
	end
	return list
end

--[=[
	@within InpAct
	Creates and connects a button to an Input Axis.
	```lua
	InpAct:AddButton("Reload", {
        CustomButton = nil,  --If you want to connect your own TextButton or ImageButton instead
        DefaultPosition = UDim2.fromScale(0.759, 0.667), --DefaultSize because eventually mobile control settings are coming
        DefaultSize = UDim2.fromOffset(70, 70), --DefaultSize because eventually mobile control settings are coming
        Draggable = true, --true lets the players hold a click on the button while dragging away
        Icon = 9808870392,  --the image displayed on the button
    })
	```
]=]
function library:AddButton(name: string, options: {
	CustomButton: GuiButton?,
	DefaultPosition: UDim2,
	Thumbstick: boolean?,
	DefaultSize: UDim2?,
	Draggable: boolean?,
	Icon: number?,
})
	local btn = newButton(name, options)

	if btn then
		btn.InputBegan:Connect(function(inputObject: InputObject)
			if inputObject.UserInputState == Enum.UserInputState.Change then
				return
			end
			if inputObject.UserInputType ~= Touch and inputObject.UserInputType ~= MouseButton1 then
				return
			end
			if not editMode and not inputAxes[name].InputState then
				inputAxes[name].OnInput(inputObject)
				inputAxes[name].InputState = true
				inputAxes[name].TouchInput = inputObject
			end
		end)
	end
	inputAxes[name].TouchButton = btn
end

--[=[
	@within InpAct
	Gets the current state of an Input Axis.
	```lua
	local isButtonDown, wasButtonDownLastTime = InpAct:GetInputState("Reload")
	```
]=]
function library:GetInputState(name: string): (boolean, boolean)
	local old = history[name] or false
	local new = inputAxes[name].InputState
	history[name] = new
	return new, old
end

-- Ideally we would want the callback to be static but this is more flexible
-- BUT this might make people think they can connect multiple callbacks
--function library.OnInput(name: string, onInput: (InputObject) -> nil)
--	inputAxes[name].OnInput = onInput
--end

--[=[
	@within InpAct
	Control whether mobile touch buttons are visible or not.
	```lua
	InpAct:SetTouchButtonsEnabled(false)
	```
]=]
function library:SetTouchButtonsEnabled(enabled: boolean)
	UI.Enabled = enabled
end

--[=[
	@within InpAct
	Control whether mobile touch buttons are visible or not.
	```lua
	local keybinds = InpAct:GetKeybinds() --then save this to a datastore or something
	```
]=]
function library:GetKeybinds(): {[string]: {InputType}}
	local results = {}
	for name, axis in inputAxes do
		local inputs = {}
		for key in axis.Inputs do
			table.insert(inputs, key)
		end
		results[name] = inputs
	end
	return results
end

--[=[
	@within InpAct
	Control whether mobile touch buttons are visible or not.
	```lua
	InpAct:SetKeybinds(savedKeybinds) --retrieved from a datastore or something
	```
]=]
function library:UseKeybinds(keybinds: {[string]: {InputType}})
	for name, inputs in keybinds do
		library:SetInputs(name, inputs)
	end
end

--CONNECTIONS
UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed: boolean)
	if gameProcessed then return end

	local interpretedInput = interpret(inputObject)

	for name: string, axis: InputAxis in inputAxes do
		if not axis.Inputs or axis.Inputs[interpretedInput] then
			axis.OnInput(inputObject)
			axis.InputState = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(inputObject: InputObject, gameProcessed: boolean)
	local interpretedInput = interpret(inputObject)
	local isTouchOrMouse = inputObject.UserInputType == Touch or inputObject.UserInputType == MouseButton1

	for name: string, axis: InputAxis in inputAxes do
		if (isTouchOrMouse and axis.TouchInput == inputObject) or
			(not gameProcessed and (not axis.Inputs or axis.Inputs[interpretedInput])) then
			axis.OnInput(inputObject)
			axis.InputState = false
			axis.TouchInput = nil
		end
	end
end)

return library
