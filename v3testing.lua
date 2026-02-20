--[[ $vense.lua$ V3 ]]

-- ── Services ──────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── Config ────────────────────────────────────────────────────────────────────
local Config = {
    MainColor   = Color3.fromRGB(30, 30, 35),
    AccentColor = Color3.fromRGB(100, 200, 255),
    TextColor   = Color3.fromRGB(255, 255, 255),
    DarkColor   = Color3.fromRGB(20, 20, 25),
    OnColor     = Color3.fromRGB(100, 200, 100),
}

local Features = {
    Noclip       = false,
    InfiniteJump = false,
    ChinaHat     = false,
    BoostFPS     = false,
    HealthBar    = false,
    Crosshair    = false,
    Particles    = false,
}

local ColorStates = {
    ChinaHatColor    = Color3.fromRGB(255, 80,  80),
    ChinaHatNeon     = false,
    ChinaHatRainbow  = false,

    HealthBarColor   = Color3.fromRGB(100, 220, 100),
    HealthBarNeon    = false,
    HealthBarRainbow = false,

    CrosshairColor   = Color3.fromRGB(255, 255, 255),
    CrosshairNeon    = false,
    CrosshairRainbow = false,
    CrosshairSpin    = false,

    ParticlesColor   = Color3.fromRGB(100, 200, 255),
    ParticlesNeon    = true,
    ParticlesRainbow = false,
}

local Connections  = {}
local RainbowConns = {}
local ParticleOrbs = {}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function getChar()
    return player.Character
end

local function uiCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function makeTween(obj, t, props, style, dir)
    return TweenService:Create(obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props)
end

local function stopRainbowKey(key)
    if RainbowConns[key] then
        RainbowConns[key]:Disconnect()
        RainbowConns[key] = nil
    end
end

-- ── Preset colors ─────────────────────────────────────────────────────────────
local PRESETS = {
    { name = "red",       color = Color3.fromRGB(220, 50,  50),  neon = false, rainbow = false },
    { name = "blue",      color = Color3.fromRGB(50,  120, 255), neon = false, rainbow = false },
    { name = "yellow",    color = Color3.fromRGB(255, 220, 30),  neon = false, rainbow = false },
    { name = "white",     color = Color3.fromRGB(255, 255, 255), neon = false, rainbow = false },
    { name = "black",     color = Color3.fromRGB(20,  20,  20),  neon = false, rainbow = false },
    { name = "green",     color = Color3.fromRGB(30,  160, 60),  neon = false, rainbow = false },
    { name = "✦ neon",   color = Color3.fromRGB(0,   255, 120), neon = true,  rainbow = false },
    { name = "❖ rainbow", color = Color3.fromRGB(255, 0,   0),   neon = true,  rainbow = true  },
}

-- ── Injection splash ──────────────────────────────────────────────────────────
local function createInjectionAnimation()
    local sg = Instance.new("ScreenGui")
    sg.Name = "InjectionAnimation"; sg.ResetOnSpawn = false; sg.Parent = playerGui

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundColor3 = Config.DarkColor; lbl.BackgroundTransparency = 0
    lbl.Text = "$vense.lua$"; lbl.TextSize = 48
    lbl.TextColor3 = Config.AccentColor; lbl.Font = Enum.Font.GothamBold
    lbl.TextTransparency = 1; lbl.Parent = sg

    local fi = makeTween(lbl, 0.8, {TextTransparency = 0})
    fi:Play()
    fi.Completed:Connect(function()
        wait(1)
        local fo = TweenService:Create(lbl, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {TextTransparency = 1, BackgroundTransparency = 1})
        fo:Play()
        fo.Completed:Connect(function() sg:Destroy() end)
    end)
end

