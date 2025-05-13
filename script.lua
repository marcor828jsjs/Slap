-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Referências do jogador
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Teleporte automático ao executar o script
if hrp then
    local originalPosition = hrp.Position
    hrp.Position = Vector3.new(-36.62, 432.12, 314.03)
    task.wait(0.1)
    hrp.Position = originalPosition
end

-- Configurações iniciais da câmera
local fixedPosition = Vector3.new(-43.227, 165.792, -73.785)
local lookDirection = Vector3.new(0.534, -0.459, 0.710).Unit
local function lookVectorToAngles(vec)
    local pitch = math.asin(-vec.Y)
    local yaw = math.atan2(vec.X, vec.Z)
    return Vector2.new(math.deg(pitch), math.deg(yaw))
end
local rotation = lookVectorToAngles(lookDirection)
local rotationSensitivity = 2
local moveSpeed = 10
local zoomSensitivity = 0.005
local maxZoomOffset = 50
local minZoomOffset = -10
local zoomOffset = 0

-- Variáveis de estado
local antipalmadaEnabled = false
local cameraEnabled = false
local monitoramentoEnabled = false
local infiniteJumpEnabled = true -- Ativado por padrão
local espEnabled = true -- Ativado por padrão
local espHighlights = {}

-- GUI principal
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "DeltaHUD"
gui.Parent = player:WaitForChild("PlayerGui")

-- Botão Emoji (😁) - Canto superior direito
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleHUD"
toggleBtn.Size = UDim2.new(0, 54, 0, 54)
toggleBtn.Position = UDim2.new(1, -64, 0, 10)
toggleBtn.Text = "😁"
toggleBtn.TextScaled = true
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0.25, 0)
cornerToggle.Parent = toggleBtn
toggleBtn.Parent = gui

-- Botão E - Abaixo do Emoji
local btnE = Instance.new("TextButton")
btnE.Name = "PressE"
btnE.Size = UDim2.new(0, 54, 0, 54)
btnE.Position = UDim2.new(1, -64, 0, 74)
btnE.Text = "E"
btnE.TextScaled = true
btnE.Font = Enum.Font.GothamBold
btnE.TextColor3 = Color3.new(1, 1, 1)
btnE.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
btnE.BorderSizePixel = 0
btnE.Active = true
btnE.Draggable = true
local cornerE = Instance.new("UICorner")
cornerE.CornerRadius = UDim.new(0.25, 0)
cornerE.Parent = btnE
btnE.Parent = gui

-- Frame principal da HUD
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BorderSizePixel = 0
local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0.1, 0)
cornerFrame.Parent = mainFrame
mainFrame.Parent = gui

-- Antipalmada Label e Switch
local antipalmadaLabel = Instance.new("TextLabel")
antipalmadaLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
antipalmadaLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
antipalmadaLabel.Text = "Antipalmada"
antipalmadaLabel.TextColor3 = Color3.new(1, 1, 1)
antipalmadaLabel.Font = Enum.Font.Gotham
antipalmadaLabel.TextScaled = true
antipalmadaLabel.BackgroundTransparency = 1
antipalmadaLabel.Parent = mainFrame

local antipalmadaSwitch = Instance.new("TextButton")
antipalmadaSwitch.Size = UDim2.new(0.3, 0, 0.1, 0)
antipalmadaSwitch.Position = UDim2.new(0.65, 0, 0.1, 0)
antipalmadaSwitch.Text = "Off"
antipalmadaSwitch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
antipalmadaSwitch.Font = Enum.Font.GothamBold
antipalmadaSwitch.TextColor3 = Color3.new(1, 1, 1)
antipalmadaSwitch.TextScaled = true
antipalmadaSwitch.BorderSizePixel = 0
local cornerAntiSwitch = Instance.new("UICorner")
cornerAntiSwitch.CornerRadius = UDim.new(0.5, 0)
cornerAntiSwitch.Parent = antipalmadaSwitch
antipalmadaSwitch.Parent = mainFrame

-- Câmera Label e Switch
local cameraLabel = Instance.new("TextLabel")
cameraLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
cameraLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
cameraLabel.Text = "Câmera"
cameraLabel.TextColor3 = Color3.new(1, 1, 1)
cameraLabel.Font = Enum.Font.Gotham
cameraLabel.TextScaled = true
cameraLabel.BackgroundTransparency = 1
cameraLabel.Parent = mainFrame

