local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "VONTROP",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "cre by bellchuppy",
	ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("MOVEMENT", 4483362458)
MainTab:CreateSection("MOVEMENT")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local SpeedOn = false
local SpeedValue = 50
local JumpOn = false
local JumpValue = 70
local InfJump = false
local Noclip = false
local FloatOn = false
local NotifyOn = true

local FloatPart
local FloatConn
local NoclipConn
local FloatY

local function GetChar()
	return LocalPlayer.Character
end

local function GetHum()
	local c = GetChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
	local c = GetChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function Notify(text)
	if not NotifyOn then return end
	Rayfield:Notify({
		Title = "VONTROP",
		Content = text,
		Duration = 2,
		Image = "user"
	})
end

RunService.Heartbeat:Connect(function()
	local char = GetChar()
	local hum = GetHum()
	local hrp = GetHRP()
	if not char or not hum or not hrp then return end
	if hum.Health <= 0 then return end

	if SpeedOn then
		local moveDir = hum.MoveDirection
		if moveDir.Magnitude > 0 then
			hrp.AssemblyLinearVelocity = Vector3.new(
				moveDir.X * SpeedValue,
				hrp.AssemblyLinearVelocity.Y,
				moveDir.Z * SpeedValue
			)
		end
	end

	if JumpOn then
		hum.UseJumpPower = true
		hum.JumpPower = JumpValue
	else
		hum.UseJumpPower = true
		hum.JumpPower = 50
	end
end)

local function EnableNoclip()
	if NoclipConn then return end
	NoclipConn = RunService.Stepped:Connect(function()
		local char = GetChar()
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end)
end

local function DisableNoclip()
	if NoclipConn then
		NoclipConn:Disconnect()
		NoclipConn = nil
	end
	local char = GetChar()
	if char then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end

UserInputService.JumpRequest:Connect(function()
	if InfJump then
		local hum = GetHum()
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

local function EnableFloat()
	if FloatConn then return end
	local hrp = GetHRP()
	if not hrp then return end
	FloatY = hrp.Position.Y - 3
	FloatPart = Instance.new("Part")
	FloatPart.Size = Vector3.new(999999,1,999999)
	FloatPart.Anchored = true
	FloatPart.Transparency = 1
	FloatPart.CanCollide = true
	FloatPart.Parent = workspace
	FloatConn = RunService.Heartbeat:Connect(function()
		if not FloatOn then return end
		local hrp = GetHRP()
		local hum = GetHum()
		if hrp and hum then
			if hum.FloorMaterial == Enum.Material.Air and hrp.AssemblyLinearVelocity.Y < 0 then
				FloatY = hrp.Position.Y - 3
			end
			FloatPart.Position = Vector3.new(hrp.Position.X, FloatY, hrp.Position.Z)
		end
	end)
end

local function DisableFloat()
	if FloatConn then
		FloatConn:Disconnect()
		FloatConn = nil
	end
	if FloatPart then
		FloatPart:Destroy()
		FloatPart = nil
	end
end

MainTab:CreateToggle({
	Name = "SPEED",
	CurrentValue = false,
	Callback = function(v)
		SpeedOn = v
		Notify("SPEED " .. (v and "ON" or "OFF"))
	end
})

MainTab:CreateSlider({
	Name = "SPEED VALUE",
	Range = {1,300},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v)
		SpeedValue = v
	end
})

MainTab:CreateToggle({
	Name = "JUMP",
	CurrentValue = false,
	Callback = function(v)
		JumpOn = v
		Notify("JUMP " .. (v and "ON" or "OFF"))
	end
})

MainTab:CreateSlider({
	Name = "JUMP VALUE",
	Range = {1,300},
	Increment = 1,
	CurrentValue = 70,
	Callback = function(v)
		JumpValue = v
	end
})

MainTab:CreateToggle({
	Name = "INFINITE JUMP",
	CurrentValue = false,
	Callback = function(v)
		InfJump = v
		Notify("INFINITE JUMP " .. (v and "ON" or "OFF"))
	end
})

MainTab:CreateToggle({
	Name = "NOCLIP",
	CurrentValue = false,
	Callback = function(v)
		Noclip = v
		if v then
			EnableNoclip()
		else
			DisableNoclip()
		end
		Notify("NOCLIP " .. (v and "ON" or "OFF"))
	end
})

MainTab:CreateToggle({
	Name = "FLOAT",
	CurrentValue = false,
	Callback = function(v)
		FloatOn = v
		if v then
			EnableFloat()
		else
			DisableFloat()
		end
		Notify("FLOAT " .. (v and "ON" or "OFF"))
	end
})

MainTab:CreateSection("INVISIBLE")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local InvisibleEnabled = false
local LockInvisibleBtn = false
local invisCurrentSize = 18
local invisCurrentShape = "SQUARE"

local character, humanoid, rootPart
local parts = {}

local function updateCharacterData()
	character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	parts = {}

	for _,v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 0 then
			table.insert(parts,v)
		end
	end
end

updateCharacterData()

local function ApplyInvisible(state)
	InvisibleEnabled = state

	for _,v in pairs(parts) do
		v.Transparency = state and 0.5 or 0
	end

	Notify(state and "INVISIBLE ON" or "INVISIBLE OFF")
	UpdateButton()
end

RunService.Heartbeat:Connect(function()

	if InvisibleEnabled and rootPart and humanoid then

		local oldCF = rootPart.CFrame
		local oldOffset = humanoid.CameraOffset

		local hideCF = oldCF * CFrame.new(0,-200000,0)

		rootPart.CFrame = hideCF

		humanoid.CameraOffset =
			hideCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position

		RunService.RenderStepped:Wait()

		rootPart.CFrame = oldCF
		humanoid.CameraOffset = oldOffset

	end

end)

LocalPlayer.CharacterAdded:Connect(function()
	InvisibleEnabled = false
	task.wait(1)
	updateCharacterData()
end)

-- FLOAT GUI

local InvisGui = Instance.new("ScreenGui")
InvisGui.Name = "InvisibleFloatGui"
InvisGui.Parent = game.CoreGui
InvisGui.Enabled = false
InvisGui.ResetOnSpawn = false

local InvisBtn = Instance.new("TextButton")
InvisBtn.Size = UDim2.new(0,200,0,50)
InvisBtn.Position = UDim2.new(0.5,-100,0.7,0)
InvisBtn.BackgroundTransparency = 1
InvisBtn.Text = "INVISIBLE : OFF"
InvisBtn.Font = Enum.Font.Gotham
InvisBtn.TextSize = 18
InvisBtn.TextColor3 = Color3.fromRGB(0,0,0)
InvisBtn.TextStrokeTransparency = 0.8
InvisBtn.Parent = InvisGui

local invisCorner = Instance.new("UICorner", InvisBtn)
invisCorner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Thickness = 2
stroke.Parent = InvisBtn

-- ==================== SHAPE & SIZE FUNCTIONS ====================

local function applyInvisShape(shape, size)
	if shape == "RECTANGLE" then
		local w = size * 8
		local h = size * 2
		InvisBtn.Size = UDim2.new(0, w, 0, h)
		invisCorner.CornerRadius = UDim.new(0, 16)
		InvisBtn.TextSize = math.clamp(size * 0.55, 8, 60)
	elseif shape == "SQUARE" then
		local s = size * 4
		InvisBtn.Size = UDim2.new(0, s, 0, s)
		invisCorner.CornerRadius = UDim.new(0, 8)
		InvisBtn.TextSize = math.clamp(size * 0.4, 6, 50)
	elseif shape == "CIRCLE" then
		local s = size * 3
		InvisBtn.Size = UDim2.new(0, s, 0, s)
		invisCorner.CornerRadius = UDim.new(0.5, 0)
		InvisBtn.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end
		InvisBtn.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

applyInvisShape(invisCurrentShape, invisCurrentSize)

function UpdateButton()

	if InvisibleEnabled then
		InvisBtn.Text = "INVISIBLE : ON"
		InvisBtn.TextColor3 = Color3.fromRGB(0,0,0)
	else
		InvisBtn.Text = "INVISIBLE : OFF"
		InvisBtn.TextColor3 = Color3.fromRGB(0,0,0)
	end

end

InvisBtn.MouseButton1Click:Connect(function()
	ApplyInvisible(not InvisibleEnabled)
end)

-- DRAG

local dragging = false
local dragStart
local startPos

InvisBtn.InputBegan:Connect(function(input)

	if LockInvisibleBtn then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = InvisBtn.Position

	end
end)

UIS.InputChanged:Connect(function(input)

	if LockInvisibleBtn then return end

	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		local delta = input.Position - dragStart

		InvisBtn.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false

	end
end)

-- MENU

MainTab:CreateToggle({
	Name = "INVISIBLE",
	CurrentValue = false,
	Callback = function(v)
		ApplyInvisible(v)
	end
})

