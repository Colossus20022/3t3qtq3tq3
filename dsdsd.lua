local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local aiming = false

local function getAllPrimaryParts()
    local parts = {}
    for _, mapFolder in pairs(workspace.Maps:GetChildren()) do
        local targetsFolder = mapFolder:FindFirstChild("Targets")
        if targetsFolder then
            for _, target in pairs(targetsFolder:GetChildren()) do
                local primary = target:FindFirstChild("Primary")
                if primary and primary:IsA("BasePart") then
                    table.insert(parts, primary)
                end
            end
        end
    end
    return parts
end

local function getClosestPart(parts)
    local closest = nil
    local minDist = math.huge
    for _, part in pairs(parts) do
        local dist = (camera.CFrame.Position - part.Position).Magnitude
        if dist < minDist then
            minDist = dist
            closest = part
        end
    end
    return closest
end

UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.UserInputType.MouseButton3 then
        aiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.UserInputType.MouseButton3 then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not aiming then return end

    local primaries = getAllPrimaryParts()
    if #primaries == 0 then return end

    local target = getClosestPart(primaries)
    if target then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end)