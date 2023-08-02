local rep = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Throttle = require(rep.Packages.Throttle)
local Richify = require(rep.Packages.Richify)
local EventReader = require(rep.Packages.EventReader)

local Button: Model = workspace:WaitForChild("Button")
local Prompt: ProximityPrompt = Button:WaitForChild("Button"):WaitForChild("ProximityPrompt") :: ProximityPrompt
local Label: TextLabel = Button:WaitForChild("BillboardGui"):WaitForChild("TextLabel") :: TextLabel

local read, onEvent = EventReader()
Prompt.Triggered:Connect(onEvent)

local DEBOUNCE = 1

local count = 0

local function updateText()
    print("count:", count, tostring(count))
    -- Label.Text = count .. " Clicks"
    Label.Text = Richify(tostring(count)) "bold" "color" (Color3.fromRGB(0, 251, 255)).string .. " Clicks"
end
updateText()

RunService.Heartbeat:Connect(function()
    for _, plr in read() do
        if Throttle(DEBOUNCE) then
           count += 1
           updateText()
        end
    end
end)

return true --not really important for this example