-- ── Noclip ────────────────────────────────────────────────────────────────────
local function toggleNoclip(enabled)
    if Connections.Noclip then Connections.Noclip:Disconnect() end
    if enabled then
        Connections.Noclip = RunService.Stepped:Connect(function()
            local char = getChar()
            if not Features.Noclip or not char or not char:FindFirstChild("HumanoidRootPart") then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end

-- ── Infinite Jump ─────────────────────────────────────────────────────────────
local function toggleInfiniteJump(enabled)
    if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
    if enabled then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            local char = getChar()
            if Features.InfiniteJump and char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

-- ── China Hat ─────────────────────────────────────────────────────────────────
local function startHatRainbow()
    stopRainbowKey("hat")
    RainbowConns["hat"] = RunService.Heartbeat:Connect(function()
        local char = getChar()
        if not char or not char:FindFirstChild("ChinaHatCone") then stopRainbowKey("hat") return end
        local c = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
        local cone = char:FindFirstChild("ChinaHatCone")
        local brim = char:FindFirstChild("ChinaHatBrim")
        if cone then cone.Color = c end
        if brim then brim.Color = c end
    end)
end

local function applyHatColor(color, neon, rainbow)
    local char = getChar()
    if not char then return end
    local cone = char:FindFirstChild("ChinaHatCone")
    local brim = char:FindFirstChild("ChinaHatBrim")
    if not cone or not brim then return end
    local mat = neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
    cone.Material = mat; brim.Material = mat
    if not rainbow then cone.Color = color; brim.Color = color end
end

local function removeChinaHat()
    stopRainbowKey("hat")
    local char = getChar()
    if not char then return end
    for _, partName in ipairs({"ChinaHatCone","ChinaHatBrim"}) do
        local p = char:FindFirstChild(partName)
        if p then p:Destroy() end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, v in pairs(head:GetChildren()) do
            if v:IsA("Motor6D") and (v.Name == "ChinaHatConeWeld" or v.Name == "ChinaHatBrimWeld") then
                v:Destroy()
            end
        end
    end
end

local function createChinaHat()
    removeChinaHat()
    local char = getChar()
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local mat = ColorStates.ChinaHatNeon and Enum.Material.Neon or Enum.Material.SmoothPlastic
    local col = ColorStates.ChinaHatColor

    local brim = Instance.new("Part")
    brim.Name="ChinaHatBrim"; brim.Size=Vector3.new(1,1,1)
    brim.Color=col; brim.Material=mat; brim.CanCollide=false; brim.Anchored=false
    brim.TopSurface=Enum.SurfaceType.Smooth; brim.BottomSurface=Enum.SurfaceType.Smooth
    brim.Parent=char
    local bm = Instance.new("SpecialMesh"); bm.MeshType=Enum.MeshType.Cylinder
    bm.Scale=Vector3.new(0.4,5.5,5.5); bm.Parent=brim
    local bw = Instance.new("Motor6D"); bw.Name="ChinaHatBrimWeld"
    bw.Part0=head; bw.Part1=brim
    bw.C0=CFrame.new(0,head.Size.Y/2+0.15,0)*CFrame.Angles(0,0,math.rad(90))
    bw.Parent=head

    local cone = Instance.new("Part")
    cone.Name="ChinaHatCone"; cone.Size=Vector3.new(4.2,3.2,4.2)
    cone.Color=col; cone.Material=mat; cone.CanCollide=false; cone.Anchored=false
    cone.TopSurface=Enum.SurfaceType.Smooth; cone.BottomSurface=Enum.SurfaceType.Smooth
    cone.Parent=char
    local cm = Instance.new("SpecialMesh"); cm.MeshType=Enum.MeshType.Sphere
    cm.Scale=Vector3.new(1,0.75,1); cm.Parent=cone
    local cw = Instance.new("Motor6D"); cw.Name="ChinaHatConeWeld"
    cw.Part0=head; cw.Part1=cone
    cw.C0=CFrame.new(0,head.Size.Y/2+0.2+cone.Size.Y/2*0.75-0.3,0)
    cw.Parent=head

    if ColorStates.ChinaHatRainbow then startHatRainbow() end
end

-- ── Boost FPS ─────────────────────────────────────────────────────────────────
local function boostFPS(enabled)
    if enabled then
        game.Lighting.GlobalShadows=false; game.Lighting.Brightness=2
        for _, d in pairs(workspace:GetDescendants()) do
            if d:IsA("Texture") then d:Destroy() end
        end
    else
        game.Lighting.GlobalShadows=true; game.Lighting.Brightness=1
    end
end

-- ── Health Bar ────────────────────────────────────────────────────────────────
local HealthBarGui = nil

local function destroyHealthBar()
    stopRainbowKey("healthbar")
    if Connections.HealthBar     then Connections.HealthBar:Disconnect();     Connections.HealthBar     = nil end
    if Connections.HealthBarDied then Connections.HealthBarDied:Disconnect(); Connections.HealthBarDied = nil end
    if HealthBarGui then HealthBarGui:Destroy(); HealthBarGui = nil end
end

local function createHealthBar()
    destroyHealthBar()
    local char = getChar(); if not char then return end
    local humanoid = char:FindFirstChild("Humanoid"); if not humanoid then return end

    local sg = Instance.new("ScreenGui")
    sg.Name="VenseHealthBar"; sg.ResetOnSpawn=false; sg.DisplayOrder=5; sg.Parent=playerGui
    HealthBarGui = sg

    local container = Instance.new("Frame")
    container.Name="Container"; container.Size=UDim2.new(0,320,0,28)
    container.Position=UDim2.new(0.5,-160,1,-60)
    container.BackgroundColor3=Color3.fromRGB(15,15,18); container.BorderSizePixel=0
    container.Parent=sg; uiCorner(container,14)

    local track = Instance.new("Frame")
    track.Size=UDim2.new(1,-8,1,-8); track.Position=UDim2.new(0,4,0,4)
    track.BackgroundColor3=Color3.fromRGB(35,35,40); track.BorderSizePixel=0
    track.Parent=container; uiCorner(track,10)

    local fill = Instance.new("Frame")
    fill.Name="Fill"; fill.Size=UDim2.new(1,0,1,0)
    fill.BackgroundColor3=ColorStates.HealthBarColor; fill.BorderSizePixel=0
    fill.Parent=track; uiCorner(fill,10)

    local shine = Instance.new("Frame")
    shine.Size=UDim2.new(1,0,0.45,0); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0; shine.ZIndex=3
    shine.Parent=fill; uiCorner(shine,10)

    local healthLbl = Instance.new("TextLabel")
    healthLbl.Size=UDim2.new(1,0,1,0); healthLbl.BackgroundTransparency=1
    healthLbl.Text="100 HP"; healthLbl.TextColor3=Color3.fromRGB(255,255,255)
    healthLbl.Font=Enum.Font.GothamBold; healthLbl.TextSize=13; healthLbl.ZIndex=4
    healthLbl.Parent=container

    local dangerOverlay = Instance.new("Frame")
    dangerOverlay.Size=UDim2.new(1,0,1,0)
    dangerOverlay.BackgroundColor3=Color3.fromRGB(255,40,40)
    dangerOverlay.BackgroundTransparency=1; dangerOverlay.BorderSizePixel=0
    dangerOverlay.ZIndex=5; dangerOverlay.Parent=container; uiCorner(dangerOverlay,14)

    local lastHealth = humanoid.Health
    local dangerPulseActive = false

    local function updateBar(hp, maxHp)
        local ratio = math.clamp(hp / math.max(maxHp,1), 0, 1)
        local targetColor
        if ColorStates.HealthBarRainbow then
            targetColor = fill.BackgroundColor3
        elseif ColorStates.HealthBarNeon then
            targetColor = ColorStates.HealthBarColor
        else
            local r = ColorStates.HealthBarColor.R
            local g = ColorStates.HealthBarColor.G
            local b = ColorStates.HealthBarColor.B
            targetColor = Color3.fromRGB(
                math.floor(r + (1-ratio)*(220-r)),
                math.floor(g * ratio),
                math.floor(b * ratio * 0.5)
            )
        end

        makeTween(fill, 0.35, {Size=UDim2.new(ratio,0,1,0)}, Enum.EasingStyle.Quart):Play()
        if not ColorStates.HealthBarRainbow then
            makeTween(fill, 0.35, {BackgroundColor3=targetColor}):Play()
        end
        healthLbl.Text = math.floor(hp) .. " HP"
        healthLbl.TextColor3 = Color3.fromRGB(255,255,255)

        if ratio <= 0.3 and not dangerPulseActive then
            dangerPulseActive = true
            coroutine.wrap(function()
                while dangerPulseActive and Features.HealthBar do
                    local c2 = getChar()
                    local hum = c2 and c2:FindFirstChild("Humanoid")
                    if not hum or hum.Health/hum.MaxHealth > 0.3 then
                        dangerPulseActive = false
                        makeTween(dangerOverlay,0.3,{BackgroundTransparency=1}):Play()
                        break
                    end
                    makeTween(dangerOverlay,0.4,{BackgroundTransparency=0.75}):Play()
                    wait(0.4)
                    makeTween(dangerOverlay,0.4,{BackgroundTransparency=1}):Play()
                    wait(0.4)
                end
            end)()
        elseif ratio > 0.3 then
            dangerPulseActive = false
            makeTween(dangerOverlay,0.3,{BackgroundTransparency=1}):Play()
        end

        if hp > lastHealth then
            local flash = makeTween(shine, 0.15, {BackgroundTransparency=0.5})
            flash:Play()
            flash.Completed:Connect(function()
                makeTween(shine, 0.4, {BackgroundTransparency=0.82}):Play()
            end)
        end
        lastHealth = hp
    end

    updateBar(humanoid.Health, humanoid.MaxHealth)

    Connections.HealthBar = humanoid.HealthChanged:Connect(function(hp)
        updateBar(math.max(hp, 0), humanoid.MaxHealth)
    end)

    Connections.HealthBarDied = humanoid.Died:Connect(function()
        dangerPulseActive = false
        makeTween(dangerOverlay, 0.2, {BackgroundTransparency=1}):Play()
        makeTween(fill, 0.5, {Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(180,40,40)}, Enum.EasingStyle.Quart):Play()
        healthLbl.Text = "dead"
        healthLbl.TextColor3 = Color3.fromRGB(220,80,80)
    end)

    if ColorStates.HealthBarRainbow then
        RainbowConns["healthbar"] = RunService.Heartbeat:Connect(function()
            if not Features.HealthBar then stopRainbowKey("healthbar") return end
            fill.BackgroundColor3 = Color3.fromHSV((tick()*0.5)%1, 1, 1)
        end)
    end

    container.Position = UDim2.new(0.5,-160,1,10)
    container.BackgroundTransparency = 1
    makeTween(container, 0.5, {Position=UDim2.new(0.5,-160,1,-60), BackgroundTransparency=0}, Enum.EasingStyle.Back):Play()
end

local function toggleHealthBar(enabled)
    if enabled then
        createHealthBar()
    else
        if HealthBarGui then
            local cont = HealthBarGui:FindFirstChild("Container")
            if cont then
                local out = makeTween(cont, 0.35, {Position=UDim2.new(0.5,-160,1,20), BackgroundTransparency=1})
                out:Play()
                out.Completed:Connect(function() destroyHealthBar() end)
            else
                destroyHealthBar()
            end
        end
    end
end

-- ── Crosshair ─────────────────────────────────────────────────────────────────
local CrosshairGui = nil

local function destroyCrosshair()
    stopRainbowKey("crosshair")
    if Connections.CrosshairSpin then Connections.CrosshairSpin:Disconnect(); Connections.CrosshairSpin=nil end
    if CrosshairGui then CrosshairGui:Destroy(); CrosshairGui=nil end
end

local function createCrosshair()
    destroyCrosshair()
    local sg = Instance.new("ScreenGui")
    sg.Name="VenseCrosshair"; sg.ResetOnSpawn=false
    sg.DisplayOrder=10; sg.IgnoreGuiInset=true; sg.Parent=playerGui
    CrosshairGui = sg

    local col = ColorStates.CrosshairColor
    local root = Instance.new("Frame")
    root.Name="Root"; root.Size=UDim2.new(0,60,0,60)
    root.Position=UDim2.new(0.5,-30,0.5,-30)
    root.BackgroundTransparency=1; root.BorderSizePixel=0; root.Parent=sg

    local dot = Instance.new("Frame")
    dot.Size=UDim2.new(0,5,0,5); dot.Position=UDim2.new(0.5,-2,0.5,-2)
    dot.BackgroundColor3=col; dot.BorderSizePixel=0; dot.Parent=root; uiCorner(dot,3)

    local armDefs = {
        {name="Top",    size=UDim2.new(0,2,0,14), pos=UDim2.new(0.5,-1,0.5,-22)},
        {name="Bottom", size=UDim2.new(0,2,0,14), pos=UDim2.new(0.5,-1,0.5,8)},
        {name="Left",   size=UDim2.new(0,14,0,2), pos=UDim2.new(0.5,-22,0.5,-1)},
        {name="Right",  size=UDim2.new(0,14,0,2), pos=UDim2.new(0.5,8,0.5,-1)},
    }
    local arms = {}
    for _, def in ipairs(armDefs) do
        local arm = Instance.new("Frame")
        arm.Name=def.name; arm.Size=def.size; arm.Position=def.pos
        arm.BackgroundColor3=col; arm.BorderSizePixel=0; arm.Parent=root; uiCorner(arm,2)
        local ol = Instance.new("Frame")
        ol.Size=UDim2.new(1,4,1,4); ol.Position=UDim2.new(0,-2,0,-2)
        ol.BackgroundColor3=Color3.fromRGB(0,0,0); ol.BackgroundTransparency=0.5
        ol.BorderSizePixel=0; ol.ZIndex=arm.ZIndex-1; ol.Parent=arm; uiCorner(ol,3)
        arms[def.name] = arm
    end
    local dol = Instance.new("Frame")
    dol.Size=UDim2.new(1,4,1,4); dol.Position=UDim2.new(0,-2,0,-2)
    dol.BackgroundColor3=Color3.fromRGB(0,0,0); dol.BackgroundTransparency=0.5
    dol.BorderSizePixel=0; dol.ZIndex=dot.ZIndex-1; dol.Parent=dot; uiCorner(dol,4)

    local function applyColor(c)
        dot.BackgroundColor3=c
        for _, arm in pairs(arms) do arm.BackgroundColor3=c end
    end

    if ColorStates.CrosshairRainbow then
        RainbowConns["crosshair"] = RunService.Heartbeat:Connect(function()
            if not Features.Crosshair then stopRainbowKey("crosshair") return end
            applyColor(Color3.fromHSV((tick()*0.6)%1, 1, 1))
        end)
    else
        applyColor(col)
    end

    if ColorStates.CrosshairSpin then
        local angle = 0
        Connections.CrosshairSpin = RunService.Heartbeat:Connect(function(dt)
            if not Features.Crosshair then
                if Connections.CrosshairSpin then Connections.CrosshairSpin:Disconnect(); Connections.CrosshairSpin=nil end
                return
            end
            angle = angle + dt * 180
            root.Rotation = angle % 360
        end)
    end

    -- Staggered fade in
    local pieces = {dot, arms.Top, arms.Bottom, arms.Left, arms.Right}
    for _, p in ipairs(pieces) do p.BackgroundTransparency = 1 end
    local delays = {0, 0.05, 0.05, 0.1, 0.1}
    for i, p in ipairs(pieces) do
        local d = delays[i]
        coroutine.wrap(function()
            wait(d)
            makeTween(p, 0.3, {BackgroundTransparency=0}):Play()
        end)()
    end
end

local function toggleCrosshair(enabled)
    if enabled then
        createCrosshair()
    else
        if CrosshairGui then
            local root = CrosshairGui:FindFirstChild("Root")
            if root then
                for _, c in pairs(root:GetChildren()) do
                    if c:IsA("Frame") then makeTween(c,0.25,{BackgroundTransparency=1}):Play() end
                end
            end
            coroutine.wrap(function() wait(0.3); destroyCrosshair() end)()
        end
    end
end

-- ── Particles ─────────────────────────────────────────────────────────────────
local function destroyParticles()
    stopRainbowKey("particles")
    if Connections.Particles then Connections.Particles:Disconnect(); Connections.Particles=nil end
    for _, orb in pairs(ParticleOrbs) do
        if orb and orb.Parent then orb:Destroy() end
    end
    ParticleOrbs = {}
end

local function createParticles()
    destroyParticles()
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end

    local NUM_ORBS=8; local RADIUS=3.5; local ORB_SIZE=0.35
    local SPEED=1.2;  local BOB_HEIGHT=1.2; local BOB_SPEED=0.8
    local col = ColorStates.ParticlesColor

    for i = 1, NUM_ORBS do
        local orb = Instance.new("Part")
        orb.Name="VenseOrb_"..i; orb.Size=Vector3.new(ORB_SIZE,ORB_SIZE,ORB_SIZE)
        orb.Color=col; orb.Material=Enum.Material.Neon
        orb.CanCollide=false; orb.Anchored=true; orb.CastShadow=false
        orb.TopSurface=Enum.SurfaceType.Smooth; orb.BottomSurface=Enum.SurfaceType.Smooth
        orb.Parent=workspace
        local mesh = Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=orb
        local bb = Instance.new("BillboardGui")
        bb.Size=UDim2.new(0,28,0,28); bb.AlwaysOnTop=false; bb.Adornee=orb; bb.Parent=orb
        local glow = Instance.new("ImageLabel")
        glow.Size=UDim2.new(1,0,1,0); glow.BackgroundTransparency=1
        glow.Image="rbxassetid://6407871923"
        glow.ImageColor3=col; glow.ImageTransparency=0.3; glow.Parent=bb
        table.insert(ParticleOrbs, orb)
    end

    local startTime = tick()
    Connections.Particles = RunService.Heartbeat:Connect(function()
        local char2 = getChar()
        if not char2 or not Features.Particles then destroyParticles() return end
        local root2 = char2:FindFirstChild("HumanoidRootPart"); if not root2 then return end
        local t = tick() - startTime
        local base = root2.Position

        for i, orb in ipairs(ParticleOrbs) do
            if not orb or not orb.Parent then continue end
            local ao = (i-1)/NUM_ORBS * math.pi*2
            local angle = t * SPEED * math.pi*2 + ao
            local bp = (i-1)/NUM_ORBS * math.pi*2
            local bobY = math.sin(t * BOB_SPEED * math.pi*2 + bp) * BOB_HEIGHT
            orb.CFrame = CFrame.new(base.X + math.cos(angle)*RADIUS, base.Y+1+bobY, base.Z + math.sin(angle)*RADIUS)
            local pulse = 1 + math.sin(t*3+bp)*0.15
            local sz = ORB_SIZE * pulse
            orb.Size = Vector3.new(sz,sz,sz)
            if ColorStates.ParticlesRainbow then
                local hue = ((t*0.4)+(i-1)/NUM_ORBS)%1
                local rc = Color3.fromHSV(hue,1,1)
                orb.Color=rc
                local bb2=orb:FindFirstChildOfClass("BillboardGui")
                if bb2 then local img=bb2:FindFirstChildOfClass("ImageLabel"); if img then img.ImageColor3=rc end end
            end
        end
    end)
end

local function toggleParticles(enabled)
    if enabled then createParticles() else destroyParticles() end
end

-- ── Color Picker popup ────────────────────────────────────────────────────────
local function createColorPicker(title, guiName, onSelect, extraOptions)
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local sg = Instance.new("ScreenGui")
    sg.Name=guiName; sg.ResetOnSpawn=false; sg.DisplayOrder=20; sg.Parent=playerGui

    local extraH = extraOptions and 50 or 0
    local H = 240 + extraH

    local frame = Instance.new("Frame")
    frame.Size=UDim2.new(0,0,0,0); frame.Position=UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3=Config.MainColor; frame.BorderSizePixel=0; frame.Parent=sg
    uiCorner(frame,12)
    makeTween(frame, 0.3, {Size=UDim2.new(0,340,0,H), Position=UDim2.new(0.5,-170,0.5,-H/2)}, Enum.EasingStyle.Back):Play()

    local titleBar = Instance.new("Frame")
    titleBar.Size=UDim2.new(1,0,0,44); titleBar.BackgroundColor3=Config.AccentColor
    titleBar.BorderSizePixel=0; titleBar.Parent=frame; uiCorner(titleBar,12)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size=UDim2.new(1,-50,1,0); titleLbl.Position=UDim2.new(0,14,0,0)
    titleLbl.BackgroundTransparency=1; titleLbl.Text=title
    titleLbl.TextColor3=Config.TextColor; titleLbl.Font=Enum.Font.GothamBold
    titleLbl.TextSize=16; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar

    local closeX = Instance.new("TextButton")
    closeX.Size=UDim2.new(0,36,0,36); closeX.Position=UDim2.new(1,-40,0,4)
    closeX.BackgroundColor3=Config.DarkColor; closeX.TextColor3=Config.TextColor
    closeX.Text="x"; closeX.TextSize=18; closeX.Font=Enum.Font.GothamBold
    closeX.BorderSizePixel=0; closeX.Parent=titleBar; uiCorner(closeX,6)
    closeX.MouseButton1Click:Connect(function() sg:Destroy() end)

    local grid = Instance.new("Frame")
    grid.Size=UDim2.new(1,-24,0,130); grid.Position=UDim2.new(0,12,0,54)
    grid.BackgroundTransparency=1; grid.Parent=frame
    local gl = Instance.new("UIGridLayout")
    gl.CellSize=UDim2.new(0,66,0,40); gl.CellPadding=UDim2.new(0,8,0,8)
    gl.SortOrder=Enum.SortOrder.LayoutOrder; gl.Parent=grid

    local selectedBtn = nil
    for i, preset in ipairs(PRESETS) do
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(0,66,0,40)
        btn.BackgroundColor3=preset.rainbow and Color3.fromRGB(255,80,80) or preset.color
        btn.BorderSizePixel=0; btn.Text=preset.name
        btn.TextColor3=(preset.name=="white" or preset.name=="yellow") and Color3.fromRGB(30,30,30) or Color3.fromRGB(255,255,255)
        btn.TextSize=11; btn.Font=Enum.Font.GothamBold; btn.LayoutOrder=i; btn.Parent=grid
        uiCorner(btn,7)
        if preset.rainbow then
            coroutine.wrap(function()
                while btn.Parent do
                    btn.BackgroundColor3=Color3.fromHSV((tick()*0.5)%1,1,1)
                    RunService.Heartbeat:Wait()
                end
            end)()
        end
        btn.MouseButton1Click:Connect(function()
            if selectedBtn then selectedBtn.BorderSizePixel=0 end
            btn.BorderSizePixel=2; selectedBtn=btn
            onSelect(preset)
        end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.12,{Size=UDim2.new(0,70,0,44)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.12,{Size=UDim2.new(0,66,0,40)}):Play() end)
    end

    if extraOptions then
        for idx, opt in ipairs(extraOptions) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size=UDim2.new(1,-24,0,36); optBtn.Position=UDim2.new(0,12,0,194+(idx-1)*46)
            optBtn.BackgroundColor3=opt.active() and Config.OnColor or Color3.fromRGB(200,80,80)
            optBtn.TextColor3=Config.TextColor
            optBtn.Text=opt.label..(opt.active() and ": on" or ": off")
            optBtn.Font=Enum.Font.GothamBold; optBtn.TextSize=13; optBtn.BorderSizePixel=0
            optBtn.Parent=frame; uiCorner(optBtn,8)
            optBtn.MouseButton1Click:Connect(function()
                opt.toggle()
                optBtn.Text=opt.label..(opt.active() and ": on" or ": off")
                makeTween(optBtn,0.2,{BackgroundColor3=opt.active() and Config.OnColor or Color3.fromRGB(200,80,80)}):Play()
            end)
        end
    end

    local doneBtn = Instance.new("TextButton")
    doneBtn.Size=UDim2.new(1,-24,0,34); doneBtn.Position=UDim2.new(0,12,1,-46)
    doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor
    doneBtn.Text="done"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=14
    doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,8)
    doneBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- ── Picker launchers ──────────────────────────────────────────────────────────
