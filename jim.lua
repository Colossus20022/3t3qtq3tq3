--// Cache
local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = 
    select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

--// Preventing Multiple Processes
pcall(function()
    getgenv().Aimbot.Functions:Exit()
end)

--// Environment
getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Variables
local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}
local PlayerCache = {}
local LastUpdate = 0
local UpdateInterval = 0.1 -- Atualiza cache a cada 0.1s para melhor FPS

--// Script Settings
Environment.Settings = {
    Enabled = true,
    TeamCheck = false,
    AliveCheck = true,
    WallCheck = false,
    Sensitivity = 0,
    ThirdPerson = false,
    ThirdPersonSensitivity = 3,
    TriggerKey = "MouseButton2",
    Toggle = false,
    LockPart = "Head",
    IgnoreTeammates = true,
    PredictMovement = false,
    PredictionAmount = 0.1,
    SmoothAim = true
}

Environment.FOVSettings = {
    Enabled = true,
    Visible = true,
    Amount = 90,
    Color = Color3.fromRGB(255, 255, 255),
    LockedColor = Color3.fromRGB(255, 70, 70),
    Transparency = 0.5,
    Sides = 60,
    Thickness = 1,
    Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")

--// UI Library
local MenuVisible = false
local MenuGui = nil

local function CreateMenu()
    -- Criar ScreenGui
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "AimbotMenu"
    MenuGui.ResetOnSpawn = false
    MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        MenuGui.Parent = game:GetService("CoreGui")
    end)
    
    if not MenuGui.Parent then
        MenuGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Frame Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MenuGui
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "рџЋЇ Aimbot Configuration"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseButton.Text = "вњ•"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        MenuVisible = false
        MainFrame.Visible = false
    end)
    
    -- ScrollFrame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    ScrollFrame.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ScrollFrame
    
    -- FunГ§ГЈo para criar seГ§ГЈo
    local function CreateSection(name)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, 0, 0, 30)
        Section.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        Section.BorderSizePixel = 0
        Section.Parent = ScrollFrame
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = Section
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, -10, 1, 0)
        SectionLabel.Position = UDim2.new(0, 10, 0, 0)
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Text = "в–ё " .. name
        SectionLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        SectionLabel.TextSize = 14
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.Parent = Section
        
        return Section
    end
    
    -- FunГ§ГЈo para criar toggle
    local function CreateToggle(name, default, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(1, 0, 0, 35)
        Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        Toggle.BorderSizePixel = 0
        Toggle.Parent = ScrollFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = Toggle
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Toggle
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 40, 0, 20)
        Button.Position = UDim2.new(1, -50, 0.5, -10)
        Button.BackgroundColor3 = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
        Button.Text = default and "ON" or "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 11
        Button.Font = Enum.Font.GothamBold
        Button.Parent = Toggle
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button
        
        local value = default
        Button.MouseButton1Click:Connect(function()
            value = not value
            Button.BackgroundColor3 = value and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
            Button.Text = value and "ON" or "OFF"
            callback(value)
        end)
        
        return Toggle
    end
    
    -- FunГ§ГЈo para criar slider
    local function CreateSlider(name, min, max, default, callback)
        local Slider = Instance.new("Frame")
        Slider.Size = UDim2.new(1, 0, 0, 50)
        Slider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        Slider.BorderSizePixel = 0
        Slider.Parent = ScrollFrame
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 6)
        SliderCorner.Parent = Slider
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = name .. ": " .. tostring(default)
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Slider
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Size = UDim2.new(1, -20, 0, 6)
        SliderBar.Position = UDim2.new(0, 10, 0, 32)
        SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        SliderBar.BorderSizePixel = 0
        SliderBar.Parent = Slider
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 3)
        BarCorner.Parent = SliderBar
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 3)
        FillCorner.Parent = Fill
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.Parent = SliderBar
        
        local dragging = false
        
        Button.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local relativePos = mousePos.X - SliderBar.AbsolutePosition.X
                local percentage = mathclamp(relativePos / SliderBar.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percentage
                value = math.floor(value * 100) / 100
                
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                Label.Text = name .. ": " .. tostring(value)
                callback(value)
            end
        end)
        
        return Slider
    end
    
    -- Criar UI
    CreateSection("Main Settings")
    CreateToggle("Enabled", Environment.Settings.Enabled, function(v)
        Environment.Settings.Enabled = v
    end)
    
    CreateToggle("Team Check", Environment.Settings.TeamCheck, function(v)
        Environment.Settings.TeamCheck = v
    end)
    
    CreateToggle("Alive Check", Environment.Settings.AliveCheck, function(v)
        Environment.Settings.AliveCheck = v
    end)
    
    CreateToggle("Wall Check", Environment.Settings.WallCheck, function(v)
        Environment.Settings.WallCheck = v
    end)
    
    CreateToggle("Toggle Mode", Environment.Settings.Toggle, function(v)
        Environment.Settings.Toggle = v
    end)
    
    CreateSection("Aim Settings")
    CreateSlider("Sensitivity", 0, 2, Environment.Settings.Sensitivity, function(v)
        Environment.Settings.Sensitivity = v
    end)
    
    CreateToggle("Third Person", Environment.Settings.ThirdPerson, function(v)
        Environment.Settings.ThirdPerson = v
    end)
    
    CreateSlider("Third Person Sens", 0.1, 5, Environment.Settings.ThirdPersonSensitivity, function(v)
        Environment.Settings.ThirdPersonSensitivity = v
    end)
    
    CreateToggle("Predict Movement", Environment.Settings.PredictMovement, function(v)
        Environment.Settings.PredictMovement = v
    end)
    
    CreateSection("FOV Settings")
    CreateToggle("FOV Enabled", Environment.FOVSettings.Enabled, function(v)
        Environment.FOVSettings.Enabled = v
    end)
    
    CreateToggle("FOV Visible", Environment.FOVSettings.Visible, function(v)
        Environment.FOVSettings.Visible = v
    end)
    
    CreateSlider("FOV Size", 20, 500, Environment.FOVSettings.Amount, function(v)
        Environment.FOVSettings.Amount = v
    end)
    
    CreateSlider("FOV Transparency", 0, 1, Environment.FOVSettings.Transparency, function(v)
        Environment.FOVSettings.Transparency = v
    end)
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    MainFrame.Visible = false
end

