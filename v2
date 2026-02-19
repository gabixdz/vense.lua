--[[
    $vense.lua$ - Enhanced Smooth GUI Menu with Toggleable Features
    Features: Noclip, Infinite Jumps, Model Changer, China Hat, Boost FPS
    Mobile Supported, Draggable, Minimizable, Toggle Indicators
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
    OnColor = Color3.fromRGB(100, 200, 100),
}

-- Feature Toggles and States
local Features = {
    Noclip = false,
    InfiniteJump = false,
    ChinaHat = false,
    BoostFPS = false,
}

-- Color States
local ColorStates = {
    ModelColor = Color3.fromRGB(100, 200, 255),
    ModelNeon = false,
    ChinaHatColor = Color3.fromRGB(255, 100, 100),
    ChinaHatNeon = false,
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

-- Color Picker GUI
local function createColorPicker(title, initialColor, callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ColorPicker"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 250)
    frame.Position = UDim2.new(0.5, -150, 0.5, -125)
    frame.BackgroundColor3 = Config.MainColor
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    -- Title
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, 0, 0, 40)
    titleText.BackgroundColor3 = Config.AccentColor
    titleText.BorderSizePixel = 0
    titleText.Text = title
    titleText.TextColor3 = Config.TextColor
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleText

    -- RGB Sliders
    local r, g, b = initialColor.R * 255, initialColor.G * 255, initialColor.B * 255

    local function createSlider(label, position, initialValue, callback2)
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Size = UDim2.new(0.9, 0, 0, 35)
        sliderContainer.Position = UDim2.new(0.05, 0, 0, position)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Parent = frame

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0, 40, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Config.AccentColor
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 12
        labelText.Parent = sliderContainer

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -80, 0, 10)
        sliderBg.Position = UDim2.new(0, 50, 0.5, -5)
        sliderBg.BackgroundColor3 = Config.DarkColor
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = sliderContainer

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 5)
        sliderCorner.Parent = sliderBg

        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 15, 0, 15)
        sliderButton.Position = UDim2.new(0, (initialValue / 255) * (sliderBg.AbsoluteSize.X - 15), 0.5, -7.5)
        sliderButton.BackgroundColor3 = Config.AccentColor
        sliderButton.BorderSizePixel = 0
        sliderButton.Text = ""
        sliderButton.Parent = sliderBg

        local sliderCorner2 = Instance.new("UICorner")
        sliderCorner2.CornerRadius = UDim.new(0, 7)
        sliderCorner2.Parent = sliderButton

        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0, 30, 1, 0)
        valueText.Position = UDim2.new(1, -30, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.Text = tostring(math.floor(initialValue))
        valueText.TextColor3 = Config.TextColor
        valueText.Font = Enum.Font.GothamBold
        valueText.TextSize = 12
        valueText.Parent = sliderContainer

        local dragging = false
        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local maxX = sliderBg.AbsoluteSize.X - 15
                local mouseX = input.Position.X - sliderBg.AbsolutePosition.X
                local newX = math.max(0, math.min(mouseX, maxX))
                local newValue = (newX / maxX) * 255
                sliderButton.Position = UDim2.new(0, newX, 0.5, -7.5)
                valueText.Text = tostring(math.floor(newValue))
                callback2(newValue)
            end
        end)
    end

    createSlider("R:", 50, r, function(val)
        r = val
        callback(Color3.fromRGB(r, g, b))
    end)

    createSlider("G:", 95, g, function(val)
        g = val
        callback(Color3.fromRGB(r, g, b))
    end)

    createSlider("B:", 140, b, function(val)
        b = val
        callback(Color3.fromRGB(r, g, b))
    end)

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, 0, 0, 40)
    closeBtn.Position = UDim2.new(0, 0, 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CLOSE"
    closeBtn.TextColor3 = Config.TextColor
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Create China Hat
local function createChinaHat()
    if not character:FindFirstChild("HumanoidRootPart") then return end
    
    local head = character:FindFirstChild("Head")
    if head then
        -- Remove old hat if exists
        if character:FindFirstChild("ChinaHat") then
            character:FindFirstChild("ChinaHat"):Destroy()
        end

        local hatModel = Instance.new("Model")
        hatModel.Name = "ChinaHat"
        hatModel.Parent = character

        -- Main cone part
        local cone = Instance.new("Part")
        cone.Shape = Enum.PartType.Ball
        cone.Size = Vector3.new(2, 2.5, 2)
        cone.Color = ColorStates.ChinaHatColor
        cone.Material = Enum.Material.Neon if ColorStates.ChinaHatNeon else Enum.Material.SmoothPlastic
        cone.CanCollide = false
        cone.TopSurface = Enum.SurfaceType.Smooth
        cone.BottomSurface = Enum.SurfaceType.Smooth
        cone.Parent = hatModel

        -- Weld to head
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = cone
        weld.Parent = cone

        cone.Position = head.Position + Vector3.new(0, 2, 0)

        -- Add some cylinders for decoration
        for i = 1, 3 do
            local decoration = Instance.new("Part")
            decoration.Shape = Enum.PartType.Ball
            decoration.Size = Vector3.new(0.5, 2, 0.5)
            decoration.Color = ColorStates.ChinaHatColor
            decoration.Material = Enum.Material.Neon if ColorStates.ChinaHatNeon else Enum.Material.SmoothPlastic
            decoration.CanCollide = false
            decoration.Parent = hatModel

            local angle = (i / 3) * math.pi * 2
            decoration.Position = cone.Position + Vector3.new(math.cos(angle) * 1.2, 1, math.sin(angle) * 1.2)

            local weld2 = Instance.new("WeldConstraint")
            weld2.Part0 = cone
            weld2.Part1 = decoration
            weld2.Parent = decoration
        end
    end
end

-- Remove China Hat
local function removeChinaHat()
    if character:FindFirstChild("ChinaHat") then
        character:FindFirstChild("ChinaHat"):Destroy()
    end
end

-- Boost FPS Function
local function boostFPS()
    local terrain = workspace.Terrain
    
    -- Set terrain to lowest detail
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.CanCollide = true
        end
    end
    
    -- Disable shadows
    game.Lighting.GlobalShadows = false
    game.Lighting.Brightness = 2
    
    -- Set all textures to lowest quality
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Texture") then
            descendant:Destroy()
        end
    end
end

-- Revert FPS Boost
local function revertFPSBoost()
    game.Lighting.GlobalShadows = true
    game.Lighting.Brightness = 1
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
    mainFrame.Size = UDim2.new(0, 380, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
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

    -- Feature Button Creator with Toggle Indicator
    local featureButtons = {}
    
    local function createFeatureButton(name, description, featureKey, callback)
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
        buttonLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
        buttonLayout.Parent = button

        -- Left container for text
        local textContainer = Instance.new("Frame")
        textContainer.Size = UDim2.new(0.85, 0, 1, 0)
        textContainer.BackgroundTransparency = 1
        textContainer.BorderSizePixel = 0
        textContainer.LayoutOrder = 1
        textContainer.Parent = button

        local textLayout = Instance.new("UIListLayout")
        textLayout.FillDirection = Enum.FillDirection.Vertical
        textLayout.SortOrder = Enum.SortOrder.LayoutOrder
        textLayout.Parent = textContainer

        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(1, 0, 0, 25)
        nameText.BackgroundTransparency = 1
        nameText.Text = name
        nameText.TextColor3 = Config.AccentColor
        nameText.TextSize = 16
        nameText.Font = Enum.Font.GothamBold
        nameText.TextXAlignment = Enum.TextXAlignment.Left
        nameText.LayoutOrder = 1
        nameText.Parent = textContainer

        local descText = Instance.new("TextLabel")
        descText.Size = UDim2.new(1, 0, 0, 35)
        descText.BackgroundTransparency = 1
        descText.Text = description
        descText.TextColor3 = Color3.fromRGB(180, 180, 180)
        descText.TextSize = 11
        descText.Font = Enum.Font.Gotham
        descText.TextXAlignment = Enum.TextXAlignment.Left
        descText.TextWrapped = true
        descText.LayoutOrder = 2
        descText.Parent = textContainer

        -- Toggle Indicator
        local toggleIndicator = Instance.new("TextLabel")
        toggleIndicator.Size = UDim2.new(0, 50, 1, 0)
        toggleIndicator.BackgroundTransparency = 1
        toggleIndicator.Text = "OFF"
        toggleIndicator.TextColor3 = Color3.fromRGB(200, 80, 80)
        toggleIndicator.TextSize = 14
        toggleIndicator.Font = Enum.Font.GothamBold
        toggleIndicator.LayoutOrder = 2
        toggleIndicator.Parent = button

        featureButtons[name] = {button = button, indicator = toggleIndicator}

        button.MouseButton1Click:Connect(function()
            Features[featureKey] = not Features[featureKey]
            
            if Features[featureKey] then
                toggleIndicator.Text = "ON"
                toggleIndicator.TextColor3 = Config.OnColor
            else
                toggleIndicator.Text = "OFF"
                toggleIndicator.TextColor3 = Color3.fromRGB(200, 80, 80)
            end
            
            callback(Features[featureKey])
        end)
        
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
    createFeatureButton("NOCLIP", "Walk through walls", "Noclip", function(enabled)
        if enabled then
            local noclipConnection
            noclipConnection = RunService.Stepped:Connect(function()
                if not Features.Noclip or not character:FindFirstChild("HumanoidRootPart") then
                    if noclipConnection then noclipConnection:Disconnect() end
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
    createFeatureButton("INFINITE JUMP", "Jump infinitely without limit", "InfiniteJump", function(enabled)
        if enabled then
            local jumpConnection
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if Features.InfiniteJump and character:FindFirstChild("Humanoid") then
                    character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    -- China Hat Feature
    createFeatureButton("CHINA HAT", "Wear a customizable china hat", "ChinaHat", function(enabled)
        if enabled then
            createChinaHat()
            createColorPicker("CHINA HAT COLOR", ColorStates.ChinaHatColor, function(color)
                ColorStates.ChinaHatColor = color
                if character:FindFirstChild("ChinaHat") then
                    character:FindFirstChild("ChinaHat"):Destroy()
                end
                createChinaHat()
            end)
        else
            removeChinaHat()
        end
    end)

    -- Boost FPS Feature
    createFeatureButton("BOOST FPS", "Lower all textures for better performance", "BoostFPS", function(enabled)
        if enabled then
            boostFPS()
        else
            revertFPSBoost()
        end
    end)

    -- Model Changer Feature
    local function createModelChanger()
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

        -- Model preview showing current color
        local previewLabel = Instance.new("TextLabel")
        previewLabel.Size = UDim2.new(1, 0, 0, 40)
        previewLabel.BackgroundColor3 = ColorStates.ModelColor
        previewLabel.BorderSizePixel = 0
        previewLabel.Text = "Current Color"
        previewLabel.TextColor3 = Config.TextColor
        previewLabel.Font = Enum.Font.GothamBold
        previewLabel.Parent = modelGui

        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 8)
        previewCorner.Parent = previewLabel

        local function createModelOption(modelName, modelType)
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
                -- Change character appearance
                if character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    -- Remove all body parts except humanoid
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part:Destroy()
                        end
                    end

                    -- Create new model
                    local newPart = Instance.new("Part")
                    newPart.Shape = (modelType == "Ball" and Enum.PartType.Ball) or 
                                   (modelType == "Block" and Enum.PartType.Block) or 
                                   Enum.PartType.Block
                    
                    if modelType == "Triangle" then
                        -- Create triangle effect with rotation
                        newPart.Shape = Enum.PartType.Block
                        newPart.Size = Vector3.new(2, 2, 0.5)
                    else
                        newPart.Size = Vector3.new(2, 2, 2)
                    end
                    
                    newPart.Color = ColorStates.ModelColor
                    newPart.Material = ColorStates.ModelNeon and Enum.Material.Neon or Enum.Material.SmoothPlastic
                    newPart.CanCollide = false
                    newPart.TopSurface = Enum.SurfaceType.Smooth
                    newPart.BottomSurface = Enum.SurfaceType.Smooth
                    newPart.Parent = character

                    -- Weld to HumanoidRootPart
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = humanoidRootPart
                    weld.Part1 = newPart
                    weld.Parent = newPart
                end

                contentFrame.Visible = true
                titleBar.Visible = true
                modelGui:Destroy()
            end)

            optionBtn.MouseEnter:Connect(function()
                local TweenService = game:GetService("TweenService")
                TweenService:Create(optionBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
            end)

            optionBtn.MouseLeave:Connect(function()
                local TweenService = game:GetService("TweenService")
                TweenService:Create(optionBtn, TweenInfo.new(0.2), {BackgroundColor3 = Config.DarkColor}):Play()
            end)
        end

        -- Color customization buttons
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(1, 0, 0, 40)
        colorBtn.BackgroundColor3 = Config.AccentColor
        colorBtn.TextColor3 = Config.TextColor
        colorBtn.Text = "CUSTOMIZE COLOR"
        colorBtn.Font = Enum.Font.GothamBold
        colorBtn.BorderSizePixel = 0
        colorBtn.Parent = modelGui

        local colorBtnCorner = Instance.new("UICorner")
        colorBtnCorner.CornerRadius = UDim.new(0, 8)
        colorBtnCorner.Parent = colorBtn

        colorBtn.MouseButton1Click:Connect(function()
            createColorPicker("MODEL COLOR", ColorStates.ModelColor, function(color)
                ColorStates.ModelColor = color
                previewLabel.BackgroundColor3 = color
            end)
        end)

        -- Neon toggle
        local neonBtn = Instance.new("TextButton")
        neonBtn.Size = UDim2.new(1, 0, 0, 40)
        neonBtn.BackgroundColor3 = ColorStates.ModelNeon and Config.OnColor or Color3.fromRGB(200, 80, 80)
        neonBtn.TextColor3 = Config.TextColor
        neonBtn.Text = ColorStates.ModelNeon and "NEON: ON" or "NEON: OFF"
        neonBtn.Font = Enum.Font.GothamBold
        neonBtn.BorderSizePixel = 0
        neonBtn.Parent = modelGui

        local neonBtnCorner = Instance.new("UICorner")
        neonBtnCorner.CornerRadius = UDim.new(0, 8)
        neonBtnCorner.Parent = neonBtn

        neonBtn.MouseButton1Click:Connect(function()
            ColorStates.ModelNeon = not ColorStates.ModelNeon
            neonBtn.Text = ColorStates.ModelNeon and "NEON: ON" or "NEON: OFF"
            local TweenService = game:GetService("TweenService")
            TweenService:Create(neonBtn, TweenInfo.new(0.2), {BackgroundColor3 = ColorStates.ModelNeon and Config.OnColor or Color3.fromRGB(200, 80, 80)}):Play()
        end)

        createModelOption("● CIRCLE", "Ball")
        createModelOption("■ SQUARE", "Block")
        createModelOption("▲ TRIANGLE", "Block")

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
            titleBar.Visible = true
            modelGui:Destroy()
        end)
    end

    local modelBtn = Instance.new("TextButton")
    modelBtn.Name = "ModelChanger"
    modelBtn.Size = UDim2.new(1, 0, 0, 70)
    modelBtn.BackgroundColor3 = Config.DarkColor
    modelBtn.BorderSizePixel = 0
    modelBtn.TextTransparency = 1
    modelBtn.Parent = contentFrame

    local modelBtnCorner = Instance.new("UICorner")
    modelBtnCorner.CornerRadius = UDim.new(0, 8)
    modelBtnCorner.Parent = modelBtn

    local modelBtnPadding = Instance.new("UIPadding")
    modelBtnPadding.PaddingLeft = UDim.new(0, 12)
    modelBtnPadding.PaddingRight = UDim.new(0, 12)
    modelBtnPadding.PaddingTop = UDim.new(0, 8)
    modelBtnPadding.PaddingBottom = UDim.new(0, 8)
    modelBtnPadding.Parent = modelBtn

    local modelNameText = Instance.new("TextLabel")
    modelNameText.Size = UDim2.new(1, 0, 0, 25)
    modelNameText.BackgroundTransparency = 1
    modelNameText.Text = "MODEL CHANGER"
    modelNameText.TextColor3 = Config.AccentColor
    modelNameText.TextSize = 16
    modelNameText.Font = Enum.Font.GothamBold
    modelNameText.TextXAlignment = Enum.TextXAlignment.Left
    modelNameText.Parent = modelBtn

    local modelDescText = Instance.new("TextLabel")
    modelDescText.Size = UDim2.new(1, 0, 0, 35)
    modelDescText.Position = UDim2.new(0, 0, 0, 25)
    modelDescText.BackgroundTransparency = 1
    modelDescText.Text = "Change your visual appearance and customize colors"
    modelDescText.TextColor3 = Color3.fromRGB(180, 180, 180)
    modelDescText.TextSize = 11
    modelDescText.Font = Enum.Font.Gotham
    modelDescText.TextXAlignment = Enum.TextXAlignment.Left
    modelDescText.TextWrapped = true
    modelDescText.Parent = modelBtn

    modelBtn.MouseButton1Click:Connect(function()
        contentFrame.Visible = false
        titleBar.Visible = false
        createModelChanger()
    end)

    modelBtn.MouseEnter:Connect(function()
        local TweenService = game:GetService("TweenService")
        TweenService:Create(modelBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)

    modelBtn.MouseLeave:Connect(function()
        local TweenService = game:GetService("TweenService")
        TweenService:Create(modelBtn, TweenInfo.new(0.2), {BackgroundColor3 = Config.DarkColor}):Play()
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

-- Create Minimized Button with Animation
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

    local function onButtonClick()
        -- Animation: Scale up and restore GUI
        local TweenService = game:GetService("TweenService")
        local originalSize = minimizedBtn.Size
        
        TweenService:Create(
            minimizedBtn,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Size = UDim2.new(0, 60, 0, 60)}
        ):Play()

        wait(0.15)
        screenGui:Destroy()
        createMainGui()
    end

    minimizedBtn.MouseButton1Click:Connect(onButtonClick)

    -- Mobile Support: Touch Handling
    minimizedBtn.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Touch then
            onButtonClick()
        end
    end)

    -- Bounce animation on spawn
    local TweenService = game:GetService("TweenService")
    minimizedBtn.Position = UDim2.new(0, 20, 1, -50)
    TweenService:Create(
        minimizedBtn,
        TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 20, 1, -70)}
    ):Play()
end

-- Initialize
createInjectionAnimation()
wait(2)
          createMainGui()
