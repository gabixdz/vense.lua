--[[ $vense.lua$ V4 ]]

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

-- ══════════════════════════════════════════════════════════════════════════════
-- VISUALS.WIN EFFECTS  (functions only — no GUI changes above this line)
-- ══════════════════════════════════════════════════════════════════════════════

local VSettings = {}
local VEnabled  = {}
local VConns    = {}
local VObjects  = {}
local VRainbow  = {}

-- shared helpers
local function rainbowColor(offset)
    return Color3.fromHSV(((tick()*0.4)+(offset or 0))%1, 1, 1)
end
local function vStopRainbow(k)
    if VRainbow[k] then VRainbow[k]:Disconnect(); VRainbow[k]=nil end
end
local function vCleanObjects(k)
    if VObjects[k] then
        for _, o in pairs(VObjects[k]) do
            if typeof(o)=="Instance" and o.Parent then o:Destroy() end
        end
        VObjects[k] = {}
    end
end
local function vDisconn(k)
    if VConns[k] then
        if typeof(VConns[k])=="RBXScriptConnection" then
            VConns[k]:Disconnect()
        elseif type(VConns[k])=="table" then
            for _, c in pairs(VConns[k]) do
                if typeof(c)=="RBXScriptConnection" then c:Disconnect() end
            end
        end
        VConns[k] = nil
    end
end
local function makePart(size, color, mat, parent)
    local p = Instance.new("Part")
    p.Size = size or Vector3.new(1,1,1); p.Color = color or Color3.new(1,1,1)
    p.Material = mat or Enum.Material.Neon
    p.CanCollide=false; p.Anchored=true; p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent = parent or workspace; return p
end
local function vGetColor(k, offset)
    if VSettings[k] and VSettings[k].rainbow then return rainbowColor(offset or 0) end
    return VSettings[k] and VSettings[k].color or Color3.fromRGB(100,200,255)
end
local function getHRP() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar(); return c and c:FindFirstChild("Humanoid") end

-- ring builder: returns a table of SEGS parts forming a flat circle of radius R
local function buildRing(SEGS, R, col)
    local parts = {}
    for i = 1, SEGS do
        local a1=(i-1)/SEGS*math.pi*2; local a2=i/SEGS*math.pi*2
        local p1=Vector3.new(math.cos(a1),0,math.sin(a1))
        local p2=Vector3.new(math.cos(a2),0,math.sin(a2))
        local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
        local seg=makePart(Vector3.new(len*R,0.08,0.12),col)
        seg.CFrame=CFrame.new(mid*R, mid*R+Vector3.new(-(p2-p1).Z,0,(p2-p1).X))
        table.insert(parts,seg)
    end
    return parts
end
-- update existing ring parts to radius R, centered at origin (caller adds center)
local function updateRing(parts, SEGS, center, R, transparency)
    for i, seg in ipairs(parts) do
        if not seg.Parent then continue end
        local a1=(i-1)/SEGS*math.pi*2; local a2=i/SEGS*math.pi*2
        local p1=Vector3.new(math.cos(a1),0,math.sin(a1))
        local p2=Vector3.new(math.cos(a2),0,math.sin(a2))
        local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
        seg.Size=Vector3.new(len*R,0.07,0.1)
        seg.CFrame=CFrame.new(center+mid*R, center+mid*R+Vector3.new(-(p2-p1).Z,0,(p2-p1).X))
        if transparency then seg.Transparency=transparency end
    end
end

-- effect list
local VisualOrder = {
    {"Trail",          "body trail",       "glowing trail follows your movement"},
    {"JumpCircle",     "jump circle",      "circle expands on the ground when you jump"},
    {"Shockwave",      "shockwave",        "rings explode outward when you land"},
    {"Wings",          "wings",            "glowing wings attached to your back"},
    {"GroundGlow",     "ground glow",      "pulsing ring beneath your feet"},
    {"HeadAura",       "head aura",        "glowing sphere around your head"},
    {"FootSparks",     "footstep sparks",  "sparks burst under your feet"},
    {"NameTag",        "nametag",          "glowing name tag above your head"},
    {"Runes",          "floating runes",   "runic symbols orbit around you"},
    {"Lightning",      "lightning",        "lightning crackles around you"},
    {"Smoke",          "smoke trail",      "soft smoke drifts behind you"},
    {"Petals",         "petal rain",       "flower petals float around you"},
    {"StarBurst",      "star burst",       "stars shoot outward in bursts"},
    {"Ghost",          "ghost echo",       "ghost copies trail behind you"},
    {"Bubbles",        "bubbles",          "bubbles float upward around you"},
    {"FireCrown",      "fire crown",       "flames crown your head"},
    {"IceCrystals",    "ice crystals",     "ice shards orbit around you"},
    {"NeonGrid",       "neon grid",        "neon grid follows you on the ground"},
    {"Halo",           "halo",             "glowing ring hovers above your head"},
    {"Dragon",         "dragon aura",      "dragon energy spirals around you"},
    {"MusicBars",      "music bars",       "equalizer bars pulse around you"},
    {"Glitch",         "glitch",           "your body flickers and glitches"},
    {"Constellation",  "constellation",    "connected stars orbit around you"},
    {"DeathExplosion", "death explosion",  "rings explode outward when you die"},
    {"SpiralVortex",   "spiral vortex",    "particles spiral upward around you"},
    {"Meteors",        "meteor shower",    "meteors fall down around you"},
    {"Aura",           "aura",             "layered glow aura around your body"},
    {"PortalRing",     "portal ring",      "spinning ring orbits your waist"},
    {"SparkleBurst",   "sparkle burst",    "sparkles pop all over your body"},
}

