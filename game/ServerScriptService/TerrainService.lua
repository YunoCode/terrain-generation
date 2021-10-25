local Debris = game:GetService("Debris")
local TerrainService = {}

local TG = require(script.Parent.TerrainGeneration)
local PolygonConnector = require(script.Parent.PolygonConnector)

function TerrainService:Init()
	local NewTerrain = TG.new(TG:GetProperties()):Generate()
	--NewTerrain:Draw()
	
	local diagram = NewTerrain:GetPoints()
	local pc = PolygonConnector.new('d', diagram, {
		Material = Enum.Material.Grass,
		Color = Color3.fromRGB(28, 92, 28)
	})
	local tris = pc:ConnectPoints()
	for i, v in pairs(tris) do
		local avg = v.Position.Y - NewTerrain:GetLowestPoint()

		if avg <= 6 then
			game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Sand)
		elseif avg <= 30 then
			game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Grass)
		elseif avg <= 60 then
			game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Rock)
		else
			game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Snow)
		end
	end
end

return TerrainService