MainTab:CreateToggle({
	Name = "FLOAT INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		InvisGui.Enabled = v
		Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			InvisBtn.TextTransparency = 1
			stroke.Transparency = 1
		else
			InvisBtn.TextTransparency = 0
			stroke.Transparency = 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 18,
	Callback = function(value)
		invisCurrentSize = value
		applyInvisShape(invisCurrentShape, invisCurrentSize)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		if type(option) == "table" then
			invisCurrentShape = option[1]
		else
			invisCurrentShape = option
		end
		applyInvisShape(invisCurrentShape, invisCurrentSize)
		Notify("SHAPE: " .. invisCurrentShape)
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LockInvisibleBtn = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

MainTab:CreateSection("SPEED GLITCH")

local RunService = game:GetService("RunService")
local DEFAULT_WALKSPEED = 16
local MAX_SPEED = 200
local SpeedGlitchEnabled = false
local SpeedValue = 50
local SpeedConn
local humanoid

local function BindCharacter(char)
	humanoid = char:WaitForChild("Humanoid")
	humanoid.WalkSpeed = DEFAULT_WALKSPEED

	if SpeedConn then
		SpeedConn:Disconnect()
		SpeedConn = nil
	end

	SpeedConn = RunService.RenderStepped:Connect(function()
		if not humanoid or humanoid.Health <= 0 then return end

		if not SpeedGlitchEnabled then
			if humanoid.WalkSpeed ~= DEFAULT_WALKSPEED then
				humanoid.WalkSpeed = DEFAULT_WALKSPEED
			end
			return
		end

		local state = humanoid:GetState()

		local isJumping =
			state == Enum.HumanoidStateType.Jumping
			or state == Enum.HumanoidStateType.Freefall

		local isMoving = humanoid.MoveDirection.Magnitude > 0.1

		if isJumping and isMoving then
			humanoid.WalkSpeed = SpeedValue
		else
			humanoid.WalkSpeed = DEFAULT_WALKSPEED
		end
	end)
end

LocalPlayer.CharacterAdded:Connect(BindCharacter)

if LocalPlayer.Character then
	BindCharacter(LocalPlayer.Character)
end

MainTab:CreateToggle({
	Name = "SPEED GLITCH",
	CurrentValue = false,
	Callback = function(v)
		SpeedGlitchEnabled = v
		Notify(v and "SPEEDGLITCH ON" or "SPEEDGLITCH OFF")
	end
})

MainTab:CreateSlider({
	Name = "SPEED",
	Range = {16,200},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 50,
	Callback = function(v)
		SpeedValue = v
	end
})

local SpeedGui = Instance.new("ScreenGui")
SpeedGui.Name = "SpeedGlitchFloatingGui"
SpeedGui.Parent = game.CoreGui
SpeedGui.Enabled = false
SpeedGui.ResetOnSpawn = false

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Position = UDim2.new(0.5,-100,0.48,0)
SpeedBtn.BackgroundTransparency = 1
SpeedBtn.Text = "SPEED GLITCH : OFF"
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextColor3 = Color3.fromRGB(0,0,0)
SpeedBtn.Parent = SpeedGui

local speedCorner = Instance.new("UICorner", SpeedBtn)
speedCorner.CornerRadius = UDim.new(0, 12)

local strokeSpeed = Instance.new("UIStroke")
strokeSpeed.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeSpeed.Color = Color3.fromRGB(255,255,255)
strokeSpeed.Thickness = 2
strokeSpeed.Parent = SpeedBtn

-- ==================== SHAPE & SIZE FUNCTIONS ====================

local sp_Size = 18
local sp_Shape = "SQUARE"

local function applySpeedShape(shape, size)
	if shape == "RECTANGLE" then
		local w, h = size * 8, size * 2
		SpeedBtn.Size = UDim2.new(0, w, 0, h)
		speedCorner.CornerRadius = UDim.new(0, 16)
		SpeedBtn.TextSize = math.clamp(size * 0.55, 8, 60)
	elseif shape == "SQUARE" then
		local s = size * 4
		SpeedBtn.Size = UDim2.new(0, s, 0, s)
		speedCorner.CornerRadius = UDim.new(0, 8)
		SpeedBtn.TextSize = math.clamp(size * 0.4, 6, 50)
	elseif shape == "CIRCLE" then
		local s = size * 3
		SpeedBtn.Size = UDim2.new(0, s, 0, s)
		speedCorner.CornerRadius = UDim.new(0.5, 0)
		SpeedBtn.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

applySpeedShape(sp_Shape, sp_Size)

-- ==================== CLICK ====================

SpeedBtn.MouseButton1Click:Connect(function()
	SpeedGlitchEnabled = not SpeedGlitchEnabled
	SpeedBtn.Text = SpeedGlitchEnabled and "SPEED GLITCH : ON" or "SPEED GLITCH : OFF"
end)

-- ==================== DRAG ====================

local LockSpeedBtn = false
local draggingS = false
local dragStartS
local startPosS

SpeedBtn.InputBegan:Connect(function(input)
	if LockSpeedBtn then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		draggingS = true
		dragStartS = input.Position
		startPosS = SpeedBtn.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if LockSpeedBtn then return end
	if draggingS and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStartS
		SpeedBtn.Position = UDim2.new(
			startPosS.X.Scale,
			startPosS.X.Offset + delta.X,
			startPosS.Y.Scale,
			startPosS.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		draggingS = false
	end
end)

-- ==================== RAYFIELD UI ====================

MainTab:CreateToggle({
	Name = "FLOAT SPEEDGLITCH BUTTON",
	CurrentValue = false,
	Callback = function(v)
		SpeedGui.Enabled = v
		Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		SpeedBtn.TextTransparency = v and 1 or 0
		strokeSpeed.Transparency = v and 1 or 0
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 18,
	Callback = function(value)
		sp_Size = value
		applySpeedShape(sp_Shape, sp_Size)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		sp_Shape = type(option) == "table" and option[1] or option
		applySpeedShape(sp_Shape, sp_Size)
		Notify("SHAPE: " .. sp_Shape)
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LockSpeedBtn = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

MainTab:CreateSection("REMOVE HIDDEN PLAYER")

local RemoveHidden = false
local RemoveConn
local RemoveLock = false
local savedTransparency = {}

-- GUI
local RemoveGui = Instance.new("ScreenGui")
RemoveGui.Name = "RemoveHiddenGui"
RemoveGui.Parent = game.CoreGui
RemoveGui.Enabled = false
RemoveGui.ResetOnSpawn = false

local RemoveBtn = Instance.new("TextButton")
RemoveBtn.Position = UDim2.new(0.5,-100,0.8,0)
RemoveBtn.BackgroundTransparency = 1
RemoveBtn.Text = "REMOVE HIDDEN : OFF"
RemoveBtn.Font = Enum.Font.Gotham
RemoveBtn.TextColor3 = Color3.fromRGB(0,0,0)
RemoveBtn.TextStrokeTransparency = 0.8
RemoveBtn.Parent = RemoveGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = RemoveBtn

-- FIX VIỀN
local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Parent = RemoveBtn

-- ==================== SHAPE & SIZE FUNCTIONS ====================

local rm_Size = 18
local rm_Shape = "SQUARE"

local function applyRemoveShape(shape, size)
	if shape == "RECTANGLE" then
		local w, h = size * 8, size * 2
		RemoveBtn.Size = UDim2.new(0, w, 0, h)
		corner.CornerRadius = UDim.new(0, 16)
		RemoveBtn.TextSize = math.clamp(size * 0.55, 8, 60)
	elseif shape == "SQUARE" then
		local s = size * 4
		RemoveBtn.Size = UDim2.new(0, s, 0, s)
		corner.CornerRadius = UDim.new(0, 8)
		RemoveBtn.TextSize = math.clamp(size * 0.4, 6, 50)
	elseif shape == "CIRCLE" then
		local s = size * 3
		RemoveBtn.Size = UDim2.new(0, s, 0, s)
		corner.CornerRadius = UDim.new(0.5, 0)
		RemoveBtn.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

applyRemoveShape(rm_Shape, rm_Size)


-- HIỆN PLAYER ẨN + INVISIBLE
local function ShowHidden()

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= LocalPlayer then

			local char = plr.Character

			if char then

				for _,v in pairs(char:GetDescendants()) do

					if v:IsA("BasePart") then

						if savedTransparency[v] == nil then
							savedTransparency[v] = v.Transparency
						end

						v.Transparency = 0
						v.LocalTransparencyModifier = 0
						v.CanCollide = true

					end

					if v:IsA("Decal") then
						v.Transparency = 0
					end

					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end

				end

				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Transparency = 0
				end

			end

		end

	end

end


-- KHÔI PHỤC
local function RestorePlayers()

	for part,value in pairs(savedTransparency) do

		if part and part.Parent then
			part.Transparency = value
		end

	end

	savedTransparency = {}

end


-- START
local function StartRemove()

	if RemoveConn then return end

	RemoveConn = RunService.Heartbeat:Connect(function()

		if RemoveHidden then
			ShowHidden()
		end

	end)

end


-- STOP
local function StopRemove()

	if RemoveConn then
		RemoveConn:Disconnect()
		RemoveConn = nil
	end

	RestorePlayers()

end


-- UPDATE BUTTON
local function UpdateBtn()

	if RemoveHidden then
		RemoveBtn.Text = "REMOVE HIDDEN : ON"
	else
		RemoveBtn.Text = "REMOVE HIDDEN : OFF"
	end

end


-- TOGGLE
local function ToggleRemove()

	RemoveHidden = not RemoveHidden
	UpdateBtn()

	if RemoveHidden then
		StartRemove()
	else
		StopRemove()
	end

	Notify(RemoveHidden and "REMOVE HIDDEN ON" or "REMOVE HIDDEN OFF")

end


RemoveBtn.MouseButton1Click:Connect(function()
	ToggleRemove()
end)


-- DRAG BUTTON
local dragging = false
local dragStart
local startPos

RemoveBtn.InputBegan:Connect(function(input)

	if RemoveLock then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = RemoveBtn.Position

	end

end)


UIS.InputChanged:Connect(function(input)

	if RemoveLock then return end

	if dragging then

		local delta = input.Position - dragStart

		RemoveBtn.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

	end

end)


UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false

	end

end)


-- MENU
MainTab:CreateToggle({
	Name = "REMOVE HIDDEN PLAYER",
	CurrentValue = false,
	Callback = function(v)

		RemoveHidden = v
		UpdateBtn()

		if v then
			StartRemove()
		else
			StopRemove()
		end

	end
})


MainTab:CreateToggle({
	Name = "FLOAT REMOVE HIDDEN PLAYER BUTTON",
	CurrentValue = false,
	Callback = function(v)
		RemoveGui.Enabled = v
		Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		RemoveBtn.TextTransparency = v and 1 or 0
		stroke.Transparency = v and 1 or 0
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 18,
	Callback = function(value)
		rm_Size = value
		applyRemoveShape(rm_Shape, rm_Size)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		rm_Shape = type(option) == "table" and option[1] or option
		applyRemoveShape(rm_Shape, rm_Size)
		Notify("SHAPE: " .. rm_Shape)
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		RemoveLock = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

MainTab:CreateSection("SETTINGS")

MainTab:CreateToggle({
	Name = "NOTIFICATION",
	CurrentValue = true,
	Callback = function(v)
		NotifyOn = v
		Rayfield:Notify({
			Title = "VONTROP",
			Content = "NOTIFICATION " .. (v and "ON" or "OFF"),
			Duration = 2,
			Image = "user"
		})
	end
})

local MainTab = Window:CreateTab("ESP", 4483362458)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local NOTIFICATIONS_ON = true

local function Notify(text)
	if not NOTIFICATIONS_ON then return end
	Rayfield:Notify({ Title = "VONTROP", Content = text, Duration = 2, Image = "user" })
end

local function GetMyHRP()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local Settings = {
	MURDER        = false,
	MUR_TRACER    = false,
	MUR_RECT      = false,
	MUR_NAME      = false,
	MUR_DISTANCE  = false,
	MUR_OUTLINE   = false,

	SHERIFF       = false,
	SHR_TRACER    = false,
	SHR_RECT      = false,
	SHR_NAME      = false,
	SHR_DISTANCE  = false,
	SHR_OUTLINE   = false,

	INNOCENT      = false,
	INN_TRACER    = false,
	INN_RECT      = false,
	INN_NAME      = false,
	INN_DISTANCE  = false,
	INN_OUTLINE   = false,

	GUN           = false,
	GUN_TRACER    = false,
	GUN_RECT      = false,
	GUN_NAME      = false,
	GUN_DISTANCE  = false,
	GUN_OUTLINE   = false,

	ENEMY         = false,
	ENE_TRACER    = false,
	ENE_RECT      = false,
	ENE_NAME      = false,
	ENE_DISTANCE  = false,
	ENE_OUTLINE   = false,

	TEAM          = false,
	TEAM_TRACER   = false,
	TEAM_RECT     = false,
	TEAM_NAME     = false,
	TEAM_DISTANCE = false,
	TEAM_OUTLINE  = false,
}

local Colors = {
	MUR = {
		Main    = Color3.fromRGB(255, 0,   0),
		Outline = Color3.fromRGB(255, 0,   0),
		Fill    = Color3.fromRGB(255, 120, 120),
	},
	SHR = {
		Main    = Color3.fromRGB(0,   170, 255),
		Outline = Color3.fromRGB(0,   170, 255),
		Fill    = Color3.fromRGB(170, 220, 255),
	},
	INN = {
		Main    = Color3.fromRGB(0,   255, 0),
		Outline = Color3.fromRGB(0,   255, 0),
		Fill    = Color3.fromRGB(170, 255, 170),
	},
	GUN = {
		Main    = Color3.fromRGB(255, 255, 0),
		Outline = Color3.fromRGB(255, 255, 0),
		Fill    = Color3.fromRGB(255, 255, 170),
	},
}

local EnemyColor = Color3.fromRGB(255, 0, 0)
local TeamColor  = Color3.fromRGB(0, 255, 0)

local MurObjects  = {} ; local MurHL  = {}
local ShrObjects  = {} ; local ShrHL  = {}
local InnObjects  = {} ; local InnHL  = {}
local EneObjects  = {} ; local EneHL  = {}
local TeamObjects = {} ; local TeamHL = {}
local GunObjects  = {} ; local GunHL  = nil

local function IsMurder(plr)
	local char = plr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	return char:FindFirstChild("Knife") ~= nil
		or plr.Backpack:FindFirstChild("Knife") ~= nil
end

local function IsSheriff(plr)
	local char = plr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	return char:FindFirstChild("Gun") ~= nil
		or plr.Backpack:FindFirstChild("Gun") ~= nil
end

local function IsInnocent(plr)
	local char = plr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if char:FindFirstChild("Knife") then return false end
	if plr.Backpack:FindFirstChild("Knife") then return false end
	if char:FindFirstChild("Gun") then return false end
	if plr.Backpack:FindFirstChild("Gun") then return false end
	return true
end

local function FindGunDrop()
	local gunDrop = workspace:FindFirstChild("GunDrop", true)
	if not gunDrop then return nil end
	if gunDrop:IsA("BasePart") then return gunDrop end
	return gunDrop:FindFirstChild("Handle")
		or gunDrop:FindFirstChildWhichIsA("BasePart")
end

local function IsEnemy(plr)
	local char = plr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if LocalPlayer.Team and plr.Team then
		return plr.Team ~= LocalPlayer.Team
	end
	if LocalPlayer.TeamColor and plr.TeamColor then
		return plr.TeamColor ~= LocalPlayer.TeamColor
	end
	return false
end

local function IsTeammate(plr)
	local char = plr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if LocalPlayer.Team and plr.Team then
		return plr.Team == LocalPlayer.Team
	end
	if LocalPlayer.TeamColor and plr.TeamColor then
		return plr.TeamColor == LocalPlayer.TeamColor
	end
	return false
end

local function MakeDrawings()
	local t = {}

	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Visible = false
	t.Tracer = tracer

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Visible = false
	t.Box = box

	local text = Drawing.new("Text")
	text.Size = 13
	text.Center = true
	text.Outline = true
	text.Visible = false
	t.Text = text

	return t
end

local function ClearDrawings(t)
	if not t then return end
	for _, v in pairs(t) do
		pcall(function() v:Remove() end)
	end
end

local function SafeHighlight(hlTable, key, char, outlineColor, fillColor)
	if hlTable[key] then
		if not hlTable[key].Parent or hlTable[key].Adornee ~= char then
			pcall(function() hlTable[key]:Destroy() end)
			hlTable[key] = nil
		end
	end

	if not hlTable[key] then
		local hl = Instance.new("Highlight")
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Adornee   = char
		hl.Parent    = game.CoreGui
		hlTable[key] = hl
	end

	local hl = hlTable[key]
	hl.OutlineColor        = outlineColor
	hl.FillColor           = fillColor
	hl.OutlineTransparency = 0
	hl.FillTransparency    = 0.55
end

local function RemoveHighlight(hlTable, key)
	if hlTable[key] then
		pcall(function() hlTable[key]:Destroy() end)
		hlTable[key] = nil
	end
end

local function ClearPlayer(plr)
	ClearDrawings(MurObjects[plr])  ; MurObjects[plr]  = nil ; RemoveHighlight(MurHL,  plr)
	ClearDrawings(ShrObjects[plr])  ; ShrObjects[plr]  = nil ; RemoveHighlight(ShrHL,  plr)
	ClearDrawings(InnObjects[plr])  ; InnObjects[plr]  = nil ; RemoveHighlight(InnHL,  plr)
	ClearDrawings(EneObjects[plr])  ; EneObjects[plr]  = nil ; RemoveHighlight(EneHL,  plr)
	ClearDrawings(TeamObjects[plr]) ; TeamObjects[plr] = nil ; RemoveHighlight(TeamHL, plr)
end

local function ClearGunESP()
	ClearDrawings(GunObjects)
	GunObjects = {}
	if GunHL then pcall(function() GunHL:Destroy() end) ; GunHL = nil end
end

local function RenderTarget(objs, hrpPos, color, tracer_on, rect_on, name_on, dist_on, label)
	local pos, onScreen = Camera:WorldToViewportPoint(hrpPos)

	if onScreen then
		local myHRP = GetMyHRP()
		local dist = myHRP and math.floor((myHRP.Position - hrpPos).Magnitude) or 0

		local boxW = math.clamp(1800 / pos.Z, 16, 40)
		local boxH = boxW * 1.6

		local box = objs.Box
		box.Visible  = rect_on
		box.Color    = color
		box.Size     = Vector2.new(boxW, boxH)
		box.Position = Vector2.new(pos.X - boxW/2, pos.Y - boxH/2)

		local tracer = objs.Tracer
		tracer.Visible = tracer_on
		tracer.Color   = color
		tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
		tracer.To      = Vector2.new(pos.X, pos.Y)

		local text = objs.Text
		if name_on and dist_on then
			text.Text    = label .. " [m:" .. dist .. "]"
			text.Visible = true
		elseif name_on then
			text.Text    = label
			text.Visible = true
		elseif dist_on then
			text.Text    = "[m:" .. dist .. "]"
			text.Visible = true
		else
			text.Visible = false
		end
		text.Color    = color
		text.Position = Vector2.new(pos.X, pos.Y - boxH / 1.2)
	else
		objs.Box.Visible    = false
		objs.Tracer.Visible = false
		objs.Text.Visible   = false
	end
end

RunService.RenderStepped:Connect(function()
	local s = Settings

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end

		local char  = plr.Character
		local hum   = char and char:FindFirstChildOfClass("Humanoid")
		local hrp   = char and char:FindFirstChild("HumanoidRootPart")
		local alive = hum and hrp and hum.Health > 0

		if s.MURDER and alive and IsMurder(plr) then
			if not MurObjects[plr] then MurObjects[plr] = MakeDrawings() end
			RenderTarget(MurObjects[plr], hrp.Position,
				Colors.MUR.Main, s.MUR_TRACER, s.MUR_RECT, s.MUR_NAME, s.MUR_DISTANCE, plr.Name)
			if s.MUR_OUTLINE then
				SafeHighlight(MurHL, plr, char, Colors.MUR.Outline, Colors.MUR.Fill)
			else
				RemoveHighlight(MurHL, plr)
			end
		else
			ClearDrawings(MurObjects[plr]) ; MurObjects[plr] = nil
			RemoveHighlight(MurHL, plr)
		end

		if s.SHERIFF and alive and IsSheriff(plr) then
			if not ShrObjects[plr] then ShrObjects[plr] = MakeDrawings() end
			RenderTarget(ShrObjects[plr], hrp.Position,
				Colors.SHR.Main, s.SHR_TRACER, s.SHR_RECT, s.SHR_NAME, s.SHR_DISTANCE, plr.Name)
			if s.SHR_OUTLINE then
				SafeHighlight(ShrHL, plr, char, Colors.SHR.Outline, Colors.SHR.Fill)
			else
				RemoveHighlight(ShrHL, plr)
			end
		else
			ClearDrawings(ShrObjects[plr]) ; ShrObjects[plr] = nil
			RemoveHighlight(ShrHL, plr)
		end

		if s.INNOCENT and IsInnocent(plr) then
			if not InnObjects[plr] then InnObjects[plr] = MakeDrawings() end
			RenderTarget(InnObjects[plr], hrp.Position,
				Colors.INN.Main, s.INN_TRACER, s.INN_RECT, s.INN_NAME, s.INN_DISTANCE, plr.Name)
			if s.INN_OUTLINE then
				SafeHighlight(InnHL, plr, char, Colors.INN.Outline, Colors.INN.Fill)
			else
				RemoveHighlight(InnHL, plr)
			end
		else
			ClearDrawings(InnObjects[plr]) ; InnObjects[plr] = nil
			RemoveHighlight(InnHL, plr)
		end

		if s.ENEMY and IsEnemy(plr) then
			if not EneObjects[plr] then EneObjects[plr] = MakeDrawings() end
			local fill = Color3.new(
				math.min(EnemyColor.R + 0.3, 1),
				math.min(EnemyColor.G + 0.3, 1),
				math.min(EnemyColor.B + 0.3, 1)
			)
			RenderTarget(EneObjects[plr], hrp.Position,
				EnemyColor, s.ENE_TRACER, s.ENE_RECT, s.ENE_NAME, s.ENE_DISTANCE, plr.Name)
			if s.ENE_OUTLINE then
				SafeHighlight(EneHL, plr, char, EnemyColor, fill)
			else
				RemoveHighlight(EneHL, plr)
			end
		else
			ClearDrawings(EneObjects[plr]) ; EneObjects[plr] = nil
			RemoveHighlight(EneHL, plr)
		end

		if s.TEAM and IsTeammate(plr) then
			if not TeamObjects[plr] then TeamObjects[plr] = MakeDrawings() end
			local fill = Color3.new(
				math.min(TeamColor.R + 0.3, 1),
				math.min(TeamColor.G + 0.3, 1),
				math.min(TeamColor.B + 0.3, 1)
			)
			RenderTarget(TeamObjects[plr], hrp.Position,
				TeamColor, s.TEAM_TRACER, s.TEAM_RECT, s.TEAM_NAME, s.TEAM_DISTANCE, plr.Name)
			if s.TEAM_OUTLINE then
				SafeHighlight(TeamHL, plr, char, TeamColor, fill)
			else
				RemoveHighlight(TeamHL, plr)
			end
		else
			ClearDrawings(TeamObjects[plr]) ; TeamObjects[plr] = nil
			RemoveHighlight(TeamHL, plr)
		end
	end

	if s.GUN then
		local gun = FindGunDrop()
		if gun then
			if not GunObjects.Tracer then GunObjects = MakeDrawings() end
			if s.GUN_OUTLINE then
				if GunHL and (not GunHL.Parent or GunHL.Adornee ~= gun) then
					pcall(function() GunHL:Destroy() end) ; GunHL = nil
				end
				if not GunHL then
					local hl = Instance.new("Highlight")
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Adornee   = gun
					hl.Parent    = game.CoreGui
					GunHL = hl
				end
				GunHL.OutlineColor        = Colors.GUN.Outline
				GunHL.FillColor           = Colors.GUN.Fill
				GunHL.OutlineTransparency = 0
				GunHL.FillTransparency    = 0.55
			else
				if GunHL then pcall(function() GunHL:Destroy() end) ; GunHL = nil end
			end
			RenderTarget(GunObjects, gun.Position,
				Colors.GUN.Main, s.GUN_TRACER, s.GUN_RECT, s.GUN_NAME, s.GUN_DISTANCE, "GUN DROPPED!")
		else
			ClearGunESP()
		end
	else
		ClearGunESP()
	end
end)

local ESP_COIN = false
local COIN_HIT = false

local COIN_HIT_COLOR     = Color3.fromRGB(255, 215, 0)
local COIN_OUTLINE_COLOR = Color3.fromRGB(255, 165, 0)

local CoinData   = {}
local KnownCoins = {}

local DescAddedConn   = nil
local DescRemovedConn = nil

local function CreateCoinHitbox(coin)
	if CoinData[coin] then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Adornee      = coin
	box.AlwaysOnTop  = true
	box.ZIndex       = 10
	box.Size         = coin.Size + Vector3.new(0.1, 0.1, 0.1)
	box.Color3       = COIN_HIT_COLOR
	box.Transparency = 0.25
	box.Parent       = game.CoreGui

	local outline = Instance.new("SelectionBox")
	outline.Adornee             = coin
	outline.LineThickness       = 0.02
	outline.Color3              = COIN_OUTLINE_COLOR
	outline.SurfaceTransparency = 1
	outline.Parent              = game.CoreGui

	CoinData[coin] = { box = box, outline = outline }
end

local function RemoveCoinHitbox(coin)
	if CoinData[coin] then
		pcall(function() CoinData[coin].box:Destroy()     end)
		pcall(function() CoinData[coin].outline:Destroy() end)
		CoinData[coin] = nil
	end
end

local function ClearAllCoinESP()
	for coin in pairs(CoinData) do
		RemoveCoinHitbox(coin)
	end
end

local function ApplyCoinHit(state)
	if state then
		for coin in pairs(KnownCoins) do
			CreateCoinHitbox(coin)
		end
	else
		ClearAllCoinESP()
	end
end

local function RegisterCoin(v)
	if v.Name == "Coin_Server" and v:IsA("BasePart") then
		KnownCoins[v] = true
		if ESP_COIN and COIN_HIT then CreateCoinHitbox(v) end
	end
end

local function UnregisterCoin(v)
	KnownCoins[v] = nil
	RemoveCoinHitbox(v)
end

local function StartCoinTracking()
	if DescAddedConn then return end

	for _, v in ipairs(workspace:GetDescendants()) do
		RegisterCoin(v)
	end

	DescAddedConn = workspace.DescendantAdded:Connect(function(v)
		RegisterCoin(v)
	end)

	DescRemovedConn = workspace.DescendantRemoving:Connect(function(v)
		if KnownCoins[v] then
			UnregisterCoin(v)
		end
	end)
end

local function StopCoinTracking()
	if DescAddedConn   then DescAddedConn:Disconnect()   ; DescAddedConn   = nil end
	if DescRemovedConn then DescRemovedConn:Disconnect() ; DescRemovedConn = nil end
	ClearAllCoinESP()
	KnownCoins = {}
end

Players.PlayerRemoving:Connect(function(plr)
	ClearPlayer(plr)
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		RemoveHighlight(MurHL,  plr)
		RemoveHighlight(ShrHL,  plr)
		RemoveHighlight(InnHL,  plr)
		RemoveHighlight(EneHL,  plr)
		RemoveHighlight(TeamHL, plr)
	end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function()
			RemoveHighlight(MurHL,  plr)
			RemoveHighlight(ShrHL,  plr)
			RemoveHighlight(InnHL,  plr)
			RemoveHighlight(EneHL,  plr)
			RemoveHighlight(TeamHL, plr)
		end)
	end
end

local S = Settings

MainTab:CreateSection("MURDERER ESP")
MainTab:CreateToggle({ Name="ESP MURDERER", CurrentValue=false, Callback=function(v) S.MURDER=v;       Notify("ESP MURDERER "..(v and "ON" or "OFF")) end })
MainTab:CreateToggle({ Name="CHAMS",        CurrentValue=false, Callback=function(v) S.MUR_OUTLINE=v   end })
MainTab:CreateToggle({ Name="TRACER",       CurrentValue=false, Callback=function(v) S.MUR_TRACER=v    end })
MainTab:CreateToggle({ Name="RECTANGLE",    CurrentValue=false, Callback=function(v) S.MUR_RECT=v      end })
MainTab:CreateToggle({ Name="NAME",         CurrentValue=false, Callback=function(v) S.MUR_NAME=v      end })
MainTab:CreateToggle({ Name="DISTANCE",     CurrentValue=false, Callback=function(v) S.MUR_DISTANCE=v  end })

MainTab:CreateSection("SHERIFF ESP")
MainTab:CreateToggle({ Name="ESP SHERIFF",  CurrentValue=false, Callback=function(v) S.SHERIFF=v;      Notify("ESP SHERIFF "..(v and "ON" or "OFF")) end })
MainTab:CreateToggle({ Name="CHAMS",        CurrentValue=false, Callback=function(v) S.SHR_OUTLINE=v   end })
MainTab:CreateToggle({ Name="TRACER",       CurrentValue=false, Callback=function(v) S.SHR_TRACER=v    end })
MainTab:CreateToggle({ Name="RECTANGLE",    CurrentValue=false, Callback=function(v) S.SHR_RECT=v      end })
MainTab:CreateToggle({ Name="NAME",         CurrentValue=false, Callback=function(v) S.SHR_NAME=v      end })
MainTab:CreateToggle({ Name="DISTANCE",     CurrentValue=false, Callback=function(v) S.SHR_DISTANCE=v  end })

MainTab:CreateSection("INNOCENT ESP")
MainTab:CreateToggle({ Name="ESP INNOCENT", CurrentValue=false, Callback=function(v) S.INNOCENT=v;     Notify("ESP INNOCENT "..(v and "ON" or "OFF")) end })
MainTab:CreateToggle({ Name="CHAMS",        CurrentValue=false, Callback=function(v) S.INN_OUTLINE=v   end })
MainTab:CreateToggle({ Name="TRACER",       CurrentValue=false, Callback=function(v) S.INN_TRACER=v    end })
MainTab:CreateToggle({ Name="RECTANGLE",    CurrentValue=false, Callback=function(v) S.INN_RECT=v      end })
MainTab:CreateToggle({ Name="NAME",         CurrentValue=false, Callback=function(v) S.INN_NAME=v      end })
MainTab:CreateToggle({ Name="DISTANCE",     CurrentValue=false, Callback=function(v) S.INN_DISTANCE=v  end })

MainTab:CreateSection("GUN ESP")
MainTab:CreateToggle({ Name="ESP GUN",      CurrentValue=false, Callback=function(v) S.GUN=v;          Notify("ESP GUN "..(v and "ON" or "OFF")) end })
MainTab:CreateToggle({ Name="CHAMS",        CurrentValue=false, Callback=function(v) S.GUN_OUTLINE=v   end })
MainTab:CreateToggle({ Name="TRACER",       CurrentValue=false, Callback=function(v) S.GUN_TRACER=v    end })
MainTab:CreateToggle({ Name="RECTANGLE",    CurrentValue=false, Callback=function(v) S.GUN_RECT=v      end })
MainTab:CreateToggle({ Name="TEXT",         CurrentValue=false, Callback=function(v) S.GUN_NAME=v      end })
MainTab:CreateToggle({ Name="DISTANCE",     CurrentValue=false, Callback=function(v) S.GUN_DISTANCE=v  end })

MainTab:CreateSection("COIN ESP")
MainTab:CreateToggle({
	Name = "COIN ESP",
	CurrentValue = false,
	Callback = function(v)
		ESP_COIN = v
		if v then
			StartCoinTracking()
			if COIN_HIT then ApplyCoinHit(true) end
		else
			StopCoinTracking()
		end
		Notify("COIN ESP "..(v and "ON" or "OFF"))
	end
})
MainTab:CreateToggle({
	Name = "HIT (Highlight Box)",
	CurrentValue = false,
	Callback = function(v)
		COIN_HIT = v
		if ESP_COIN then ApplyCoinHit(v) end
	end
})

MainTab:CreateSection("ENEMY ESP")
MainTab:CreateToggle({ Name="ESP ENEMY",    CurrentValue=false, Callback=function(v) S.ENEMY=v;        Notify("ESP ENEMY "..(v and "ON" or "OFF")) end })
MainTab:CreateToggle({ Name="CHAMS",        CurrentValue=false, Callback=function(v) S.ENE_OUTLINE=v   end })
MainTab:CreateToggle({ Name="TRACER",       CurrentValue=false, Callback=function(v) S.ENE_TRACER=v    end })
MainTab:CreateToggle({ Name="RECTANGLE",    CurrentValue=false, Callback=function(v) S.ENE_RECT=v      end })
MainTab:CreateToggle({ Name="NAME",         CurrentValue=false, Callback=function(v) S.ENE_NAME=v      end })
MainTab:CreateToggle({ Name="DISTANCE",     CurrentValue=false, Callback=function(v) S.ENE_DISTANCE=v  end })
MainTab:CreateColorPicker({
	Name     = "ESP COLOR",
	Color    = Color3.fromRGB(255, 0, 0),
	Callback = function(color) EnemyColor = color end
})

MainTab:CreateSection("TEAM ESP")
MainTab:CreateToggle({ Name="ESP TEAM",     CurrentValue=false, Callback=function(v) S.TEAM=v;         Notify("ESP TEAM "..(v and "ON" or "OFF")) end })
MainTab:CreateToggle({ Name="CHAMS",        CurrentValue=false, Callback=function(v) S.TEAM_OUTLINE=v  end })
MainTab:CreateToggle({ Name="TRACER",       CurrentValue=false, Callback=function(v) S.TEAM_TRACER=v   end })
MainTab:CreateToggle({ Name="RECTANGLE",    CurrentValue=false, Callback=function(v) S.TEAM_RECT=v     end })
MainTab:CreateToggle({ Name="NAME",         CurrentValue=false, Callback=function(v) S.TEAM_NAME=v     end })
MainTab:CreateToggle({ Name="DISTANCE",     CurrentValue=false, Callback=function(v) S.TEAM_DISTANCE=v end })
MainTab:CreateColorPicker({
	Name     = "ESP COLOR",
	Color    = Color3.fromRGB(0, 255, 0),
	Callback = function(color) TeamColor = color end
})

MainTab:CreateSection("SETTINGS")
MainTab:CreateToggle({
	Name = "NOTIFICATION",
	CurrentValue = true,
	Callback = function(v)
		NOTIFICATIONS_ON = v
		Rayfield:Notify({
			Title    = "VONTROP",
			Content  = v and "NOTIFICATION ON" or "NOTIFICATION OFF",
			Duration = 2,
			Image    = "user"
		})
	end
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RANGE = 99999

local MainTab = Window:CreateTab("KNIFE", 4483362458)

local NOTIFICATION = true

local function Notify(text)
	if NOTIFICATION then
		Rayfield:Notify({
			Title = "VONTROP",
			Content = text,
			Duration = 2,
			Image = "user"
		})
	end
end

local function GetKnife()
	local char = LocalPlayer.Character
	if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then return tool end
	for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = char
			task.wait(0.1)
			return v
		end
	end
	return nil
end

local function CreateFloatButton(gui, text, defaultPos, callback, lockedRef, shapeRef, sizeRef)
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.Parent = gui

	local c = Instance.new("UICorner")
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = Color3.fromRGB(255, 255, 255)
	s.Thickness = 2
	s.Parent = btn

	-- Áp dụng size/shape ban đầu mà không reset vị trí
	local function applyShape(shape, size, forcePos)
		local curPos = forcePos or btn.Position
		if shape == "RECTANGLE" then
			local w, h = size * 8, size * 2
			btn.Size = UDim2.new(0, w, 0, h)
			btn.Position = curPos
			c.CornerRadius = UDim.new(0, 16)
			btn.TextSize = math.clamp(size * 0.55, 8, 60)
		elseif shape == "SQUARE" then
			local ss = size * 4
			btn.Size = UDim2.new(0, ss, 0, ss)
			btn.Position = curPos
			c.CornerRadius = UDim.new(0, 8)
			btn.TextSize = math.clamp(size * 0.4, 6, 50)
		elseif shape == "CIRCLE" then
			local ss = size * 3
			btn.Size = UDim2.new(0, ss, 0, ss)
			btn.Position = curPos
			c.CornerRadius = UDim.new(0.5, 0)
			btn.TextSize = math.clamp(size * 0.3, 5, 40)
		end
	end

	applyShape(shapeRef[1], sizeRef[1], defaultPos)

	local conns = {}

	conns[#conns+1] = btn.MouseButton1Click:Connect(callback)

	local dragging = false
	local dragStart, startPos

	conns[#conns+1] = btn.InputBegan:Connect(function(input)
		if lockedRef[1] then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = btn.Position
		end
	end)

	conns[#conns+1] = UserInputService.InputChanged:Connect(function(input)
		if not dragging or lockedRef[1] then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			btn.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	conns[#conns+1] = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return btn, c, s, conns, applyShape
end

MainTab:CreateSection("KILL EVERYONE")

local function KillEveryone()
	local knife = GetKnife()
	if not knife or not knife:FindFirstChild("Handle") then return end
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				if (myHRP.Position - hrp.Position).Magnitude <= RANGE then
					knife:Activate()
					firetouchinterest(knife.Handle, hrp, 0)
					firetouchinterest(knife.Handle, hrp, 1)
					task.wait(0.03)
				end
			end
		end
	end
end

MainTab:CreateButton({ Name = "KILL EVERYONE", Callback = KillEveryone })

local ke_FloatGui = Instance.new("ScreenGui")
ke_FloatGui.Name = "KillEveryoneFloatingGui"
ke_FloatGui.Parent = game.CoreGui
ke_FloatGui.Enabled = false

local LOCKED1 = {false}
local ke_Size = {25}
local ke_Shape = {"RECTANGLE"}
local ke_DefaultPos = UDim2.new(0.5, -100, 0.8, 0)

local ke_Btn, ke_Corner, ke_Stroke, ke_Conns, ke_ApplyShape
local ke_InvisibleOn = false

local function ke_DestroyBtn()
	if ke_Conns then
		for _, c in ipairs(ke_Conns) do c:Disconnect() end
		ke_Conns = nil
	end
	if ke_Btn then
		ke_Btn:Destroy()
		ke_Btn = nil
	end
end

local function ke_CreateBtn()
	ke_DestroyBtn()
	ke_Btn, ke_Corner, ke_Stroke, ke_Conns, ke_ApplyShape =
		CreateFloatButton(ke_FloatGui, "KILL EVERYONE", ke_DefaultPos,
			KillEveryone, LOCKED1, ke_Shape, ke_Size)
	if ke_InvisibleOn then
		ke_Btn.TextTransparency = 1
		ke_Stroke.Transparency = 1
	end
end

ke_CreateBtn()

MainTab:CreateToggle({
	Name = "FLOAT KILL EVERYONE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			ke_CreateBtn()
			ke_FloatGui.Enabled = true
			Notify("FLOAT BUTTON ENABLED")
		else
			ke_FloatGui.Enabled = false
			ke_DestroyBtn()
			Notify("FLOAT BUTTON DISABLED")
		end
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		ke_InvisibleOn = v
		if ke_Btn then
			ke_Btn.TextTransparency = v and 1 or 0
			ke_Stroke.Transparency = v and 1 or 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100}, Increment = 1, Suffix = "px", CurrentValue = 25,
	Callback = function(value)
		ke_Size[1] = value
		if ke_Btn then ke_ApplyShape(ke_Shape[1], ke_Size[1]) end
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"RECTANGLE"}, MultipleOptions = false,
	Callback = function(option)
		ke_Shape[1] = type(option) == "table" and option[1] or option
		if ke_Btn then ke_ApplyShape(ke_Shape[1], ke_Size[1]) end
		Notify("SHAPE: " .. ke_Shape[1])
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LOCKED1[1] = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

local AUTO_KILL_EVERYONE = false
MainTab:CreateToggle({
	Name = "AUTO KILL EVERYONE",
	CurrentValue = false,
	Callback = function(v)
		AUTO_KILL_EVERYONE = v
		Notify(v and "AUTO KILL EVERYONE ON" or "AUTO KILL EVERYONE OFF")
	end
})
task.spawn(function()
	while true do
		if AUTO_KILL_EVERYONE then pcall(KillEveryone) end
		task.wait(0.5)
	end
end)

MainTab:CreateSection("KILL SHERIFF / HERO")

local function GetSheriffOrHero()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if plr.Backpack:FindFirstChild("Gun")
			or (plr.Character and plr.Character:FindFirstChild("Gun")) then
				return plr
			end
		end
	end
	return nil
end

local function KillSheriffHero()
	local target = GetSheriffOrHero()
	if not target then return end
	local knife = GetKnife()
	if not knife or not knife:FindFirstChild("Handle") then return end
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local char = target.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if myHRP and hrp and hum and hum.Health > 0 then
		if (myHRP.Position - hrp.Position).Magnitude <= RANGE then
			knife:Activate()
			firetouchinterest(knife.Handle, hrp, 0)
			firetouchinterest(knife.Handle, hrp, 1)
		end
	end
end

MainTab:CreateButton({ Name = "KILL SHERIFF / HERO", Callback = KillSheriffHero })

local sh_FloatGui = Instance.new("ScreenGui")
sh_FloatGui.Name = "KillSheriffFloat"
sh_FloatGui.Parent = game.CoreGui
sh_FloatGui.Enabled = false

local LOCKED2 = {false}
local sh_Size = {25}
local sh_Shape = {"RECTANGLE"}
local sh_DefaultPos = UDim2.new(0.5, -100, 0.7, 0)

local sh_Btn, sh_Corner, sh_Stroke, sh_Conns, sh_ApplyShape
local sh_InvisibleOn = false

local function sh_DestroyBtn()
	if sh_Conns then
		for _, c in ipairs(sh_Conns) do c:Disconnect() end
		sh_Conns = nil
	end
	if sh_Btn then sh_Btn:Destroy() sh_Btn = nil end
end

local function sh_CreateBtn()
	sh_DestroyBtn()
	sh_Btn, sh_Corner, sh_Stroke, sh_Conns, sh_ApplyShape =
		CreateFloatButton(sh_FloatGui, "KILL SHERIFF / HERO", sh_DefaultPos,
			KillSheriffHero, LOCKED2, sh_Shape, sh_Size)
	if sh_InvisibleOn then
		sh_Btn.TextTransparency = 1
		sh_Stroke.Transparency = 1
	end
end

sh_CreateBtn()

MainTab:CreateToggle({
	Name = "FLOAT KILL SHERIFF/HERO BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			sh_CreateBtn()
			sh_FloatGui.Enabled = true
			Notify("FLOAT BUTTON ENABLED")
		else
			sh_FloatGui.Enabled = false
			sh_DestroyBtn()
			Notify("FLOAT BUTTON DISABLED")
		end
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		sh_InvisibleOn = v
		if sh_Btn then
			sh_Btn.TextTransparency = v and 1 or 0
			sh_Stroke.Transparency = v and 1 or 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100}, Increment = 1, Suffix = "px", CurrentValue = 25,
	Callback = function(value)
		sh_Size[1] = value
		if sh_Btn then sh_ApplyShape(sh_Shape[1], sh_Size[1]) end
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"RECTANGLE"}, MultipleOptions = false,
	Callback = function(option)
		sh_Shape[1] = type(option) == "table" and option[1] or option
		if sh_Btn then sh_ApplyShape(sh_Shape[1], sh_Size[1]) end
		Notify("SHAPE: " .. sh_Shape[1])
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LOCKED2[1] = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

local AUTO_KILL_SHERIFF = false
MainTab:CreateToggle({
	Name = "AUTO KILL SHERIFF/HERO",
	CurrentValue = false,
	Callback = function(v)
		AUTO_KILL_SHERIFF = v
		Notify(v and "AUTO KILL SHERIFF ON" or "AUTO KILL SHERIFF OFF")
	end
})
task.spawn(function()
	while true do
		if AUTO_KILL_SHERIFF then pcall(KillSheriffHero) end
		task.wait(0.5)
	end
end)

MainTab:CreateSection("KILL CLOSEST")

local function GetClosestPlayer()
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end
	local closest, shortest = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local dist = (myHRP.Position - hrp.Position).Magnitude
				if dist < shortest then
					shortest = dist
					closest = plr
				end
			end
		end
	end
	return closest
end

local function KillClosest()
	local target = GetClosestPlayer()
	if not target then return end
	local knife = GetKnife()
	if not knife or not knife:FindFirstChild("Handle") then return end
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local char = target.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if myHRP and hrp and hum and hum.Health > 0 then
		if (myHRP.Position - hrp.Position).Magnitude <= RANGE then
			knife:Activate()
			firetouchinterest(knife.Handle, hrp, 0)
			firetouchinterest(knife.Handle, hrp, 1)
		end
	end
end

MainTab:CreateButton({ Name = "KILL CLOSEST", Callback = KillClosest })

local cl_FloatGui = Instance.new("ScreenGui")
cl_FloatGui.Name = "KillClosestFloatGui"
cl_FloatGui.Parent = game.CoreGui
cl_FloatGui.Enabled = false

local LOCKED3 = {false}
local cl_Size = {25}
local cl_Shape = {"RECTANGLE"}
local cl_DefaultPos = UDim2.new(0.5, -100, 0.65, 0)

local cl_Btn, cl_Corner, cl_Stroke, cl_Conns, cl_ApplyShape
local cl_InvisibleOn = false

local function cl_DestroyBtn()
	if cl_Conns then
		for _, c in ipairs(cl_Conns) do c:Disconnect() end
		cl_Conns = nil
	end
	if cl_Btn then cl_Btn:Destroy() cl_Btn = nil end
end

local function cl_CreateBtn()
	cl_DestroyBtn()
	cl_Btn, cl_Corner, cl_Stroke, cl_Conns, cl_ApplyShape =
		CreateFloatButton(cl_FloatGui, "KILL CLOSEST", cl_DefaultPos,
			KillClosest, LOCKED3, cl_Shape, cl_Size)
	if cl_InvisibleOn then
		cl_Btn.TextTransparency = 1
		cl_Stroke.Transparency = 1
	end
end

cl_CreateBtn()

MainTab:CreateToggle({
	Name = "FLOAT KILL CLOSEST BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			cl_CreateBtn()
			cl_FloatGui.Enabled = true
			Notify("FLOAT BUTTON ENABLED")
		else
			cl_FloatGui.Enabled = false
			cl_DestroyBtn()
			Notify("FLOAT BUTTON DISABLED")
		end
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		cl_InvisibleOn = v
		if cl_Btn then
			cl_Btn.TextTransparency = v and 1 or 0
			cl_Stroke.Transparency = v and 1 or 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100}, Increment = 1, Suffix = "px", CurrentValue = 25,
	Callback = function(value)
		cl_Size[1] = value
		if cl_Btn then cl_ApplyShape(cl_Shape[1], cl_Size[1]) end
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"RECTANGLE"}, MultipleOptions = false,
	Callback = function(option)
		cl_Shape[1] = type(option) == "table" and option[1] or option
		if cl_Btn then cl_ApplyShape(cl_Shape[1], cl_Size[1]) end
		Notify("SHAPE: " .. cl_Shape[1])
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LOCKED3[1] = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

MainTab:CreateSection("SETTINGS")

MainTab:CreateToggle({
	Name = "NOTIFICATION",
	CurrentValue = true,
	Callback = function(v)
		NOTIFICATION = v
		if v then
			Notify("NOTIFICATION ON")
		else
			Rayfield:Notify({
				Title = "VONTROP",
				Content = "NOTIFICATION OFF",
				Duration = 2,
				Image = "user"
			})
		end
	end
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local MainTab = Window:CreateTab("GUN", 4483362458)
MainTab:CreateSection("SHOOT MURDERER")

local NOTIFICATION = true

local function Notify(text)
	if NOTIFICATION then
		Rayfield:Notify({
			Title = "VONTROP",
			Content = text,
			Duration = 2,
			Image = "user"
		})
	end
end

local offsetToPingMult = 1

local function findSheriff()
	for _, i in ipairs(Players:GetPlayers()) do
		if i.Backpack:FindFirstChild("Gun") or (i.Character and i.Character:FindFirstChild("Gun")) then
			return i
		end
	end
	return nil
end

local function findMurderer()
	for _, i in ipairs(Players:GetPlayers()) do
		if i ~= LocalPlayer then
			if i.Backpack:FindFirstChild("Knife") or (i.Character and i.Character:FindFirstChild("Knife")) then
				return i
			end
		end
	end
	return nil
end

local function getPredictedPosition(player, shootOffset)
	local character = player.Character
	if not character then return Vector3.new(0,0,0) end
	
	local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
	local hum = character:FindFirstChild("Humanoid")
	
	if not hrp or not hum then return Vector3.new(0,0,0) end
	
	local velocity = hrp.AssemblyLinearVelocity
	local playerMoveDirection = hum.MoveDirection
	
	local predictedPosition = hrp.Position
		+ (velocity * Vector3.new(0.75, 0.5, 0.75)) * (shootOffset / 15)
		+ playerMoveDirection * shootOffset
	
	local ping = LocalPlayer:GetNetworkPing() * 1000
	predictedPosition = predictedPosition * (((ping) * ((offsetToPingMult - 1) * 0.01)) + 1)
	
	return predictedPosition
end

local function shootMurder()
	local shootOffset = 2.8
	if findSheriff() ~= LocalPlayer then return end
	
	local murderer = findMurderer()
	if not murderer or not murderer.Character then return end
	
	if not LocalPlayer.Character:FindFirstChild("Gun") then
		local gunInBackpack = LocalPlayer.Backpack:FindFirstChild("Gun")
		if gunInBackpack then
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(gunInBackpack)
			task.wait(0.15)
		else return end
	end
	
	local predictedPos = getPredictedPosition(murderer, shootOffset)
	local rightHand = LocalPlayer.Character:FindFirstChild("RightHand") or LocalPlayer.Character:FindFirstChild("Right Arm")
	if not rightHand then return end
	
	local args = { CFrame.new(rightHand.Position), CFrame.new(predictedPos) }
	local gunTool = LocalPlayer.Character:WaitForChild("Gun")
	local shootRemote = gunTool:FindFirstChild("Shoot")
	
	if shootRemote then
		shootRemote:FireServer(unpack(args))
	end
end

MainTab:CreateButton({
	Name = "SHOOT MURDERER",
	Callback = function()
		shootMurder()
	end
})

local LOCKBUTTON = false
local currentButtonSize = 60  -- default size (1-100)
local currentShape = "SQUARE"  -- default shape

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatShootMurderer"
FloatGui.Parent = game.CoreGui
FloatGui.Enabled = false

local FloatButton = Instance.new("TextButton")
FloatButton.Position = UDim2.new(0.5, -200, 0.65, 0)
FloatButton.BackgroundTransparency = 1
FloatButton.Text = "SHOOT MURDERER"
FloatButton.Font = Enum.Font.Gotham
FloatButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FloatButton.Parent = FloatGui

local corner = Instance.new("UICorner")
corner.Parent = FloatButton

local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Parent = FloatButton

local function applyShape(shape, size)
	if shape == "RECTANGLE" then
		-- Width = size * 8, Height = size * 2
		local w = size * 8
		local h = size * 2
		FloatButton.Size = UDim2.new(0, w, 0, h)
		corner.CornerRadius = UDim.new(0, 16)
		FloatButton.TextSize = math.clamp(size * 0.55, 8, 60)

	elseif shape == "SQUARE" then
		-- Width = Height = size * 4
		local s = size * 4
		FloatButton.Size = UDim2.new(0, s, 0, s)
		corner.CornerRadius = UDim.new(0, 8)
		FloatButton.TextSize = math.clamp(size * 0.4, 6, 50)

	elseif shape == "CIRCLE" then
		-- Width = Height = size * 3, fully rounded
		local s = size * 3
		FloatButton.Size = UDim2.new(0, s, 0, s)
		corner.CornerRadius = UDim.new(0.5, 0)
		FloatButton.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

-- Apply default shape and size on load
applyShape(currentShape, currentButtonSize)

FloatButton.MouseButton1Click:Connect(function()
	shootMurder()
end)

local dragging = false
local dragStart, startPos

FloatButton.InputBegan:Connect(function(input)
	if LOCKBUTTON then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = FloatButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and not LOCKBUTTON and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		FloatButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

MainTab:CreateToggle({
	Name = "FLOAT SHOOTMURDERER BUTTON",
	CurrentValue = false,
	Callback = function(v)
		FloatGui.Enabled = v
		Notify(v and "FLOAT BUTTON ENABLE" or "FLOAT BUTTON DISABLED")
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			-- Tàng hình: ẩn hình nền, chữ, viền — nhưng vẫn click được
			FloatButton.BackgroundTransparency = 1
			FloatButton.TextTransparency = 1
			stroke.Transparency = 1
		else
			-- Hiện lại
			FloatButton.BackgroundTransparency = 1
			FloatButton.TextTransparency = 0
			stroke.Transparency = 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON UNINVISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 60,
	Callback = function(value)
		currentButtonSize = value
		applyShape(currentShape, currentButtonSize)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		if type(option) == "table" then
			currentShape = option[1]
		else
			currentShape = option
		end
		applyShape(currentShape, currentButtonSize)
		Notify("SHAPE: " .. currentShape)
	end
})

MainTab:CreateToggle({
	Name = "LOCKBUTTON",
	CurrentValue = false,
	Callback = function(v)
		LOCKBUTTON = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

local AUTO_SHOOT = false
MainTab:CreateToggle({
	Name = "AUTO SHOOTMURDERER",
	CurrentValue = false,
	Callback = function(v)
		AUTO_SHOOT = v
		Notify(v and "AUTO SHOOT ON" or "AUTO SHOOT OFF")
	end
})

task.spawn(function()
	while true do
		if AUTO_SHOOT then
			pcall(function()
				if findSheriff() == LocalPlayer then
					local murderer = findMurderer()
					if murderer and murderer.Character then
						if not LocalPlayer.Character:FindFirstChild("Gun") then
							local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
							if gun then
								LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(gun)
								task.wait(0.1)
							end
						end
						local rightHand = LocalPlayer.Character:FindFirstChild("RightHand") or LocalPlayer.Character:FindFirstChild("Right Arm")
						if rightHand then
							local predictedPos = getPredictedPosition(murderer, 2.8)
							local args = { CFrame.new(rightHand.Position), CFrame.new(predictedPos) }
							local gunTool = LocalPlayer.Character:FindFirstChild("Gun")
							if gunTool then
								local shootRemote = gunTool:FindFirstChild("Shoot")
								if shootRemote then shootRemote:FireServer(unpack(args)) end
							end
						end
					end
				end
			end)
		end
		task.wait(0.25)
	end
end)

MainTab:CreateSection("SHOOT MURDERER (UE)")

local LOCKBUTTON = false
local currentButtonSize = 60
local currentShape = "SQUARE"
local offsetToPingMult = 1

local function findSheriff()
	for _, i in ipairs(Players:GetPlayers()) do
		if i.Backpack:FindFirstChild("Gun") or (i.Character and i.Character:FindFirstChild("Gun")) then
			return i
		end
	end
	return nil
end

local function findMurderer()
	for _, i in ipairs(Players:GetPlayers()) do
		if i ~= LocalPlayer then
			if i.Backpack:FindFirstChild("Knife") or (i.Character and i.Character:FindFirstChild("Knife")) then
				return i
			end
		end
	end
	return nil
end

local function getPredictedPosition(player, shootOffset)
	local character = player.Character
	if not character then return Vector3.new(0,0,0) end
	
	local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
	local hum = character:FindFirstChild("Humanoid")
	if not hrp or not hum then return Vector3.new(0,0,0) end
	
	local velocity = hrp.AssemblyLinearVelocity
	local moveDir = hum.MoveDirection
	
	local predicted = hrp.Position
		+ (velocity * Vector3.new(0.75,0.5,0.75)) * (shootOffset / 15)
		+ moveDir * shootOffset
	
	local ping = LocalPlayer:GetNetworkPing() * 1000
	predicted = predicted * (((ping) * ((offsetToPingMult - 1) * 0.01)) + 1)
	
	return predicted
end

local function shootMurder()

	local shootOffset = 2.8
	
	if findSheriff() ~= LocalPlayer then return end
	
	local murderer = findMurderer()
	if not murderer or not murderer.Character then return end
	
	local char = LocalPlayer.Character
	if not char then return end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	
	if not char:FindFirstChild("Gun") then
		local gunInBackpack = LocalPlayer.Backpack:FindFirstChild("Gun")
		if gunInBackpack then
			hum:EquipTool(gunInBackpack)
			task.wait(0.12)
		else
			return
		end
	end
	
	local predictedPos = getPredictedPosition(murderer, shootOffset)
	
	local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	if not rightHand then return end
	
	local gunTool = char:FindFirstChild("Gun")
	if not gunTool then return end
	
	local shootRemote = gunTool:FindFirstChild("Shoot")
	if not shootRemote then return end
	
	shootRemote:FireServer(
		CFrame.new(rightHand.Position),
		CFrame.new(predictedPos)
	)
	
	task.wait(0.05)
	hum:UnequipTools()

end

MainTab:CreateButton({
	Name = "SHOOT MURDERER (UE)",
	Callback = shootMurder
})

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatShootMurderer"
FloatGui.ResetOnSpawn = false
FloatGui.Parent = game.CoreGui
FloatGui.Enabled = false

local ButtonFrame = Instance.new("Frame")
ButtonFrame.Size = UDim2.new(0,400,0,100)
ButtonFrame.Position = UDim2.new(0.5,-200,0.65,0)
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Active = true
ButtonFrame.Parent = FloatGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,16)
frameCorner.Parent = ButtonFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Color = Color3.fromRGB(255,255,255)
frameStroke.Thickness = 2
frameStroke.Parent = ButtonFrame

local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(1,0,1,0)
FloatButton.BackgroundTransparency = 1
FloatButton.Text = "SHOOT MURDERER"
FloatButton.Font = Enum.Font.Gotham
FloatButton.TextSize = 28
FloatButton.TextColor3 = Color3.fromRGB(0,0,0)
FloatButton.Active = false
FloatButton.Parent = ButtonFrame

FloatButton.MouseButton1Click:Connect(shootMurder)

local function applyShape(shape, size)
	if shape == "RECTANGLE" then
		local w = size * 8
		local h = size * 2
		ButtonFrame.Size = UDim2.new(0, w, 0, h)
		frameCorner.CornerRadius = UDim.new(0, 16)
		FloatButton.TextSize = math.clamp(size * 0.55, 8, 60)
	elseif shape == "SQUARE" then
		local s = size * 4
		ButtonFrame.Size = UDim2.new(0, s, 0, s)
		frameCorner.CornerRadius = UDim.new(0, 8)
		FloatButton.TextSize = math.clamp(size * 0.4, 6, 50)
	elseif shape == "CIRCLE" then
		local s = size * 3
		ButtonFrame.Size = UDim2.new(0, s, 0, s)
		frameCorner.CornerRadius = UDim.new(0.5, 0)
		FloatButton.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

applyShape(currentShape, currentButtonSize)
local dragStart, startPos

ButtonFrame.InputBegan:Connect(function(input)
	if LOCKBUTTON then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = ButtonFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and not LOCKBUTTON and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		
		local delta = input.Position - dragStart
		
		ButtonFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

MainTab:CreateToggle({
	Name = "FLOAT SHOOTMURDERER (UE) BUTTON",
	CurrentValue = false,
	Callback = function(v)
		FloatGui.Enabled = v
		Notify(v and "FLOAT BUTTON ON" or "FLOAT BUTTON OFF")
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			FloatButton.TextTransparency = 1
			frameStroke.Transparency = 1
		else
			FloatButton.TextTransparency = 0
			frameStroke.Transparency = 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON UNINVISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 60,
	Callback = function(value)
		currentButtonSize = value
		applyShape(currentShape, currentButtonSize)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		if type(option) == "table" then
			currentShape = option[1]
		else
			currentShape = option
		end
		applyShape(currentShape, currentButtonSize)
		Notify("SHAPE: " .. currentShape)
	end
})

MainTab:CreateToggle({
	Name = "LOCKBUTTON",
	CurrentValue = false,
	Callback = function(v)
		LOCKBUTTON = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

local AUTO_SHOOT = false

task.spawn(function()
	while true do
		
		if AUTO_SHOOT then
			
			pcall(function()
				
				if findSheriff() ~= LocalPlayer then return end
				
				local murderer = findMurderer()
				if not murderer or not murderer.Character then return end
				
				local char = LocalPlayer.Character
				if not char then return end
				
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum then return end
				
				if not char:FindFirstChild("Gun") then
					local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
					if gun then
						hum:EquipTool(gun)
						task.wait(0.12)
					else
						return
					end
				end
				
				local predictedPos = getPredictedPosition(murderer,2.8)
				
				local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
				if not rightHand then return end
				
				local gunTool = char:FindFirstChild("Gun")
				if not gunTool then return end
				
				local shootRemote = gunTool:FindFirstChild("Shoot")
				if not shootRemote then return end
				
				shootRemote:FireServer(
					CFrame.new(rightHand.Position),
					CFrame.new(predictedPos)
				)
				
			end)
			
		end
		
		task.wait(0.25)
		
	end
end)

MainTab:CreateToggle({
	Name = "AUTO SHOOTMURDERER (UE)",
	CurrentValue = false,
	Callback = function(v)
		AUTO_SHOOT = v
		Notify(v and "AUTO SHOOT ON" or "AUTO SHOOT OFF")
	end
})

local GrabGunRunning = false
local LOCKED_GRAB = false
local grabCurrentSize = 18
local grabCurrentShape = "SQUARE"

MainTab:CreateSection("GRAB GUN")

local function FindDroppedGun()
	local gunDrop = workspace:FindFirstChild("GunDrop", true)
	if gunDrop then
		return gunDrop:IsA("BasePart") and gunDrop or gunDrop:FindFirstChild("Handle") or gunDrop:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function GrabGun()
	if GrabGunRunning then return end
	GrabGunRunning = true
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then GrabGunRunning = false return end
	local gunPart = FindDroppedGun()
	if not gunPart then GrabGunRunning = false return end
	local oldCFrame = hrp.CFrame
	hrp.CFrame = gunPart.CFrame * CFrame.new(0, 0, -1)
	task.wait(0.12)
	hrp.CFrame = oldCFrame
	GrabGunRunning = false
end

MainTab:CreateButton({
	Name = "GRAB GUN",
	Callback = GrabGun
})

local GrabGui = Instance.new("ScreenGui")
GrabGui.Name = "FloatGrabGunGui"
GrabGui.Parent = game.CoreGui
GrabGui.Enabled = false

local GrabBtn = Instance.new("TextButton")
GrabBtn.Position = UDim2.new(0.5, -100, 0.65, 0)
GrabBtn.Text = "GRAB GUN"
GrabBtn.Font = Enum.Font.Gotham
GrabBtn.TextColor3 = Color3.fromRGB(0,0,0)
GrabBtn.BackgroundTransparency = 1
GrabBtn.Parent = GrabGui

local cornerGrab = Instance.new("UICorner")
cornerGrab.Parent = GrabBtn

local strokeGrab = Instance.new("UIStroke")
strokeGrab.Parent = GrabBtn
strokeGrab.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeGrab.Color = Color3.fromRGB(255,255,255)
strokeGrab.Thickness = 2

-- ==================== SHAPE & SIZE FUNCTIONS ====================

local function applyGrabShape(shape, size)
	if shape == "RECTANGLE" then
		local w = size * 8
		local h = size * 2
		GrabBtn.Size = UDim2.new(0, w, 0, h)
		cornerGrab.CornerRadius = UDim.new(0, 16)
		GrabBtn.TextSize = math.clamp(size * 0.55, 8, 60)
	elseif shape == "SQUARE" then
		local s = size * 4
		GrabBtn.Size = UDim2.new(0, s, 0, s)
		cornerGrab.CornerRadius = UDim.new(0, 8)
		GrabBtn.TextSize = math.clamp(size * 0.4, 6, 50)
	elseif shape == "CIRCLE" then
		local s = size * 3
		GrabBtn.Size = UDim2.new(0, s, 0, s)
		cornerGrab.CornerRadius = UDim.new(0.5, 0)
		GrabBtn.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

applyGrabShape(grabCurrentShape, grabCurrentSize)

-- ==================== CLICK ====================

GrabBtn.MouseButton1Click:Connect(function() GrabGun() end)

-- ==================== DRAG ====================

local draggingGrab = false
local dragStartGrab, startPosGrab

GrabBtn.InputBegan:Connect(function(input)
	if LOCKED_GRAB then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingGrab = true
		dragStartGrab = input.Position
		startPosGrab = GrabBtn.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingGrab and not LOCKED_GRAB and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartGrab
		GrabBtn.Position = UDim2.new(startPosGrab.X.Scale, startPosGrab.X.Offset + delta.X, startPosGrab.Y.Scale, startPosGrab.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingGrab = false
	end
end)

-- ==================== RAYFIELD UI ====================

MainTab:CreateToggle({
	Name = "FLOAT GRAB GUN BUTTON",
	CurrentValue = false,
	Callback = function(v)
		GrabGui.Enabled = v
		Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
	end
})

MainTab:CreateSection("BUTTON SETTINGS")

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			GrabBtn.TextTransparency = 1
			strokeGrab.Transparency = 1
		else
			GrabBtn.TextTransparency = 0
			strokeGrab.Transparency = 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 18,
	Callback = function(value)
		grabCurrentSize = value
		applyGrabShape(grabCurrentShape, grabCurrentSize)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		if type(option) == "table" then
			grabCurrentShape = option[1]
		else
			grabCurrentShape = option
		end
		applyGrabShape(grabCurrentShape, grabCurrentSize)
		Notify("SHAPE: " .. grabCurrentShape)
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LOCKED_GRAB = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

-- ==================== AUTO GRAB ====================

local AUTO_GRAB_GUN = false
task.spawn(function()
	while true do
		if AUTO_GRAB_GUN then
			pcall(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				local gunPart = FindDroppedGun()
				if not gunPart then return end
				local oldCFrame = hrp.CFrame
				hrp.CFrame = gunPart.CFrame * CFrame.new(0,0,-1)
				task.wait(0.12)
				hrp.CFrame = oldCFrame
			end)
		end
		task.wait(0.35)
	end
end)

MainTab:CreateToggle({
	Name = "AUTO GRAB GUN",
	CurrentValue = false,
	Callback = function(v)
		AUTO_GRAB_GUN = v
		Notify(v and "AUTO GRAB ENABLED" or "AUTO GRAB DISABLED")
	end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local LockFlingBtn = false
local flingCurrentSize = 18
local flingCurrentShape = "SQUARE"

local function Notify(text)
	if NOTIFICATION then
		Rayfield:Notify({
			Title = "VONTROP",
			Content = text,
			Duration = 2,
			Image = "user"
		})
	end
end

local function FindSheriff()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			if p.Backpack:FindFirstChild("Gun")
			or (p.Character and p.Character:FindFirstChild("Gun")) then
				return p
			end
		end
	end
	return nil
end

local function StrongFlingPlayer(TargetPlayer)

	if not TargetPlayer or TargetPlayer == LocalPlayer then return end
	if not TargetPlayer.Character or not LocalPlayer.Character then return end

	local Character = LocalPlayer.Character
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	local TRootPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not RootPart or not TRootPart then return end

	local OldCFrame = RootPart.CFrame

	local BV = Instance.new("BodyVelocity")
	BV.MaxForce = Vector3.new(9e9,9e9,9e9)
	BV.Velocity = Vector3.new(99999,99999,99999)
	BV.P = 9e9
	BV.Parent = RootPart

	local BG = Instance.new("BodyAngularVelocity")
	BG.MaxTorque = Vector3.new(9e9,9e9,9e9)
	BG.AngularVelocity = Vector3.new(99999,99999,99999)
	BG.P = 9e9
	BG.Parent = RootPart

	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	Humanoid.AutoRotate = false

	local start = tick()

	repeat

		if not TRootPart.Parent then break end

		RootPart.CFrame =
			TRootPart.CFrame *
			CFrame.new(0,-1.5,0) *
			CFrame.Angles(
				math.rad(math.random(-360,360)),
				math.rad(math.random(-360,360)),
				math.rad(math.random(-360,360))
			)

		RunService.Heartbeat:Wait()

	until
		TRootPart.AssemblyLinearVelocity.Magnitude > 300
		or tick() - start > 2
		or Humanoid.Health <= 0

	BV:Destroy()
	BG:Destroy()

	RootPart.AssemblyLinearVelocity = Vector3.zero
	RootPart.AssemblyAngularVelocity = Vector3.zero

	RootPart.CFrame = OldCFrame

	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.1)
	Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	Humanoid.AutoRotate = true

	workspace.CurrentCamera.CameraSubject = Humanoid
end


MainTab:CreateSection("STEAL GUN")

MainTab:CreateButton({
	Name = "STEAL GUN",
	Callback = function()
		local sheriff = FindSheriff()
		if sheriff then
			StrongFlingPlayer(sheriff)
		end
	end
})

local FlingGui = Instance.new("ScreenGui")
FlingGui.Name = "StealGunFloatingGui"
FlingGui.Parent = game.CoreGui
FlingGui.Enabled = false
FlingGui.ResetOnSpawn = false

local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(0, 200, 0, 50)
FlingBtn.Position = UDim2.new(0.5, -100, 0.6, 0)
FlingBtn.BackgroundTransparency = 1
FlingBtn.Text = "STEAL GUN"
FlingBtn.Font = Enum.Font.Gotham
FlingBtn.TextSize = 18
FlingBtn.TextColor3 = Color3.fromRGB(0,0,0)
FlingBtn.TextStrokeTransparency = 0.8
FlingBtn.Parent = FlingGui

local flingCorner = Instance.new("UICorner", FlingBtn)
flingCorner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Thickness = 2
stroke.Parent = FlingBtn

-- ==================== SHAPE & SIZE FUNCTIONS ====================

local function applyFlingShape(shape, size)
	if shape == "RECTANGLE" then
		local w = size * 8
		local h = size * 2
		FlingBtn.Size = UDim2.new(0, w, 0, h)
		flingCorner.CornerRadius = UDim.new(0, 16)
		FlingBtn.TextSize = math.clamp(size * 0.55, 8, 60)
	elseif shape == "SQUARE" then
		local s = size * 4
		FlingBtn.Size = UDim2.new(0, s, 0, s)
		flingCorner.CornerRadius = UDim.new(0, 8)
		FlingBtn.TextSize = math.clamp(size * 0.4, 6, 50)
	elseif shape == "CIRCLE" then
		local s = size * 3
		FlingBtn.Size = UDim2.new(0, s, 0, s)
		flingCorner.CornerRadius = UDim.new(0.5, 0)
		FlingBtn.TextSize = math.clamp(size * 0.3, 5, 40)
	end
end

applyFlingShape(flingCurrentShape, flingCurrentSize)

FlingBtn.MouseButton1Click:Connect(function()

	local sheriff = FindSheriff()

	if sheriff then
		StrongFlingPlayer(sheriff)
	end

end)

local dragging = false
local dragStart, startPos

FlingBtn.InputBegan:Connect(function(input)

	if LockFlingBtn then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = FlingBtn.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if LockFlingBtn then return end

	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		local delta = input.Position - dragStart

		FlingBtn.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false

	end

end)

MainTab:CreateToggle({
	Name = "FLOAT STEAL GUN BUTTON",
	CurrentValue = false,
	Callback = function(v)
		FlingGui.Enabled = v
		Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
	end
})

MainTab:CreateToggle({
	Name = "INVISIBLE BUTTON",
	CurrentValue = false,
	Callback = function(v)
		if v then
			FlingBtn.TextTransparency = 1
			stroke.Transparency = 1
		else
			FlingBtn.TextTransparency = 0
			stroke.Transparency = 0
		end
		Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
	end
})

MainTab:CreateSlider({
	Name = "BUTTON SIZE",
	Range = {1, 100},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 18,
	Callback = function(value)
		flingCurrentSize = value
		applyFlingShape(flingCurrentShape, flingCurrentSize)
	end
})

MainTab:CreateDropdown({
	Name = "BUTTON SHAPE",
	Options = {"RECTANGLE", "CIRCLE", "SQUARE"},
	CurrentOption = {"SQUARE"},
	MultipleOptions = false,
	Callback = function(option)
		if type(option) == "table" then
			flingCurrentShape = option[1]
		else
			flingCurrentShape = option
		end
		applyFlingShape(flingCurrentShape, flingCurrentSize)
		Notify("SHAPE: " .. flingCurrentShape)
	end
})

MainTab:CreateToggle({
	Name = "LOCK BUTTON",
	CurrentValue = false,
	Callback = function(v)
		LockFlingBtn = v
		Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
	end
})

local AUTO_STEAL_GUN = false

MainTab:CreateToggle({
	Name = "AUTO STEAL GUN",
	CurrentValue = false,
	Callback = function(v)
		AUTO_STEAL_GUN = v
		Notify(v and "AUTO STEAL GUN ENABLED" or "AUTO STEAL GUN DISABLED")
	end
})

task.spawn(function()
	while true do
		if AUTO_STEAL_GUN then
			pcall(function()
				local sheriff = FindSheriff()
				if sheriff then
					StrongFlingPlayer(sheriff)
				end
			end)
		end
		task.wait(1)
	end
end)

MainTab:CreateSection("SETTINGS")

MainTab:CreateToggle({
	Name = "NOTIFICATION",
	CurrentValue = true,
	Callback = function(v)
		if v then
			NOTIFICATION = true
			Notify("NOTIFICATION ON")
		else
			Notify("NOTIFICATION OFF")
			NOTIFICATION = false
		end
	end
})




