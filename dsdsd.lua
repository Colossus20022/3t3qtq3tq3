local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local WorkspaceService = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local SilentAimEnabled = true
local HeadChance = 10
local FOVRadius = 60
local NonHeadParts = {"Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
local InSilentAim = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Color = Color3.fromRGB(240, 60, 60)
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

local TargetDot = Drawing.new("Circle")
TargetDot.Thickness = 1
TargetDot.NumSides = 16
TargetDot.Filled = true
TargetDot.Radius = 4
TargetDot.Color = Color3.fromRGB(240, 60, 60)
TargetDot.Visible = false

local function IsAlive(Character)
    if not Character or not Character:IsDescendantOf(WorkspaceService) then
        return false
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then
        return false
    end
    if Humanoid:GetAttribute("Dead") then
        return false
    end
    if Character:GetAttribute("Safe") then
        return false
    end
    return true
end

local function GetTargetPart(Character)
    if math.random(1, 100) <= HeadChance then
        local Head = Character:FindFirstChild("Head")
        if Head then
            return Head
        end
    end
    local Shuffled = table.clone(NonHeadParts)
    for I = #Shuffled, 2, -1 do
        local J = math.random(1, I)
        Shuffled[I], Shuffled[J] = Shuffled[J], Shuffled[I]
    end
    for I = 1, #Shuffled do
        local Part = Character:FindFirstChild(Shuffled[I])
        if Part then
            return Part
        end
    end
    return Character:FindFirstChild("Head")
end

local VisibilityParams = RaycastParams.new()
VisibilityParams.FilterType = Enum.RaycastFilterType.Exclude
VisibilityParams.CollisionGroup = "WeaponDetection"

local function IsVisible(TargetPart, TargetCharacter)
    local MyCharacter = LocalPlayer.Character
    if not MyCharacter then
        return false
    end
    local Root = MyCharacter:FindFirstChild("HumanoidRootPart") or MyCharacter:FindFirstChild("Torso")
    if not Root then
        return false
    end
    local Origin = Root.Position
    local Direction = TargetPart.Position - Origin
    VisibilityParams.FilterDescendantsInstances = {MyCharacter}
    local Result = WorkspaceService:Raycast(Origin, Direction, VisibilityParams)
    if not Result then
        return true
    end
    return Result.Instance:IsDescendantOf(TargetCharacter)
end

local function GetNearestTarget()
    local Camera = WorkspaceService.CurrentCamera
    if not Camera then
        return nil, nil
    end
    local MouseLocation = UserInputService:GetMouseLocation()
    local BestDistance = math.huge
    local BestPart = nil

    local CharactersFolder = WorkspaceService:FindFirstChild("Characters")
    if not CharactersFolder then return nil, nil end

    local AllCharacters = CharactersFolder:GetChildren()
    for I = 1, #AllCharacters do
        local Character = AllCharacters[I]
        if Character ~= LocalPlayer.Character and IsAlive(Character) then
            local Head = Character:FindFirstChild("Head")
            if Head then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                if OnScreen then
                    local ScreenDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MouseLocation).Magnitude
                    if ScreenDist < FOVRadius and ScreenDist < BestDistance then
                        if IsVisible(Head, Character) then
                            BestDistance = ScreenDist
                            BestPart = GetTargetPart(Character)
                        end
                    end
                end
            end
        end
    end

    return BestPart
end

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local Method = getnamecallmethod()

    if SilentAimEnabled and not InSilentAim and Method == "Raycast" and Self == WorkspaceService then
        local Origin, Direction, RayParams = ...
        if typeof(Origin) == "Vector3" and typeof(Direction) == "Vector3" and Direction.Magnitude > 10 then
            local MyCharacter = LocalPlayer.Character
            if MyCharacter then
                local Root = MyCharacter:FindFirstChild("HumanoidRootPart") or MyCharacter:FindFirstChild("Torso")
                if Root and (Origin - Root.Position).Magnitude < 15 then
                    InSilentAim = true
                    local TargetPart = GetNearestTarget()
                    InSilentAim = false
                    if TargetPart then
                        local NewDirection = (TargetPart.Position - Origin).Unit * Direction.Magnitude
                        setnamecallmethod(Method)
                        return OldNamecall(Self, Origin, NewDirection, RayParams)
                    end
                end
            end
        end
    end

    setnamecallmethod(Method)
    return OldNamecall(Self, ...)
end))

UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if Input.KeyCode == Enum.UserInputType.MouseButton3 then
        SilentAimEnabled = not SilentAimEnabled
    end
end)

RunService.RenderStepped:Connect(function()
    local Camera = WorkspaceService.CurrentCamera
    if not Camera then
        FOVCircle.Visible = false
        TargetDot.Visible = false
        return
    end
    local MousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = MousePos
    FOVCircle.Radius = FOVRadius
    FOVCircle.Visible = SilentAimEnabled
    if not SilentAimEnabled then
        TargetDot.Visible = false
        return
    end
    local Part = GetNearestTarget()
    if Part then
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
        if OnScreen then
            TargetDot.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
            TargetDot.Visible = true
            return
        end
    end
    TargetDot.Visible = false
end)