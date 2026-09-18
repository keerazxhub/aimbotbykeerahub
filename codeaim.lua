local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ ตั้งค่าเริ่มต้น (Configuration) ]] --
local Settings = {
    AimbotEnabled = false,
    TeamCheck = true,      -- true = ไม่ล็อกพวกเดียวกัน / false = ล็อกทุกคน
    FOV_Scale = 0.35,      -- ขนาด FOV แบบวงกลมเดี่ยว (35% ของจอ)
    Smoothness = 0.30,     -- ค่าเริ่มต้นความเนียน
    TargetPart = "Head"    -- ค่าเริ่มต้นล็อกที่หัว
}

local smoothnessLevels = {
    {val = 0.30, text = "Smooth: 0.30"},
    {val = 0.75, text = "Smooth: 0.75"}
}
local smoothnessIndex = 1

local isSwiping = false 
local currentFOV_Radius = 0 

-- ตรวจจับการแตะและปัดหน้าจอของผู้เล่นมือถือ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        isSwiping = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        isSwiping = false
    end
end)

-- [[ สร้าง UI หลัก ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAutoFOVGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- วงกลม FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FOVCircle

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.5
UIStroke.Parent = FOVCircle

-- ปุ่ม Toggle หลัก (Aim Assist)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 130, 0, 40)
ToggleButton.Position = UDim2.new(0.85, -25, 0.22, 0)
ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Aim Assist: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

-- ปุ่มซ่อน/โชว์เมนู (เฟือง)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 40, 0, 40)
MenuBtn.Position = UDim2.new(0.85, 65, 0.22, 0)
MenuBtn.AnchorPoint = Vector2.new(0.5, 0.5)
MenuBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Text = "⚙️"
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 20
MenuBtn.Parent = ScreenGui
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 8)

-- เมนูตั้งค่า (Settings Menu)
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 140, 0, 220)
MenuFrame.Position = UDim2.new(0.85, -5, 0.30, 0) 
MenuFrame.AnchorPoint = Vector2.new(0.5, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BackgroundTransparency = 0.2
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui
Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)

MenuBtn.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
end)

-- ฟังก์ชันสร้างปุ่มปรับ FOV แบบวงกลมเดี่ยว
local function CreateFOVUI(name, yPos, defaultValue, formatString, step, minVal, maxVal, settingKey)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.Position = UDim2.new(0, 0, 0, yPos)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.Text = string.format(formatString, defaultValue)
    Label.Parent = MenuFrame

    local BtnMinus = Instance.new("TextButton")
    BtnMinus.Size = UDim2.new(0, 30, 0, 22)
    BtnMinus.Position = UDim2.new(0.1, 0, 0, yPos + 18)
    BtnMinus.Text = "-"
    BtnMinus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    BtnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnMinus.Font = Enum.Font.GothamBold
    BtnMinus.Parent = MenuFrame
    Instance.new("UICorner", BtnMinus).CornerRadius = UDim.new(0, 4)

    local BtnPlus = Instance.new("TextButton")
    BtnPlus.Size = UDim2.new(0, 30, 0, 22)
    BtnPlus.Position = UDim2.new(0.9, -30, 0, yPos + 18)
    BtnPlus.Text = "+"
    BtnPlus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    BtnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnPlus.Font = Enum.Font.GothamBold
    BtnPlus.Parent = MenuFrame
    Instance.new("UICorner", BtnPlus).CornerRadius = UDim.new(0, 4)

    BtnMinus.MouseButton1Click:Connect(function()
        Settings[settingKey] = math.max(minVal, Settings[settingKey] - step)
        Label.Text = string.format(formatString, Settings[settingKey] * 100)
    end)

    BtnPlus.MouseButton1Click:Connect(function()
        Settings[settingKey] = math.min(maxVal, Settings[settingKey] + step)
        Label.Text = string.format(formatString, Settings[settingKey] * 100)
    end)
end

CreateFOVUI("FOV", 5, Settings.FOV_Scale * 100, "FOV: %d%%", 0.05, 0.1, 1.0, "FOV_Scale")

-- ปุ่มสลับ Smoothness (0.30 และ 0.75)
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(1, 0, 0, 18)
SmoothLabel.Position = UDim2.new(0, 0, 0, 55)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothLabel.Font = Enum.Font.GothamSemibold
SmoothLabel.TextSize = 12
SmoothLabel.Text = "Smoothness"
SmoothLabel.Parent = MenuFrame

local SmoothToggleButton = Instance.new("TextButton")
SmoothToggleButton.Size = UDim2.new(0, 110, 0, 25)
SmoothToggleButton.Position = UDim2.new(0.5, 0, 0, 78)
SmoothToggleButton.AnchorPoint = Vector2.new(0.5, 0)
SmoothToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SmoothToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothToggleButton.Text = "Smooth: 0.30"
SmoothToggleButton.Font = Enum.Font.GothamBold
SmoothToggleButton.TextSize = 12
SmoothToggleButton.Parent = MenuFrame
Instance.new("UICorner", SmoothToggleButton).CornerRadius = UDim.new(0, 4)