for _, v in ipairs(VisualOrder) do
    local k = v[1]
    VSettings[k] = {
        color=Color3.fromRGB(100,200,255), rainbow=false,
        size=1.0, speed=1.0, opacity=0.8, count=6, delay=1.5,
    }
    VEnabled[k]=false; VObjects[k]={}
end

-- ── VFuncs ────────────────────────────────────────────────────────────────────
local VFuncs = {}

VFuncs["Trail"] = {
    start = function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
        local a0=Instance.new("Attachment"); a0.Position=Vector3.new(0,1,0);  a0.Parent=hrp
        local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,-1,0); a1.Parent=hrp
        local tr=Instance.new("Trail")
        tr.Attachment0=a0; tr.Attachment1=a1; tr.Lifetime=0.8; tr.MinLength=0
        tr.FaceCamera=true; tr.LightEmission=1
        tr.Color=ColorSequence.new(s.color)
        tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1-s.opacity),NumberSequenceKeypoint.new(1,1)})
        tr.WidthScale=NumberSequence.new(s.size*2); tr.Parent=hrp
        VObjects[k]={a0,a1,tr}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function()
            if not VEnabled[k] then vStopRainbow(k) return end; tr.Color=ColorSequence.new(rainbowColor())
        end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

VFuncs["JumpCircle"] = {
    start = function(k)
        local hum=getHum(); if not hum then return end
        VConns[k]=hum.Jumping:Connect(function(active)
            if not active then return end
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
            local SEGS=36; local R0=s.size*3; local col=vGetColor(k)
            local parts=buildRing(SEGS,R0,col)
            -- offset all parts to be centered on landing spot
            local base=hrp.Position-Vector3.new(0,3,0)
            for _,seg in ipairs(parts) do seg.CFrame=seg.CFrame+base end
            local t0=tick(); local conn; conn=RunService.Heartbeat:Connect(function()
                local el=tick()-t0; if el>0.6 then conn:Disconnect()
                    for _,seg in ipairs(parts) do if seg.Parent then seg:Destroy() end end; return end
                local prog=el/0.6; local R=R0+s.size*8*prog
                updateRing(parts,SEGS,base,R,prog)
                if s.rainbow then for _,seg in ipairs(parts) do if seg.Parent then seg.Color=rainbowColor() end end end
            end)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Shockwave"] = {
    start = function(k)
        local wasInAir=false
        VConns[k]=RunService.Heartbeat:Connect(function()
            if not VEnabled[k] then return end; local h=getHum(); if not h then return end
            local inAir=h:GetState()==Enum.HumanoidStateType.Freefall or h:GetState()==Enum.HumanoidStateType.Jumping
            if wasInAir and not inAir then
                local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
                local base=hrp.Position-Vector3.new(0,3,0)
                for wave=1,3 do coroutine.wrap(function()
                    task.wait(wave*0.07)
                    local SEGS=36; local MAXR=s.size*(5+wave*3); local col=vGetColor(k)
                    local parts=buildRing(SEGS,0.3,col)
                    for _,seg in ipairs(parts) do seg.CFrame=seg.CFrame+base end
                    local t0=tick(); local conn; conn=RunService.Heartbeat:Connect(function()
                        local el=tick()-t0; if el>0.55 then conn:Disconnect()
                            for _,seg in ipairs(parts) do if seg.Parent then seg:Destroy() end end; return end
                        local prog=el/0.55; local R=MAXR*prog
                        updateRing(parts,SEGS,base,R,prog)
                    end)
                end)() end
            end; wasInAir=inAir
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Wings"] = {
    start = function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local wings={}
        for side=-1,1,2 do for seg=1,4 do
            local w=makePart(Vector3.new(0.15,0.8+seg*0.2,1.2+seg*0.3)*s.size,vGetColor(k))
            w.Transparency=1-s.opacity; table.insert(wings,w)
        end end
        VObjects[k]=wings; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp2=getHRP(); if not hrp2 then return end; local s2=VSettings[k]; local t=tick()-t0
            local flap=math.sin(t*3)*0.3; local idx=0
            for side=-1,1,2 do for seg=1,4 do idx=idx+1; local w=wings[idx]; if not w or not w.Parent then continue end
                w.CFrame=hrp2.CFrame*CFrame.new((side*(1+seg*0.7+flap*seg*0.2))*s2.size,(seg*0.5+math.sin(t*3+seg)*0.2)*s2.size,-seg*0.3*s2.size)*CFrame.Angles(0,0,side*math.rad(30+seg*10+flap*20))
                if s2.rainbow then w.Color=rainbowColor(idx/8) end
            end end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["GroundGlow"] = {
    start = function(k)
        local s=VSettings[k]; local SEGS=48; local parts={}
        for i=1,SEGS do
            local seg=makePart(Vector3.new(0.5,0.07,0.12),vGetColor(k)); seg.Transparency=1-s.opacity*0.7
            table.insert(parts,seg)
        end
        VObjects[k]=parts; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            local R=4*s2.size*(1+math.sin(t*2)*0.08)
            local base=hrp.Position-Vector3.new(0,3,0)
            updateRing(parts,SEGS,base,R,nil)
            if s2.rainbow then for i,seg in ipairs(parts) do if seg.Parent then seg.Color=rainbowColor((i-1)/SEGS) end end end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["HeadAura"] = {
    start = function(k)
        local s=VSettings[k]; local aura=makePart(Vector3.new(3,3,3)*s.size,vGetColor(k))
        aura.Transparency=1-s.opacity*0.5
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=aura
        VObjects[k]={aura}; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
            local s2=VSettings[k]; local t=tick()-t0; local pulse=1+math.sin(t*2.5)*0.08
            local sz=3*s2.size*pulse; aura.Size=Vector3.new(sz,sz,sz); aura.CFrame=CFrame.new(head.Position)
            if s2.rainbow then aura.Color=rainbowColor() end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["FootSparks"] = {
    start = function(k)
        local lastPos=nil; local stepTimer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; stepTimer=stepTimer+dt
            if lastPos and (hrp.Position-lastPos).Magnitude>1.2 and stepTimer>0.1 then
                stepTimer=0; local col=vGetColor(k)
                for _=1,5 do
                    local spark=makePart(Vector3.new(0.1,0.1,0.1)*s.size,col)
                    local foot=hrp.Position-Vector3.new(math.random(-2,2)*0.3,3,math.random(-2,2)*0.3)
                    spark.CFrame=CFrame.new(foot)
                    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,26*s.size,0,26*s.size); bb.Adornee=spark; bb.AlwaysOnTop=false; bb.Parent=spark
                    local img=Instance.new("ImageLabel"); img.Size=UDim2.new(1,0,1,0); img.BackgroundTransparency=1; img.Image="rbxassetid://6407871923"; img.ImageColor3=col; img.Parent=bb
                    makeTween(spark,0.35,{CFrame=CFrame.new(foot+Vector3.new(math.random(-3,3),math.random(2,5),math.random(-3,3))),Transparency=1}):Play()
                    game:GetService("Debris"):AddItem(spark,0.4)
                end
            end; lastPos=hrp.Position
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["NameTag"] = {
    start = function(k)
        local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
        local s=VSettings[k]
        local bg=Instance.new("BillboardGui"); bg.Size=UDim2.new(0,220*s.size,0,44); bg.StudsOffset=Vector3.new(0,3.5,0); bg.Adornee=head; bg.AlwaysOnTop=true; bg.Parent=head
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=17*s.size; lbl.TextColor3=s.color; lbl.TextStrokeTransparency=0.3
        local mode=s.nameMode or "username"
        lbl.Text="✦ "..(mode=="displayname" and player.DisplayName or mode=="custom" and (s.customName or player.Name) or player.Name).." ✦"
        lbl.Parent=bg; VObjects[k]={bg}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function() if not VEnabled[k] then vStopRainbow(k) return end; lbl.TextColor3=rainbowColor() end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

VFuncs["Runes"] = {
    start = function(k)
        local RC={"ᚠ","ᚢ","ᚦ","ᚨ","ᚱ","ᚲ","ᚷ","ᚹ","ᚺ","ᚾ","ᛁ","ᛃ","ᛇ","ᛈ","ᛉ","ᛊ","ᛏ","ᛒ","ᛖ","ᛗ","ᛚ","ᛜ","ᛞ","ᛟ"}
        local s=VSettings[k]; local n=math.floor(s.count); local runes={}
        for i=1,n do
            local part=makePart(Vector3.new(0.1,0.1,0.1),Color3.fromRGB(1,1,1)); part.Transparency=1
            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,40*s.size,0,40*s.size); bb.Adornee=part; bb.Parent=part
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=RC[math.random(#RC)]; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=28*s.size; lbl.TextColor3=s.color; lbl.TextStrokeTransparency=0.2; lbl.Parent=bb
            table.insert(runes,{part=part,lbl=lbl})
        end
        local objList={}; for _,r in ipairs(runes) do table.insert(objList,r.part) end; VObjects[k]=objList; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,r in ipairs(runes) do if not r.part.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*0.5+ao; local yBob=math.sin(t*1.2+ao)*1.5+1
                r.part.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*4*s2.size,yBob,math.sin(angle)*4*s2.size))
                if s2.rainbow then r.lbl.TextColor3=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Lightning"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.08/s.speed then return end; timer=0
            local pos=hrp.Position+Vector3.new(math.random(-2,2),math.random(-1,2),math.random(-2,2))
            for _=1,math.random(4,8) do
                local nextPos=pos+Vector3.new(math.random(-2,2),math.random(-2,2),math.random(-2,2))*s.size
                local len=(nextPos-pos).Magnitude; local bolt=makePart(Vector3.new(0.05,0.05,len),vGetColor(k))
                bolt.CFrame=CFrame.new((pos+nextPos)/2,nextPos); bolt.Transparency=0.1
                makeTween(bolt,0.1,{Transparency=1}):Play(); game:GetService("Debris"):AddItem(bolt,0.12); pos=nextPos
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Smoke"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.05/s.speed then return end; timer=0
            local puff=makePart(Vector3.new(1,1,1)*s.size*0.8,vGetColor(k)); puff.Transparency=1-s.opacity*0.5
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=puff
            puff.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-1,1)*0.3,math.random(-1,0),math.random(-1,1)*0.3))
            local sz=s.size*(2+math.random()*2)
            makeTween(puff,0.8,{Size=Vector3.new(sz,sz,sz),Transparency=1,CFrame=CFrame.new(puff.Position+Vector3.new(math.random(-1,1),2,math.random(-1,1)))}):Play()
            game:GetService("Debris"):AddItem(puff,0.9)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Petals"] = {
    start = function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local petals={}
        for i=1,n do local p=makePart(Vector3.new(0.2,0.05,0.3)*s.size,vGetColor(k)); p.Transparency=0.2; table.insert(petals,p) end
        VObjects[k]=petals
        local off={}; for i=1,n do off[i]={x=math.random(-5,5),y=math.random(-4,6),z=math.random(-5,5),t=math.random()*10} end
        local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,p in ipairs(petals) do if not p.Parent then continue end; local o=off[i]
                p.CFrame=CFrame.new(hrp.Position+Vector3.new(o.x+math.sin(t*0.7+o.t)*1.5,o.y-((t*0.5+o.t)%8)-2,o.z+math.cos(t*0.5+o.t)*1.5))*CFrame.Angles(t*0.5+o.t,t*0.3,t*0.7)
                if s2.rainbow then p.Color=rainbowColor(i/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["StarBurst"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<(s.delay or 1.5)/s.speed then return end; timer=0
            for i=1,12 do
                local star=makePart(Vector3.new(0.12,0.12,0.5)*s.size,vGetColor(k))
                local angle=(i-1)/12*math.pi*2; local dir=Vector3.new(math.cos(angle),math.random(-1,1)*0.3,math.sin(angle))
                star.CFrame=CFrame.new(hrp.Position,hrp.Position+dir)
                makeTween(star,0.5,{CFrame=CFrame.new(hrp.Position+dir*8*s.size),Transparency=1,Size=Vector3.new(0.05,0.05,0.1)}):Play()
                game:GetService("Debris"):AddItem(star,0.55)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Ghost"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local char=getChar(); if not char then return end; local s=VSettings[k]; timer=timer+dt
            if timer<(s.delay or 0.12)/s.speed then return end; timer=0
            for _,part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                    local ghost=makePart(part.Size,s.rainbow and rainbowColor() or s.color)
                    ghost.CFrame=part.CFrame; ghost.Transparency=1-s.opacity*0.4
                    for _,v in pairs(part:GetChildren()) do if v:IsA("SpecialMesh") then v:Clone().Parent=ghost end end
                    makeTween(ghost,0.4,{Transparency=1}):Play(); game:GetService("Debris"):AddItem(ghost,0.45)
                end
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Bubbles"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.3 then return end; timer=0
            for _=1,math.floor(s.count*0.5+1) do
                local sz=(0.2+math.random()*0.5)*s.size; local bubble=makePart(Vector3.new(sz,sz,sz),vGetColor(k)); bubble.Transparency=0.5
                local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=bubble
                bubble.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-3,3),0,math.random(-3,3)))
                local rise=math.random(5,12)
                makeTween(bubble,rise*0.3,{CFrame=CFrame.new(bubble.Position+Vector3.new(math.random(-2,2),rise,math.random(-2,2))),Transparency=1}):Play()
                game:GetService("Debris"):AddItem(bubble,rise*0.35)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["FireCrown"] = {
    start = function(k)
        local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
        local s=VSettings[k]; local n=math.floor(s.count); local flames={}
        for i=1,n do local flame=makePart(Vector3.new(0.2,0.2,0.2)*s.size,vGetColor(k)); flame.Parent=workspace; table.insert(flames,flame) end
        VObjects[k]=flames; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char2=getChar(); if not char2 then return end; local head2=char2:FindFirstChild("Head"); if not head2 then return end
            local s2=VSettings[k]; local t=tick()-t0
            for i,flame in ipairs(flames) do if not flame.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local height=1+math.sin(t*5+ao)*0.3+0.8
                flame.CFrame=CFrame.new(head2.Position+Vector3.new(math.cos(ao)*0.7*s2.size,height+math.sin(t*8+ao)*0.15,math.sin(ao)*0.7*s2.size))
                local sz=(0.15+math.abs(math.sin(t*6+ao))*0.15)*s2.size; flame.Size=Vector3.new(sz,sz*1.5,sz)
                if s2.rainbow then flame.Color=rainbowColor(i/n)
                else local c=s2.color; flame.Color=Color3.new(math.min(c.R+0.2,1),c.G*math.abs(math.sin(t*3+ao)),c.B*0.2) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["IceCrystals"] = {
    start = function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local crystals={}
        for i=1,n do
            local cry=makePart(Vector3.new(0.2*s.size,1.2*s.size,0.2*s.size),vGetColor(k))
            cry.Material=Enum.Material.Glass; cry.Transparency=1-s.opacity*0.8; table.insert(crystals,cry)
        end
        VObjects[k]=crystals; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,cry in ipairs(crystals) do if not cry.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*s2.speed+ao
                cry.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*3*s2.size,math.sin(t*1.5+ao)*0.5,math.sin(angle)*3*s2.size))*CFrame.Angles(t*2+ao,math.sin(t+ao)*0.5,t+ao)
                if s2.rainbow then cry.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["NeonGrid"] = {
    start = function(k)
        local s=VSettings[k]; local sz=s.size*8; local lines={}
        for i=-4,4 do for _,axis in ipairs({"x","z"}) do
            local line=makePart(axis=="x" and Vector3.new(sz,0.05,0.05) or Vector3.new(0.05,0.05,sz),vGetColor(k))
            line.Transparency=1-s.opacity*0.7; table.insert(lines,{part=line,offset=i*s.size,axis=axis})
        end end
        local objList={}; for _,l in ipairs(lines) do table.insert(objList,l.part) end; VObjects[k]=objList
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local base=hrp.Position-Vector3.new(0,3,0)
            for _,l in ipairs(lines) do if not l.part.Parent then continue end
                l.part.CFrame=l.axis=="x" and CFrame.new(base+Vector3.new(0,0,l.offset)) or CFrame.new(base+Vector3.new(l.offset,0,0))
                if s2.rainbow then l.part.Color=rainbowColor(l.offset/10) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Halo"] = {
    start = function(k)
        local s=VSettings[k]; local SEGS=40; local parts={}
        for i=1,SEGS do
            local seg=makePart(Vector3.new(0.35*s.size,0.18*s.size,0.18*s.size),vGetColor(k)); seg.Transparency=1-s.opacity; table.insert(parts,seg)
        end
        VObjects[k]=parts; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
            local s2=VSettings[k]; local t=tick()-t0; local R=1.5*s2.size; local tilt=math.rad(12)
            local center=head.Position+Vector3.new(0,1.2+math.sin(t*1.5)*0.12,0)
            for i,seg in ipairs(parts) do if not seg.Parent then continue end
                local ang=(i-1)/SEGS*math.pi*2+t*0.4; local angN=i/SEGS*math.pi*2+t*0.4
                local p1=Vector3.new(math.cos(ang)*R,math.sin(ang)*R*math.sin(tilt),math.sin(ang)*R*math.cos(tilt))
                local p2=Vector3.new(math.cos(angN)*R,math.sin(angN)*R*math.sin(tilt),math.sin(angN)*R*math.cos(tilt))
                local len=(p2-p1).Magnitude; seg.Size=Vector3.new(len+0.02,0.18*s2.size,0.15*s2.size)
                seg.CFrame=CFrame.new(center+(p1+p2)/2,center+p2)
                if s2.rainbow then seg.Color=rainbowColor((i-1)/SEGS) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Dragon"] = {
    start = function(k)
        local s=VSettings[k]; local segments=20; local parts={}
        for i=1,segments do
            local p=makePart(Vector3.new(0.3,0.3,0.3)*s.size,vGetColor(k)); p.Transparency=1-s.opacity*0.7
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=p; table.insert(parts,p)
        end
        VObjects[k]=parts; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,p in ipairs(parts) do if not p.Parent then continue end
                local phase=(i-1)/segments*math.pi*2; local spiralAngle=t*s2.speed*2+phase; local radius=(2+math.sin(phase))*s2.size
                p.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(spiralAngle)*radius,math.sin(t*s2.speed+phase)*2.5,math.sin(spiralAngle)*radius))
                local sz=(0.2+math.abs(math.sin(t*4+phase))*0.15)*s2.size; p.Size=Vector3.new(sz,sz,sz)
                if s2.rainbow then p.Color=rainbowColor(phase/(math.pi*2)) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["MusicBars"] = {
    start = function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local bars={}
        for i=1,n do local bar=makePart(Vector3.new(0.3*s.size,1,0.3*s.size),vGetColor(k)); bar.Transparency=0.2; table.insert(bars,bar) end
        VObjects[k]=bars; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,bar in ipairs(bars) do if not bar.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local height=1+math.abs(math.sin(t*s2.speed*3+ao*2))*3*s2.size
                bar.Size=Vector3.new(0.3*s2.size,height,0.3*s2.size); bar.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(ao)*4*s2.size,height/2-1,math.sin(ao)*4*s2.size))
                if s2.rainbow then bar.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Glitch"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local char=getChar(); if not char then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.15/s.speed then return end; timer=0; if math.random()>0.4 then return end
            for _,part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and math.random()>0.5 then
                    local ghost=makePart(part.Size,s.rainbow and rainbowColor() or s.color)
                    ghost.CFrame=part.CFrame*CFrame.new(math.random(-1,1)*0.5,math.random(-1,1)*0.3,math.random(-1,1)*0.5); ghost.Transparency=1-s.opacity*0.6
                    makeTween(ghost,0.08,{Transparency=1}):Play(); game:GetService("Debris"):AddItem(ghost,0.1)
                end
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Constellation"] = {
    start = function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local stars={}; local beams={}
        for i=1,n do
            local star=makePart(Vector3.new(0.18,0.18,0.18)*s.size,vGetColor(k)); local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=star; table.insert(stars,star)
        end
        for i=1,n do local beam=makePart(Vector3.new(0.04,0.04,1),vGetColor(k)); beam.Transparency=0.5; table.insert(beams,beam) end
        local objList={}; for _,s2 in ipairs(stars) do table.insert(objList,s2) end; for _,b in ipairs(beams) do table.insert(objList,b) end; VObjects[k]=objList
        local t0=tick(); local positions={}
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,star in ipairs(stars) do if not star.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*0.4+ao
                local pos=hrp.Position+Vector3.new(math.cos(angle)*5*s2.size,math.sin(t*0.8+ao)*2,math.sin(angle)*5*s2.size)
                star.CFrame=CFrame.new(pos); positions[i]=pos; if s2.rainbow then star.Color=rainbowColor((i-1)/n) end
            end
            for i,beam in ipairs(beams) do if not beam.Parent then continue end
                local p1=positions[i]; local p2=positions[(i%n)+1]; if not p1 or not p2 then continue end
                local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                beam.CFrame=CFrame.new(mid,p2)*CFrame.new(0,0,-len/2); beam.Size=Vector3.new(0.04,0.04,len)
                if s2.rainbow then beam.Color=rainbowColor((i-1)/n+0.1) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["DeathExplosion"] = {
    start = function(k)
        local char=getChar(); if not char then return end; local hum=getHum(); if not hum then return end
        VConns[k]=hum.Died:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local col=vGetColor(k)
            for wave=1,5 do coroutine.wrap(function()
                task.wait(wave*0.1); local SEGS=28; local MAXR=s.size*wave*5; local parts={}
                for i=1,SEGS do
                    local ang=(i-1)/SEGS*math.pi*2; local seg=makePart(Vector3.new(0.4,0.07,0.1),col)
                    seg.CFrame=CFrame.new(hrp.Position,hrp.Position+Vector3.new(math.cos(ang),0,math.sin(ang))); table.insert(parts,seg)
                end
                local t0=tick(); local ec; ec=RunService.Heartbeat:Connect(function()
                    local el=tick()-t0; if el>0.6 then ec:Disconnect(); for _,seg in ipairs(parts) do if seg.Parent then seg:Destroy() end end; return end
                    local prog=el/0.6; local R=MAXR*prog
                    for i,seg in ipairs(parts) do if not seg.Parent then continue end
                        local ang=(i-1)/SEGS*math.pi*2
                        seg.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(ang)*R,0,math.sin(ang)*R),hrp.Position+Vector3.new(math.cos(ang+0.01)*R,0,math.sin(ang+0.01)*R))
                        seg.Transparency=prog
                    end
                end)
            end)() end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["SpiralVortex"] = {
    start = function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local dots={}
        for i=1,n do
            local d=makePart(Vector3.new(0.2,0.2,0.2)*s.size,vGetColor(k)); local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=d; table.insert(dots,d)
        end
        VObjects[k]=dots; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,d in ipairs(dots) do if not d.Parent then continue end
                local prog=((t*s2.speed*0.3+(i-1)/n)%1); local angle=prog*math.pi*6+((i-1)/n*math.pi*2)
                d.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*(1-prog)*3*s2.size,(prog*6-3)*s2.size,math.sin(angle)*(1-prog)*3*s2.size))
                d.Transparency=prog; if s2.rainbow then d.Color=rainbowColor(prog+(i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Meteors"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.35/s.speed then return end; timer=0
            local col=vGetColor(k); local ox=math.random(-10,10); local oz=math.random(-10,10)
            local startP=hrp.Position+Vector3.new(ox,22,oz)
            local endP  =hrp.Position+Vector3.new(ox,-10,oz)
            local meteor=makePart(Vector3.new(0.2,0.2,1.5)*s.size,col)
            meteor.CFrame=CFrame.new(startP,endP)
            local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,0,0.75); a1.Parent=meteor
            local a2=Instance.new("Attachment"); a2.Position=Vector3.new(0,0,-0.75); a2.Parent=meteor
            local tail=Instance.new("Trail"); tail.Attachment0=a1; tail.Attachment1=a2; tail.Lifetime=0.4; tail.LightEmission=1
            tail.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,col)})
            tail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); tail.Parent=meteor
            local dur=0.65/s.speed; local dist=(endP-startP).Magnitude
            makeTween(meteor,dur,{CFrame=CFrame.new(endP,startP)*CFrame.new(0,0,-dist)},Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
            game:GetService("Debris"):AddItem(meteor,dur+0.1)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Aura"] = {
    start = function(k)
        local s=VSettings[k]; local layers=5; local auras={}
        for i=1,layers do
            local a=makePart(Vector3.new(4+i*0.4,6+i*0.4,4+i*0.4)*s.size,s.color); a.Transparency=1-(s.opacity*0.18/i)
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Scale=Vector3.new(1,1.2,1); mesh.Parent=a; table.insert(auras,a)
        end
        VObjects[k]=auras; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,a in ipairs(auras) do if not a.Parent then continue end
                a.CFrame=CFrame.new(hrp.Position)
                local col=s2.rainbow and Color3.fromHSV(((t*s2.speed*0.25)+(i-1)/layers)%1,1,1) or s2.color
                a.Color=col; local pulse=1+math.sin(t*2+(i-1))*0.04; local sz=(4+i*0.4)*s2.size*pulse; a.Size=Vector3.new(sz,sz*1.2,sz)
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["PortalRing"] = {
    start = function(k)
        local s=VSettings[k]; local SEGS=36; local segments={}
        for i=1,SEGS do
            local seg=makePart(Vector3.new(0.28*s.size,0.18*s.size,0.15*s.size),vGetColor(k)); seg.Transparency=1-s.opacity; table.insert(segments,seg)
        end
        VObjects[k]=segments; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0; local R=2.5*s2.size
            for i,seg in ipairs(segments) do if not seg.Parent then continue end
                local ang=(i-1)/SEGS*math.pi*2+t*s2.speed; local angN=i/SEGS*math.pi*2+t*s2.speed
                local p1=hrp.Position+Vector3.new(math.cos(ang)*R,math.sin(ang)*0.25,math.sin(ang)*R)
                local p2=hrp.Position+Vector3.new(math.cos(angN)*R,math.sin(angN)*0.25,math.sin(angN)*R)
                local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                seg.Size=Vector3.new(len+0.04,0.18*s2.size,0.14*s2.size); seg.CFrame=CFrame.new(mid,p2)
                if s2.rainbow then seg.Color=rainbowColor((i-1)/SEGS) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["SparkleBurst"] = {
    start = function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.05/s.speed then return end; timer=0
            for _=1,3 do
                local col=vGetColor(k); local sparkle=makePart(Vector3.new(0.1,0.1,0.1)*s.size,col)
                sparkle.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-2,2),math.random(-3,3),math.random(-2,2)))
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,18,0,18); bb.Adornee=sparkle; bb.Parent=sparkle
                local img=Instance.new("ImageLabel"); img.Size=UDim2.new(1,0,1,0); img.BackgroundTransparency=1; img.Image="rbxassetid://6407871923"; img.ImageColor3=col; img.Parent=bb
                makeTween(sparkle,0.35,{Size=Vector3.new(0.3,0.3,0.3)*s.size,Transparency=1}):Play(); game:GetService("Debris"):AddItem(sparkle,0.4)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