local function openHatPicker()
    createColorPicker("hat color", "HatColorPicker", function(preset)
        ColorStates.ChinaHatColor=preset.color; ColorStates.ChinaHatNeon=preset.neon; ColorStates.ChinaHatRainbow=preset.rainbow
        stopRainbowKey("hat")
        if Features.ChinaHat then
            applyHatColor(preset.color, preset.neon, preset.rainbow)
            if preset.rainbow then startHatRainbow() end
        end
    end, nil)
end

local function openHealthBarPicker()
    createColorPicker("health bar color", "HealthBarColorPicker", function(preset)
        ColorStates.HealthBarColor=preset.color; ColorStates.HealthBarNeon=preset.neon; ColorStates.HealthBarRainbow=preset.rainbow
        stopRainbowKey("healthbar")
        if Features.HealthBar then createHealthBar() end
    end, nil)
end

local function openCrosshairPicker()
    createColorPicker("crosshair color", "CrosshairColorPicker", function(preset)
        ColorStates.CrosshairColor=preset.color; ColorStates.CrosshairNeon=preset.neon; ColorStates.CrosshairRainbow=preset.rainbow
        stopRainbowKey("crosshair")
        if Features.Crosshair then createCrosshair() end
    end, {
        {
            label  = "⟳ spin",
            active = function() return ColorStates.CrosshairSpin end,
            toggle = function()
                ColorStates.CrosshairSpin = not ColorStates.CrosshairSpin
                if Features.Crosshair then createCrosshair() end
            end,
        }
    })
