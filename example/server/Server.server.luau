local rep = game:GetService("ReplicatedStorage")

local Bunch = require(rep.Packages.Bunch)
local x = Bunch.Element

local systems = Bunch.new(script.Parent.Systems:GetDescendants())
    :filter(x.ClassName:equals("ModuleScript"))

for _, module: ModuleScript in systems do
    require(module)
end