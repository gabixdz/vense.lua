--[[ $vense.lua$ V3 ]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
    ChinaHatSize     = 1.0,
    ChinaHatOpacity  = 1.0,

    HealthBarColor   = Color3.fromRGB(100, 220, 100),
    HealthBarNeon    = false,
    HealthBarRainbow = false,
    HealthBarSize    = 1.0,
    HealthBarOpacity = 1.0,

    CrosshairColor   = Color3.fromRGB(255, 255, 255),
    CrosshairNeon    = false,
    CrosshairRainbow = false,
    CrosshairSpin    = false,
    CrosshairSize    = 1.0,
    CrosshairOpacity = 1.0,

    ParticlesColor   = Color3.fromRGB(100, 200, 255),
    ParticlesNeon    = true,
    ParticlesRainbow = false,
    ParticlesSize    = 1.0,
    ParticlesOpacity = 1.0,
}

-- visuals.win effect settings
local VSettings = {}
local VEnabled  = {}
local VConns    = {}
local VObjects  = {}
local VRainbow  = {}

local VisualOrder = {
    {"Trail","body trail","glowing trail follows your movement"},
    {"JumpCircle","jump circle","ring expands when you jump"},
    {"Shockwave","shockwave","shockwave explodes when you land"},
    {"Orbit","orbit","glowing orbs orbit around you"},
    {"Wings","wings","glowing wings on your back"},
    {"GroundGlow","ground glow","glowing circle beneath your feet"},
    {"SpeedLines","speed lines","lines shoot past when moving fast"},
    {"HeadAura","head aura","glowing aura around your head"},
    {"FootSparks","footstep sparks","sparks pop under your feet"},
    {"NameTag","nametag glow","glowing name tag above head"},
    {"Chams","body outline","neon outline around your body"},
    {"Runes","floating runes","mystical runes float around you"},
    {"Lightning","lightning","lightning crackles around you"},
    {"Smoke","smoke trail","dreamy smoke follows your movement"},
    {"Petals","petal rain","flower petals drift around you"},
    {"StarBurst","star burst","stars explode outward periodically"},
    {"EnergyRings","energy rings","spinning energy rings surround you"},
    {"Ghost","ghost echo","transparent ghost copies trail you"},
    {"Bubbles","bubbles","iridescent bubbles float up around you"},
    {"FireCrown","fire crown","fiery crown of flames on your head"},
    {"IceCrystals","ice crystals","sharp ice shards orbit around you"},
    {"NeonGrid","neon grid","neon grid platform under your feet"},
    {"Comet","comet tail","bright comet-like streak trails you"},
    {"VoidRipple","void ripple","dark energy ripples expand from you"},
    {"Halo","angel halo","glowing halo floats above your head"},
    {"Dragon","dragon aura","fierce dragon energy surrounds you"},
    {"MusicBars","music bars","equalizer bars bounce around you"},
    {"Glitch","glitch effect","your body glitches and fragments"},
    {"Constellation","constellation","stars connected by lines orbit you"},
    {"DeathExplosion","death explosion","epic explosion when you die"},
    {"SpiralVortex","spiral vortex","particles spiral up from ground"},
    {"Meteors","meteor shower","meteors streak down around you"},
    {"RainbowAura","rainbow aura","full-body rainbow glow aura"},
    {"PortalRing","portal ring","swirling portal ring around waist"},
    {"SparkleBurst","sparkle burst","random sparkles pop over your body"},
}

for _,v in ipairs(VisualOrder) do
    local k=v[1]
    VSettings[k]={color=Color3.fromRGB(100,200,255),rainbow=false,size=1.0,speed=1.0,opacity=0.7,count=6}
    VEnabled[k]=false
end

local Connections  = {}
local RainbowConns = {}
local ParticleOrbs = {}

-- helpers
local function getChar()  return player.Character end
local function getHRP()   local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar(); return c and c:FindFirstChild("Humanoid") end

local function uiCorner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p end
local function makeTween(obj,t,props,style,dir)
    return TweenService:Create(obj,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props)
end
local function stopRainbowKey(key) if RainbowConns[key] then RainbowConns[key]:Disconnect(); RainbowConns[key]=nil end end
local function rainbowColor(offset) return Color3.fromHSV(((tick()*0.4)+(offset or 0))%1,1,1) end
local function vStopRainbow(k) if VRainbow[k] then VRainbow[k]:Disconnect(); VRainbow[k]=nil end end
local function vCleanObjects(k)
    if VObjects[k] then
        for _,o in pairs(VObjects[k]) do if typeof(o)=="Instance" and o.Parent then o:Destroy() end end
        VObjects[k]={}
    end
end
local function vDisconn(k)
    if VConns[k] then
        if typeof(VConns[k])=="RBXScriptConnection" then VConns[k]:Disconnect()
        elseif type(VConns[k])=="table" then for _,c in pairs(VConns[k]) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end end
        VConns[k]=nil
    end
end
local function makePart(size,color,mat,parent)
    local p=Instance.new("Part")
    p.Size=size or Vector3.new(1,1,1); p.Color=color or Color3.new(1,1,1)
    p.Material=mat or Enum.Material.Neon; p.CanCollide=false; p.Anchored=true; p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or workspace; return p
end
local function vGetColor(k,offset) if VSettings[k].rainbow then return rainbowColor(offset or 0) end; return VSettings[k].color end

local PRESETS = {
    {name="red",       color=Color3.fromRGB(220,50,50),   neon=false,rainbow=false},
    {name="blue",      color=Color3.fromRGB(50,120,255),  neon=false,rainbow=false},
    {name="yellow",    color=Color3.fromRGB(255,220,30),  neon=false,rainbow=false},
    {name="white",     color=Color3.fromRGB(255,255,255), neon=false,rainbow=false},
    {name="black",     color=Color3.fromRGB(20,20,20),    neon=false,rainbow=false},
    {name="green",     color=Color3.fromRGB(30,160,60),   neon=false,rainbow=false},
    {name="✦ neon",   color=Color3.fromRGB(0,255,120),   neon=true, rainbow=false},
    {name="❖ rainbow", color=Color3.fromRGB(255,0,0),     neon=true, rainbow=true },
}

-- splash
local function createInjectionAnimation()
    local sg=Instance.new("ScreenGui"); sg.Name="InjectionAnimation"; sg.ResetOnSpawn=false; sg.Parent=playerGui
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundColor3=Config.DarkColor; lbl.BackgroundTransparency=0; lbl.Text="$vense.lua$"; lbl.TextSize=48
    lbl.TextColor3=Config.AccentColor; lbl.Font=Enum.Font.GothamBold; lbl.TextTransparency=1; lbl.Parent=sg
    local fi=makeTween(lbl,0.8,{TextTransparency=0}); fi:Play()
    fi.Completed:Connect(function()
        task.wait(1)
        local fo=TweenService:Create(lbl,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{TextTransparency=1,BackgroundTransparency=1})
        fo:Play(); fo.Completed:Connect(function() sg:Destroy() end)
    end)
end

