--[[
    $vense.lua$ - Smooth GUI Menu with Multiple Features
    Features: Noclip, Infinite Jumps, Model Changer
    Mobile Supported, Draggable, Minimizable
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

-- Configuration
local Config = {
    MainColor = Color3.fromRGB(30, 30, 35),
    AccentColor = Color3.fromRGB(100, 200, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    DarkColor = Color3.fromRGB(20, 20, 25),
}

-- Feature Toggles
local Features = {
    Noclip = false,
    InfiniteJump = false,
}

-- Create Injection Animation Screen
local function createInjectionAnimation()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InjectionAnimation"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "InjectionText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundColor3 = Config.DarkColor
    textLabel.BackgroundTransparency = 0
    textLabel.Text = "$vense.lua$"
    textLabel.TextSize = 48
    textLabel.TextColor3 = Config.AccentColor
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = screenGui

    -- Animation
    local TweenService = game:GetService("TweenService")
    
    -- Fade in text
    local fadeInTween = TweenService:Create(
        textLabel,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        {TextTransparency = 0}
    )
    
    textLabel.TextTransparency = 1
    fadeInTween:Play()
    
    -- Wait and fade out
    fadeInTween.Completed:Connect(function()
        wait(1)
        local fadeOutTween = TweenService:Create(
            textLabel,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {TextTransparency = 1, BackgroundTransparency = 1}
        )
        fadeOutTween:Play()
        fadeOutTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

-- Create Main GUI
local function createMainGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VenseGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Config.MainColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Config.AccentColor
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "VENSE"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Config.DarkColor
    closeBtn.TextColor3 = Config.TextColor
    closeBtn.Text = "×"
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn

    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -50)
    contentFrame.Position = UDim2.new(0, 0, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.Parent = contentFrame

    -- List Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 12)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame

    -- Feature Button Creator
    local function createFeatureButton(name, description, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, 0, 0, 70)
        button.BackgroundColor3 = Config.DarkColor
        button.BorderSizePixel = 0
        button.TextTransparency = 1
        button.Parent = contentFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button

        local buttonPadding = Instance.new("UIPadding")
        buttonPadding.PaddingLeft = UDim.new(0, 12)
        buttonPadding.PaddingRight = UDim.new(0, 12)
        buttonPadding.PaddingTop = UDim.new(0, 8)
        buttonPadding.PaddingBottom = UDim.new(0, 8)
        buttonPadding.Parent = button

        local buttonLayout = Instance.new("UIListLayout")
        buttonLayout.FillDirection = Enum.FillDirection.Vertical
        buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
        buttonLayout.Parent = button

        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(1, 0, 0, 25)
        nameText.BackgroundTransparency = 1
        nameText.Text = name
        nameText.TextColor3 = Config.AccentColor
        nameText.TextSize = 16
        nameText.Font = Enum.Font.GothamBold
        nameText.TextXAlignment = Enum.TextXAlignment.Left
        nameText.LayoutOrder = 1
        nameText.Parent = button

        local descText = Instance.new("TextLabel")
        descText.Size = UDim2.new(1, 0, 0, 35)
        descText.BackgroundTransparency = 1
        descText.Text = description
        descText.TextColor3 = Color3.fromRGB(180, 180, 180)
        descText.TextSize = 12
        descText.Font = Enum.Font.Gotham
        descText.TextXAlignment = Enum.TextXAlignment.Left
        descText.TextWrapped = true
        descText.LayoutOrder = 2
        descText.Parent = button

        button.MouseButton1Click:Connect(callback)
        
        -- Hover Effect
        button.MouseEnter:Connect(function()
            local TweenService = game:GetService("TweenService")
            TweenService:Create(
                button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}
            ):Play()
        end)

        button.MouseLeave:Connect(function()
            local TweenService = game:GetService("TweenService")
            TweenService:Create(
                button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Config.DarkColor}
            ):Play()
        end)

        return button
    end

    -- Noclip Feature
    createFeatureButton("NOCLIP", "Walk through walls", function()
        Features.Noclip = not Features.Noclip
        if Features.Noclip then
            local noclipConnection
            noclipConnection = RunService.Stepped:Connect(function()
                if not Features.Noclip or not character:FindFirstChild("HumanoidRootPart") then
                    noclipConnection:Disconnect()
                    return
                end
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end)

    -- Infinite Jump Feature
    createFeatureButton("INFINITE JUMP", "Jump forever", function()
        Features.InfiniteJump = not Features.InfiniteJump
        if Features.InfiniteJump then
            local jumpConnection
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if Features.InfiniteJump and character:FindFirstChild("Humanoid") then
                    character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    -- Model Changer Feature
    createFeatureButton("MODEL CHANGER", "Change your appearance", function()
        screenGui:FindFirstChild("TitleBar").Visible = false
        contentFrame.Visible = false
        
        local modelGui = Instance.new("Frame")
        modelGui.Name = "ModelChanger"
        modelGui.Size = UDim2.new(1, 0, 1, -50)
        modelGui.Position = UDim2.new(0, 0, 0, 50)
        modelGui.BackgroundTransparency = 1
        modelGui.BorderSizePixel = 0
        modelGui.Parent = mainFrame

        local modelPadding = Instance.new("UIPadding")
        modelPadding.PaddingLeft = UDim.new(0, 15)
        modelPadding.PaddingRight = UDim.new(0, 15)
        modelPadding.PaddingTop = UDim.new(0, 15)
        modelPadding.PaddingBottom = UDim.new(0, 15)
        modelPadding.Parent = modelGui

        local modelLayout = Instance.new("UIListLayout")
        modelLayout.Padding = UDim.new(0, 10)
        modelLayout.FillDirection = Enum.FillDirection.Vertical
        modelLayout.SortOrder = Enum.SortOrder.LayoutOrder
        modelLayout.Parent = modelGui

        local function createModelOption(modelName, shapeFunc)
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, 50)
            optionBtn.BackgroundColor3 = Config.DarkColor
            optionBtn.TextColor3 = Config.TextColor
            optionBtn.Text = modelName
            optionBtn.Font = Enum.Font.GothamBold
            optionBtn.TextSize = 14
            optionBtn.BorderSizePixel = 0
            optionBtn.Parent = modelGui

            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 8)
            optionCorner.Parent = optionBtn

            optionBtn.MouseButton1Click:Connect(function()
                shapeFunc()
                contentFrame.Visible = true
                screenGui:FindFirstChild("TitleBar").Visible = true
                modelGui:Destroy()
            end)
        end

        -- Circle Model
        createModelOption("● CIRCLE", function()
            if character:FindFirstChild("HumanoidRootPart") then
                character:ClearAllChildren()
                local sphere = Instance.new("Part")
                sphere.Shape = Enum.PartType.Ball
                sphere.Size = Vector3.new(2, 2, 2)
                sphere.CanCollide = true
                sphere.Parent = character
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = sphere
                bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            end
        end)

        -- Square Model
        createModelOption("■ SQUARE", function()
            if character:FindFirstChild("HumanoidRootPart") then
                character:ClearAllChildren()
                local cube = Instance.new("Part")
                cube.Shape = Enum.PartType.Block
                cube.Size = Vector3.new(2, 2, 2)
                cube.CanCollide = true
                cube.Parent = character
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = cube
                bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            end
        end)

        -- Triangle Model
        createModelOption("▲ TRIANGLE", function()
            if character:FindFirstChild("HumanoidRootPart") then
                character:ClearAllChildren()
                local wedge = Instance.new("Part")
                wedge.Shape = Enum.PartType.Block
                wedge.Size = Vector3.new(2, 2, 2)
                wedge.CanCollide = true
                wedge.Parent = character
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = wedge
                bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            end
        end)

        local backBtn = Instance.new("TextButton")
        backBtn.Size = UDim2.new(1, 0, 0, 40)
        backBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        backBtn.TextColor3 = Config.TextColor
        backBtn.Text = "BACK"
        backBtn.Font = Enum.Font.GothamBold
        backBtn.BorderSizePixel = 0
        backBtn.Parent = modelGui

        local backCorner = Instance.new("UICorner")
        backCorner.CornerRadius = UDim.new(0, 8)
        backCorner.Parent = backBtn

        backBtn.MouseButton1Click:Connect(function()
            contentFrame.Visible = true
            screenGui:FindFirstChild("TitleBar").Visible = true
            modelGui:Destroy()
        end)
    end)

    -- Dragging Functionality
    local dragging = false
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Close Button Functionality
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        createMinimizedButton()
    end)

    return screenGui
end

-- Create Minimized Button
function createMinimizedButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VenseMinimized"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local minimizedBtn = Instance.new("TextButton")
    minimizedBtn.Name = "MinimizedBtn"
    minimizedBtn.Size = UDim2.new(0, 50, 0, 50)
    minimizedBtn.Position = UDim2.new(0, 20, 1, -70)
    minimizedBtn.BackgroundColor3 = Config.AccentColor
    minimizedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizedBtn.Text = "V"
    minimizedBtn.TextSize = 24
    minimizedBtn.Font = Enum.Font.GothamBold
    minimizedBtn.BorderSizePixel = 0
    minimizedBtn.Parent = screenGui

    local minimizedCorner = Instance.new("UICorner")
    minimizedCorner.CornerRadius = UDim.new(0, 8)
    minimizedCorner.Parent = minimizedBtn

    minimizedBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        createMainGui()
    end)

    -- Mobile Support: Touch Handling
    minimizedBtn.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Touch then
            minimizedBtn.MouseButton1Click:Fire()
        end
    end)
end

-- Initialize
createInjectionAnimation()
wait(2)
createMainGui()
