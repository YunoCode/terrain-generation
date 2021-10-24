local PolygonConnecter = require(game:GetService("ReplicatedStorage").Yuno).setup:GetEnv()

function PolygonConnecter.new(Points: {any: any}, Color: Color3): ({any: any})
    --> Points is a table containing X and Y of a plain (XY format)

    return setmetatable({
        _Points = Points,
        _Color = Color,
    }, PolygonConnecter)
end

function PolygonConnecter:ConnectPoints()
    for i, X in pairs(self._Points) do
        
    end
end

return PolygonConnecter