-- noclip
local function toggleNoclip(enabled)
    if Connections.Noclip then Connections.Noclip:Disconnect() end
    if enabled then
        Connections.Noclip=RunService.Stepped:Connect(function()
            local char=getChar(); if not Features.Noclip or not char then return end
            for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    end
end

-- infinite jump
local function toggleInfiniteJump(enabled)
    if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
    if enabled then
        Connections.InfiniteJump=UserInputService.JumpRequest:Connect(function()
            local char=getChar()
            if Features.InfiniteJump and char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

-- china hat
local function startHatRainbow()
    stopRainbowKey("hat")
    RainbowConns["hat"]=RunService.Heartbeat:Connect(function()
        local char=getChar(); if not char or not char:FindFirstChild("ChinaHatCone") then stopRainbowKey("hat"); return end
        local c=Color3.fromHSV((tick()*0.5)%1,1,1)
        local cone=char:FindFirstChild("ChinaHatCone"); local brim=char:FindFirstChild("ChinaHatBrim")
        if cone then cone.Color=c end; if brim then brim.Color=c end
    end)
end
local function applyHatColor(color,neon,rainbow)
    local char=getChar(); if not char then return end
    local cone=char:FindFirstChild("ChinaHatCone"); local brim=char:FindFirstChild("ChinaHatBrim"); if not cone or not brim then return end
    local mat=neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
    cone.Material=mat; brim.Material=mat; if not rainbow then cone.Color=color; brim.Color=color end
end
local function removeChinaHat()
    stopRainbowKey("hat"); local char=getChar(); if not char then return end
    for _,n in ipairs({"ChinaHatCone","ChinaHatBrim"}) do local p=char:FindFirstChild(n); if p then p:Destroy() end end
    local head=char:FindFirstChild("Head"); if head then
        for _,v in pairs(head:GetChildren()) do if v:IsA("Motor6D") and (v.Name=="ChinaHatConeWeld" or v.Name=="ChinaHatBrimWeld") then v:Destroy() end end
    end
end
local function createChinaHat()
    removeChinaHat(); local char=getChar(); if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local mat=ColorStates.ChinaHatNeon and Enum.Material.Neon or Enum.Material.SmoothPlastic
    local col=ColorStates.ChinaHatColor; local sz=ColorStates.ChinaHatSize; local op=1-ColorStates.ChinaHatOpacity

    local brim=Instance.new("Part"); brim.Name="ChinaHatBrim"; brim.Size=Vector3.new(1,1,1)
    brim.Color=col; brim.Material=mat; brim.CanCollide=false; brim.Anchored=false; brim.Transparency=op
    brim.TopSurface=Enum.SurfaceType.Smooth; brim.BottomSurface=Enum.SurfaceType.Smooth; brim.Parent=char
    local bm=Instance.new("SpecialMesh"); bm.MeshType=Enum.MeshType.Cylinder; bm.Scale=Vector3.new(0.4,5.5*sz,5.5*sz); bm.Parent=brim
    local bw=Instance.new("Motor6D"); bw.Name="ChinaHatBrimWeld"; bw.Part0=head; bw.Part1=brim
    bw.C0=CFrame.new(0,head.Size.Y/2+0.15,0)*CFrame.Angles(0,0,math.rad(90)); bw.Parent=head

    local cone=Instance.new("Part"); cone.Name="ChinaHatCone"; cone.Size=Vector3.new(4.2*sz,3.2*sz,4.2*sz)
    cone.Color=col; cone.Material=mat; cone.CanCollide=false; cone.Anchored=false; cone.Transparency=op
    cone.TopSurface=Enum.SurfaceType.Smooth; cone.BottomSurface=Enum.SurfaceType.Smooth; cone.Parent=char
    local cm=Instance.new("SpecialMesh"); cm.MeshType=Enum.MeshType.Sphere; cm.Scale=Vector3.new(1,0.75,1); cm.Parent=cone
    local cw=Instance.new("Motor6D"); cw.Name="ChinaHatConeWeld"; cw.Part0=head; cw.Part1=cone
    cw.C0=CFrame.new(0,head.Size.Y/2+0.2+cone.Size.Y/2*0.75-0.3,0); cw.Parent=head
    if ColorStates.ChinaHatRainbow then startHatRainbow() end
end

-- boost fps
local function boostFPS(enabled)
    if enabled then game.Lighting.GlobalShadows=false; game.Lighting.Brightness=2
        for _,d in pairs(workspace:GetDescendants()) do if d:IsA("Texture") then d:Destroy() end end
    else game.Lighting.GlobalShadows=true; game.Lighting.Brightness=1 end
end

-- health bar
local HealthBarGui=nil
local function destroyHealthBar()
    stopRainbowKey("healthbar")
    if Connections.HealthBar     then Connections.HealthBar:Disconnect();     Connections.HealthBar=nil end
    if Connections.HealthBarDied then Connections.HealthBarDied:Disconnect(); Connections.HealthBarDied=nil end
    if HealthBarGui then HealthBarGui:Destroy(); HealthBarGui=nil end
end
local function createHealthBar()
    destroyHealthBar(); local char=getChar(); if not char then return end
    local humanoid=char:FindFirstChild("Humanoid"); if not humanoid then return end
    local barW=math.floor(320*ColorStates.HealthBarSize); local barH=math.floor(28*ColorStates.HealthBarSize)
    local sg=Instance.new("ScreenGui"); sg.Name="VenseHealthBar"; sg.ResetOnSpawn=false; sg.DisplayOrder=5; sg.Parent=playerGui; HealthBarGui=sg
    local container=Instance.new("Frame"); container.Name="Container"; container.Size=UDim2.new(0,barW,0,barH)
    container.Position=UDim2.new(0.5,-barW/2,1,-60); container.BackgroundColor3=Color3.fromRGB(15,15,18)
    container.BorderSizePixel=0; container.BackgroundTransparency=1-ColorStates.HealthBarOpacity; container.Parent=sg; uiCorner(container,14)
    local track=Instance.new("Frame"); track.Size=UDim2.new(1,-8,1,-8); track.Position=UDim2.new(0,4,0,4)
    track.BackgroundColor3=Color3.fromRGB(35,35,40); track.BorderSizePixel=0; track.Parent=container; uiCorner(track,10)
    local fill=Instance.new("Frame"); fill.Name="Fill"; fill.Size=UDim2.new(1,0,1,0)
    fill.BackgroundColor3=ColorStates.HealthBarColor; fill.BorderSizePixel=0; fill.Parent=track; uiCorner(fill,10)
    local shine=Instance.new("Frame"); shine.Size=UDim2.new(1,0,0.45,0); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0; shine.ZIndex=3; shine.Parent=fill; uiCorner(shine,10)
    local healthLbl=Instance.new("TextLabel"); healthLbl.Size=UDim2.new(1,0,1,0); healthLbl.BackgroundTransparency=1
    healthLbl.Text="100 HP"; healthLbl.TextColor3=Color3.fromRGB(255,255,255); healthLbl.Font=Enum.Font.GothamBold
    healthLbl.TextSize=math.floor(13*ColorStates.HealthBarSize); healthLbl.ZIndex=4; healthLbl.Parent=container
    local dangerOverlay=Instance.new("Frame"); dangerOverlay.Size=UDim2.new(1,0,1,0)
    dangerOverlay.BackgroundColor3=Color3.fromRGB(255,40,40); dangerOverlay.BackgroundTransparency=1
    dangerOverlay.BorderSizePixel=0; dangerOverlay.ZIndex=5; dangerOverlay.Parent=container; uiCorner(dangerOverlay,14)
    local lastHealth=humanoid.Health; local dangerPulseActive=false
    local function updateBar(hp,maxHp)
        local ratio=math.clamp(hp/math.max(maxHp,1),0,1)
        local targetColor
        if ColorStates.HealthBarRainbow then targetColor=fill.BackgroundColor3
        elseif ColorStates.HealthBarNeon then targetColor=ColorStates.HealthBarColor
        else local r=ColorStates.HealthBarColor.R; local g=ColorStates.HealthBarColor.G; local b=ColorStates.HealthBarColor.B
            targetColor=Color3.fromRGB(math.floor(r+(1-ratio)*(220-r)),math.floor(g*ratio),math.floor(b*ratio*0.5)) end
        makeTween(fill,0.35,{Size=UDim2.new(ratio,0,1,0)},Enum.EasingStyle.Quart):Play()
        if not ColorStates.HealthBarRainbow then makeTween(fill,0.35,{BackgroundColor3=targetColor}):Play() end
        healthLbl.Text=math.floor(hp).." HP"; healthLbl.TextColor3=Color3.fromRGB(255,255,255)
        if ratio<=0.3 and not dangerPulseActive then
            dangerPulseActive=true
            coroutine.wrap(function()
                while dangerPulseActive and Features.HealthBar do
                    local c2=getChar(); local hum=c2 and c2:FindFirstChild("Humanoid")
                    if not hum or hum.Health/hum.MaxHealth>0.3 then dangerPulseActive=false; makeTween(dangerOverlay,0.3,{BackgroundTransparency=1}):Play(); break end
                    makeTween(dangerOverlay,0.4,{BackgroundTransparency=0.75}):Play(); task.wait(0.4)
                    makeTween(dangerOverlay,0.4,{BackgroundTransparency=1}):Play(); task.wait(0.4)
                end
            end)()
        elseif ratio>0.3 then dangerPulseActive=false; makeTween(dangerOverlay,0.3,{BackgroundTransparency=1}):Play() end
        if hp>lastHealth then local flash=makeTween(shine,0.15,{BackgroundTransparency=0.5}); flash:Play()
            flash.Completed:Connect(function() makeTween(shine,0.4,{BackgroundTransparency=0.82}):Play() end) end
        lastHealth=hp
    end
    updateBar(humanoid.Health,humanoid.MaxHealth)
    Connections.HealthBar=humanoid.HealthChanged:Connect(function(hp) updateBar(math.max(hp,0),humanoid.MaxHealth) end)
    Connections.HealthBarDied=humanoid.Died:Connect(function()
        dangerPulseActive=false; makeTween(dangerOverlay,0.2,{BackgroundTransparency=1}):Play()
        makeTween(fill,0.5,{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(180,40,40)},Enum.EasingStyle.Quart):Play()
        healthLbl.Text="dead"; healthLbl.TextColor3=Color3.fromRGB(220,80,80)
    end)
    if ColorStates.HealthBarRainbow then
        RainbowConns["healthbar"]=RunService.Heartbeat:Connect(function()
            if not Features.HealthBar then stopRainbowKey("healthbar"); return end
            fill.BackgroundColor3=Color3.fromHSV((tick()*0.5)%1,1,1)
        end)
    end
    container.Position=UDim2.new(0.5,-barW/2,1,10); container.BackgroundTransparency=1
    makeTween(container,0.5,{Position=UDim2.new(0.5,-barW/2,1,-60),BackgroundTransparency=1-ColorStates.HealthBarOpacity},Enum.EasingStyle.Back):Play()
end
local function toggleHealthBar(enabled)
    if enabled then createHealthBar()
    else if HealthBarGui then
        local cont=HealthBarGui:FindFirstChild("Container")
        if cont then local out=makeTween(cont,0.35,{Position=UDim2.new(0.5,-160,1,20),BackgroundTransparency=1}); out:Play()
            out.Completed:Connect(function() destroyHealthBar() end)
        else destroyHealthBar() end
    end end
end

-- crosshair
local CrosshairGui=nil
local function destroyCrosshair()
    stopRainbowKey("crosshair")
    if Connections.CrosshairSpin then Connections.CrosshairSpin:Disconnect(); Connections.CrosshairSpin=nil end
    if CrosshairGui then CrosshairGui:Destroy(); CrosshairGui=nil end
end
local function createCrosshair()
    destroyCrosshair()
    local sg=Instance.new("ScreenGui"); sg.Name="VenseCrosshair"; sg.ResetOnSpawn=false
    sg.DisplayOrder=10; sg.IgnoreGuiInset=true; sg.Parent=playerGui; CrosshairGui=sg
    local col=ColorStates.CrosshairColor; local sz=ColorStates.CrosshairSize; local op=1-ColorStates.CrosshairOpacity
    local root=Instance.new("Frame"); root.Name="Root"; root.Size=UDim2.new(0,60*sz,0,60*sz)
    root.Position=UDim2.new(0.5,-30*sz,0.5,-30*sz); root.BackgroundTransparency=1; root.BorderSizePixel=0; root.Parent=sg
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,5*sz,0,5*sz); dot.Position=UDim2.new(0.5,-2*sz,0.5,-2*sz)
    dot.BackgroundColor3=col; dot.BorderSizePixel=0; dot.BackgroundTransparency=op; dot.Parent=root; uiCorner(dot,3)
    local armDefs={
        {name="Top",    size=UDim2.new(0,2*sz,0,14*sz), pos=UDim2.new(0.5,-1*sz,0.5,-22*sz)},
        {name="Bottom", size=UDim2.new(0,2*sz,0,14*sz), pos=UDim2.new(0.5,-1*sz,0.5,8*sz)},
        {name="Left",   size=UDim2.new(0,14*sz,0,2*sz), pos=UDim2.new(0.5,-22*sz,0.5,-1*sz)},
        {name="Right",  size=UDim2.new(0,14*sz,0,2*sz), pos=UDim2.new(0.5,8*sz,0.5,-1*sz)},
    }
    local arms={}
    for _,def in ipairs(armDefs) do
        local arm=Instance.new("Frame"); arm.Name=def.name; arm.Size=def.size; arm.Position=def.pos
        arm.BackgroundColor3=col; arm.BorderSizePixel=0; arm.BackgroundTransparency=op; arm.Parent=root; uiCorner(arm,2)
        local ol=Instance.new("Frame"); ol.Size=UDim2.new(1,4,1,4); ol.Position=UDim2.new(0,-2,0,-2)
        ol.BackgroundColor3=Color3.fromRGB(0,0,0); ol.BackgroundTransparency=0.5; ol.BorderSizePixel=0; ol.ZIndex=arm.ZIndex-1; ol.Parent=arm; uiCorner(ol,3)
        arms[def.name]=arm
    end
    local dol=Instance.new("Frame"); dol.Size=UDim2.new(1,4,1,4); dol.Position=UDim2.new(0,-2,0,-2)
    dol.BackgroundColor3=Color3.fromRGB(0,0,0); dol.BackgroundTransparency=0.5; dol.BorderSizePixel=0; dol.ZIndex=dot.ZIndex-1; dol.Parent=dot; uiCorner(dol,4)
    local function applyColor(c) dot.BackgroundColor3=c; for _,arm in pairs(arms) do arm.BackgroundColor3=c end end
    if ColorStates.CrosshairRainbow then
        RainbowConns["crosshair"]=RunService.Heartbeat:Connect(function()
            if not Features.Crosshair then stopRainbowKey("crosshair"); return end
            applyColor(Color3.fromHSV((tick()*0.6)%1,1,1))
        end)
    else applyColor(col) end
    if ColorStates.CrosshairSpin then
        local angle=0
        Connections.CrosshairSpin=RunService.Heartbeat:Connect(function(dt)
            if not Features.Crosshair then if Connections.CrosshairSpin then Connections.CrosshairSpin:Disconnect(); Connections.CrosshairSpin=nil end; return end
            angle=angle+dt*180; root.Rotation=angle%360
        end)
    end
    local pieces={dot,arms.Top,arms.Bottom,arms.Left,arms.Right}
    for _,p in ipairs(pieces) do p.BackgroundTransparency=1 end
    local delays={0,0.05,0.05,0.1,0.1}
    for i,p in ipairs(pieces) do coroutine.wrap(function() task.wait(delays[i]); makeTween(p,0.3,{BackgroundTransparency=op}):Play() end)() end
end
local function toggleCrosshair(enabled)
    if enabled then createCrosshair()
    else if CrosshairGui then
        local r=CrosshairGui:FindFirstChild("Root")
        if r then for _,c in pairs(r:GetChildren()) do if c:IsA("Frame") then makeTween(c,0.25,{BackgroundTransparency=1}):Play() end end end
        coroutine.wrap(function() task.wait(0.3); destroyCrosshair() end)()
    end end
end

-- particles
local function destroyParticles()
    stopRainbowKey("particles")
    if Connections.Particles then Connections.Particles:Disconnect(); Connections.Particles=nil end
    for _,orb in pairs(ParticleOrbs) do if orb and orb.Parent then orb:Destroy() end end
    ParticleOrbs={}
end
local function createParticles()
    destroyParticles(); local char=getChar(); if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local NUM=8; local RAD=3.5*ColorStates.ParticlesSize; local ORSZ=0.35*ColorStates.ParticlesSize
    local col=ColorStates.ParticlesColor
    for i=1,NUM do
        local orb=Instance.new("Part"); orb.Name="VenseOrb_"..i; orb.Size=Vector3.new(ORSZ,ORSZ,ORSZ)
        orb.Color=col; orb.Material=Enum.Material.Neon; orb.CanCollide=false; orb.Anchored=true; orb.CastShadow=false
        orb.Transparency=1-ColorStates.ParticlesOpacity; orb.TopSurface=Enum.SurfaceType.Smooth; orb.BottomSurface=Enum.SurfaceType.Smooth; orb.Parent=workspace
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=orb
        local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,28,0,28); bb.Adornee=orb; bb.Parent=orb
        local glow=Instance.new("ImageLabel"); glow.Size=UDim2.new(1,0,1,0); glow.BackgroundTransparency=1
        glow.Image="rbxassetid://6407871923"; glow.ImageColor3=col; glow.ImageTransparency=0.3; glow.Parent=bb
        table.insert(ParticleOrbs,orb)
    end
    local st=tick()
    Connections.Particles=RunService.Heartbeat:Connect(function()
        local char2=getChar(); if not char2 or not Features.Particles then destroyParticles(); return end
        local r2=char2:FindFirstChild("HumanoidRootPart"); if not r2 then return end
        local t=tick()-st; local base=r2.Position
        for i,orb in ipairs(ParticleOrbs) do
            if not orb or not orb.Parent then continue end
            local ao=(i-1)/NUM*math.pi*2; local angle=t*1.2*math.pi*2+ao; local bobY=math.sin(t*0.8*math.pi*2+ao)*1.2
            orb.CFrame=CFrame.new(base.X+math.cos(angle)*RAD,base.Y+1+bobY,base.Z+math.sin(angle)*RAD)
            local pulse=1+math.sin(t*3+ao)*0.15; local sz=ORSZ*pulse; orb.Size=Vector3.new(sz,sz,sz)
            if ColorStates.ParticlesRainbow then
                local rc=Color3.fromHSV(((t*0.4)+(i-1)/NUM)%1,1,1); orb.Color=rc
                local bb2=orb:FindFirstChildOfClass("BillboardGui"); if bb2 then local img=bb2:FindFirstChildOfClass("ImageLabel"); if img then img.ImageColor3=rc end end
            end
        end
    end)
