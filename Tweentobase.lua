-- Exploit GUI Tween do Bazy (do loadstring, działa w grze Roblox po stronie executora)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local BASE_NAME = "Base"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,200,0,50)
frame.Position = UDim2.new(0,100,0,100)
frame.BackgroundColor3 = Color3.fromRGB(20,70,30)
frame.Active = true

-- Dragging
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local button = Instance.new("TextButton")
button.Parent = frame
button.Size = UDim2.new(1,0,1,0)
button.Text = "TWEEN DO BAZY"
button.Font = Enum.Font.FredokaOne
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0,255,0) -- Zielony kolor przycisku
button.TextColor3 = Color3.new(1,1,1)

local function getBasePos()
    local base = workspace:FindFirstChild(BASE_NAME)
    if base and base:IsA("BasePart") then
        return base.Position + Vector3.new(0,3,0)
    end
    return nil
end
local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end
local function tweenToBase()
    local hrp = getHRP()
    local target = getBasePos()
    if not hrp or not target then
        button.Text = "Brak bazy!"
        wait(1)
        button.Text = "TWEEN DO BAZY"
        return
    end
    local dist = (hrp.Position-target).Magnitude
    local time = math.clamp(dist/20, 0.8, 6)
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Quad), {CFrame = CFrame.new(target)})
    button.Text = "Tweenuję..."
    tween:Play()
    tween.Completed:Wait()
    button.Text = "TWEEN DO BAZY"
end

button.MouseButton1Click:Connect(tweenToBase)
