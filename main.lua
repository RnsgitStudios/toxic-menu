local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variáveis de status
local flying = false
local infiniteHealth = false
local espEnabled = false
local aimbotEnabled = false

-- Configurações de voo
local flySpeed = 50
local flyDirection = Vector3.new()

-- Função de notificação
local function showNotification(text)
	print(text) -- Pode ser substituído por uma função de GUI se desejar
end

-- GUI do Menu
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

-- Botão principal para abrir/fechar o menu
local toggleMenuButton = Instance.new("TextButton", screenGui)
toggleMenuButton.Size = UDim2.new(0, 50, 0, 50)  -- Ajusta o tamanho para ser quadrado (50x50)
toggleMenuButton.Position = UDim2.new(0, 10, 0, 10)
toggleMenuButton.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
toggleMenuButton.Text = ""
toggleMenuButton.BorderSizePixel = 0
toggleMenuButton.BackgroundTransparency = 0.3

-- Faz o botão ser circular
local corner = Instance.new("UICorner", toggleMenuButton)
corner.CornerRadius = UDim.new(1, 0) -- Deixa completamente circular

-- Imagem da logo dentro do botão
local logoImage = Instance.new("ImageLabel", toggleMenuButton)
logoImage.Size = UDim2.new(0.8, 0, 0.8, 0)  -- Ajusta o tamanho para 80% do botão
logoImage.Position = UDim2.new(0.1, 0, 0.1, 0)  -- Centraliza a logo dentro do botão
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://87510669729440" -- Insira o ID da imagem da logo aqui

-- Frame do menu principal
local mainMenu = Instance.new("Frame", screenGui)
mainMenu.Size = UDim2.new(0, 200, 0, 280) -- Aumenta a altura para acomodar o título
mainMenu.Position = UDim2.new(0.5, -100, 0.5, -140)
mainMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainMenu.Visible = false
mainMenu.Active = true
mainMenu.Draggable = true

-- Título do menu
local titleLabel = Instance.new("TextLabel", mainMenu)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Toxic menu"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold

-- Função para alternar o menu
toggleMenuButton.MouseButton1Click:Connect(function()
	mainMenu.Visible = not mainMenu.Visible
	toggleMenuButton.BackgroundColor3 = mainMenu.Visible and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(0, 128, 255) -- Muda a cor ao abrir/fechar
end)

-- Funções de ativação
local function toggleFly()
	flying = not flying
	if flying then
		LocalPlayer.Character.Humanoid.PlatformStand = true
		showNotification("Modo Voo Ativado")
	else
		LocalPlayer.Character.Humanoid.PlatformStand = false
		showNotification("Modo Voo Desativado")
	end
end

local function toggleInfiniteHealth()
	infiniteHealth = not infiniteHealth
	if infiniteHealth then
		local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.MaxHealth = 1e6
			humanoid.Health = 1e6
			humanoid.HealthChanged:Connect(function(currentHealth)
				if infiniteHealth and currentHealth < humanoid.MaxHealth then
					humanoid.Health = humanoid.MaxHealth
				end
			end)
		end
		showNotification("Vida Infinita Ativada")
	else
		showNotification("Vida Infinita Desativada")
	end
end

local function toggleESP()
	espEnabled = not espEnabled
	showNotification(espEnabled and "ESP Ativado" or "ESP Desativado")
	-- Código de ESP pode ser implementado aqui
end

local function toggleAimbot()
	aimbotEnabled = not aimbotEnabled
	showNotification(aimbotEnabled and "Aimbot Ativado" or "Aimbot Desativado")
	-- Código de Aimbot pode ser implementado aqui
end

-- Função para criar botões de alternância com cor
local function createToggleButton(text, position, toggleFunction)
	local button = Instance.new("TextButton", mainMenu)
	button.Size = UDim2.new(0, 150, 0, 40)
	button.Position = position
	button.Text = text
	button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	button.TextColor3 = Color3.new(1, 1, 1)

	button.MouseButton1Click:Connect(function()
		toggleFunction()
		button.BackgroundColor3 = button.BackgroundColor3 == Color3.fromRGB(70, 70, 70) 
			and Color3.fromRGB(0, 255, 0) 
			or Color3.fromRGB(70, 70, 70)
	end)
end

-- Criando os botões de alternância no menu
createToggleButton("FLY", UDim2.new(0, 25, 0, 50), toggleFly)
createToggleButton("Invencible", UDim2.new(0, 25, 0, 100), toggleInfiniteHealth)
createToggleButton("ESP", UDim2.new(0, 25, 0, 150), toggleESP)
createToggleButton("Aimbot", UDim2.new(0, 25, 0, 200), toggleAimbot)

-- Função para permitir arrastar o botão de abrir o menu
local dragging = false
local dragInput, dragStart, startPos

toggleMenuButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = toggleMenuButton.Position
	end
end)

toggleMenuButton.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		toggleMenuButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

toggleMenuButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Loop para aplicar o movimento de voo
RunService.RenderStepped:Connect(function()
	if flying then
		local moveDirection = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(flyDirection)).Unit
		LocalPlayer.Character.HumanoidRootPart.Velocity = moveDirection * flySpeed
	end
end)

-- Controles de voo
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then
		flyDirection = flyDirection + Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.S then
		flyDirection = flyDirection + Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.A then
		flyDirection = flyDirection + Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.D then
		flyDirection = flyDirection + Vector3.new(1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.E then
		flyDirection = flyDirection + Vector3.new(0, 1, 0)
	elseif input.KeyCode == Enum.KeyCode.Q then
		flyDirection = flyDirection + Vector3.new(0, -1, 0)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then
		flyDirection = flyDirection - Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.S then
		flyDirection = flyDirection - Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.A then
		flyDirection = flyDirection - Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.D then
		flyDirection = flyDirection - Vector3.new(1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.E then
		flyDirection = flyDirection - Vector3.new(0, 1, 0)
	elseif input.KeyCode == Enum.KeyCode.Q then
		flyDirection = flyDirection - Vector3.new(0, -1, 0)
	end
end)