end
local function toggleParticles(enabled) if enabled then createParticles() else destroyParticles() end end

-- ==========================================================================
-- VISUALS.WIN EFFECTS
-- ==========================================================================
local VFuncs={}

VFuncs["Trail"]={
    start=function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
        local a0=Instance.new("Attachment"); a0.Position=Vector3.new(0,1,0); a0.Parent=hrp
        local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,-1,0); a1.Parent=hrp
        local tr=Instance.new("Trail"); tr.Attachment0=a0; tr.Attachment1=a1; tr.Lifetime=0.6; tr.MinLength=0
        tr.Color=ColorSequence.new(s.color)
        tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1-s.opacity),NumberSequenceKeypoint.new(1,1)})
        tr.WidthScale=NumberSequence.new(s.size*1.5); tr.LightEmission=1; tr.FaceCamera=true; tr.Parent=hrp
        VObjects[k]={a0,a1,tr}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function() if not VEnabled[k] then vStopRainbow(k); return end; tr.Color=ColorSequence.new(rainbowColor()) end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

VFuncs["JumpCircle"]={
    start=function(k)
        local hum=getHum(); if not hum then return end; local s=VSettings[k]
        VConns[k]=hum.Jumping:Connect(function(active)
            if not active then return end; local hrp=getHRP(); if not hrp then return end
            local ring=makePart(Vector3.new(s.size*4,0.1,s.size*4),vGetColor(k))
            ring.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0))
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.05,1,1); mesh.Parent=ring
            makeTween(ring,0.5,{Size=Vector3.new(s.size*12,0.05,s.size*12)}):Play()
            makeTween(ring,0.5,{Transparency=1}):Play(); game:GetService("Debris"):AddItem(ring,0.6)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Shockwave"]={
    start=function(k)
        local wasInAir=false
        VConns[k]=RunService.Heartbeat:Connect(function()
            if not VEnabled[k] then return end; local h=getHum(); if not h then return end
            local inAir=h:GetState()==Enum.HumanoidStateType.Freefall or h:GetState()==Enum.HumanoidStateType.Jumping
            if wasInAir and not inAir then
                local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local col=vGetColor(k)
                for i=1,3 do
                    local ring=makePart(Vector3.new(1,0.1,1),col); ring.CFrame=CFrame.new(hrp.Position-Vector3.new(0,2.8,0)); ring.Transparency=1-s.opacity
                    local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.05*i,1,1); mesh.Parent=ring
                    coroutine.wrap(function() task.wait(i*0.06); local sz=s.size*(6+i*3)
                        makeTween(ring,0.5,{Size=Vector3.new(sz,0.05,sz)},Enum.EasingStyle.Quart):Play()
                        makeTween(ring,0.5,{Transparency=1}):Play(); game:GetService("Debris"):AddItem(ring,0.6) end)()
                end
            end; wasInAir=inAir
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Orbit"]={
    start=function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local n=math.floor(s.count); local orbs={}
        for i=1,n do
            local orb=makePart(Vector3.new(0.3,0.3,0.3)*s.size,vGetColor(k))
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=orb
            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,24,0,24); bb.Adornee=orb; bb.Parent=orb
            local g=Instance.new("ImageLabel"); g.Size=UDim2.new(1,0,1,0); g.BackgroundTransparency=1; g.Image="rbxassetid://6407871923"; g.ImageColor3=s.color; g.ImageTransparency=0.3; g.Parent=bb
            table.insert(orbs,orb)
        end
        VObjects[k]=orbs; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp2=getHRP(); if not hrp2 then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,orb in ipairs(orbs) do if not orb.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*s2.speed*math.pi*2+ao; local bob=math.sin(t*1.5+ao)*1.2
                orb.CFrame=CFrame.new(hrp2.Position+Vector3.new(math.cos(angle)*3.5*s2.size,bob,math.sin(angle)*3.5*s2.size))
                local sz=0.3*s2.size*(1+math.sin(t*3+ao)*0.15); orb.Size=Vector3.new(sz,sz,sz)
                if s2.rainbow then local c=rainbowColor((i-1)/n); orb.Color=c
                    local bb2=orb:FindFirstChildOfClass("BillboardGui"); if bb2 then local img=bb2:FindFirstChildOfClass("ImageLabel"); if img then img.ImageColor3=c end end end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Wings"]={
    start=function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local wings={}
        for side=-1,1,2 do for seg=1,4 do
            local w=makePart(Vector3.new(0.15,0.8+seg*0.2,1.2+seg*0.3)*s.size,vGetColor(k)); w.Transparency=1-s.opacity; w.Parent=workspace; table.insert(wings,w)
        end end
        VObjects[k]=wings; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp2=getHRP(); if not hrp2 then return end; local s2=VSettings[k]; local t=tick()-t0; local flap=math.sin(t*3)*0.3; local idx=0
            for side=-1,1,2 do for seg=1,4 do idx=idx+1; local w=wings[idx]; if not w or not w.Parent then continue end
                w.CFrame=hrp2.CFrame*CFrame.new((side*(1+seg*0.7+flap*seg*0.2))*s2.size,(seg*0.5+math.sin(t*3+seg)*0.2)*s2.size,-seg*0.3*s2.size)*CFrame.Angles(0,0,side*math.rad(30+seg*10+flap*20))
                if s2.rainbow then w.Color=rainbowColor(idx/8) end
            end end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["GroundGlow"]={
    start=function(k)
        local s=VSettings[k]; local glow=makePart(Vector3.new(6,0.05,6)*s.size,vGetColor(k)); glow.Transparency=1-s.opacity*0.6
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.03,1,1); mesh.Parent=glow
        VObjects[k]={glow}; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            local sz=6*s2.size*(1+math.sin(t*2)*0.12); glow.Size=Vector3.new(sz,0.05,sz)
            glow.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)); if s2.rainbow then glow.Color=rainbowColor() end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["SpeedLines"]={
    start=function(k)
        local lastPos=nil
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
            if lastPos and (hrp.Position-lastPos).Magnitude/0.016>15 then
                for _=1,2 do
                    local line=makePart(Vector3.new(0.05,0.05,math.random(3,8)*s.size),vGetColor(k))
                    local offset=Vector3.new(math.random(-4,4),math.random(-2,2),math.random(-4,4))
                    line.CFrame=CFrame.new(hrp.Position+offset,hrp.Position+offset+hrp.CFrame.LookVector*10); line.Transparency=0.2
                    makeTween(line,0.2,{Transparency=1,CFrame=line.CFrame*CFrame.new(0,0,-5)}):Play(); game:GetService("Debris"):AddItem(line,0.25)
                end
            end; lastPos=hrp.Position
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["HeadAura"]={
    start=function(k)
        local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
        local s=VSettings[k]; local aura=makePart(Vector3.new(3,3,3)*s.size,vGetColor(k)); aura.Transparency=1-s.opacity*0.5
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=aura
        VObjects[k]={aura}; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char2=getChar(); if not char2 then return end; local head2=char2:FindFirstChild("Head"); if not head2 then return end
            local s2=VSettings[k]; local t=tick()-t0; local pulse=1+math.sin(t*2.5)*0.08; local sz=3*s2.size*pulse
            aura.Size=Vector3.new(sz,sz,sz); aura.CFrame=CFrame.new(head2.Position); if s2.rainbow then aura.Color=rainbowColor() end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["FootSparks"]={
    start=function(k)
        local lastPos=nil; local stepTimer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; stepTimer=stepTimer+dt
            if lastPos and (hrp.Position-lastPos).Magnitude>1.5 and stepTimer>0.15 then
                stepTimer=0
                for _=1,5 do
                    local spark=makePart(Vector3.new(0.08,0.08,0.08)*s.size,vGetColor(k))
                    spark.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)+Vector3.new(math.random(-1,1)*0.5,0,math.random(-1,1)*0.5))
                    makeTween(spark,0.4,{CFrame=CFrame.new(spark.Position+Vector3.new(math.random(-4,4),math.random(3,7),math.random(-4,4))),Transparency=1,Size=Vector3.new(0.01,0.01,0.01)}):Play()
                    game:GetService("Debris"):AddItem(spark,0.5)
                end
            end; lastPos=hrp.Position
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["NameTag"]={
    start=function(k)
        local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end; local s=VSettings[k]
        local sg=Instance.new("BillboardGui"); sg.Size=UDim2.new(0,200*s.size,0,40); sg.StudsOffset=Vector3.new(0,3.5,0); sg.Adornee=head; sg.AlwaysOnTop=true; sg.Parent=head
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
        lbl.Text="✦ "..player.Name.." ✦"; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=16*s.size; lbl.TextColor3=s.color; lbl.TextStrokeTransparency=0.3; lbl.Parent=sg
        VObjects[k]={sg}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function() if not VEnabled[k] then vStopRainbow(k); return end; lbl.TextColor3=rainbowColor() end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

VFuncs["Chams"]={
    start=function(k)
        local char=getChar(); if not char then return end; local s=VSettings[k]; local parts={}
        for _,part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                local clone=part:Clone(); clone.Anchored=false; clone.CanCollide=false; clone.CastShadow=false
                clone.Material=Enum.Material.Neon; clone.Color=s.color; clone.Transparency=1-s.opacity*0.6
                clone.Size=part.Size+Vector3.new(0.15*s.size,0.15*s.size,0.15*s.size)
                for _,v in pairs(clone:GetChildren()) do if not v:IsA("SpecialMesh") then v:Destroy() end end
                local weld=Instance.new("WeldConstraint"); weld.Part0=part; weld.Part1=clone; weld.Parent=clone
                clone.Parent=char; table.insert(parts,clone)
            end
        end
        VObjects[k]=parts
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function()
            if not VEnabled[k] then vStopRainbow(k); return end; local c=rainbowColor()
            for _,p in pairs(parts) do if p.Parent then p.Color=c end end
        end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

VFuncs["Runes"]={
    start=function(k)
        local runeChars={"ᚠ","ᚢ","ᚦ","ᚨ","ᚱ","ᚲ","ᚷ","ᚹ","ᚺ","ᚾ","ᛁ","ᛃ","ᛇ","ᛈ","ᛉ","ᛊ","ᛏ","ᛒ","ᛖ","ᛗ","ᛚ","ᛜ","ᛞ","ᛟ"}
        local s=VSettings[k]; local n=math.floor(s.count); local runes={}
        for i=1,n do
            local part=makePart(Vector3.new(0.1,0.1,0.1),Color3.fromRGB(1,1,1)); part.Transparency=1
            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,40*s.size,0,40*s.size); bb.Adornee=part; bb.Parent=part
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
            lbl.Text=runeChars[math.random(#runeChars)]; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=28*s.size; lbl.TextColor3=s.color; lbl.TextStrokeTransparency=0.2; lbl.Parent=bb
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

VFuncs["Lightning"]={
    start=function(k)
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

VFuncs["Smoke"]={
    start=function(k)
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

VFuncs["Petals"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local petals={}
        for i=1,n do local p=makePart(Vector3.new(0.2,0.05,0.3)*s.size,vGetColor(k)); p.Transparency=0.2; table.insert(petals,p) end
        VObjects[k]=petals
        local offsets={}; for i=1,n do offsets[i]={x=math.random(-5,5),y=math.random(-4,6),z=math.random(-5,5),t=math.random()*10} end
        local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,p in ipairs(petals) do if not p.Parent then continue end; local o=offsets[i]
                p.CFrame=CFrame.new(hrp.Position+Vector3.new(o.x+math.sin(t*0.7+o.t)*1.5,o.y-((t*0.5+o.t)%8)-2,o.z+math.cos(t*0.5+o.t)*1.5))*CFrame.Angles(t*0.5+o.t,t*0.3,t*0.7)
                if s2.rainbow then p.Color=rainbowColor(i/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["StarBurst"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<1.5/s.speed then return end; timer=0
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

VFuncs["EnergyRings"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(math.clamp(s.count,1,6)); local rings={}
        for i=1,n do
            local ring=makePart(Vector3.new(5,0.08,5)*s.size,vGetColor(k)); ring.Transparency=0.3
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.04,1,1); mesh.Parent=ring; table.insert(rings,ring)
        end
        VObjects[k]=rings; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,ring in ipairs(rings) do if not ring.Parent then continue end
                ring.CFrame=CFrame.new(hrp.Position)*CFrame.Angles((i-1)/n*math.pi,t*s2.speed*(1+i*0.3),0)
                if s2.rainbow then ring.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Ghost"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local char=getChar(); if not char then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.12/s.speed then return end; timer=0
            for _,part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                    local ghost=makePart(part.Size,s.rainbow and rainbowColor() or s.color); ghost.CFrame=part.CFrame; ghost.Transparency=1-s.opacity*0.4
                    for _,v in pairs(part:GetChildren()) do if v:IsA("SpecialMesh") then v:Clone().Parent=ghost end end
                    makeTween(ghost,0.4,{Transparency=1}):Play(); game:GetService("Debris"):AddItem(ghost,0.45)
                end
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Bubbles"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.3 then return end; timer=0
            for _=1,math.floor(s.count*0.5+1) do
                local sz=(0.2+math.random()*0.5)*s.size; local bubble=makePart(Vector3.new(sz,sz,sz),vGetColor(k)); bubble.Transparency=0.5
                local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=bubble
                bubble.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-3,3),0,math.random(-3,3)))
                local rise=math.random(5,12); makeTween(bubble,rise*0.3,{CFrame=CFrame.new(bubble.Position+Vector3.new(math.random(-2,2),rise,math.random(-2,2))),Transparency=1}):Play()
                game:GetService("Debris"):AddItem(bubble,rise*0.35)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["FireCrown"]={
    start=function(k)
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
                else local ratio=math.abs(math.sin(t*3+ao)); local c=s2.color; flame.Color=Color3.new(math.min(c.R+0.2,1),c.G*ratio,c.B*0.2) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["IceCrystals"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local crystals={}
        for i=1,n do
            local cry=makePart(Vector3.new(0.15,0.8,0.15)*s.size,vGetColor(k)); cry.Transparency=0.2
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Diamond; mesh.Parent=cry; table.insert(crystals,cry)
        end
        VObjects[k]=crystals; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,cry in ipairs(crystals) do if not cry.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*s2.speed+ao
                cry.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*3*s2.size,math.sin(t*1.5+ao)*0.5,math.sin(angle)*3*s2.size))*CFrame.Angles(t*2+ao,t+ao,0)
                if s2.rainbow then cry.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["NeonGrid"]={
    start=function(k)
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

VFuncs["Comet"]={
    start=function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
        local att=Instance.new("Attachment"); att.Parent=hrp
        local tr=Instance.new("Trail"); tr.Attachment0=att; tr.Attachment1=att; tr.Lifetime=1.2; tr.MinLength=0; tr.FaceCamera=true; tr.LightEmission=1; tr.LightInfluence=0
        tr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,s.color),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,s.color)})
        tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1-s.opacity),NumberSequenceKeypoint.new(1,1)})
        tr.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,s.size*3),NumberSequenceKeypoint.new(1,0)}); tr.Parent=hrp
        VObjects[k]={att,tr}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function()
            if not VEnabled[k] then vStopRainbow(k); return end; local c=rainbowColor()
            tr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,c)})
        end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

