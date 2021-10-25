local TerrainGeneration = {}--require(game:GetService("ReplicatedStorage").Yuno).setup:GetEnv()
TerrainGeneration.__index = TerrainGeneration

local Simplex = require(script.Simplex)

--> Variables
local PGTFolder = Instance.new("Folder", workspace)
PGTFolder.Name = 'PGT'

--> Redefines
local noise = math.noise

--> @TODO: populate rhe generation
--> @TODO: useful method ( :GetTrees(), ..., :Clear(), )s
--> @TODO: regions
--> @TODO: water level

local function Create(Position: Vector3, Size: Vector3): (BasePart)
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.Size = Size or Vector3.new(1, 1, 1)
	Part.Position = Position
	Part.Parent = PGTFolder

	return Part
end

function TerrainGeneration.new(Properties): ({any: any})
	Properties.Table = {}
	return setmetatable(Properties, TerrainGeneration)
end

function TerrainGeneration:Generate()

	--> Actual terrain
	for x = 1, self.Size.X do
		self.Table[x] = {}
		for y = 1, self.Size.Y do
			local Alpha = self:_FBM(x, y) * 10
			if self.LowestPoint == nil or Alpha < self.LowestPoint then self.LowestPoint = Alpha
			elseif self.HighestPoint == nil or Alpha > self.HighestPoint then self.HighestPoint = Alpha end

			self.Table[x][y] = Vector3.new(x*self.Spacing, Alpha, y*self.Spacing)
		end
	end

	return self
end

function TerrainGeneration:_FBM(x, y): Vector3
	local xs = x / self.TerrainDescription.Scale;
	local ys = y / self.TerrainDescription.Scale
	local G = 2.0 ^ (-self.TerrainDescription.Persistence)
	local amplitude = 1.0;
	local frequency = 1.0;
	local normalization = 0;
	local total = 0;
	local noise = self.NoiseFunc

	for o = 1, self.TerrainDescription.Octaves do
		local noiseValue = noise:Get2DValue(xs * frequency, ys * frequency) * 0.5 + 0.5;
		total += noiseValue * amplitude;
		normalization += amplitude;
		amplitude *= G;
		frequency *= self.TerrainDescription.Lacunarity;
	end

	total /= normalization;
	return math.pow(total, self.TerrainDescription.Exp) * self.TerrainDescription.Height;
end

function TerrainGeneration:GetPoints()
	return self.Table
end

function TerrainGeneration:GetLowestPoint()
	return self.LowestPoint
end

function TerrainGeneration:GetHighestPoint()
	return self.HighestPoint
end

function TerrainGeneration:Draw(Size)
	for X, YT in pairs(self.Table) do
		for Y, v in pairs(YT) do
			Create(v, Size)
		end
	end
end

function TerrainGeneration:Destroy()
	local Space = Vector3.new(self.Size.X*self.Spacing, self.WaterLevel, self.Size.Y * self.Spacing)
	workspace.Terrain:FillBlock(CFrame.new(self.Size.X*self.Spacing/2, self.LowestPoint, self.Size.Y*self.Spacing/2), Space, Enum.Material.Air)
end

function TerrainGeneration:GetProperties(Seed)
	return {
		Size = Vector3.new(500, 500, 0),
		Position = Vector3.new(),
		Spacing = 7.5,
		NoiseFunc = Simplex(Seed):Init(),
		WaterLevel = 10,
		TerrainDescription = {
			Octaves = 3,
			Scale = 56,
			Lacunarity = 2,
			Exp = 3.7,
			Persistence = 0.5,
			Height = 23,
		},
	}
end


return TerrainGeneration