end

local function openParticlesPicker()
    createColorPicker("particles color", "ParticlesColorPicker", function(preset)
        ColorStates.ParticlesColor=preset.color; ColorStates.ParticlesNeon=preset.neon; ColorStates.ParticlesRainbow=preset.rainbow
        stopRainbowKey("particles")
        if Features.Particles then
            for _, orb in pairs(ParticleOrbs) do
                if orb and orb.Parent then
                    orb.Color=preset.color
                    local bb2=orb:FindFirstChildOfClass("BillboardGui")
                    if bb2 then local img=bb2:FindFirstChildOfClass("ImageLabel"); if img then img.ImageColor3=preset.color end end
                end
            end
        end
    end, nil)
end

-- ── CharacterAdded (placed AFTER all functions are defined) ───────────────────
player.CharacterAdded:Connect(function()
    wait(0.5)
    if Features.Noclip        then toggleNoclip(false);       toggleNoclip(true)       end
    if Features.InfiniteJump  then toggleInfiniteJump(false); toggleInfiniteJump(true) end
    if Features.ChinaHat      then createChinaHat()   end
    if Features.HealthBar     then createHealthBar()  end
    if Features.Particles     then createParticles()  end
end)

-- ── Main GUI ──────────────────────────────────────────────────────────────────
local function createMainGui(fromMinimized, minimizedSg, minimizedBtn)
    if playerGui:FindFirstChild("VenseMinimized") then playerGui.VenseMinimized:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name="VenseGui"; sg.ResetOnSpawn=false; sg.Parent=playerGui

    local canvas = Instance.new("Frame")
    canvas.Name="Canvas"; canvas.Size=UDim2.new(0,340,0,480)
    canvas.Position=UDim2.new(0.5,-170,0.5,-240)
    canvas.BackgroundTransparency=1; canvas.BorderSizePixel=0; canvas.Parent=sg

    local mainFrame = Instance.new("Frame")
    mainFrame.Name="MainFrame"; mainFrame.Size=UDim2.new(1,0,1,0)
    mainFrame.BackgroundColor3=Config.MainColor; mainFrame.BackgroundTransparency=1
    mainFrame.BorderSizePixel=0; mainFrame.Active=true; mainFrame.Parent=canvas
    uiCorner(mainFrame,12)

    if fromMinimized and minimizedBtn then
        local vp = minimizedBtn.AbsolutePosition
        local vs = minimizedBtn.AbsoluteSize
        canvas.Size=UDim2.new(0,vs.X,0,vs.Y); canvas.Position=UDim2.new(0,vp.X,0,vp.Y)
        if minimizedSg then minimizedSg:Destroy() end
        TweenService:Create(canvas, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=UDim2.new(0,340,0,480), Position=UDim2.new(0.5,-170,0.5,-240)}):Play()
        makeTween(mainFrame, 0.25, {BackgroundTransparency=0}):Play()
    else
        canvas.Position=UDim2.new(0.5,-170,0.5,-260)
        TweenService:Create(canvas, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position=UDim2.new(0.5,-170,0.5,-240)}):Play()
        makeTween(mainFrame, 0.35, {BackgroundTransparency=0}):Play()
    end

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size=UDim2.new(1,0,0,50); titleBar.BackgroundColor3=Config.AccentColor
    titleBar.BorderSizePixel=0; titleBar.Parent=mainFrame; uiCorner(titleBar,12)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size=UDim2.new(1,-60,1,0); titleLbl.Position=UDim2.new(0,14,0,0)
    titleLbl.BackgroundTransparency=1; titleLbl.Text="$vense.lua$"
    titleLbl.TextColor3=Config.TextColor; titleLbl.TextSize=17
    titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    titleLbl.Parent=titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size=UDim2.new(0,40,0,40); closeBtn.Position=UDim2.new(1,-45,0,5)
    closeBtn.BackgroundColor3=Config.DarkColor; closeBtn.TextColor3=Config.TextColor
    closeBtn.Text="—"; closeBtn.TextSize=18; closeBtn.Font=Enum.Font.GothamBold
    closeBtn.BorderSizePixel=0; closeBtn.Parent=titleBar; uiCorner(closeBtn,8)

    -- Scrollable content
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size=UDim2.new(1,0,1,-50); scrollFrame.Position=UDim2.new(0,0,0,50)
    scrollFrame.BackgroundTransparency=1; scrollFrame.BorderSizePixel=0
    scrollFrame.ScrollBarThickness=3; scrollFrame.ScrollBarImageColor3=Config.AccentColor
    scrollFrame.CanvasSize=UDim2.new(0,0,0,0); scrollFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scrollFrame.Parent=mainFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft=UDim.new(0,15); pad.PaddingRight=UDim.new(0,15)
    pad.PaddingTop=UDim.new(0,15);  pad.PaddingBottom=UDim.new(0,15)
    pad.Parent=scrollFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding=UDim.new(0,12); listLayout.FillDirection=Enum.FillDirection.Vertical
    listLayout.SortOrder=Enum.SortOrder.LayoutOrder; listLayout.Parent=scrollFrame

    local function sectionLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,0,0,18); lbl.BackgroundTransparency=1; lbl.Text=text
        lbl.TextColor3=Color3.fromRGB(120,120,130); lbl.TextSize=11
        lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.Parent=scrollFrame
    end

    -- Simple toggle button
    local function makeFeatureBtn(name, desc, featureKey, cb)
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor
        btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)

        local bp=Instance.new("UIPadding")
        bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12)
        bp.PaddingTop=UDim.new(0,8);   bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn

        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal
        hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn

        local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.82,0,1,0)
        textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical
        vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox

        local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25)
        nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor
        nameLbl.TextSize=16; nameLbl.Font=Enum.Font.GothamBold
        nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox

        local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35)
        descLbl.BackgroundTransparency=1; descLbl.Text=desc
        descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=11
        descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left
        descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox

        local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,50,1,0)
        indicator.BackgroundTransparency=1
        indicator.Text=Features[featureKey] and "on" or "off"
        indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80)
        indicator.TextSize=14; indicator.Font=Enum.Font.GothamBold
        indicator.LayoutOrder=2; indicator.Parent=btn

        btn.MouseButton1Click:Connect(function()
            Features[featureKey]=not Features[featureKey]
            indicator.Text=Features[featureKey] and "on" or "off"
            indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80)
            cb(Features[featureKey])
        end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)
    end

    -- Toggle + COLOR button
    local function makeColorFeatureBtn(name, desc, featureKey, cb, colorPickerFn)
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor
        btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)

        local bp=Instance.new("UIPadding")
        bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12)
        bp.PaddingTop=UDim.new(0,8);   bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn

        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal
        hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn

        local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.60,0,1,0)
        textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical
        vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox

        local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25)
        nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor
        nameLbl.TextSize=16; nameLbl.Font=Enum.Font.GothamBold
        nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox

        local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35)
        descLbl.BackgroundTransparency=1; descLbl.Text=desc
        descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=11
        descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left
        descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox

        local rightSide=Instance.new("Frame"); rightSide.Size=UDim2.new(0.40,0,1,0)
        rightSide.BackgroundTransparency=1; rightSide.LayoutOrder=2; rightSide.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal
        rl.HorizontalAlignment=Enum.HorizontalAlignment.Right
        rl.VerticalAlignment=Enum.VerticalAlignment.Center
        rl.Padding=UDim.new(0,6); rl.Parent=rightSide

        local colorBtn=Instance.new("TextButton"); colorBtn.Size=UDim2.new(0,52,0,28)
        colorBtn.BackgroundColor3=Config.AccentColor; colorBtn.TextColor3=Config.TextColor
        colorBtn.Text="color"; colorBtn.TextSize=10; colorBtn.Font=Enum.Font.GothamBold
        colorBtn.BorderSizePixel=0; colorBtn.LayoutOrder=1; colorBtn.Parent=rightSide; uiCorner(colorBtn,6)

        local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,36,0,28)
        indicator.BackgroundTransparency=1
        indicator.Text=Features[featureKey] and "on" or "off"
        indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80)
        indicator.TextSize=13; indicator.Font=Enum.Font.GothamBold
        indicator.LayoutOrder=2; indicator.Parent=rightSide

        colorBtn.MouseButton1Click:Connect(colorPickerFn)
        btn.MouseButton1Click:Connect(function()
            Features[featureKey]=not Features[featureKey]
            indicator.Text=Features[featureKey] and "on" or "off"
            indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80)
            cb(Features[featureKey])
        end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)
    end

    -- Build buttons
    sectionLabel("  cheats")
    makeFeatureBtn("noclip", "walk through walls and objects", "Noclip", toggleNoclip)
    makeFeatureBtn("infinite jump", "jump infinitely without limit", "InfiniteJump", toggleInfiniteJump)

    sectionLabel("  visuals")
    makeColorFeatureBtn("china hat", "rice hat on your head", "ChinaHat", function(enabled)
        if enabled then createChinaHat() else removeChinaHat() end
    end, openHatPicker)
    makeColorFeatureBtn("health bar", "animated hp bar at bottom of screen", "HealthBar", toggleHealthBar, openHealthBarPicker)
    makeColorFeatureBtn("crosshair", "custom crosshair with spin option", "Crosshair", toggleCrosshair, openCrosshairPicker)
    makeColorFeatureBtn("particles", "glowing orbs orbiting your character", "Particles", toggleParticles, openParticlesPicker)

    sectionLabel("  performance")
    makeFeatureBtn("boost fps", "disable shadows and textures for better fps", "BoostFPS", boostFPS)

    -- Dragging
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    mainFrame.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=canvas.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            dragInput=input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then
            local d=input.Position-dragStart
            canvas.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(canvas, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),
            {Size=UDim2.new(0,50,0,50), Position=UDim2.new(0,20,1,-70)}):Play()
        makeTween(mainFrame, 0.25, {BackgroundTransparency=1}):Play()
        coroutine.wrap(function()
            wait(0.32)
            sg:Destroy()
            createMinimizedButton()
        end)()
    end)
