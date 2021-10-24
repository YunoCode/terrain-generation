local TerrainGeneration = {}
TerrainGeneration.__index = TerrainGeneration

local Simplex = require(script.Simplex)

--> Variables
local PGTFolder = Instance.new("Folder", workspace)
PGTFolder.Name = 'PGT'

--> Redefines
local noise = math.noise

--> @TODO: populate rhe generation
--> @TODO: useful method ( :GetTrees(), ..., :Clear(), )

local function Create(Position: Vector3, Size: Vector3): (BasePart)
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.Size = Size or Vector3.new(7.5, 7.5, 7.5)
	Part.Position = Position
	Part.Parent = PGTFolder

	return Part
end

function TerrainGeneration.new(Properties): ({any: any})
	return setmetatable(Properties, TerrainGeneration)
end

function TerrainGeneration:Generate()
	local GridSize = 7.5
	local HillGrid = GridSize * 1.7

	local Freq = 0.05
	local Amp = 160
	local Total = 0

	for y = 1, self.Size.Y do
		for x = 1, self.Size.X do
			local Alpha = self:FBM(x, y) * 10
			Create(Vector3.new(x*7.5, Alpha, y*7.5))
		end
	end

	return self
end

function TerrainGeneration:FBM(x, y): Vector3
	local xs = x / self.Scale;
	local ys = y / self.Scale
	local G = 2.0 ^ (-self.Persistence)
	local amplitude = 1.0;
	local frequency = 1.0;
	local normalization = 0;
	local total = 0;
	local noise = self.NoiseFunc
	for o = 1, self.Octaves do
		local noiseValue = noise:Get2DValue(
			xs * frequency, ys * frequency) * 0.5 + 0.5;
		total += noiseValue * amplitude;
		normalization += amplitude;
		amplitude *= G;
		frequency *= self.Lacunarity;
	end
	total /= normalization;
	return math.pow(
		total, self.Exp) * self.Height;
end


function TerrainGeneration:GetProperties()
	return {
		Size = Vector3.new(100, 100, 0),
		Position = Vector3.new(),
		NoiseFunc = Simplex():Init(),
		Octaves = 3,
		Scale = 56,
		Lacunarity = 2,
		Exp = 3.7,
		Persistence = 0.5,
		Height = 23
	}
end


return TerrainGeneration