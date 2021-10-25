local Debris = game:GetService("Debris")
local TerrainService = {}

local TG = require(script.Parent.TerrainGeneration)
local PolygonConnector = require(script.Parent.PolygonConnector)

--> @IDEA: live change

local octaves, scale, lac, exp, pers, height
local NewTerrain

function TerrainService:Init()

-- 	while true do
-- 	local Coctaves, Cscale, Clac, Cexp, Cpers, Cheight, s = unpack(game.ReplicatedStorage.RemoteFunction:InvokeClient(game.Players:WaitForChild("ProxyBuild")))
-- 	local prop = TG:GetProperties(s)
-- 	if Coctaves == octaves and Cscale == scale and Clac == lac and Cexp == exp and Cpers == pers and Cheight == height then
-- 		task.wait(1)
-- 		continue
-- 	else
-- 		if NewTerrain then
-- 			NewTerrain:Destroy()
-- 			local Space = Vector3.new(prop.Size.X*prop.Spacing+10, math.abs(NewTerrain:GetHighestPoint() - NewTerrain:GetLowestPoint())+10, prop.Size.Y * prop.Spacing+10)
-- 			workspace.Terrain:FillBlock(CFrame.new(prop.Size.X*prop.Spacing/2, math.abs(NewTerrain:GetHighestPoint() - NewTerrain:GetLowestPoint())/2, prop.Size.Y*prop.Spacing/2), Space, Enum.Material.Air)
-- 		end
-- 	end

-- 	octaves, scale, lac, exp, pers, height = Coctaves, Cscale, Clac, Cexp, Cpers, Cheight

-- 	prop.TerrainDescription.Octaves = Coctaves
-- 	prop.TerrainDescription.Scale = Cscale
-- 	prop.TerrainDescription.Lacunarity = Clac
-- 	prop.TerrainDescription.Exp = Cexp
-- 	prop.TerrainDescription.Persistence = Cpers
-- 	prop.TerrainDescription.Height = Cheight

-- 	NewTerrain = TG.new(prop):Generate()
-- 	local diagram = NewTerrain:GetPoints()
-- 	local pc = PolygonConnector.new('d', diagram)
-- 	local tris = pc:ConnectPoints()
-- 	for i, v in pairs(tris) do
-- 		task.wait()
-- 		for i, v in pairs(v) do
-- 			local avg = math.abs(v.CFrame.Position.Y - NewTerrain:GetLowestPoint())
-- 			if avg <= 6 then
-- 				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Sand)
-- 			elseif avg <= 30 then
-- 				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Grass)
-- 			elseif avg <= 60 then
-- 				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Rock)
-- 			else
-- 				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Snow)
-- 			end
-- 		end
-- 	end
-- end

	local prop = TG:GetProperties(math.random(10000))

	prop.TerrainDescription.Octaves = 4
	prop.TerrainDescription.Scale = 150
	prop.TerrainDescription.Lacunarity = 2
	prop.TerrainDescription.Exp = 3.7
	prop.TerrainDescription.Persistence = 0.8
	prop.TerrainDescription.Height = 60

	NewTerrain = TG.new(prop):Generate()
	local diagram = NewTerrain:GetPoints()
	local pc = PolygonConnector.new('d', diagram)
	local tris = pc:ConnectPoints()
	local iter = 0

	for i, v in pairs(tris) do
		iter += 1
		if iter == 1000  then
			task.wait()
			iter = 0
		end
		for i, v in pairs(v) do
			local avg = math.abs(v.CFrame.Position.Y - NewTerrain:GetLowestPoint())
			if avg <= 5	then
				game.Workspace.Terrain:FillBlock(CFrame.new(v.CFrame.Position.X, NewTerrain:GetLowestPoint(), v.CFrame.Position.Z), v.Size + Vector3.new(3,0, 0),Enum.Material.Water)
				--game.Workspace.Terrain:FillBlock(v.CFrame * CFrame.new(0, -10, 0),v.Size + Vector3.new(3, 0, 0),Enum.Material.Sand)
			elseif avg <= 10 then
				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Sand)
			elseif avg <= 45 then
				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Grass)
				local m = math.random(500)
				if m <= 2 then
					local r = game.ReplicatedStorage.bush:Clone()
					r.Parent = workspace
					r:PivotTo(CFrame.new(v.CFrame.Position) * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(math.random(360)), 0))
				elseif m <= 3 then
					local r = game.ReplicatedStorage.rock:Clone()
					r.Parent = workspace
					r:PivotTo(CFrame.new(v.CFrame.Position) * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(math.random(360)), 0))
				elseif m <= 20 then
					local r = game.ReplicatedStorage.tree:Clone()
					r.Parent = workspace
					r:PivotTo(CFrame.new(v.CFrame.Position) * CFrame.Angles(0, math.rad(math.random(360)), 0))
				end
			elseif avg <= 120 then
				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Rock)
			else
				game.Workspace.Terrain:FillBlock(v.CFrame,v.Size + Vector3.new(3, 0, 0),Enum.Material.Snow)
			end
		end
	end
end

return TerrainService