--// Functions
local function CancelLock()
    Environment.Locked = nil
    if Animation then Animation:Cancel() end
    Environment.FOVCircle.Color = Environment.FOVSettings.Color
end

local function UpdatePlayerCache()
    local currentTime = tick()
    if currentTime - LastUpdate < UpdateInterval then return end
    LastUpdate = currentTime
    
    PlayerCache = {}
    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer and v.Character then
            PlayerCache[#PlayerCache + 1] = v
        end
    end
end

local function GetClosestPlayer()
    if not Environment.Locked then
        RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)
        UpdatePlayerCache()

        for _, v in next, PlayerCache do
            local char = v.Character
            local lockPart = char and char:FindFirstChild(Environment.Settings.LockPart)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if lockPart and humanoid then
                if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                if Environment.Settings.AliveCheck and humanoid.Health <= 0 then continue end
                if Environment.Settings.WallCheck then
                    local parts = Camera:GetPartsObscuringTarget({lockPart.Position}, char:GetDescendants())
                    if #parts > 0 then continue end
                end

                local targetPos = lockPart.Position
                if Environment.Settings.PredictMovement and char:FindFirstChild("HumanoidRootPart") then
                    local velocity = char.HumanoidRootPart.AssemblyVelocity
                    targetPos = targetPos + (velocity * Environment.Settings.PredictionAmount)
                end

                local Vector, OnScreen = Camera:WorldToViewportPoint(targetPos)
                local MousePos = UserInputService:GetMouseLocation()
                local Distance = (Vector2(MousePos.X, MousePos.Y) - Vector2(Vector.X, Vector.Y)).Magnitude

                if Distance < RequiredDistance and OnScreen then
                    RequiredDistance = Distance
                    Environment.Locked = v
                end
            end
        end
    else
        local char = Environment.Locked.Character
        if not char or not char:FindFirstChild(Environment.Settings.LockPart) then
            CancelLock()
            return
        end
        
        local lockPart = char[Environment.Settings.LockPart]
        local Vector = Camera:WorldToViewportPoint(lockPart.Position)
        local MousePos = UserInputService:GetMouseLocation()
        local Distance = (Vector2(MousePos.X, MousePos.Y) - Vector2(Vector.X, Vector.Y)).Magnitude
        
        if Distance > RequiredDistance then
            CancelLock()
        end
    end
