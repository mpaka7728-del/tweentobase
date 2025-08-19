-- STEAL A BRAINROT: TWEEN DO BAZY
-- Działa na LocalScript (StarterGui lub StarterPlayerScripts)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local BASE_NAME = "Base" -- Zmień na swoją nazwę bazy

-- GUI Button
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,50)
frame.Position = UDim2.new(0,100,0,100)
frame.BackgroundColor3 = Color3.fromRGB(32,32,32)
frame.Active = true
frame.Parent = gui

local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local button = Instance.new("TextButton")
button.Size = UDim2.new(1,0,1,0)
button.Text = "TWEEN DO BAZY"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 26
button.BackgroundColor3 = Color3.fromRGB(60,160,60)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = frame

local function getBasePosition()
	local base = workspace:FindFirstChild(BASE_NAME)
	if base and base:IsA("BasePart") then
		return base.Position + Vector3.new(0,3,0)
	end
	return nil
end

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart")
end

local function tweenToBase()
	local hrp = getHRP()
	local target = getBasePosition()
	if not hrp or not target then
		button.Text = "Brak bazy/HRP!"
		wait(1)
		button.Text = "TWEEN DO BAZY"
		return
	end
	local dist = (hrp.Position-target).Magnitude
	local tweenInfo = TweenInfo.new(dist/24, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(target)})
	tween:Play()
	button.Text = "Teleportuję..."
	tween.Completed:Wait()
	button.Text = "TWEEN DO BAZY"
end

button.MouseButton1Click:Connect(tweenToBase)