local cameraSwitch = Instance.new("TextButton")
cameraSwitch.Size = UDim2.new(0.3, 0, 0.1, 0)
cameraSwitch.Position = UDim2.new(0.65, 0, 0.25, 0)
cameraSwitch.Text = "Off"
cameraSwitch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
cameraSwitch.Font = Enum.Font.GothamBold
cameraSwitch.TextColor3 = Color3.new(1, 1, 1)
cameraSwitch.TextScaled = true
cameraSwitch.BorderSizePixel = 0
local cornerCamSwitch = Instance.new("UICorner")
cornerCamSwitch.CornerRadius = UDim.new(0.5, 0)
cornerCamSwitch.Parent = cameraSwitch
cameraSwitch.Parent = mainFrame

-- Monitoramento Label e Switch
local monitoramentoLabel = Instance.new("TextLabel")
monitoramentoLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
monitoramentoLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
monitoramentoLabel.Text = "Monitoramento"
monitoramentoLabel.TextColor3 = Color3.new(1, 1, 1)
monitoramentoLabel.Font = Enum.Font.Gotham
monitoramentoLabel.TextScaled = true
monitoramentoLabel.BackgroundTransparency = 1
monitoramentoLabel.Parent = mainFrame

local monitoramentoSwitch = Instance.new("TextButton")
monitoramentoSwitch.Size = UDim2.new(0.3, 0, 0.1, 0)
monitoramentoSwitch.Position = UDim2.new(0.65, 0, 0.4, 0)
monitoramentoSwitch.Text = "Off"
monitoramentoSwitch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
monitoramentoSwitch.Font = Enum.Font.GothamBold
monitoramentoSwitch.TextColor3 = Color3.new(1, 1, 1)
monitoramentoSwitch.TextScaled = true
monitoramentoSwitch.BorderSizePixel = 0
local cornerMonSwitch = Instance.new("UICorner")
cornerMonSwitch.CornerRadius = UDim.new(0.5, 0)
cornerMonSwitch.Parent = monitoramentoSwitch
monitoramentoSwitch.Parent = mainFrame

-- Pulo Infinito Label e Switch
local infiniteJumpLabel = Instance.new("TextLabel")
infiniteJumpLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
infiniteJumpLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
infiniteJumpLabel.Text = "Pulo Infinito"
infiniteJumpLabel.TextColor3 = Color3.new(1, 1, 1)
infiniteJumpLabel.Font = Enum.Font.Gotham
infiniteJumpLabel.TextScaled = true
infiniteJumpLabel.BackgroundTransparency = 1
infiniteJumpLabel.Parent = mainFrame

local infiniteJumpSwitch = Instance.new("TextButton")
infiniteJumpSwitch.Size = UDim2.new(0.3, 0, 0.1, 0)
infiniteJumpSwitch.Position = UDim2.new(0.65, 0, 0.55, 0)
infiniteJumpSwitch.Text = "On"
infiniteJumpSwitch.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
infiniteJumpSwitch.Font = Enum.Font.GothamBold
infiniteJumpSwitch.TextColor3 = Color3.new(1, 1, 1)
infiniteJumpSwitch.TextScaled = true
infiniteJumpSwitch.BorderSizePixel = 0
local cornerJumpSwitch = Instance.new("UICorner")
cornerJumpSwitch.CornerRadius = UDim.new(0.5, 0)
cornerJumpSwitch.Parent = infiniteJumpSwitch
infiniteJumpSwitch.Parent = mainFrame

-- ESP Label e Switch
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
espLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
espLabel.Text = "ESP"
espLabel.TextColor3 = Color3.new(1, 1, 1)
espLabel.Font = Enum.Font.Gotham
espLabel.TextScaled = true
espLabel.BackgroundTransparency = 1
espLabel.Parent = mainFrame

local espSwitch = Instance.new("TextButton")
espSwitch.Size = UDim2.new(0.3, 0, 0.1, 0)
espSwitch.Position = UDim2.new(0.65, 0, 0.7, 0)
espSwitch.Text = "On"
espSwitch.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
espSwitch.Font = Enum.Font.GothamBold
espSwitch.TextColor3 = Color3.new(1, 1, 1)
espSwitch.TextScaled = true
espSwitch.BorderSizePixel = 0
local cornerEspSwitch = Instance.new("UICorner")
cornerEspSwitch.CornerRadius = UDim.new(0.5, 0)
cornerEspSwitch.Parent = espSwitch
espSwitch.Parent = mainFrame

