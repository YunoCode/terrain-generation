local TerrainService = {}

local TG = require(script.Parent.TerrainGeneration)

function TerrainService:Init()
	local NewTerrain = TG.new(TG:GetProperties()):Generate()
end

return TerrainService