VFuncs["VoidRipple"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.8/s.speed then return end; timer=0
            for i=1,3 do
                local ring=makePart(Vector3.new(1,0.1,1),vGetColor(k)); ring.Transparency=0.3
                local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.05,1,1); mesh.Parent=ring; ring.CFrame=CFrame.new(hrp.Position)
                coroutine.wrap(function() task.wait(i*0.15); local sz=s.size*(4+i*2)
                    makeTween(ring,0.7,{Size=Vector3.new(sz,0.05,sz),Transparency=1}):Play(); game:GetService("Debris"):AddItem(ring,0.8) end)()
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["Halo"]={
    start=function(k)
        local s=VSettings[k]; local halo=makePart(Vector3.new(3,0.15,3)*s.size,vGetColor(k)); halo.Transparency=1-s.opacity
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.06,1,1); mesh.Parent=halo
        VObjects[k]={halo}; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
            local s2=VSettings[k]; local t=tick()-t0
            halo.CFrame=CFrame.new(head.Position+Vector3.new(0,1.5+math.sin(t*1.5)*0.15,0))*CFrame.Angles(math.rad(10),t*0.5,0)
            if s2.rainbow then halo.Color=rainbowColor() end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Dragon"]={
    start=function(k)
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

VFuncs["MusicBars"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local bars={}
        for i=1,n do local bar=makePart(Vector3.new(0.3*s.size,1,0.3*s.size),vGetColor(k)); bar.Transparency=0.2; table.insert(bars,bar) end
        VObjects[k]=bars; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,bar in ipairs(bars) do if not bar.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local height=1+math.abs(math.sin(t*s2.speed*3+ao*2))*3*s2.size
                bar.Size=Vector3.new(0.3*s2.size,height,0.3*s2.size)
                bar.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(ao)*4*s2.size,height/2-1,math.sin(ao)*4*s2.size))
                if s2.rainbow then bar.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["Glitch"]={
    start=function(k)
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

VFuncs["Constellation"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local stars={}; local beams={}
        for i=1,n do local star=makePart(Vector3.new(0.18,0.18,0.18)*s.size,vGetColor(k))
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=star; table.insert(stars,star) end
        for i=1,n do local beam=makePart(Vector3.new(0.04,0.04,1),vGetColor(k)); beam.Transparency=0.5; table.insert(beams,beam) end
        local objList={}; for _,s2 in ipairs(stars) do table.insert(objList,s2) end; for _,b in ipairs(beams) do table.insert(objList,b) end; VObjects[k]=objList
        local t0=tick(); local positions={}
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,star in ipairs(stars) do if not star.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*0.4+ao; local r=5*s2.size
                local pos=hrp.Position+Vector3.new(math.cos(angle)*r,math.sin(t*0.8+ao)*2,math.sin(angle)*r)
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

VFuncs["DeathExplosion"]={
    start=function(k)
        local char=getChar(); if not char then return end; local hum=getHum(); if not hum then return end
        VConns[k]=hum.Died:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local col=vGetColor(k)
            for wave=1,5 do coroutine.wrap(function() task.wait(wave*0.1)
                local ring=makePart(Vector3.new(1,0.1,1),col); ring.CFrame=CFrame.new(hrp.Position)
                local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Cylinder; mesh.Scale=Vector3.new(0.05,1,1); mesh.Parent=ring
                makeTween(ring,0.6,{Size=Vector3.new(s.size*wave*6,0.08,s.size*wave*6),Transparency=1},Enum.EasingStyle.Quart):Play()
                game:GetService("Debris"):AddItem(ring,0.7) end)() end
            for _=1,30 do
                local shard=makePart(Vector3.new(0.15,0.15,0.5)*s.size,s.rainbow and rainbowColor(math.random()) or col); shard.CFrame=CFrame.new(hrp.Position)
                local dir=Vector3.new(math.random(-10,10),math.random(2,15),math.random(-10,10)).Unit
                makeTween(shard,0.8,{CFrame=CFrame.new(hrp.Position+dir*8*s.size),Transparency=1,Size=Vector3.new(0.02,0.02,0.02)},Enum.EasingStyle.Quart):Play()
                game:GetService("Debris"):AddItem(shard,0.9)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["SpiralVortex"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local dots={}
        for i=1,n do local d=makePart(Vector3.new(0.2,0.2,0.2)*s.size,vGetColor(k))
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=d; table.insert(dots,d) end
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

VFuncs["Meteors"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.3/s.speed then return end; timer=0
            local col=vGetColor(k); local offset=Vector3.new(math.random(-8,8),0,math.random(-8,8))
            local startP=hrp.Position+offset+Vector3.new(0,15,0); local endP=hrp.Position+offset-Vector3.new(0,5,0)
            local meteor=makePart(Vector3.new(0.2,0.2,2)*s.size,col); meteor.CFrame=CFrame.new(startP,endP)
            local tail=Instance.new("Trail"); local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,0,1); a1.Parent=meteor
            local a2=Instance.new("Attachment"); a2.Position=Vector3.new(0,0,-1); a2.Parent=meteor
            tail.Attachment0=a1; tail.Attachment1=a2; tail.Lifetime=0.3; tail.Color=ColorSequence.new(col); tail.LightEmission=1
            tail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); tail.Parent=meteor
            makeTween(meteor,0.5,{CFrame=CFrame.new(endP,startP)*CFrame.new(0,0,-(startP-endP).Magnitude)},Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
            makeTween(meteor,0.5,{Transparency=0.8}):Play(); game:GetService("Debris"):AddItem(meteor,0.6)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

VFuncs["RainbowAura"]={
    start=function(k)
        local s=VSettings[k]; local layers=5; local auras={}
        for i=1,layers do
            local a=makePart(Vector3.new(4+i*0.5,6+i*0.5,4+i*0.5)*s.size,Color3.fromRGB(255,0,0)); a.Transparency=1-(s.opacity*0.15/i)
            local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Scale=Vector3.new(1,1.2,1); mesh.Parent=a; table.insert(auras,a)
        end
        VObjects[k]=auras; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,a in ipairs(auras) do if not a.Parent then continue end
                a.CFrame=CFrame.new(hrp.Position); a.Color=Color3.fromHSV(((t*s2.speed*0.2)+(i-1)/layers)%1,1,1)
                local pulse=1+math.sin(t*2+(i-1))*0.04; local sz=(4+i*0.5)*s2.size*pulse; a.Size=Vector3.new(sz,sz*1.2,sz)
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["PortalRing"]={
    start=function(k)
        local s=VSettings[k]; local n=24; local segments={}
        for i=1,n do local seg=makePart(Vector3.new(0.2,0.2,0.4)*s.size,vGetColor(k)); seg.Transparency=1-s.opacity; table.insert(segments,seg) end
        VObjects[k]=segments; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,seg in ipairs(segments) do if not seg.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=ao+t*s2.speed; local radius=2.5*s2.size; local waver=math.sin(t*3+ao)*0.2
                seg.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*radius,waver,math.sin(angle)*radius),hrp.Position+Vector3.new(math.cos(angle+0.1)*radius,waver,math.sin(angle+0.1)*radius))
                if s2.rainbow then seg.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

VFuncs["SparkleBurst"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.05/s.speed then return end; timer=0
            for _=1,3 do
                local col=vGetColor(k); local sparkle=makePart(Vector3.new(0.1,0.1,0.1)*s.size,col)
                sparkle.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-2,2),math.random(-3,3),math.random(-2,2)))
                local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=sparkle
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,16,0,16); bb.Adornee=sparkle; bb.Parent=sparkle
                local img=Instance.new("ImageLabel"); img.Size=UDim2.new(1,0,1,0); img.BackgroundTransparency=1; img.Image="rbxassetid://6407871923"; img.ImageColor3=col; img.ImageTransparency=0.3; img.Parent=bb
                makeTween(sparkle,0.35,{Size=Vector3.new(0.3,0.3,0.3)*s.size,Transparency=1}):Play(); game:GetService("Debris"):AddItem(sparkle,0.4)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

local function enableVisual(key)  if VEnabled[key] then return end; VEnabled[key]=true;  if VFuncs[key] then pcall(VFuncs[key].start,key) end end
local function disableVisual(key) if not VEnabled[key] then return end; VEnabled[key]=false; if VFuncs[key] then pcall(VFuncs[key].stop,key) end end

-- ==========================================================================
-- COLOR PICKER
-- ==========================================================================
local function createColorPicker(title,guiName,onSelect,extraOptions)
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local sg=Instance.new("ScreenGui"); sg.Name=guiName; sg.ResetOnSpawn=false; sg.DisplayOrder=20; sg.Parent=playerGui
    local extraH=extraOptions and 50 or 0; local pH=240+extraH
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,0,0,0); frame.Position=UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3=Config.MainColor; frame.BorderSizePixel=0; frame.Parent=sg; uiCorner(frame,12)
    makeTween(frame,0.3,{Size=UDim2.new(0,340,0,pH),Position=UDim2.new(0.5,-170,0.5,-pH/2)},Enum.EasingStyle.Back):Play()
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,44); titleBar.BackgroundColor3=Config.AccentColor; titleBar.BorderSizePixel=0; titleBar.Parent=frame; uiCorner(titleBar,12)
    local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-50,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.BackgroundTransparency=1; titleLbl.Text=title
    titleLbl.TextColor3=Config.TextColor; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=16; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar
    local closeX=Instance.new("TextButton"); closeX.Size=UDim2.new(0,36,0,36); closeX.Position=UDim2.new(1,-40,0,4)
    closeX.BackgroundColor3=Config.DarkColor; closeX.TextColor3=Config.TextColor; closeX.Text="x"; closeX.TextSize=18; closeX.Font=Enum.Font.GothamBold; closeX.BorderSizePixel=0; closeX.Parent=titleBar; uiCorner(closeX,6)
    closeX.MouseButton1Click:Connect(function() sg:Destroy() end)
    local grid=Instance.new("Frame"); grid.Size=UDim2.new(1,-24,0,130); grid.Position=UDim2.new(0,12,0,54); grid.BackgroundTransparency=1; grid.Parent=frame
    local gl=Instance.new("UIGridLayout"); gl.CellSize=UDim2.new(0,66,0,40); gl.CellPadding=UDim2.new(0,8,0,8); gl.SortOrder=Enum.SortOrder.LayoutOrder; gl.Parent=grid
    local selectedBtn=nil
    for i,preset in ipairs(PRESETS) do
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,66,0,40)
        btn.BackgroundColor3=preset.rainbow and Color3.fromRGB(255,80,80) or preset.color; btn.BorderSizePixel=0; btn.Text=preset.name
        btn.TextColor3=(preset.name=="white" or preset.name=="yellow") and Color3.fromRGB(30,30,30) or Color3.fromRGB(255,255,255)
        btn.TextSize=11; btn.Font=Enum.Font.GothamBold; btn.LayoutOrder=i; btn.Parent=grid; uiCorner(btn,7)
        if preset.rainbow then coroutine.wrap(function() while btn.Parent do btn.BackgroundColor3=Color3.fromHSV((tick()*0.5)%1,1,1); RunService.Heartbeat:Wait() end end)() end
        btn.MouseButton1Click:Connect(function()
            if selectedBtn then selectedBtn.BorderSizePixel=0 end; btn.BorderSizePixel=2; selectedBtn=btn; onSelect(preset)
        end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.12,{Size=UDim2.new(0,70,0,44)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.12,{Size=UDim2.new(0,66,0,40)}):Play() end)
    end
    if extraOptions then
        for idx,opt in ipairs(extraOptions) do
            local optBtn=Instance.new("TextButton"); optBtn.Size=UDim2.new(1,-24,0,36); optBtn.Position=UDim2.new(0,12,0,194+(idx-1)*46)
            optBtn.BackgroundColor3=opt.active() and Config.OnColor or Color3.fromRGB(200,80,80); optBtn.TextColor3=Config.TextColor
            optBtn.Text=opt.label..(opt.active() and ": on" or ": off"); optBtn.Font=Enum.Font.GothamBold; optBtn.TextSize=13; optBtn.BorderSizePixel=0; optBtn.Parent=frame; uiCorner(optBtn,8)
            optBtn.MouseButton1Click:Connect(function() opt.toggle(); optBtn.Text=opt.label..(opt.active() and ": on" or ": off"); makeTween(optBtn,0.2,{BackgroundColor3=opt.active() and Config.OnColor or Color3.fromRGB(200,80,80)}):Play() end)
        end
    end
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,34); doneBtn.Position=UDim2.new(0,12,1,-46)
    doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="done"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=14; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,8)
    doneBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- slider row helper (reused in both settings panels)