end

-- ── Minimized V button ────────────────────────────────────────────────────────
function createMinimizedButton()
    if playerGui:FindFirstChild("VenseMinimized") then playerGui.VenseMinimized:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name="VenseMinimized"; sg.ResetOnSpawn=false; sg.Parent=playerGui

    local btn = Instance.new("TextButton")
    btn.Name="MinimizedBtn"; btn.Size=UDim2.new(0,50,0,50)
    btn.Position=UDim2.new(0,20,1,-70); btn.BackgroundColor3=Config.AccentColor
    btn.TextColor3=Color3.fromRGB(255,255,255); btn.Text="V"
    btn.TextSize=22; btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0; btn.Parent=sg; uiCorner(btn,10)

    coroutine.wrap(function()
        while btn.Parent do
            makeTween(btn,0.8,{Size=UDim2.new(0,54,0,54)}):Play(); wait(0.8)
            if not btn.Parent then break end
            makeTween(btn,0.8,{Size=UDim2.new(0,50,0,50)}):Play(); wait(0.8)
        end
    end)()

    local clicked = false
    local function onButtonClick()
        if clicked then return end; clicked=true
        makeTween(btn,0.12,{Size=UDim2.new(0,42,0,42)}):Play()
        wait(0.12)
        createMainGui(true, sg, btn)
    end

    btn.MouseButton1Click:Connect(onButtonClick)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch then onButtonClick() end
    end)
end

-- ── Init ──────────────────────────────────────────────────────────────────────
createInjectionAnimation()
wait(2)
createMainGui(false, nil, nil)