-- Botão TP Troll
local tpTrollBtn = Instance.new("TextButton")
tpTrollBtn.Size = UDim2.new(0.6, 0, 0.1, 0)
tpTrollBtn.Position = UDim2.new(0.2, 0, 0.85, 0)
tpTrollBtn.Text = "TP Troll"
tpTrollBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
tpTrollBtn.Font = Enum.Font.GothamBold
tpTrollBtn.TextColor3 = Color3.new(1, 1, 1)
tpTrollBtn.TextScaled = true
tpTrollBtn.BorderSizePixel = 0
local cornerTpTroll = Instance.new("UICorner")
cornerTpTroll.CornerRadius = UDim.new(0.3, 0)
cornerTpTroll.Parent = tpTrollBtn
tpTrollBtn.Parent = mainFrame

-- Prompt inicial da câmera
local promptGui = Instance.new("ScreenGui")
promptGui.Name = "CameraPrompt"
promptGui.Parent = player:WaitForChild("PlayerGui")

local promptFrame = Instance.new("Frame")
promptFrame.Size = UDim2.new(0, 350, 0, 200)
promptFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
promptFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
promptFrame.BorderSizePixel = 0
local cornerPrompt = Instance.new("UICorner")
cornerPrompt.CornerRadius = UDim.new(0.1, 0)
cornerPrompt.Parent = promptFrame
promptFrame.Parent = promptGui

local promptText = Instance.new("TextLabel")
promptText.Size = UDim2.new(1, 0, 0.4, 0)
promptText.Position = UDim2.new(0, 0, 0.1, 0)
promptText.Text = "Deseja ativar a câmera?"
promptText.TextColor3 = Color3.new(1, 1, 1)
promptText.Font = Enum.Font.Gotham
promptText.TextScaled = true
promptText.BackgroundTransparency = 1
promptText.Parent = promptFrame

local yesBtn = Instance.new("TextButton")
yesBtn.Size = UDim2.new(0.45, -10, 0.25, 0)
yesBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
yesBtn.Text = "Sim"
yesBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
yesBtn.Font = Enum.Font.GothamBold
yesBtn.TextColor3 = Color3.new(1, 1, 1)
yesBtn.TextScaled = true
yesBtn.BorderSizePixel = 0
local cornerYes = Instance.new("UICorner")
cornerYes.CornerRadius = UDim.new(0.3, 0)
cornerYes.Parent = yesBtn
yesBtn.Parent = promptFrame

local noBtn = Instance.new("TextButton")
noBtn.Size = UDim2.new(0.45, -10, 0.25, 0)
noBtn.Position = UDim2.new(0.5, 5, 0.65, 0)
noBtn.Text = "Não"
noBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
noBtn.Font = Enum.Font.GothamBold
noBtn.TextColor3 = Color3.new(1, 1, 1)
noBtn.TextScaled = true
noBtn.BorderSizePixel = 0
local cornerNo = Instance.new("UICorner")
cornerNo.CornerRadius = UDim.new(0.3, 0)
cornerNo.Parent = noBtn
noBtn.Parent = promptFrame

-- Antipalmada
local function notificar(texto)
    local gui = Instance.new("BillboardGui")
    gui.Name = "NotificacaoAnti"
    gui.Size = UDim2.new(0, 200, 0, 40)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Adornee = hrp
    local textoLabel = Instance.new("TextLabel")
    textoLabel.Size = UDim2.new(1, 0, 1, 0)
    textoLabel.BackgroundTransparency = 1
    textoLabel.Text = texto
    textoLabel.TextColor3 = Color3.new(1, 1, 1)
    textoLabel.TextScaled = true
    textoLabel.Font = Enum.Font.GothamBold
    textoLabel.Parent = gui
    gui.Parent = player:WaitForChild("PlayerGui")
    task.delay(5, function()
        if gui then gui:Destroy() end
    end)
end

local function aplicarPropriedades()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(999, 0.3, 0.5)
        end
    end
end

local function removerImpulsores()
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") or v:IsA("BodyPosition") or v:IsA("VectorForce") then
            v:Destroy()
        end
    end
end

local function antipalmadaLogic()
    if not antipalmadaEnabled then return end
    aplicarPropriedades()
    removerImpulsores()
    local vel = hrp.Velocity
    if vel.Magnitude > 90 then
        hrp.Velocity = Vector3.new(vel.X * 0.3, math.clamp(vel.Y, -60, 60), vel.Z * 0.3)
    end
end

local function setupAntipalmada()
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        humanoid:SetStateEnabled(state, true)
    end
    for _, state in pairs({
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.Seated
    }) do
        humanoid:SetStateEnabled(state, false)
    end
    aplicarPropriedades()
    notificar("Modo Imortal Ativado: Palmada anulada + Parkour livre")