SmoothToggleButton.MouseButton1Click:Connect(function()
    smoothnessIndex = smoothnessIndex + 1
    if smoothnessIndex > #smoothnessLevels then
        smoothnessIndex = 1
    end
    local currentLevel = smoothnessLevels[smoothnessIndex]
    Settings.Smoothness = currentLevel.val
    SmoothToggleButton.Text = currentLevel.text
end)

-- ปุ่มสลับเป้าหมาย ล็อกหัว / ล็อกตัว
local PartLabel = Instance.new("TextLabel")
PartLabel.Size = UDim2.new(1, 0, 0, 18)
PartLabel.Position = UDim2.new(0, 0, 0, 105)
PartLabel.BackgroundTransparency = 1
PartLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PartLabel.Font = Enum.Font.GothamSemibold
PartLabel.TextSize = 12
PartLabel.Text = "Target Part"
PartLabel.Parent = MenuFrame

local PartToggleButton = Instance.new("TextButton")
PartToggleButton.Size = UDim2.new(0, 110, 0, 25)
PartToggleButton.Position = UDim2.new(0.5, 0, 0, 128)
PartToggleButton.AnchorPoint = Vector2.new(0.5, 0)
PartToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
PartToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PartToggleButton.Text = "Part: Head"
PartToggleButton.Font = Enum.Font.GothamBold
PartToggleButton.TextSize = 12
PartToggleButton.Parent = MenuFrame
Instance.new("UICorner", PartToggleButton).CornerRadius = UDim.new(0, 4)

PartToggleButton.MouseButton1Click:Connect(function()
    if Settings.TargetPart == "Head" then
        Settings.TargetPart = "HumanoidRootPart"
        PartToggleButton.Text = "Part: Body"
        PartToggleButton.BackgroundColor3 = Color3.fromRGB(170, 85, 0)
    else
        Settings.TargetPart = "Head"
        PartToggleButton.Text = "Part: Head"
        PartToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- ปุ่มสลับโหมดทีม (เช็คทีม หรือ ล็อกทุกคน)
local TeamCheckLabel = Instance.new("TextLabel")
TeamCheckLabel.Size = UDim2.new(1, 0, 0, 18)
TeamCheckLabel.Position = UDim2.new(0, 0, 0, 155)
TeamCheckLabel.BackgroundTransparency = 1
TeamCheckLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckLabel.Font = Enum.Font.GothamSemibold
TeamCheckLabel.TextSize = 12
TeamCheckLabel.Text = "Team Filter"
TeamCheckLabel.Parent = MenuFrame

local TeamToggleButton = Instance.new("TextButton")
TeamToggleButton.Size = UDim2.new(0, 110, 0, 25)
TeamToggleButton.Position = UDim2.new(0.5, 0, 0, 178)
TeamToggleButton.AnchorPoint = Vector2.new(0.5, 0)
TeamToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
TeamToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamToggleButton.Text = "Check Team: ON"
TeamToggleButton.Font = Enum.Font.GothamBold
TeamToggleButton.TextSize = 11
TeamToggleButton.Parent = MenuFrame
Instance.new("UICorner", TeamToggleButton).CornerRadius = UDim.new(0, 4)

TeamToggleButton.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    if Settings.TeamCheck then
        TeamToggleButton.Text = "Check Team: ON"
        TeamToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        TeamToggleButton.Text = "Lock Everyone"
        TeamToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then
        ToggleButton.Text = "Aim Assist: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        UIStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "Aim Assist: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        UIStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- [[ ฟังก์ชันตรวจสอบกำแพง ]] --
local function IsVisible(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera} 

    local direction = (targetPart.Position - Camera.CFrame.Position).Unit * 1000
    local result = Workspace:Raycast(Camera.CFrame.Position, direction, rayParams)

    if result and result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- [[ ระบบเช็คทีมอัตโนมัติ ]] --
local function IsTeamMate(player)
    if not Settings.TeamCheck then return false end
    if player == LocalPlayer then return true end

    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team == player.Team
    end

    if LocalPlayer.TeamColor and player.TeamColor then
        return LocalPlayer.TeamColor == player.TeamColor
    end

    return false
end

-- [[ ฟังก์ชันค้นหาเป้าหมาย ]] --
local function GetClosestTarget()
    local closestDistance = currentFOV_Radius
    local closestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.TargetPart) then
            
            if IsTeamMate(player) then
                continue
            end

            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPart = player.Character[Settings.TargetPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                if onScreen then
                    local targetVec2 = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (targetVec2 - screenCenter).Magnitude

                    if distance < closestDistance then
                        if IsVisible(targetPart) then
                            closestDistance = distance
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize
    currentFOV_Radius = math.min(viewport.X, viewport.Y) * Settings.FOV_Scale

    if Settings.AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local activeSmoothness = isSwiping and (Settings.Smoothness * 0.4) or Settings.Smoothness
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, activeSmoothness)
        end
    end
    
    if FOVCircle then
        FOVCircle.Size = UDim2.new(0, currentFOV_Radius * 2, 0, currentFOV_Radius * 2)
        FOVCircle.Position = UDim2.new(0, viewport.X / 2, 0, viewport.Y / 2)
    end
end)