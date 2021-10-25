local PolygonConnector = {}--require(game:GetService("ReplicatedStorage").Yuno).setup:GetEnv()
PolygonConnector.__index = PolygonConnector

--> @TODO: Render method

local function GenerateTriangle(a: Vector3, b: Vector3, c:Vector3, p: Instance): ({any: any})
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

    return {
        w1 = {
            CFrame = CFrame.fromMatrix((a + b)/2, right, up, back),
            Size = Vector3.new(0, height, math.abs(ab:Dot(back))),
        },
        w2 = {
            Size = Vector3.new(0, height, math.abs(ac:Dot(back))),
            CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back),
        }
    }
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
            table.insert(Tris, GenerateTriangle(a, b, c, self._Storage))


            if d == nil then continue end
            table.insert(Tris, GenerateTriangle(d, b, c, self._Storage))
        end
    end

    return Tris
end

function PolygonConnector:Render(Tris: {any: any})
    for i, v in pairs(Tris) do
        local w1 = Instance.new("WedgePart");

        w1.Size = v.w1.Size;
        w1.CFrame = v.w1.CFrame;
        w1.Parent = self._Storage
        w1.Anchored = true
        w1.CastShadow = false

        for i, v in pairs(self.Properties) do
            pcall(function()
                w1[i] = v
            end)
        end

        local w2 = Instance.new("WedgePart");
        w2.Size = v.w2.Size
        w2.CFrame = v.w2.CFrame
        w2.Parent = self._Storage
        w2.CastShadow = false
        w2.Anchored = true

        for i, v in pairs(self.Properties) do
            pcall(function()
                w2[i] = v
            end)
        end
    end
end

function PolygonConnector:Destroy()
    self._Storage:Destroy()
    self = nil
end

return PolygonConnector