local function enableVisual(key)
    if VEnabled[key] then return end; VEnabled[key]=true
    if VFuncs[key] then pcall(VFuncs[key].start, key) end
end
local function disableVisual(key)
    if not VEnabled[key] then return end; VEnabled[key]=false
    if VFuncs[key] then pcall(VFuncs[key].stop, key) end
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

-- ── Visual effect color picker (same style, applies to VSettings) ─────────────
local function openVisualColorPicker(key)
    local guiName = "VPicker_"..key
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local s = VSettings[key]
    createColorPicker(key:lower().." color", guiName, function(preset)
        s.color   = preset.color
        s.rainbow = preset.rainbow
        if VEnabled[key] then disableVisual(key); task.wait(0.05); enableVisual(key) end
    end, nil)
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
    -- restart any active visuals
    for _, v in ipairs(VisualOrder) do
        local k = v[1]
        if VEnabled[k] then
            pcall(VFuncs[k].stop, k)
            task.wait(0.05)
            pcall(VFuncs[k].start, k)
        end
    end
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

    -- Visual effect button (color + on/off) — same style as makeColorFeatureBtn
    local function makeVisualBtn(name, desc, key)
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
        indicator.Text=VEnabled[key] and "on" or "off"
        indicator.TextColor3=VEnabled[key] and Config.OnColor or Color3.fromRGB(200,80,80)
        indicator.TextSize=13; indicator.Font=Enum.Font.GothamBold
        indicator.LayoutOrder=2; indicator.Parent=rightSide

        colorBtn.MouseButton1Click:Connect(function() openVisualColorPicker(key) end)
        btn.MouseButton1Click:Connect(function()
            if VEnabled[key] then disableVisual(key) else enableVisual(key) end
            indicator.Text=VEnabled[key] and "on" or "off"
            indicator.TextColor3=VEnabled[key] and Config.OnColor or Color3.fromRGB(200,80,80)
        end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)
    end

    -- Build buttons
    sectionLabel("  cheats")
    makeFeatureBtn("noclip", "walk through walls and objects", "Noclip", toggleNoclip)
    makeFeatureBtn("infinite jump", "jump infinitely without limit", "InfiniteJump", toggleInfiniteJump)

    sectionLabel("  visuals")
    makeColorFeatureBtn("china hat", "china hat on your head", "ChinaHat", function(enabled)
        if enabled then createChinaHat() else removeChinaHat() end
    end, openHatPicker)
    makeColorFeatureBtn("health bar", "animated hp bar at bottom of screen", "HealthBar", toggleHealthBar, openHealthBarPicker)
    makeColorFeatureBtn("crosshair", "custom crosshair with spin option", "Crosshair", toggleCrosshair, openCrosshairPicker)
    makeColorFeatureBtn("particles", "glowing orbs orbiting your character", "Particles", toggleParticles, openParticlesPicker)

    for _, v in ipairs(VisualOrder) do
        makeVisualBtn(v[2], v[3], v[1])
    end

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
