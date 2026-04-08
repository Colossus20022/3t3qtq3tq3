local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- MOBILE CHECK
if not UserInputService.TouchEnabled then
	return
end

-- SETTINGS
local AIM_RADIUS = 80 -- studs
local AIM_STRENGTH = 0.1 -- lower = softer
local AIM_ENABLED = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0,120,0,50)
Button.Position = UDim2.new(0.7,0,0.7,0)
Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
Button.TextColor3 = Color3.new(1,1,1)
Button.Text = "Aim: OFF"
Button.Parent = ScreenGui
Button.Active = true
Button.Draggable = true

-- Toggle
Button.MouseButton1Click:Connect(function()
	AIM_ENABLED = not AIM_ENABLED
	Button.Text = AIM_ENABLED and "Aim: ON" or "Aim: OFF"
end)

-- Get closest target
local function getClosestTarget()
	local character = player.Character
	if not character or not character:FindFirstChild("Head") then return end
	
	local closest = nil
	local shortestDistance = AIM_RADIUS
	
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
			local distance = (v.Character.Head.Position - character.Head.Position).Magnitude
			
			if distance < shortestDistance then
				shortestDistance = distance
				closest = v
			end
		end
	end
	
	return closest
end

-- Soft Aim Loop
RunService.RenderStepped:Connect(function()
	if not AIM_ENABLED then return end
	
	local target = getClosestTarget()
	if target and target.Character and target.Character:FindFirstChild("Head") then
		
		local targetPos = target.Character.Head.Position
		local currentCFrame = camera.CFrame
		
		local newCFrame = currentCFrame:Lerp(
			CFrame.new(currentCFrame.Position, targetPos),
			AIM_STRENGTH
		)
		
		camera.CFrame = newCFrame
	end
end)