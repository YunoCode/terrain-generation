local PolygonConnector = {}--require(game:GetService("ReplicatedStorage").Yuno).setup:GetEnv()
PolygonConnector.__index = PolygonConnector

local function GenerateTriangle(a: Vector3, b: Vector3, c:Vector3, Properties: ({any: any}), p: Instance): (WedgePart, WedgePart)
    local ab, ac, bc = b - a, c - a, c - b;
    local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc);
    
    if (abd > acd and abd > bcd) then
        c, a = a, c;
    elseif (acd > bcd and acd > abd) then
        a, b = b, a;
    end
    
    ab, ac, bc = b - a, c - a, c - b;
    
    local right = ac:Cross(ab).Unit;
    local up = bc:Cross(right).Unit;
    local back = bc.unit;
    
    local height = math.abs(ab:Dot(up));
    
    local w1 = Instance.new("WedgePart");
    w1.Size = Vector3.new(0, height, math.abs(ab:Dot(back)));
    w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back);
    w1.Parent = p or workspace
    w1.Anchored = true
    w1.CastShadow = false

    for i, v in pairs(Properties) do
        pcall(function()
            w1[i] = v
        end)
    end

    local w2 = Instance.new("WedgePart");
    w2.Size = Vector3.new(0, height, math.abs(ac:Dot(back)));
    w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back);
    w2.Parent = p or workspace;
    w2.CastShadow = false
    w2.Anchored = true

    for i, v in pairs(Properties) do
        pcall(function()
            w2[i] = v
        end)
    end

    return w1, w2
end

function PolygonConnector.new(FolderName: string, Points: {any: any}, Properties: {any: any}): ({any: any})
    --> Points is a table containing X and Y of a plain (XY format)

    local Storage = Instance.new("Folder", workspace)
    Storage.Name = FolderName

    return setmetatable({
        _Storage = Storage,
        _Points = Points,
        _Properties = Properties,
    }, PolygonConnector)
end

function PolygonConnector:ConnectPoints()
    local Tris = {}

    for X, YT in pairs(self._Points) do
        for Y, v in pairs(YT) do
            if self._Points[X+1] == nil then break end
            local a, b, c, d = v:: Vector3, YT[Y+1]:: Vector3, self._Points[X+1][Y]:: Vector3, self._Points[X+1][Y+1]:: Vector3

            if a == nil or b == nil or c == nil then continue end

            local w1, w2 = GenerateTriangle(a, b, c, self._Properties, self._Storage)
            table.insert(Tris, w1); table.insert(Tris, w2)


            if d == nil then continue end
            local w1, w2 = GenerateTriangle(d, b, c, self._Properties, self._Storage)
            table.insert(Tris, w1); table.insert(Tris, w2)
        end
    end

    return Tris
end

return PolygonConnector