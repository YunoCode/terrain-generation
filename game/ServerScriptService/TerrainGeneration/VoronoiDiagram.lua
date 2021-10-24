local VoronoiDiagram = require(game:GetService("ReplicatedStorage").Yuno).setup:GetEnv()

function VoronoiDiagram.new(Points: number): ({any: any})
    return setmetatable({
        _Points = Points
    }, VoronoiDiagram)
end

return VoronoiDiagram