end

-- Câmera
UserInputService.TouchPinch:Connect(function(_, _, delta)
    if cameraEnabled then
        zoomOffset = math.clamp(zoomOffset + delta * zoomSensitivity, minZoomOffset, maxZoomOffset)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if cameraEnabled and input.UserInputType == Enum.UserInputType.MouseWheel then
        zoomOffset = math.clamp(zoomOffset + input.Position.Z * zoomSensitivity * 10, minZoomOffset, maxZoomOffset)
    end
end)

local function cameraUpdate(dt)
    if not cameraEnabled then return end
    local delta2d = Vector2.new(UserInputService:GetMouseDelta().Y, -UserInputService:GetMouseDelta().X)
    rotation = rotation + delta2d / rotationSensitivity
    rotation = Vector2.new(math.clamp(rotation.X, -90, 90), rotation.Y)
    local rotX = CFrame.Angles(math.rad(rotation.X), 0, 0)
    local rotY = CFrame.Angles(0, math.rad(rotation.Y), 0)
    if humanoid then
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            fixedPosition = fixedPosition + (forward * moveDir.Z + right * moveDir.X) * moveSpeed * dt
        end
    end
    local baseCFrame = CFrame.new(fixedPosition) * rotY * rotX
    camera.CFrame = baseCFrame * CFrame.new(0, 0, zoomOffset)
end

-- Monitoramento
local plataformaCentro = Vector3.new(-13.76, 150.05, -46.15)
local area = Vector3.new(15, 7, 15)
local buttonPart = workspace:WaitForChild("Button"):WaitForChild("Part")

local function criarRegiao()
    local metade = area / 2
    local canto1 = plataformaCentro - metade
    local canto2 = plataformaCentro + metade
    return Region3.new(canto1, canto2)
end

local function tocarBotao()
    if hrp and buttonPart then
        firetouchinterest(hrp, buttonPart, 0)
        task.wait(0.2)
        firetouchinterest(hrp, buttonPart, 1)
    end
end

local function monitorPlayers()
    while monitoramentoEnabled do
        local regiao = criarRegiao()
        local partes = workspace:FindPartsInRegion3(regiao, nil, math.huge)
        for _, parte in pairs(partes) do
            local char = parte:FindFirstAncestorOfClass("Model")
            local plr = Players:GetPlayerFromCharacter(char)
            if plr and plr ~= player and char:FindFirstChild("HumanoidRootPart") then
                tocarBotao()
                break
            end
        end
        task.wait(0.3)
    end
end

-- Plataformas
local function criarPlataforma(pos)
    local plataforma = Instance.new("Part")
    plataforma.Name = "PlataformaSalva"
    plataforma.Size = Vector3.new(10, 0.2, 10)
    plataforma.Anchored = true
    plataforma.CanCollide = true
    plataforma.Position = pos
    plataforma.Material = Enum.Material.SmoothPlastic
    plataforma.BrickColor = BrickColor.new("Institutional white")
    plataforma.Parent = workspace
end

local posicoes = {
    Vector3.new(12.86, 150.10, -45.95),
    Vector3.new(0.35, 150.10, -45.60),
    Vector3.new(-13.15, 150.10, -46.06),
    Vector3.new(-26.07, 150.10, -46.08),
    Vector3.new(5.58, 149.34, -45.57),
    Vector3.new(-7.36, 149.20, -45.91),
    Vector3.new(-20.23, 149.72, -45.77),
    Vector3.new(-32.52, 148.98, -46.27),
}

for _, pos in pairs(posicoes) do
    criarPlataforma(pos)
end

local tool = Instance.new("Tool")
tool.Name = "Criador de Plataforma"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = player.Backpack

tool.Activated:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local ray = Ray.new(root.Position, Vector3.new(0, -100, 0))
    local hit, position = workspace:FindPartOnRay(ray, char)
    if hit then
        criarPlataforma(Vector3.new(position.X, position.Y + 0.1, position.Z))
    else
        local fallbackPos = root.Position - Vector3.new(0, 3, 0)
        criarPlataforma(Vector3.new(fallbackPos.X, fallbackPos.Y + 0.1, fallbackPos.Z))
    end
end)

-- Pulo Infinito
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ESP (Contorno fino ao redor do personagem)
local function createEspHighlight(plr)
    if plr == player then return end
    if plr.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.OutlineTransparency = 0
        highlight.Enabled = espEnabled
        highlight.Adornee = plr.Character
        highlight.Parent = plr.Character
        espHighlights[plr] = highlight
    end
