local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

local Shirt = Character:FindFirstChild("Shirt")
local Pants = Character:FindFirstChild("Pants")

local PlayerInfo = {
    player = LocalPlayer,
    character = Character,
    humanoidRootPart = HumanoidRootPart,
    shirt = Shirt, 
    shirt = Pants,
}

return PlayerInfo