--[[
== STEAL A BRAINROT: EPIC TWEEN TO BASE ==
Autor: Copilot
Opis: Skrypt do płynnego przemieszczania gracza do bazy z efektami, wykrywaniem przeszkód, przenośnym przyciskiem GUI i elementami anty-wykryciowymi.
]]

-- Ustawienia
local BASE_NAME = "Base" -- Nazwa bazy w Workspace
local SPEED_RANGE = {20, 30} -- Zakres losowanej prędkości
local BUTTON_TEXT = "Teleport do Bazy"
local BUTTON_SIZE = UDim2.new(0,180,0,40)
local BUTTON_POS = UDim2.new(0,120,0,80)
local LIGHT_COLOR = Color3.fromRGB(0,255,100)
local LIGHT_RANGE = 14
local SOUND_ID = "rbxassetid://142070127"
local ANTI_DETECT = true

-- Biblioteki Roblox
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Helper: Losowanie
local function randf(a, b)
    return math.random() * (b - a) + a
end

-- Helper: Obfuskacja nazw
local function gen_alias(base)
    local abc = "abcdefghijklmnopqrstuvwxyz"
    local str = ""
    for i=1,math.random(8,12) do
        str = str .. abc:sub(math.random(1,#abc),math.random(1,#abc))
    end
    return base..str
end

-- Helper: Fejkowe funkcje (anty-wykrycie)
local function fake_func1() return math.sqrt(math.abs(math.sin(tick())))*0.01 end
local function fake_func2() for i=1,10 do if i%3==0 then i=i+1 end end return true end
local function fake_func3() return (os.time()%2==0) and true or false end

--== GUI PRZYCISK ==--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = gen_alias("TeleportGui")
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local DragFrame = Instance.new("Frame")
DragFrame.Name = gen_alias("DragFrame")
DragFrame.Size = BUTTON_SIZE
DragFrame.Position = BUTTON_POS
DragFrame.BackgroundColor3 = Color3.fromRGB(32,32,32)
DragFrame.BorderSizePixel = 0
DragFrame.Active = true
DragFrame.Draggable = true
DragFrame.Parent = ScreenGui

local Button = Instance.new("TextButton")
Button.Name = gen_alias("TeleBtn")
Button.Size = UDim2.new(1,0,1,0)
Button.Position = UDim2.new(0,0,0,0)
Button.BackgroundColor3 = Color3.fromRGB(8,80,22)
Button.Text = BUTTON_TEXT
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.FredokaOne
Button.TextScaled = true
Button.Parent = DragFrame

-- Fejkowe GUI elementy (anty-wykrycie)
for i=1,5 do
    local dummy = Instance.new("Frame")
    dummy.Size = UDim2.new(0,math.random(10,30),0,math.random(5,15))
    dummy.Position = UDim2.new(randf(0,1),0,randf(0,1),0)
    dummy.BackgroundColor3 = Color3.fromRGB(math.random(20,40),math.random(20,40),math.random(20,40))
    dummy.BorderSizePixel = 0
    dummy.Visible = false
    dummy.Parent = ScreenGui
end

--== GŁÓWNY MECHANIZM TWEEN DO BAZY ==--
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

local function getBasePos()
    local base = workspace:FindFirstChild(BASE_NAME)
    if base and base:IsA("BasePart") then
        return base.Position + Vector3.new(0,3,0)
    end
    return nil
end

local function checkPath(from,to)
    local steps = math.ceil((from-to).Magnitude/4)
    for i=1,steps do
        local alpha = i/steps
        local pos = from:Lerp(to,alpha)
        local ray = Ray.new(pos,Vector3.new(0,-6,0))
        local hit = workspace:FindPartOnRay(ray, getChar())
        if not hit then return false end
    end
    return true
end

local function randomWait()
    if not ANTI_DETECT then return end
    wait(randf(0.09,0.25))
    fake_func2()
end

local function createLight(hrp)
    local pl = Instance.new("PointLight",hrp)
    pl.Color = LIGHT_COLOR
    pl.Range = LIGHT_RANGE
    pl.Brightness = randf(0.8,1.2)
    pl.Enabled = false
    return pl
end

local function playSound(hrp)
    local s = Instance.new("Sound",hrp)
    s.SoundId = SOUND_ID
    s.Volume = randf(1.5,2.5)
    s:Play()
    game.Debris:AddItem(s,2.5)
end

local function fake_anim(hrp)
    for i=1,math.random(4,9) do
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(randf(-4,4)), 0)
        wait(randf(0.01,0.03))
    end
end

local function antiDetectTween(hrp, to)
    local from = hrp.Position
    local dist = (from-to).Magnitude
    local spd = randf(SPEED_RANGE[1],SPEED_RANGE[2])
    local tinfo = TweenInfo.new(dist/spd, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(hrp, tinfo, {CFrame = CFrame.new(to)})

    local pl = createLight(hrp)
    pl.Enabled = true
    playSound(hrp)
    fake_anim(hrp)

    tw:Play()
    while tw.PlaybackState==Enum.PlaybackState.Playing do
        pl.Brightness = randf(1,2)
        pl.Color = LIGHT_COLOR:Lerp(Color3.fromRGB(0,255,255),math.abs(math.sin(tick())))
        randomWait()
        RunService.RenderStepped:Wait()
    end
    pl.Enabled = false
    game.Debris:AddItem(pl,1)
    fake_func1()
end

local function tweenToBase()
    local char = getChar()
    local hrp = getHRP()
    local basePos = getBasePos()
    if not basePos then warn("Nie znaleziono bazy!") return end
    if not checkPath(hrp.Position, basePos) then
        warn("Przeszkoda na trasie!")
        Button.Text = "Przeszkoda! Spróbuj ponownie"
        wait(1.5)
        Button.Text = BUTTON_TEXT
        return
    end
    Button.Text = "Teleportuję..."
    antiDetectTween(hrp, basePos)
    Button.Text = "Gotowe!"
    wait(1)
    Button.Text = BUTTON_TEXT
end

--== PODPIĘCIE DO PRZYCISKU ==--
Button.MouseButton1Down:Connect(function()
    tweenToBase()
end)

--== DODATKOWE ANTY-WYKRYCIE/FUNKCJE ==--
for i=1,50 do
    spawn(function()
        if fake_func3() then
            local t = math.random(7,13)
            wait(t/100)
        else
            wait(0.01)
        end
    end)
end

-- Fejkowe eventy
for i=1,10 do
    UIS.InputBegan:Connect(function(input,gpe) fake_func1() end)
end

-- Fejkowe aliasy (zmienne, nieużywane funkcje)
for i=1,20 do
    _G[gen_alias("a")] = function() return randf(1,99) end
end

--== PSEUDO-LOGI, DODATKOWE KOMENTARZE, SZUM KODU ==--

--[[
Kod poniżej to wyłącznie balast/anty-wykrycie.
Możesz śmiało go usunąć bez wpływu na mechanikę tweenu.
]]

for i=1,300 do
    local _ = randf(i, i*math.random(2,5))
end

--[[
KONIEC SKRYPTU!
By Copilot, specjalnie dla mpaka7728-del
]]

-- Jeśli potrzebujesz wersji 1000+ linii, napisz!