end

local function updateEsp()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and not espHighlights[plr] then
            createEspHighlight(plr)
        end
    end
    for plr, highlight in pairs(espHighlights) do
        if not plr.Character or not plr.Character.Parent then
            highlight:Destroy()
            espHighlights[plr] = nil
        else
            highlight.Adornee = plr.Character
            highlight.Enabled = espEnabled
        end
    end
end

-- Inicializar ESP para jogadores existentes e conectar CharacterAdded
for _, plr in pairs(Players:GetPlayers()) do
    createEspHighlight(plr)
    plr.CharacterAdded:Connect(function()
        createEspHighlight(plr)
    end)
end

-- Conectar novos jogadores
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        createEspHighlight(plr)
    end)
    if plr.Character then
        createEspHighlight(plr)
    end
end)

-- Remover jogadores que saem
Players.PlayerRemoving:Connect(function(plr)
    if espHighlights[plr] then
        espHighlights[plr]:Destroy()
        espHighlights[plr] = nil
    end
end)

RunService.RenderStepped:Connect(updateEsp)

-- Anti-AFK
spawn(function()
    while true do
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        task.wait(60)
    end
end)

-- Funções da HUD
local function toggleHUD()
    mainFrame.Visible = not mainFrame.Visible
end

local function toggleAntipalmada()
    antipalmadaEnabled = not antipalmadaEnabled
    local newColor = antipalmadaEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(antipalmadaSwitch, tweenInfo, {BackgroundColor3 = newColor}):Play()
    antipalmadaSwitch.Text = antipalmadaEnabled and "On" or "Off"
    if antipalmadaEnabled then
        setupAntipalmada()
    end
end

local function toggleCamera()
    cameraEnabled = not cameraEnabled
    local newColor = cameraEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(cameraSwitch, tweenInfo, {BackgroundColor3 = newColor}):Play()
    cameraSwitch.Text = cameraEnabled and "On" or "Off"
    camera.CameraType = cameraEnabled and Enum.CameraType.Scriptable or Enum.CameraType.Custom
end

local function toggleMonitoramento()
    monitoramentoEnabled = not monitoramentoEnabled
    local newColor = monitoramentoEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(monitoramentoSwitch, tweenInfo, {BackgroundColor3 = newColor}):Play()
    monitoramentoSwitch.Text = monitoramentoEnabled and "On" or "Off"
    if monitoramentoEnabled then
        spawn(monitorPlayers)
    end
end

local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled
    local newColor = infiniteJumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(infiniteJumpSwitch, tweenInfo, {BackgroundColor3 = newColor}):Play()
    infiniteJumpSwitch.Text = infiniteJumpEnabled and "On" or "Off"
end

local function toggleEsp()
    espEnabled = not espEnabled
    local newColor = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(espSwitch, tweenInfo, {BackgroundColor3 = newColor}):Play()
    espSwitch.Text = espEnabled and "On" or "Off"
    for _, highlight in pairs(espHighlights) do
        highlight.Enabled = espEnabled
    end
end

local function teleportTroll()
    if hrp then
        hrp.CFrame = CFrame.new(22.00, 153.00, -32.00)
    end
end

-- Conexões dos botões
toggleBtn.MouseButton1Click:Connect(toggleHUD)
antipalmadaSwitch.MouseButton1Click:Connect(toggleAntipalmada)
cameraSwitch.MouseButton1Click:Connect(toggleCamera)
monitoramentoSwitch.MouseButton1Click:Connect(toggleMonitoramento)
infiniteJumpSwitch.MouseButton1Click:Connect(toggleInfiniteJump)
espSwitch.MouseButton1Click:Connect(toggleEsp)
tpTrollBtn.MouseButton1Click:Connect(teleportTroll)
btnE.MouseButton1Click:Connect(tocarBotao)

yesBtn.MouseButton1Click:Connect(function()
    cameraEnabled = true
    cameraSwitch.Text = "On"
    cameraSwitch.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    camera.CameraType = Enum.CameraType.Scriptable
    promptGui:Destroy()
end)

noBtn.MouseButton1Click:Connect(function()
    cameraEnabled = false
    cameraSwitch.Text = "Off"
    cameraSwitch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    camera.CameraType = Enum.CameraType.Custom
    promptGui:Destroy()
end)

-- Loops principais
RunService.Heartbeat:Connect(antipalmadaLogic)
RunService.RenderStepped:Connect(cameraUpdate)

-- Atualização ao ressuscitar
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    if antipalmadaEnabled then
        setupAntipalmada()
    end
end)