end

--// Typing Check
ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

--// Main Loop
local function Load()
    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
            Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
            Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
            Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
            Environment.FOVCircle.Color = Environment.FOVSettings.Color
            Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
            Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
            Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and Environment.Settings.Enabled then
            GetClosestPlayer()

            if Environment.Locked then
                local char = Environment.Locked.Character
                if not char or not char:FindFirstChild(Environment.Settings.LockPart) then
                    CancelLock()
                    return
                end
                
                local lockPart = char[Environment.Settings.LockPart]
                local targetPos = lockPart.Position
                
                if Environment.Settings.PredictMovement and char:FindFirstChild("HumanoidRootPart") then
                    local velocity = char.HumanoidRootPart.AssemblyVelocity
                    targetPos = targetPos + (velocity * Environment.Settings.PredictionAmount)
                end
                
                if Environment.Settings.ThirdPerson then
                    local sensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)
                    local Vector = Camera:WorldToViewportPoint(targetPos)
                    local MousePos = UserInputService:GetMouseLocation()
                    mousemoverel(
                        (Vector.X - MousePos.X) * sensitivity,
                        (Vector.Y - MousePos.Y) * sensitivity
                    )
                else
                    if Environment.Settings.Sensitivity > 0 then
                        Animation = TweenService:Create(
                            Camera,
                            TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                            {CFrame = CFrame.new(Camera.CFrame.Position, targetPos)}
                        )
                        Animation:Play()
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    end
                end

                Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
            end
        end
    end)

    ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        if Typing then return end
        
        -- Toggle menu com Insert
        if Input.KeyCode == Enum.KeyCode.Insert then
            MenuVisible = not MenuVisible
            if MenuGui and MenuGui:FindFirstChild("MainFrame") then
                MenuGui.MainFrame.Visible = MenuVisible
            end
            return
        end
        
        pcall(function()
            if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                if Environment.Settings.Toggle then
                    Running = not Running
                    if not Running then CancelLock() end
                else
                    Running = true
                end
            end
        end)

        pcall(function()
            if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                if Environment.Settings.Toggle then
                    Running = not Running
                    if not Running then CancelLock() end
                else
                    Running = true
                end
            end
        end)
    end)

    ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
        if Typing or Environment.Settings.Toggle then return end
        
        pcall(function()
            if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                Running = false
                CancelLock()
            end
        end)

        pcall(function()
            if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                Running = false
                CancelLock()
            end
        end)
    end)
end

--// Environment Functions
Environment.Functions = {}

function Environment.Functions:Exit()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    if Environment.FOVCircle.Remove then
        Environment.FOVCircle:Remove()
    end
    
    if MenuGui then
        MenuGui:Destroy()
    end

    getgenv().Aimbot.Functions = nil
    getgenv().Aimbot = nil
    
    Load = nil
    GetClosestPlayer = nil
    CancelLock = nil
end

function Environment.Functions:Restart()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end
    Load()
end

function Environment.Functions:ToggleMenu()
    MenuVisible = not MenuVisible
    if MenuGui and MenuGui:FindFirstChild("MainFrame") then
        MenuGui.MainFrame.Visible = MenuVisible
    end
end

--// Initialize
CreateMenu()
Load()

print("вњ… Aimbot carregado! Pressione INSERT para abrir o menu.")