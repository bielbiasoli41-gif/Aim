-- Salva na CoreGui (sobrevive ao respawn)
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local player = players.LocalPlayer

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotGhostUI"
screenGui.Parent = coreGui

-- Frame principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 200)
main.Position = UDim2.new(0.5, -150, 0.5, -100)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

-- Flocos decorativos
for i = 1, 30 do
    local flk = Instance.new("TextLabel")
    flk.Size = UDim2.new(0, 6, 0, 6)
    flk.BackgroundTransparency = 1
    flk.Text = "•"
    flk.TextColor3 = Color3.new(1, 1, 1)
    flk.TextScaled = true
    flk.Position = UDim2.new(math.random(), 0, math.random(), 0)
    flk.Parent = main
    spawn(function()
        while wait(math.random(2, 5)) do
            flk.Position = UDim2.new(math.random(), 0, math.random(), 0)
        end
    end)
end

-- Título
local tit = Instance.new("TextLabel")
tit.Size = UDim2.new(1, 0, 0.3, 0)
tit.BackgroundTransparency = 1
tit.Text = "Aimbot Ghost"
tit.TextColor3 = Color3.new(1, 1, 1)
tit.Font = Enum.Font.SourceSansBold
tit.TextScaled = true
tit.Parent = main

-- Botão Aimbot
local btnAim = Instance.new("TextButton")
btnAim.Size = UDim2.new(0.8, 0, 0.2, 0)
btnAim.Position = UDim2.new(0.1, 0, 0.4, 0)
btnAim.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
btnAim.Text = "Aimbot Off"
btnAim.TextColor3 = Color3.new(1, 1, 1)
btnAim.Font = Enum.Font.SourceSans
btnAim.TextScaled = true
btnAim.Parent = main

-- Botão Team Check
local btnTeam = Instance.new("TextButton")
btnTeam.Size = UDim2.new(0.8, 0, 0.2, 0)
btnTeam.Position = UDim2.new(0.1, 0, 0.65, 0)
btnTeam.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
btnTeam.Text = "Team Check Off"
btnTeam.TextColor3 = Color3.new(1, 1, 1)
btnTeam.Font = Enum.Font.SourceSans
btnTeam.TextScaled = true
btnTeam.Parent = main

-- Variáveis
local ativado = false
local teamChk = false
local lockPlr = nil
local lockChar = nil
local aura = nil
local travou = false

-- Atualizar GUI
local function attGui()
    btnAim.Text = ativado and "Aimbot ON" or "Aimbot Off"
    btnAim.BackgroundColor3 = ativado and Color3.new(0, 0.5, 0) or Color3.new(0.2, 0.2, 0.2)
    btnTeam.Text = teamChk and "Team Check ON" or "Team Check Off"
    btnTeam.BackgroundColor3 = teamChk and Color3.new(0, 0.5, 0) or Color3.new(0.2, 0.2, 0.2)
end

-- Criar aura visual
local function criarAura(char)
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local bx = Instance.new("BoxHandleAdornment")
    bx.Adornee = hrp
    bx.Size = Vector3.new(3, 5, 3)
    bx.Color3 = Color3.new(1, 0, 0)
    bx.Transparency = 0.4
    bx.AlwaysOnTop = true
    bx.ZIndex = 5
    bx.Parent = hrp
    
    return bx
end

-- Apagar aura
local function apagarAura()
    if aura then
        aura:Destroy()
        aura = nil
    end
end

-- Monitorar jogador travado
local function watch(plr)
    if not plr or not plr.Character then return end
    
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    
    local function limpa()
        apagarAura()
        lockPlr = nil
        lockChar = nil
        travou = false
    end
    
    if hum then
        hum.Died:Connect(limpa)
    end
    
    plr.CharacterRemoving:Connect(limpa)
end

-- Escolher alvo mais próximo
local function escolheAlvo()
    local prox = nil
    local max = math.huge
    
    for _, v in pairs(players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            -- Verifica team check
            if teamChk and v.Team == player.Team then
                continue
            end
            
            local d = (v.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).magnitude
            if d < max then
                max = d
                prox = v
            end
        end
    end
    
    if prox then
        lockPlr = prox
        lockChar = prox.Character
        travou = true
        watch(lockPlr)
        aura = criarAura(lockChar)
    end
end

-- Loop do aimbot
local function aimLoop()
    while ativado do
        if lockChar and lockChar:FindFirstChild("Head") then
            local cam = workspace.CurrentCamera
            local targetPos = lockChar.Head.Position
            local camPos = cam.CFrame.Position
            local dir = (targetPos - camPos).Unit
            
            cam.CFrame = CFrame.new(camPos, camPos + dir * 100)
        else
            -- Se perdeu o alvo, tenta encontrar outro
            if travou then
                apagarAura()
                lockPlr = nil
                lockChar = nil
                travou = false
            end
            escolheAlvo()
        end
        
        runService.RenderStepped:Wait()
    end
end

-- Toggle aimbot
local function toggleAim()
    ativado = not ativado
    attGui()
    
    if ativado then
        if not travou then
            escolheAlvo()
        end
        coroutine.wrap(aimLoop)()
    else
        apagarAura()
        lockPlr = nil
        lockChar = nil
        travou = false
    end
end

-- Toggle team check
local function toggleTeam()
    teamChk = not teamChk
    attGui()
end

-- Bind tecla X
uis.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.X then
        toggleAim()
    end
end)

-- Conectar botões
btnAim.MouseButton1Click:Connect(toggleAim)
btnTeam.MouseButton1Click:Connect(toggleTeam)
