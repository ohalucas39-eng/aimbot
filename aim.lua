-- Roblox Aimbot Script (Eğitim Amaçlı)
-- UYARI: Bu scripti kullanmak Roblox'un hizmet şartlarını ihlal eder!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Aimbot ayarları
local Aimbot = {
    Enabled = false,
    FOV = 90,
    LockedTarget = nil,
    Smoothness = 0.3,
    AimPart = "Head"
}

-- BASİT VE GARANTİLİ MENÜ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAimbotGUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- FOV çemberi
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Aimbot.FOV * 2, 0, Aimbot.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Aimbot.FOV, 0.5, -Aimbot.FOV)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.8
FOVCircle.BorderSizePixel = 2
FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FOVCircle
FOVCircle.Parent = ScreenGui

-- MENÜ FRAME
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 120)
MenuFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MenuFrame.BorderSizePixel = 2
MenuFrame.BorderColor3 = Color3.fromRGB(100, 100, 200)
MenuFrame.Parent = ScreenGui

-- BAŞLIK
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.Text = "🎯 AIMBOT MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MenuFrame

-- DURUM
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "🔴 KAPALI"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MenuFrame

-- HEDEF
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.9, 0, 0, 20)
TargetLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "🎯 HEDEF: YOK"
TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TargetLabel.TextSize = 11
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.Parent = MenuFrame

-- BİLGİ
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 30)
InfoLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "F: Aç/Kapa\nBaşlıktan sürükle"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MenuFrame

-- FOV çemberini güncelle
local function UpdateFOVCircle()
    FOVCircle.Size = UDim2.new(0, Aimbot.FOV * 2, 0, Aimbot.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Aimbot.FOV, 0.5, -Aimbot.FOV)
end

-- Yeni hedef bul
local function FindNewTarget()
    local closestTarget = nil
    local closestDistance = Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local aimPart = character:FindFirstChild(Aimbot.AimPart)
            
            if humanoid and humanoid.Health > 0 and aimPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local point = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (point - center).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestTarget = character
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- Kilitli hedefi kontrol et
local function CheckLockedTarget()
    if Aimbot.LockedTarget and Aimbot.LockedTarget.Parent then
        local humanoid = Aimbot.LockedTarget:FindFirstChild("Humanoid")
        local aimPart = Aimbot.LockedTarget:FindFirstChild(Aimbot.AimPart)
        
        if humanoid and humanoid.Health > 0 and aimPart then
            return true
        end
    end
    return false
end

-- Aimbot'u aç/kapa
local function ToggleAimbot()
    Aimbot.Enabled = not Aimbot.Enabled
    FOVCircle.Visible = Aimbot.Enabled
    
    if Aimbot.Enabled then
        StatusLabel.Text = "🟢 AÇIK"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        print("Aimbot AKTİF - Hedef aranıyor...")
    else
        StatusLabel.Text = "🔴 KAPALI"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        Aimbot.LockedTarget = nil
        TargetLabel.Text = "🎯 HEDEF: YOK"
        print("Aimbot KAPALI")
    end
end

-- F tuşu kontrolü
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        ToggleAimbot()
    end
end)

-- SÜREKLİ KİLİTLİ AİMBOT
local function PermanentLockAimbot()
    if not Aimbot.Enabled then 
        Aimbot.LockedTarget = nil
        return 
    end
    
    -- Eğer kilitli hedef varsa ve geçerliyse, ona kitli kal
    if CheckLockedTarget() then
        local aimPart = Aimbot.LockedTarget:FindFirstChild(Aimbot.AimPart)
        if aimPart then
            local currentCFrame = Camera.CFrame
            local targetPosition = aimPart.Position
            local lookVector = (targetPosition - currentCFrame.Position).Unit
            local newCFrame = CFrame.new(currentCFrame.Position, currentCFrame.Position + lookVector)
            Camera.CFrame = currentCFrame:Lerp(newCFrame, Aimbot.Smoothness)
            TargetLabel.Text = "🎯 HEDEF: " .. Aimbot.LockedTarget.Name
            return
        end
    end
    
    -- Yeni hedef ara
    local newTarget = FindNewTarget()
    if newTarget then
        Aimbot.LockedTarget = newTarget
        TargetLabel.Text = "🎯 HEDEF: " .. newTarget.Name
        print("Hedef kilitlendi: " .. newTarget.Name .. " - F'ye basana kadar takip edilecek")
    else
        TargetLabel.Text = "🎯 HEDEF: YOK"
    end
end

-- MENÜ SÜRÜKLEME
local dragging = false
local dragStart = nil
local startPos = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MenuFrame.Position
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ANA DÖNGÜ
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    PermanentLockAimbot()
end)

-- HEDEF KONTROL DÖNGÜSÜ
spawn(function()
    while true do
        wait(0.5)
        if Aimbot.LockedTarget and Aimbot.Enabled then
            if not CheckLockedTarget() then
                print("Hedef kayboldu, yeni hedef aranıyor...")
                Aimbot.LockedTarget = nil
                TargetLabel.Text = "🎯 HEDEF: YOK"
            end
        end
    end
end)

print("🎯 SÜREKLİ KİLİTLİ AIMBOT YÜKLENDİ!")
print("🎯 F tuşu: Aç/Kapa")
print("🎯 Özellik: Hedef bir kere kilitlenir, F'ye basana kadar takip eder")
print("⚠️  UYARI: EĞİTİM AMAÇLIDIR!")