local function makeSliderRow(frame,yPos,labelText,initVal,maxVal,fillColor,onChange)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-24,0,40); row.Position=UDim2.new(0,12,0,yPos)
    row.BackgroundColor3=Config.DarkColor; row.BorderSizePixel=0; row.Parent=frame; uiCorner(row,8)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.45,0,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=labelText; lbl.TextColor3=Color3.fromRGB(170,170,175)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local bg=Instance.new("Frame"); bg.Size=UDim2.new(0.45,0,0,6); bg.Position=UDim2.new(0.52,0,0.5,-3)
    bg.BackgroundColor3=Color3.fromRGB(40,40,50); bg.BorderSizePixel=0; bg.Parent=row; uiCorner(bg,3)
    local fill=Instance.new("Frame"); fill.Size=UDim2.new(math.clamp(initVal/maxVal,0,1),0,1,0)
    fill.BackgroundColor3=fillColor; fill.BorderSizePixel=0; fill.Parent=bg; uiCorner(fill,3)
    local handle=Instance.new("TextButton"); handle.Size=UDim2.new(0,14,0,14); handle.Position=UDim2.new(math.clamp(initVal/maxVal,0,1),-7,0.5,-7)
    handle.BackgroundColor3=Config.TextColor; handle.Text=""; handle.BorderSizePixel=0; handle.Parent=bg; uiCorner(handle,7)
    local dragging=false
    handle.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or not bg.Parent then return end
        local rel=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0.05,1)
        fill.Size=UDim2.new(rel,0,1,0); handle.Position=UDim2.new(rel,-7,0.5,-7); onChange(rel,lbl)
    end)
    return yPos+48
