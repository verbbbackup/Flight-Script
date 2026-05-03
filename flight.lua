-- Library Retrieval: Core Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Interface Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VerbbFlightVerticalUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

-- Minimize Button (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.TextSize = 25
MinimizeBtn.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -35, 0, 40)
Title.Text = "Verbb’s Flight"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Toggle Button
local FlightBtn = Instance.new("TextButton")
FlightBtn.Size = UDim2.new(0, 180, 0, 40)
FlightBtn.Position = UDim2.new(0.5, -90, 0, 50)
FlightBtn.Text = "FLIGHT OFF"
FlightBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
FlightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlightBtn.Parent = MainFrame

-- Speed Textbox
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 180, 0, 40)
SpeedInput.Position = UDim2.new(0.5, -90, 0, 100)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.Text = "5"
SpeedInput.PlaceholderText = "Speed (1-10)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.Parent = SpeedInput

-- Flight Variables
local flying = false
local speedMultiplier = 5
local bv, bg

-- Numerical Logic
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then
        speedMultiplier = math.clamp(val, 1, 10)
        SpeedInput.Text = tostring(speedMultiplier)
    else
        SpeedInput.Text = tostring(speedMultiplier)
    end
end)

-- Flight Protocol
local function startFlight()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    RunService:BindToRenderStep("Flight", 1, function()
        if flying and root then
            local baseSpeed = speedMultiplier * 25
            -- Use the Camera's LookVector to allow looking up/down to levitate
            local direction = camera.CFrame.LookVector
            
            -- Detect if the user is attempting to move (Forward/Backward/Sideways)
            local moveDir = char.Humanoid.MoveDirection
            
            if moveDir.Magnitude > 0 then
                -- Move in the direction the camera is facing
                bv.Velocity = direction * baseSpeed
            else
                -- Hover in place if no joystick input
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Lock character rotation to the camera
            bg.CFrame = camera.CFrame
        end
    end)
end

FlightBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        FlightBtn.Text = "FLIGHT ON"
        FlightBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        startFlight()
    else
        FlightBtn.Text = "FLIGHT OFF"
        FlightBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        RunService:UnbindFromRenderStep("Flight")
    end
end)

-- Minimize Logic
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 220, 0, 40)
        FlightBtn.Visible = false
        SpeedInput.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 220, 0, 180)
        FlightBtn.Visible = true
        SpeedInput.Visible = true
        MinimizeBtn.Text = "-"
    end
end)