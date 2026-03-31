-- NiggaHax V1 (with RGB boxes, Oreo image, toggles, ESP warning)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- STATE
--------------------------------------------------
local TARGET_COLOR = Color3.fromRGB(255, 0, 0)

local AIMBOT_KEY = Enum.UserInputType.MouseButton3
local GUI_KEY = Enum.KeyCode.RightShift

local AIMBOT_ENABLED = false
local HOLD_MODE = false

local AIM_SMOOTHNESS = 1
local MAX_DISTANCE = 600

--------------------------------------------------
-- COLORS
--------------------------------------------------
local OREO_BLACK = Color3.fromRGB(15,15,18)
local OREO_DARK  = Color3.fromRGB(30,30,36)
local OREO_WHITE = Color3.fromRGB(240,240,245)
local OREO_CREAM = Color3.fromRGB(255,0,0)

local GREEN = Color3.fromRGB(90,255,120)
local RED   = Color3.fromRGB(255,90,90)

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(330, 300)
main.Position = UDim2.fromOffset(50, 160)
main.BackgroundColor3 = OREO_BLACK
main.Active = true
main.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke", main)
stroke.Color = OREO_WHITE
stroke.Thickness = 1.5

--------------------------------------------------
-- TITLE
--------------------------------------------------
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromOffset(330, 40)
title.BackgroundTransparency = 1
title.Text = "NiggaHax V1"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = OREO_CREAM
title.TextStrokeColor3 = Color3.new(1,1,1)
title.TextStrokeTransparency = 0.7  -- lowered glow brightness
title.TextXAlignment = Enum.TextXAlignment.Center

local glow = Instance.new("UIStroke", title)
glow.Thickness = 2
glow.Transparency = 0.75  -- lowered glow brightness
glow.Color = Color3.fromRGB(255,255,255)

--------------------------------------------------
-- OREO IMAGE (Inside GUI, top right)
--------------------------------------------------
local oreoImg = Instance.new("ImageLabel", main)
oreoImg.Size = UDim2.fromOffset(80, 80)
oreoImg.Position = UDim2.fromOffset(main.AbsoluteSize.X - 90, 50)
oreoImg.BackgroundTransparency = 1
oreoImg.Image = "rbxassetid://f909fa4f-28f6-4058-9105-486ea4eca445" -- Your uploaded Oreo image
oreoImg.AnchorPoint = Vector2.new(1, 0) -- Align right edge

-- Adjust position on resize (optional)
main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	oreoImg.Position = UDim2.fromOffset(main.AbsoluteSize.X - 90, 50)
end)

--------------------------------------------------
-- SWITCH (reusable)
--------------------------------------------------
local function createSwitch(text, y, initialState, callback)
	local label = Instance.new("TextLabel", main)
	label.Position = UDim2.fromOffset(30, y)
	label.Size = UDim2.fromOffset(180, 24)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = OREO_WHITE
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left

	local bg = Instance.new("Frame", main)
	bg.Position = UDim2.fromOffset(230, y)
	bg.Size = UDim2.fromOffset(60, 24)
	bg.BackgroundColor3 = initialState and GREEN or RED
	local bgCorner = Instance.new("UICorner", bg)
	bgCorner.CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame", bg)
	knob.Size = UDim2.fromOffset(20,20)
	knob.Position = initialState and UDim2.fromOffset(38,2) or UDim2.fromOffset(2,2)
	knob.BackgroundColor3 = OREO_WHITE
	local knobCorner = Instance.new("UICorner", knob)
	knobCorner.CornerRadius = UDim.new(1,0)

	local state = initialState

	bg.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			state = not state
			callback(state)

			TweenService:Create(bg, TweenInfo.new(0.25),
				{BackgroundColor3 = state and GREEN or RED}
			):Play()

			TweenService:Create(knob, TweenInfo.new(0.25),
				{Position = state and UDim2.fromOffset(38,2) or UDim2.fromOffset(2,2)}
			):Play()
		end
	end)
end