end

-- settings panel for visuals.win effects
local function openVisualSettings(key)
    local guiName="VenseVS_"..key
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local s=VSettings[key]
    local sg=Instance.new("ScreenGui"); sg.Name=guiName; sg.ResetOnSpawn=false; sg.DisplayOrder=25; sg.Parent=playerGui
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,0,0,0); frame.Position=UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3=Config.MainColor; frame.BorderSizePixel=0; frame.Parent=sg; uiCorner(frame,12)
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,44); titleBar.BackgroundColor3=Config.AccentColor; titleBar.BorderSizePixel=0; titleBar.Parent=frame; uiCorner(titleBar,12)
    local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-50,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.BackgroundTransparency=1
    titleLbl.Text="⚙ "..key:lower(); titleLbl.TextColor3=Config.TextColor; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=15; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar
    local closeX=Instance.new("TextButton"); closeX.Size=UDim2.new(0,36,0,36); closeX.Position=UDim2.new(1,-40,0,4)
    closeX.BackgroundColor3=Config.DarkColor; closeX.TextColor3=Config.TextColor; closeX.Text="x"; closeX.TextSize=18; closeX.Font=Enum.Font.GothamBold; closeX.BorderSizePixel=0; closeX.Parent=titleBar; uiCorner(closeX,6)
    closeX.MouseButton1Click:Connect(function() sg:Destroy() end)
    local yPos=52
    -- color swatches row
    local colorRow=Instance.new("Frame"); colorRow.Size=UDim2.new(1,-24,0,62); colorRow.Position=UDim2.new(0,12,0,yPos)
    colorRow.BackgroundColor3=Config.DarkColor; colorRow.BorderSizePixel=0; colorRow.Parent=frame; uiCorner(colorRow,8)
    local clbl=Instance.new("TextLabel"); clbl.Size=UDim2.new(1,0,0,20); clbl.Position=UDim2.new(0,10,0,4)
    clbl.BackgroundTransparency=1; clbl.Text="color"; clbl.TextColor3=Color3.fromRGB(170,170,175); clbl.Font=Enum.Font.GothamBold; clbl.TextSize=12; clbl.TextXAlignment=Enum.TextXAlignment.Left; clbl.Parent=colorRow
    local cGrid=Instance.new("Frame"); cGrid.Size=UDim2.new(1,-12,0,30); cGrid.Position=UDim2.new(0,6,0,28); cGrid.BackgroundTransparency=1; cGrid.Parent=colorRow
    local cgl=Instance.new("UIGridLayout"); cgl.CellSize=UDim2.new(0,26,0,22); cgl.CellPadding=UDim2.new(0,4,0,0); cgl.SortOrder=Enum.SortOrder.LayoutOrder; cgl.Parent=cGrid
    local cPresets={Color3.fromRGB(255,80,80),Color3.fromRGB(255,160,40),Color3.fromRGB(255,230,40),Color3.fromRGB(80,220,80),Color3.fromRGB(40,180,255),Color3.fromRGB(120,80,255),Color3.fromRGB(255,80,180),Color3.fromRGB(255,255,255),Color3.fromRGB(0,255,120),Color3.fromRGB(20,20,20)}
    for ci,col in ipairs(cPresets) do
        local cb=Instance.new("TextButton"); cb.Size=UDim2.new(0,26,0,22); cb.BackgroundColor3=col; cb.Text=""; cb.BorderSizePixel=0; cb.LayoutOrder=ci; cb.Parent=cGrid; uiCorner(cb,5)
        cb.MouseButton1Click:Connect(function() s.color=col; s.rainbow=false; if VEnabled[key] then disableVisual(key); task.wait(0.05); enableVisual(key) end end)
    end
    local rbtn=Instance.new("TextButton"); rbtn.Size=UDim2.new(0,26,0,22); rbtn.Text=""; rbtn.BorderSizePixel=0; rbtn.LayoutOrder=11; rbtn.Parent=cGrid; uiCorner(rbtn,5)
    RunService.Heartbeat:Connect(function() if rbtn.Parent then rbtn.BackgroundColor3=rainbowColor() end end)
    rbtn.MouseButton1Click:Connect(function() s.rainbow=not s.rainbow; if VEnabled[key] then disableVisual(key); task.wait(0.05); enableVisual(key) end end)
    yPos=yPos+70
    yPos=makeSliderRow(frame,yPos,"size: "..string.format("%.1f",s.size),s.size,3,Config.AccentColor,function(rel,lbl) s.size=math.floor(rel*30+0.5)/10; lbl.Text="size: "..string.format("%.1f",s.size) end)
    yPos=makeSliderRow(frame,yPos,"opacity: "..string.format("%.1f",s.opacity),s.opacity,1,Color3.fromRGB(200,200,100),function(rel,lbl) s.opacity=rel; lbl.Text="opacity: "..string.format("%.1f",s.opacity) end)
    makeTween(frame,0.3,{Size=UDim2.new(0,340,0,yPos+50),Position=UDim2.new(0.5,-170,0.5,-(yPos+50)/2)},Enum.EasingStyle.Back):Play()
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,34); doneBtn.Position=UDim2.new(0,12,0,yPos+6)
    doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="apply & close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=14; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,8)
    doneBtn.MouseButton1Click:Connect(function() if VEnabled[key] then disableVisual(key); task.wait(0.05); enableVisual(key) end; sg:Destroy() end)
