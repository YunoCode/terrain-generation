if not game:IsLoaded() then game.Loaded:Wait() end

local p = game:GetService"Players".LocalPlayer

local mouse = p:GetMouse()

for i, v in ipairs(p.PlayerGui:WaitForChild("ScreenGui").Frame:GetChildren()) do
    local button = v.TextButton
    local text = v.TextLabel
    local ap = Vector2.new(v.AbsolutePosition.X, v.AbsolutePosition.Y)
    local as = Vector2.new(v.AbsoluteSize.X, v.AbsoluteSize.Y)
    local down = false

    button.MouseButton1Down:Connect(function()
        down = true
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            down = false
        end
    end)

    mouse.Move:Connect(function()
        if down == true then --if true, then this represents the mouse being dragged
    
            if mouse.X < ap.X then --out of bounds (to the left)
                
                button.Position = UDim2.new(0, 0, 1, 0)
                
            elseif mouse.X > (ap.X + as.X) then --out of bounds (to the right)
                
                button.Position = UDim2.new(0, as.X, 1, 0)
            
            else --within bounds
                
                button.Position = UDim2.new(0, (mouse.X - ap.X), 1, 0)
                
            end

            local maxSize = as.X
            local size = button.Position.X.Offset
            local num = v.max.Value * (size / maxSize) --100 because that is the range we want it to be in
        
            text.Text = num
            script[v.Name].Value = num
        end
    end)
end

game.ReplicatedStorage.RemoteFunction.OnClientInvoke = function()
    return {
        game.ReplicatedFirst.slider.octaves.Value,
        game.ReplicatedFirst.slider.scale.Value,
        game.ReplicatedFirst.slider.lacunarity.Value,
        game.ReplicatedFirst.slider.exp.Value,
        game.ReplicatedFirst.slider.persistence.Value,
        game.ReplicatedFirst.slider.height.Value,
    }
end