--------------------------------------------------
-- CREATE SWITCHES
--------------------------------------------------
createSwitch("Aimbot", 60, AIMBOT_ENABLED, function(v)
	AIMBOT_ENABLED = v
end)

createSwitch("Hold Mode", 95, HOLD_MODE, function(v)
	HOLD_MODE = v
end)

createSwitch("ESP", 130, false, function(v)
	if v then
		local msg = Instance.new("TextLabel", gui)
		msg.Size = UDim2.fromScale(1, 0.1)
		msg.Position = UDim2.fromScale(0, 0.45)
		msg.BackgroundTransparency = 1
		msg.Text = "NO ESP WORKS HERE"
		msg.Font = Enum.Font.GothamBold
		msg.TextSize = 32
		msg.TextColor3 = Color3.fromRGB(255,80,80)
		msg.TextStrokeTransparency = 0.3
		msg.TextXAlignment = Enum.TextXAlignment.Center
		msg.TextYAlignment = Enum.TextYAlignment.Center

		task.delay(15, function()
			if msg then msg:Destroy() end
		end)
	end
end)

--------------------------------------------------
-- RGB INPUT (Restored)
--------------------------------------------------
local function inputBox(placeholder, x)
	local t = Instance.new("TextBox", main)
	t.Size = UDim2.fromOffset(70, 26)
	t.Position = UDim2.fromOffset(x, 180)
	t.PlaceholderText = placeholder
	t.ClearTextOnFocus = false
	t.BackgroundColor3 = OREO_DARK
	t.TextColor3 = OREO_WHITE
	t.Font = Enum.Font.Gotham
	t.TextSize = 14
	t.BorderSizePixel = 0
	t.Text = tostring(placeholder == "R" and 255 or placeholder == "G" and 0 or 0) -- default to red
	return t
end

local rBox = inputBox("R", 20)
local gBox = inputBox("G", 115)
local bBox = inputBox("B", 210)

local colorLabel = Instance.new("TextLabel", main)
colorLabel.Size = UDim2.fromOffset(260, 18)
colorLabel.Position = UDim2.fromOffset(20, 215)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Target Color (RGB)"
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextSize = 13
colorLabel.TextColor3 = OREO_CREAM

local function updateColor()
	local r = tonumber(rBox.Text)
	local g = tonumber(gBox.Text)
	local b = tonumber(bBox.Text)
	if r and g and b then
		TARGET_COLOR = Color3.fromRGB(
			math.clamp(r,0,255),
			math.clamp(g,0,255),
			math.clamp(b,0,255)
		)
	end
end

rBox.FocusLost:Connect(updateColor)
gBox.FocusLost:Connect(updateColor)
bBox.FocusLost:Connect(updateColor)

--------------------------------------------------
-- INPUT (toggle GUI + aimbot)
--------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == GUI_KEY then
		gui.Enabled = not gui.Enabled
	end

	if input.KeyCode == AIMBOT_KEY then
		if HOLD_MODE then
			AIMBOT_ENABLED = true
		else
			AIMBOT_ENABLED = not AIMBOT_ENABLED
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if HOLD_MODE and input.KeyCode == AIMBOT_KEY then
		AIMBOT_ENABLED = false
	end
end)

--------------------------------------------------
-- TARGET FIND + AIM
--------------------------------------------------
local function getClosestTarget()
	local best, dist = nil, math.huge
	for _, p in ipairs(workspace:GetDescendants()) do
		if p:IsA("BasePart") and p.Color == TARGET_COLOR then
			local d = (camera.CFrame.Position - p.Position).Magnitude
			if d < dist and d < MAX_DISTANCE then
				dist = d
				best = p
			end
		end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	if AIMBOT_ENABLED then
		local t = getClosestTarget()
		if t then
			camera.CFrame = camera.CFrame:Lerp(
				CFrame.new(camera.CFrame.Position, t.Position),
				AIM_SMOOTHNESS
			)
		end
	end
end)

--------------------------------------------------
-- DRAGGABLE GUI
--------------------------------------------------
local dragging = false
local dragInput, dragStart, startPos

local function updatePosition(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updatePosition(input)
	end
end)