end

-- settings panel for original vense features (size + opacity)
local function openFeatureSettings(title,guiName,sizeKey,opacityKey,onApply)
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local sg=Instance.new("ScreenGui"); sg.Name=guiName; sg.ResetOnSpawn=false; sg.DisplayOrder=25; sg.Parent=playerGui
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,0,0,0); frame.Position=UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3=Config.MainColor; frame.BorderSizePixel=0; frame.Parent=sg; uiCorner(frame,12)
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,44); titleBar.BackgroundColor3=Config.AccentColor; titleBar.BorderSizePixel=0; titleBar.Parent=frame; uiCorner(titleBar,12)
    local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-50,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.BackgroundTransparency=1
    titleLbl.Text="⚙ "..title; titleLbl.TextColor3=Config.TextColor; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=15; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar
    local closeX=Instance.new("TextButton"); closeX.Size=UDim2.new(0,36,0,36); closeX.Position=UDim2.new(1,-40,0,4)
    closeX.BackgroundColor3=Config.DarkColor; closeX.TextColor3=Config.TextColor; closeX.Text="x"; closeX.TextSize=18; closeX.Font=Enum.Font.GothamBold; closeX.BorderSizePixel=0; closeX.Parent=titleBar; uiCorner(closeX,6)
    closeX.MouseButton1Click:Connect(function() sg:Destroy() end)
    local yPos=52
    yPos=makeSliderRow(frame,yPos,"size: "..string.format("%.1f",ColorStates[sizeKey]),ColorStates[sizeKey],3,Config.AccentColor,function(rel,lbl) ColorStates[sizeKey]=math.floor(rel*30+0.5)/10; lbl.Text="size: "..string.format("%.1f",ColorStates[sizeKey]) end)
    yPos=makeSliderRow(frame,yPos,"opacity: "..string.format("%.1f",ColorStates[opacityKey]),ColorStates[opacityKey],1,Color3.fromRGB(200,200,100),function(rel,lbl) ColorStates[opacityKey]=rel; lbl.Text="opacity: "..string.format("%.1f",ColorStates[opacityKey]) end)
    makeTween(frame,0.3,{Size=UDim2.new(0,340,0,yPos+50),Position=UDim2.new(0.5,-170,0.5,-(yPos+50)/2)},Enum.EasingStyle.Back):Play()
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,34); doneBtn.Position=UDim2.new(0,12,0,yPos+6)
    doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="apply & close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=14; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,8)
    doneBtn.MouseButton1Click:Connect(function() if onApply then onApply() end; sg:Destroy() end)
end

-- picker launchers
local function openHatPicker()
    createColorPicker("hat color","HatColorPicker",function(preset)
        ColorStates.ChinaHatColor=preset.color; ColorStates.ChinaHatNeon=preset.neon; ColorStates.ChinaHatRainbow=preset.rainbow
        stopRainbowKey("hat"); if Features.ChinaHat then applyHatColor(preset.color,preset.neon,preset.rainbow); if preset.rainbow then startHatRainbow() end end
    end,nil)
end
local function openHatSettings() openFeatureSettings("hat settings","HatSettings","ChinaHatSize","ChinaHatOpacity",function() if Features.ChinaHat then createChinaHat() end end) end
local function openHealthBarPicker()
    createColorPicker("health bar color","HealthBarColorPicker",function(preset)
        ColorStates.HealthBarColor=preset.color; ColorStates.HealthBarNeon=preset.neon; ColorStates.HealthBarRainbow=preset.rainbow
        stopRainbowKey("healthbar"); if Features.HealthBar then createHealthBar() end
    end,nil)
end
local function openHealthBarSettings() openFeatureSettings("healthbar settings","HealthBarSettings","HealthBarSize","HealthBarOpacity",function() if Features.HealthBar then createHealthBar() end end) end
local function openCrosshairPicker()
    createColorPicker("crosshair color","CrosshairColorPicker",function(preset)
        ColorStates.CrosshairColor=preset.color; ColorStates.CrosshairNeon=preset.neon; ColorStates.CrosshairRainbow=preset.rainbow
        stopRainbowKey("crosshair"); if Features.Crosshair then createCrosshair() end
    end,{{label="⟳ spin",active=function() return ColorStates.CrosshairSpin end,toggle=function() ColorStates.CrosshairSpin=not ColorStates.CrosshairSpin; if Features.Crosshair then createCrosshair() end end}})
end
local function openCrosshairSettings() openFeatureSettings("crosshair settings","CrosshairSettings","CrosshairSize","CrosshairOpacity",function() if Features.Crosshair then createCrosshair() end end) end
local function openParticlesPicker()
    createColorPicker("particles color","ParticlesColorPicker",function(preset)
        ColorStates.ParticlesColor=preset.color; ColorStates.ParticlesNeon=preset.neon; ColorStates.ParticlesRainbow=preset.rainbow
        stopRainbowKey("particles")
        if Features.Particles then for _,orb in pairs(ParticleOrbs) do if orb and orb.Parent then orb.Color=preset.color
            local bb2=orb:FindFirstChildOfClass("BillboardGui"); if bb2 then local img=bb2:FindFirstChildOfClass("ImageLabel"); if img then img.ImageColor3=preset.color end end end end end
    end,nil)
end
local function openParticlesSettings() openFeatureSettings("particles settings","ParticlesSettings","ParticlesSize","ParticlesOpacity",function() if Features.Particles then createParticles() end end) end

-- respawn
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Features.Noclip       then toggleNoclip(false);       toggleNoclip(true)       end
    if Features.InfiniteJump then toggleInfiniteJump(false); toggleInfiniteJump(true) end
    if Features.ChinaHat     then createChinaHat()   end
    if Features.HealthBar    then createHealthBar()  end
    if Features.Particles    then createParticles()  end
    for _,v in ipairs(VisualOrder) do local k=v[1]
        if VEnabled[k] then pcall(VFuncs[k].stop,k); task.wait(0.05); pcall(VFuncs[k].start,k) end
    end
end)

-- ==========================================================================
-- MAIN GUI
-- ==========================================================================
local function createMinimizedButton()
    if playerGui:FindFirstChild("VenseMinimized") then playerGui.VenseMinimized:Destroy() end
    local sg=Instance.new("ScreenGui"); sg.Name="VenseMinimized"; sg.ResetOnSpawn=false; sg.Parent=playerGui
    local btn=Instance.new("TextButton"); btn.Name="MinimizedBtn"; btn.Size=UDim2.new(0,50,0,50)
    btn.Position=UDim2.new(0,20,1,-70); btn.BackgroundColor3=Config.AccentColor; btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Text="V"; btn.TextSize=22; btn.Font=Enum.Font.GothamBold; btn.BorderSizePixel=0; btn.Parent=sg; uiCorner(btn,10)
    coroutine.wrap(function()
        while btn.Parent do makeTween(btn,0.8,{Size=UDim2.new(0,54,0,54)}):Play(); task.wait(0.8)
            if not btn.Parent then break end; makeTween(btn,0.8,{Size=UDim2.new(0,50,0,50)}):Play(); task.wait(0.8) end
    end)()
    local clicked=false
    local function onBtnClick() if clicked then return end; clicked=true; makeTween(btn,0.12,{Size=UDim2.new(0,42,0,42)}):Play(); task.wait(0.12); createMainGui(true,sg,btn) end
    btn.MouseButton1Click:Connect(onBtnClick)
    btn.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch then onBtnClick() end end)
end

