--Connected Discord-GitHub
--Roblox: @RehizVI | Discord: @Kod4e
---// Services //---
local runService = game:GetService("RunService")
local collectionService = game:GetService("CollectionService")
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

---// OBJECT VARIABLES //---
local events = replicatedStorage.events
local visulaizerFolder = workspace.VisualizerFolder

---// Events //---
local updateHRPOrigin = events.updateHRPOrigin
local connectHRPtoPythag = events.connectHRPtoPythag

---// Variables //---
local pointTag = "point"
local pointData = {} :: {
	[BasePart] : {
		Part : BasePart,
		Origin : Vector3,
		X : BasePart, 
		Y : BasePart, 
		Z : BasePart,
		Diagonal : BasePart,
	}
}

local config = {
	minX = -100,
	maxX = 100,
	
	minY = -50,
	maxY = 50,
	
	minZ = -100,
	maxZ = 100,
	
	minTime = 1,
	maxTime = 8
}

local worldOrigin = Vector3.new(0, 40, 0)

local easingStylesSupported = {
	Enum.EasingStyle.Linear,
	Enum.EasingStyle.Sine,
	Enum.EasingStyle.Back,
	Enum.EasingStyle.Bounce,
	Enum.EasingStyle.Elastic,
	Enum.EasingStyle.Quint,
	Enum.EasingStyle.Quart,
	Enum.EasingStyle.Cubic,
	Enum.EasingStyle.Quad,
}

---// Functions //---

--creation

local function createVisualBase() : BasePart
	local Part = Instance.new("Part")
	Part.Name = "visualBase"
	Part.Material = Enum.Material.Neon
	Part.Size = Vector3.new(0.20, 0.20, 0.20) --axis stretching to gets size dif
	Part.Anchored = true
	Part.CanCollide = false
	Part.Parent = visulaizerFolder
	
	return Part :: BasePart
end
local function createXYZDiagonal()
	local X = createVisualBase()
	X.Name = "X"
	X.Color = Color3.fromRGB(255, 0, 0)
	
	local Y = createVisualBase()
	Y.Name = "Y"
	Y.Color = Color3.fromRGB(0, 255, 0)
	
	local Z = createVisualBase()
	Z.Name = "Z"
	Z.Color = Color3.fromRGB(16, 42, 220)
	
	local Diagonal = createVisualBase()
	Diagonal.Name = "Diagonal"
	Diagonal.Color = Color3.fromRGB(213, 115, 61)
	
	return X, Y, Z, Diagonal
end

--helper

local function getRandomPosition() : Vector3
	local x = math.random(config.minX, config.maxX)
	local y = math.random(config.minY, config.maxY)
	local z = math.random(config.minZ, config.maxZ)
	
	return Vector3.new(x, y, z)
end

--tween stuff

local function pickRandomEasingStyle() : Enum.EasingStyle
	local index = math.random(1, #easingStylesSupported)
	
	return easingStylesSupported[index]
end

local function createRepeatingRandomSlideTween(part:BasePart, position:Vector3)
	local tweenInfo = TweenInfo.new(
		math.random(config.minTime, config.maxTime), 
		pickRandomEasingStyle(), 
		Enum.EasingDirection.InOut,
		0, 
		false
	)
	
	local tween = tweenService:Create(part, tweenInfo, position)
	tween:Play()
	
	tween.Completed:Once(function()
		createRepeatingRandomSlideTween(part, {Position = getRandomPosition()})
	end)
end

--setup

local function setupTagged(tagged:BasePart, wantTween:boolean, origin:Vector3?)
	local Xpart, Ypart, Zpart, Diagonal = createXYZDiagonal()
	pointData[tagged] = {
		Part = tagged,
		Origin = worldOrigin,
		X = Xpart, 
		Y = Ypart, 
		Z = Zpart,
		Diagonal = Diagonal,
	}
	
	if origin then
		pointData[tagged].Origin = origin --for customization purposes
	end
	
	--optional cuz u could connect it to a player's humanoidRootPart
	if wantTween then
		createRepeatingRandomSlideTween(tagged, {Position = getRandomPosition()})
	end
end

--runtime related

local function init()
	--parts n stuff should tween to be showcased
	for _, point in collectionService:GetTagged(pointTag) do
		setupTagged(point, true)
	end
end

local function updateTaggedVisualizers(lookup)
	local part = lookup.Part --if char leaves or smth
	if not part.Parent then return end
	
	local X = lookup.X
	local Y = lookup.Y
	local Z = lookup.Z
	local Diagonal = lookup.Diagonal
	local origin = lookup.Origin
	
	local taggedPos = part.Position
	
	--if a size goes below 0 it doesnt work right
	local Xsize = math.abs(taggedPos.X - origin.X)
	local Ysize = math.abs(taggedPos.Y - origin.Y)
	local Zsize = math.abs(taggedPos.Z - origin.Z)
	
	--3d pythagorean theorem, whole point of this script
	local DiagonalSize = math.sqrt(Xsize^2 + Ysize^2 + Zsize^2)
	
	local Xpos = Vector3.new((taggedPos.X + origin.X) / 2, origin.Y, origin.Z)
	local Ypos = Vector3.new(origin.X, (taggedPos.Y + origin.Y) / 2, origin.Z)
	local Zpos = Vector3.new(origin.X, origin.Y, (taggedPos.Z + origin.Z) / 2)
	local DiagonalPos = Vector3.new(
		(taggedPos.X + origin.X) / 2, 
		(taggedPos.Y + origin.Y) / 2, 
		(taggedPos.Z + origin.Z) / 2
	)
	
	X.Size = Vector3.new(Xsize, 0.20, 0.20)
	Y.Size = Vector3.new(0.20, Ysize, 0.20)
	Z.Size = Vector3.new(0.20, 0.20, Zsize)
	Diagonal.Size = Vector3.new(0.30, DiagonalSize, 0.30)
	
	X.Position = Xpos
	Y.Position = Ypos
	Z.Position = Zpos
	
	Diagonal.CFrame = CFrame.lookAt(
		DiagonalPos, taggedPos
	) * CFrame.Angles(math.rad(90),0,0) --so -z axis faces the point (weird roblox thingy)
end

local function update()
	for _, taggedInfo in pointData do
		updateTaggedVisualizers(taggedInfo)
	end
end

---// Main //---
init()
runService.Heartbeat:Connect(update)

connectHRPtoPythag.OnServerEvent:Connect(function(player:Player)
	if not player.Character then return end
	
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local lookup = pointData[hrp]
	if lookup then return end --dont waste time setting up again if exist
	
	setupTagged(hrp, false)
end)

updateHRPOrigin.OnServerEvent:Connect(function(player:Player)
	if not player.Character then return end
	
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local lookup = pointData[hrp]
	if not lookup then return end --cant update origin if it doesnt exist
	
	pointData[hrp].Origin = hrp.Position
end)

players.PlayerRemoving:Connect(function(player)
	if not player.Character then return end
	
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local data = pointData[hrp]
	if not data then return end
	
	data.X:Destroy()
	data.Y:Destroy()
	data.Z:Destroy()
	data.Diagonal:Destroy()

	pointData[hrp] = nil
end)