function createMainGui(fromMinimized,minimizedSg,minimizedBtn)
    if playerGui:FindFirstChild("VenseGui") then playerGui.VenseGui:Destroy() end
    if playerGui:FindFirstChild("VenseMinimized") then playerGui.VenseMinimized:Destroy() end
    local sg=Instance.new("ScreenGui"); sg.Name="VenseGui"; sg.ResetOnSpawn=false; sg.Parent=playerGui
    local canvas=Instance.new("Frame"); canvas.Name="Canvas"; canvas.Size=UDim2.new(0,360,0,530)
    canvas.Position=UDim2.new(0.5,-180,0.5,-265); canvas.BackgroundTransparency=1; canvas.BorderSizePixel=0; canvas.Parent=sg
    local mainFrame=Instance.new("Frame"); mainFrame.Name="MainFrame"; mainFrame.Size=UDim2.new(1,0,1,0)
    mainFrame.BackgroundColor3=Config.MainColor; mainFrame.BackgroundTransparency=1; mainFrame.BorderSizePixel=0; mainFrame.Active=true; mainFrame.Parent=canvas; uiCorner(mainFrame,12)
    if fromMinimized and minimizedBtn then
        local vp=minimizedBtn.AbsolutePosition; local vs=minimizedBtn.AbsoluteSize
        canvas.Size=UDim2.new(0,vs.X,0,vs.Y); canvas.Position=UDim2.new(0,vp.X,0,vp.Y)
        if minimizedSg then minimizedSg:Destroy() end
        TweenService:Create(canvas,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,360,0,530),Position=UDim2.new(0.5,-180,0.5,-265)}):Play()
        makeTween(mainFrame,0.25,{BackgroundTransparency=0}):Play()
    else
        canvas.Position=UDim2.new(0.5,-180,0.5,-285)
        TweenService:Create(canvas,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-180,0.5,-265)}):Play()
        makeTween(mainFrame,0.35,{BackgroundTransparency=0}):Play()
    end
    -- title bar
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,50); titleBar.BackgroundColor3=Config.AccentColor; titleBar.BorderSizePixel=0; titleBar.Parent=mainFrame; uiCorner(titleBar,12)
    local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-60,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.BackgroundTransparency=1; titleLbl.Text="$vense.lua$"
    titleLbl.TextColor3=Config.TextColor; titleLbl.TextSize=17; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar
    local closeBtn=Instance.new("TextButton"); closeBtn.Size=UDim2.new(0,40,0,40); closeBtn.Position=UDim2.new(1,-45,0,5)
    closeBtn.BackgroundColor3=Config.DarkColor; closeBtn.TextColor3=Config.TextColor; closeBtn.Text="—"; closeBtn.TextSize=18; closeBtn.Font=Enum.Font.GothamBold; closeBtn.BorderSizePixel=0; closeBtn.Parent=titleBar; uiCorner(closeBtn,8)
    -- scroll
    local scrollFrame=Instance.new("ScrollingFrame"); scrollFrame.Size=UDim2.new(1,0,1,-50); scrollFrame.Position=UDim2.new(0,0,0,50)
    scrollFrame.BackgroundTransparency=1; scrollFrame.BorderSizePixel=0; scrollFrame.ScrollBarThickness=3; scrollFrame.ScrollBarImageColor3=Config.AccentColor
    scrollFrame.CanvasSize=UDim2.new(0,0,0,0); scrollFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y; scrollFrame.Parent=mainFrame
    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,15); pad.PaddingRight=UDim.new(0,15); pad.PaddingTop=UDim.new(0,15); pad.PaddingBottom=UDim.new(0,15); pad.Parent=scrollFrame
    local listLayout=Instance.new("UIListLayout"); listLayout.Padding=UDim.new(0,10); listLayout.FillDirection=Enum.FillDirection.Vertical; listLayout.SortOrder=Enum.SortOrder.LayoutOrder; listLayout.Parent=scrollFrame

    local function sectionLabel(text)
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,18); lbl.BackgroundTransparency=1; lbl.Text=text
        lbl.TextColor3=Color3.fromRGB(120,120,130); lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=scrollFrame
    end

    -- simple toggle button
    local function makeFeatureBtn(name,desc,featureKey,cb)
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)
        local bp=Instance.new("UIPadding"); bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12); bp.PaddingTop=UDim.new(0,8); bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn
        local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.82,0,1,0); textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox
        local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25); nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor; nameLbl.TextSize=16; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox
        local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35); descLbl.BackgroundTransparency=1; descLbl.Text=desc; descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=11; descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox
        local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,50,1,0); indicator.BackgroundTransparency=1; indicator.Text=Features[featureKey] and "on" or "off"; indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); indicator.TextSize=14; indicator.Font=Enum.Font.GothamBold; indicator.LayoutOrder=2; indicator.Parent=btn
        btn.MouseButton1Click:Connect(function() Features[featureKey]=not Features[featureKey]; indicator.Text=Features[featureKey] and "on" or "off"; indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); cb(Features[featureKey]) end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)
    end

    -- color feature button (color + settings + toggle)
    local function makeColorFeatureBtn(name,desc,featureKey,cb,colorPickerFn,settingsFn)
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)
        local bp=Instance.new("UIPadding"); bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12); bp.PaddingTop=UDim.new(0,8); bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn
        local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.50,0,1,0); textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox
        local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25); nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor; nameLbl.TextSize=16; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox
        local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35); descLbl.BackgroundTransparency=1; descLbl.Text=desc; descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=11; descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox
        local rightSide=Instance.new("Frame"); rightSide.Size=UDim2.new(0.50,0,1,0); rightSide.BackgroundTransparency=1; rightSide.LayoutOrder=2; rightSide.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5); rl.Parent=rightSide
        local colorBtn=Instance.new("TextButton"); colorBtn.Size=UDim2.new(0,46,0,26); colorBtn.BackgroundColor3=Config.AccentColor; colorBtn.TextColor3=Config.TextColor; colorBtn.Text="color"; colorBtn.TextSize=10; colorBtn.Font=Enum.Font.GothamBold; colorBtn.BorderSizePixel=0; colorBtn.LayoutOrder=1; colorBtn.Parent=rightSide; uiCorner(colorBtn,6)
        local settingsBtn=Instance.new("TextButton"); settingsBtn.Size=UDim2.new(0,26,0,26); settingsBtn.BackgroundColor3=Config.DarkColor; settingsBtn.TextColor3=Color3.fromRGB(170,170,175); settingsBtn.Text="⚙"; settingsBtn.TextSize=14; settingsBtn.Font=Enum.Font.GothamBold; settingsBtn.BorderSizePixel=0; settingsBtn.LayoutOrder=2; settingsBtn.Parent=rightSide; uiCorner(settingsBtn,6)
        local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,32,0,26); indicator.BackgroundTransparency=1; indicator.Text=Features[featureKey] and "on" or "off"; indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); indicator.TextSize=13; indicator.Font=Enum.Font.GothamBold; indicator.LayoutOrder=3; indicator.Parent=rightSide
        colorBtn.MouseButton1Click:Connect(colorPickerFn); settingsBtn.MouseButton1Click:Connect(settingsFn)
        btn.MouseButton1Click:Connect(function() Features[featureKey]=not Features[featureKey]; indicator.Text=Features[featureKey] and "on" or "off"; indicator.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); cb(Features[featureKey]) end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)
    end

    -- visual effect button (⚙ settings + on/off)
    local function makeVisualBtn(name,desc,key)
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)
        local bp=Instance.new("UIPadding"); bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12); bp.PaddingTop=UDim.new(0,8); bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn
        local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.60,0,1,0); textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox
        local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25); nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor; nameLbl.TextSize=16; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox
        local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35); descLbl.BackgroundTransparency=1; descLbl.Text=desc; descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=11; descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox
        local rightSide=Instance.new("Frame"); rightSide.Size=UDim2.new(0.40,0,1,0); rightSide.BackgroundTransparency=1; rightSide.LayoutOrder=2; rightSide.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5); rl.Parent=rightSide
        local settingsBtn=Instance.new("TextButton"); settingsBtn.Size=UDim2.new(0,30,0,28); settingsBtn.BackgroundColor3=Config.DarkColor; settingsBtn.TextColor3=Color3.fromRGB(170,170,175); settingsBtn.Text="⚙"; settingsBtn.TextSize=16; settingsBtn.Font=Enum.Font.GothamBold; settingsBtn.BorderSizePixel=0; settingsBtn.LayoutOrder=1; settingsBtn.Parent=rightSide; uiCorner(settingsBtn,6)
        local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,36,0,28); indicator.BackgroundTransparency=1; indicator.Text=VEnabled[key] and "on" or "off"; indicator.TextColor3=VEnabled[key] and Config.OnColor or Color3.fromRGB(200,80,80); indicator.TextSize=13; indicator.Font=Enum.Font.GothamBold; indicator.LayoutOrder=2; indicator.Parent=rightSide
        settingsBtn.MouseButton1Click:Connect(function() openVisualSettings(key) end)
        btn.MouseButton1Click:Connect(function()
            if VEnabled[key] then disableVisual(key) else enableVisual(key) end
            indicator.Text=VEnabled[key] and "on" or "off"; indicator.TextColor3=VEnabled[key] and Config.OnColor or Color3.fromRGB(200,80,80)
            if VEnabled[key] then makeTween(btn,0.2,{BackgroundColor3=Color3.fromRGB(15,28,20)}):Play() else makeTween(btn,0.2,{BackgroundColor3=Config.DarkColor}):Play() end
        end)
        btn.MouseEnter:Connect(function() if not VEnabled[key] then makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end end)
        btn.MouseLeave:Connect(function() if not VEnabled[key] then makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end end)
    end

    -- build list
    sectionLabel("  cheats")
    makeFeatureBtn("noclip","walk through walls and objects","Noclip",toggleNoclip)
    makeFeatureBtn("infinite jump","jump infinitely without limit","InfiniteJump",toggleInfiniteJump)

    sectionLabel("  visuals")
    makeColorFeatureBtn("china hat","rice hat on your head","ChinaHat",function(e) if e then createChinaHat() else removeChinaHat() end end,openHatPicker,openHatSettings)
    makeColorFeatureBtn("health bar","animated hp bar at bottom of screen","HealthBar",toggleHealthBar,openHealthBarPicker,openHealthBarSettings)
    makeColorFeatureBtn("crosshair","custom crosshair with spin option","Crosshair",toggleCrosshair,openCrosshairPicker,openCrosshairSettings)
    makeColorFeatureBtn("particles","glowing orbs orbiting your character","Particles",toggleParticles,openParticlesPicker,openParticlesSettings)

    sectionLabel("  effects")
    for _,v in ipairs(VisualOrder) do makeVisualBtn(v[2],v[3],v[1]) end

    sectionLabel("  performance")
    makeFeatureBtn("boost fps","disable shadows and textures for better fps","BoostFPS",boostFPS)

    -- dragging
    local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
    mainFrame.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=canvas.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then local d=input.Position-dragStart; canvas.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(canvas,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,50,0,50),Position=UDim2.new(0,20,1,-70)}):Play()
        makeTween(mainFrame,0.25,{BackgroundTransparency=1}):Play()
        coroutine.wrap(function() task.wait(0.32); sg:Destroy(); createMinimizedButton() end)()
    end)
end

-- init
createInjectionAnimation()
task.wait(2)
createMainGui(false,nil,nil)
