--[[ $vense.lua$ V4 ]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Camera           = workspace.CurrentCamera

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Config = {
    MainColor   = Color3.fromRGB(30, 30, 35),
    AccentColor = Color3.fromRGB(100, 200, 255),
    TextColor   = Color3.fromRGB(255, 255, 255),
    DarkColor   = Color3.fromRGB(20, 20, 25),
    OnColor     = Color3.fromRGB(100, 200, 100),
    W           = 480,  -- GUI width
    BtnH        = 52,   -- button height
}

local Features = {
    Noclip       = false,
    InfiniteJump = false,
    Chams        = false,
    ESP          = false,
    ChinaHat     = false,
    BoostFPS     = false,
    HealthBar    = false,
    Crosshair    = false,
    Particles    = false,
}

local ColorStates = {
    ChinaHatColor    = Color3.fromRGB(255,80,80),
    ChinaHatNeon     = false,
    ChinaHatRainbow  = false,
    ChinaHatSize     = 1.0,
    ChinaHatOpacity  = 1.0,

    HealthBarColor   = Color3.fromRGB(100,220,100),
    HealthBarNeon    = false,
    HealthBarRainbow = false,
    HealthBarSize    = 1.0,
    HealthBarOpacity = 1.0,

    CrosshairColor   = Color3.fromRGB(255,255,255),
    CrosshairNeon    = false,
    CrosshairRainbow = false,
    CrosshairSpin    = false,
    CrosshairSize    = 1.0,
    CrosshairOpacity = 1.0,

    ParticlesColor   = Color3.fromRGB(100,200,255),
    ParticlesNeon    = true,
    ParticlesRainbow = false,
    ParticlesSize    = 1.0,
    ParticlesOpacity = 1.0,
}

-- ESP config
local ESPConfig = {
    Box          = true,
    CornerBox    = false,
    FillBox      = false,
    FillGradient = false,
    GradColor1   = Color3.fromRGB(100,200,255),
    GradColor2   = Color3.fromRGB(255,80,80),
    Skeleton     = false,
    NameESP      = true,
    NameMode     = "username",   -- "username","displayname","custom"
    CustomName   = "player",
    NameFont     = Enum.Font.GothamBold,
    NameWobbly   = false,
    VisCheck     = true,
    Distance     = true,
    Tracers      = false,
    OffArrows    = false,
    HeadDot      = true,
    Color        = Color3.fromRGB(100,200,255),
    TeamColor    = false,
}

-- Chams config
local ChamsConfig = {
    Color   = Color3.fromRGB(100,200,255),
    Rainbow = false,
    Opacity = 0.4,
    Neon    = true,
}

-- World/sky visuals
local WorldConfig = {
    WorldColor      = false,
    WorldColorVal   = Color3.fromRGB(180,200,255),
    SkyColor        = false,
    SkyColorVal     = Color3.fromRGB(50,100,200),
    SkyColorRainbow = false,
    BlackSky        = false,
    Fullbright      = false,
    FOV             = false,
    FOVVal          = 70,
    AspectRatio     = false,
    AspectRatioVal  = 1.0,
}

-- VFX settings
local VSettings = {}
local VEnabled  = {}
local VConns    = {}
local VObjects  = {}
local VRainbow  = {}

local VisualOrder = {
    {"Trail",          "body trail",        "glowing trail follows your movement"},
    {"JumpCircle",     "jump circle",       "ring expands when you jump"},
    {"Shockwave",      "shockwave",         "shockwave explodes when you land"},
    {"Wings",          "wings",             "glowing wings on your back"},
    {"GroundGlow",     "ground glow",       "glowing ring beneath your feet"},
    {"HeadAura",       "head aura",         "glowing aura around your head"},
    {"FootSparks",     "footstep sparks",   "sparks pop under your feet"},
    {"NameTag",        "nametag glow",      "glowing name tag above head"},
    {"Runes",          "floating runes",    "mystical runes float around you"},
    {"Lightning",      "lightning",         "lightning crackles around you"},
    {"Smoke",          "smoke trail",       "dreamy smoke follows your movement"},
    {"Petals",         "petal rain",        "flower petals drift around you"},
    {"StarBurst",      "star burst",        "stars explode outward periodically"},
    {"Ghost",          "ghost echo",        "transparent ghost copies trail you"},
    {"Bubbles",        "bubbles",           "bubbles float up around you"},
    {"FireCrown",      "fire crown",        "fiery crown of flames on your head"},
    {"IceCrystals",    "ice crystals",      "ice shards orbit around you"},
    {"NeonGrid",       "neon grid",         "neon grid platform under your feet"},
    {"Halo",           "angel halo",        "glowing halo floats above your head"},
    {"Dragon",         "dragon aura",       "dragon energy surrounds you"},
    {"MusicBars",      "music bars",        "equalizer bars bounce around you"},
    {"Glitch",         "glitch effect",     "your body glitches and fragments"},
    {"Constellation",  "constellation",     "stars connected by lines orbit you"},
    {"DeathExplosion", "death explosion",   "epic explosion when you die"},
    {"SpiralVortex",   "spiral vortex",     "particles spiral up from ground"},
    {"Meteors",        "meteor shower",     "meteors streak down around you"},
    {"Aura",           "aura",              "customizable full-body glow aura"},
    {"PortalRing",     "portal ring",       "swirling portal ring around waist"},
    {"SparkleBurst",   "sparkle burst",     "sparkles pop over your body"},
}

for _,v in ipairs(VisualOrder) do
    local k=v[1]
    VSettings[k]={color=Color3.fromRGB(100,200,255),rainbow=false,size=1.0,speed=1.0,opacity=0.7,count=6,delay=1.5}
    VEnabled[k]=false
end

local Connections  = {}
local RainbowConns = {}
local ParticleOrbs = {}

---------------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------------
local function getChar()  return player.Character end
local function getHRP()   local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar(); return c and c:FindFirstChild("Humanoid") end

local function uiCorner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p end
local function makeTween(obj,t,props,style,dir)
    return TweenService:Create(obj,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props)
end
local function stopRainbowKey(k) if RainbowConns[k] then RainbowConns[k]:Disconnect(); RainbowConns[k]=nil end end
local function rainbowColor(offset) return Color3.fromHSV(((tick()*0.4)+(offset or 0))%1,1,1) end
local function vStopRainbow(k) if VRainbow[k] then VRainbow[k]:Disconnect(); VRainbow[k]=nil end end
local function vCleanObjects(k)
    if VObjects[k] then for _,o in pairs(VObjects[k]) do if typeof(o)=="Instance" and o.Parent then o:Destroy() end end; VObjects[k]={} end
end
local function vDisconn(k)
    if VConns[k] then
        if typeof(VConns[k])=="RBXScriptConnection" then VConns[k]:Disconnect()
        elseif type(VConns[k])=="table" then for _,c in pairs(VConns[k]) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end end
        VConns[k]=nil
    end
end
local function makePart(size,color,mat,parent)
    local p=Instance.new("Part"); p.Size=size or Vector3.new(1,1,1); p.Color=color or Color3.new(1,1,1)
    p.Material=mat or Enum.Material.Neon; p.CanCollide=false; p.Anchored=true; p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent or workspace; return p
end
local function vGetColor(k,offset) if VSettings[k].rainbow then return rainbowColor(offset or 0) end; return VSettings[k].color end

-- flat ring: a part with CylinderMesh, lying horizontal
local function makeRing(radius,thickness,color,parent)
    local p=makePart(Vector3.new(radius*2,thickness,radius*2),color,Enum.Material.Neon,parent)
    local m=Instance.new("SpecialMesh"); m.MeshType=Enum.MeshType.Cylinder
    -- cylinder default is along Y; we rotate 90 deg on Z to lay it flat
    -- Actually we leave it upright and use CFrame rotation when placing
    m.Scale=Vector3.new(thickness/p.Size.X,1,1); m.Parent=p
    return p
end

local PRESETS = {
    {name="red",      color=Color3.fromRGB(220,50,50),   neon=false,rainbow=false},
    {name="blue",     color=Color3.fromRGB(50,120,255),  neon=false,rainbow=false},
    {name="yellow",   color=Color3.fromRGB(255,220,30),  neon=false,rainbow=false},
    {name="white",    color=Color3.fromRGB(255,255,255), neon=false,rainbow=false},
    {name="black",    color=Color3.fromRGB(20,20,20),    neon=false,rainbow=false},
    {name="green",    color=Color3.fromRGB(30,160,60),   neon=false,rainbow=false},
    {name="✦ neon",  color=Color3.fromRGB(0,255,120),   neon=true, rainbow=false},
    {name="❖ rgb",   color=Color3.fromRGB(255,0,0),     neon=true, rainbow=true },
}

---------------------------------------------------------------------------
-- SPLASH
---------------------------------------------------------------------------
local function createInjectionAnimation()
    local sg=Instance.new("ScreenGui"); sg.Name="InjectionAnimation"; sg.ResetOnSpawn=false; sg.Parent=playerGui
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundColor3=Config.DarkColor; lbl.BackgroundTransparency=0; lbl.Text="$vense.lua$"; lbl.TextSize=52
    lbl.TextColor3=Config.AccentColor; lbl.Font=Enum.Font.GothamBold; lbl.TextTransparency=1; lbl.Parent=sg
    local fi=makeTween(lbl,0.8,{TextTransparency=0}); fi:Play()
    fi.Completed:Connect(function() task.wait(1)
        local fo=TweenService:Create(lbl,TweenInfo.new(0.8),{TextTransparency=1,BackgroundTransparency=1}); fo:Play()
        fo.Completed:Connect(function() sg:Destroy() end) end)
end

---------------------------------------------------------------------------
-- NOCLIP
---------------------------------------------------------------------------
local function toggleNoclip(enabled)
    if Connections.Noclip then Connections.Noclip:Disconnect() end
    if enabled then Connections.Noclip=RunService.Stepped:Connect(function()
        local char=getChar(); if not Features.Noclip or not char then return end
        for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end) end
end

---------------------------------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------------------------------
local function toggleInfiniteJump(enabled)
    if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
    if enabled then Connections.InfiniteJump=UserInputService.JumpRequest:Connect(function()
        local char=getChar(); if Features.InfiniteJump and char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end) end
end

---------------------------------------------------------------------------
-- CHAMS (cheats tab - no kill, reposition each frame)
---------------------------------------------------------------------------
local ChamsObjects = {}
local function destroyChams()
    if Connections.Chams then Connections.Chams:Disconnect(); Connections.Chams=nil end
    for _,p in pairs(ChamsObjects) do if p and p.Parent then p:Destroy() end end
    ChamsObjects={}
end
local function createChams()
    destroyChams()
    local char=getChar(); if not char then return end
    -- create outline clones
    for _,part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
            local clone=Instance.new("SelectionBox")
            clone.Adornee=part
            clone.Color3=ChamsConfig.Color
            clone.LineThickness=0.05
            clone.SurfaceTransparency=1-ChamsConfig.Opacity
            clone.SurfaceColor3=ChamsConfig.Color
            clone.Parent=workspace
            table.insert(ChamsObjects,clone)
        end
    end
    if ChamsConfig.Rainbow then
        Connections.Chams=RunService.Heartbeat:Connect(function()
            if not Features.Chams then destroyChams(); return end
            local c=rainbowColor()
            for _,sb in pairs(ChamsObjects) do if sb and sb.Parent then sb.Color3=c; sb.SurfaceColor3=c end end
        end)
    end
end
local function toggleChams(enabled) if enabled then createChams() else destroyChams() end end

---------------------------------------------------------------------------
-- ESP
---------------------------------------------------------------------------
local ESPObjects = {}
local ESPConn    = nil
local OffArrowObjects = {}

local function removeESPForPlayer(p)
    if ESPObjects[p] then
        for _,v in pairs(ESPObjects[p]) do if typeof(v)=="Instance" and v.Parent then v:Destroy() end end
        ESPObjects[p]=nil
    end
    if OffArrowObjects[p] then if OffArrowObjects[p].Parent then OffArrowObjects[p]:Destroy() end; OffArrowObjects[p]=nil end
end

local function destroyESP()
    if ESPConn then ESPConn:Disconnect(); ESPConn=nil end
    for p,_ in pairs(ESPObjects) do removeESPForPlayer(p) end
    for p,_ in pairs(OffArrowObjects) do if OffArrowObjects[p] and OffArrowObjects[p].Parent then OffArrowObjects[p]:Destroy() end; OffArrowObjects[p]=nil end
    ESPObjects={}; OffArrowObjects={}
end

local function getNameText(p)
    if ESPConfig.NameMode=="displayname" then return p.DisplayName
    elseif ESPConfig.NameMode=="custom" then return ESPConfig.CustomName
    else return p.Name end
end

local function isVisible(char)
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    local myHRP=getHRP(); if not myHRP then return false end
    local ray=Ray.new(myHRP.Position,(hrp.Position-myHRP.Position).Unit*1000)
    local hit=workspace:FindPartOnRayWithIgnoreList(ray,{getChar(),char})
    return hit==nil
end

local SKELETON_BONES={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function startESP()
    destroyESP()
    ESPConn=RunService.Heartbeat:Connect(function()
        if not Features.ESP then destroyESP(); return end
        local myChar=getChar(); if not myChar then return end
        local cam=Camera; local vp=cam.ViewportSize

        for _,p in pairs(Players:GetPlayers()) do
            if p==player then continue end
            local char=p.Character
            if not char then removeESPForPlayer(p); continue end
            local hrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health<=0 then removeESPForPlayer(p); continue end

            local col=ESPConfig.TeamColor and (p.Team and p.TeamColor.Color or ESPConfig.Color) or ESPConfig.Color
            local vis=ESPConfig.VisCheck and isVisible(char) or true
            local alpha=vis and 1 or 0.4

            -- world to screen
            local screenPos,onScreen=cam:WorldToViewportPoint(hrp.Position)
            local dist=math.floor((hrp.Position-getHRP().Position).Magnitude)

            -- Off-screen arrow
            if ESPConfig.OffArrows then
                if not onScreen then
                    if not OffArrowObjects[p] then
                        local ag=Instance.new("ScreenGui"); ag.Name="ESPArrow_"..p.UserId; ag.ResetOnSpawn=false; ag.DisplayOrder=18; ag.Parent=playerGui
                        local arrow=Instance.new("TextLabel"); arrow.Size=UDim2.new(0,20,0,20); arrow.BackgroundTransparency=1
                        arrow.Text="▶"; arrow.TextSize=18; arrow.Font=Enum.Font.GothamBold; arrow.TextColor3=col; arrow.Parent=ag
                        OffArrowObjects[p]=ag
                    end
                    local ag=OffArrowObjects[p]
                    local lbl=ag:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        local center=Vector2.new(vp.X/2,vp.Y/2)
                        local dir=(Vector2.new(screenPos.X,screenPos.Y)-center).Unit
                        local angle=math.atan2(dir.Y,dir.X)
                        local edge=math.min(vp.X,vp.Y)*0.42
                        lbl.Position=UDim2.new(0,center.X+dir.X*edge-10,0,center.Y+dir.Y*edge-10)
                        lbl.Rotation=math.deg(angle); lbl.TextColor3=col
                    end
                else if OffArrowObjects[p] then OffArrowObjects[p]:Destroy(); OffArrowObjects[p]=nil end end
            end

            if not onScreen or screenPos.Z<0 then removeESPForPlayer(p); continue end

            -- compute bounding box from HRP
            local head=char:FindFirstChild("Head")
            local topPos=head and cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.8,0)) or screenPos
            local botPos=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
            local boxH=math.abs(topPos.Y-botPos.Y); local boxW=boxH*0.6
            local boxX=screenPos.X-boxW/2; local boxY=topPos.Y

            if not ESPObjects[p] then ESPObjects[p]={} end
            local obj=ESPObjects[p]

            local function getOrCreate(name,class,parent)
                if not obj[name] or not obj[name].Parent then
                    local inst=Instance.new(class)
                    if not obj.gui then
                        local sg=Instance.new("ScreenGui"); sg.Name="ESP_"..p.UserId; sg.ResetOnSpawn=false; sg.DisplayOrder=15; sg.IgnoreGuiInset=true; sg.Parent=playerGui; obj.gui=sg
                    end
                    inst.Parent=parent or obj.gui; obj[name]=inst
                end
                return obj[name]
            end

            -- BOX
            if ESPConfig.Box then
                local box=getOrCreate("box","Frame")
                box.Size=UDim2.new(0,boxW,0,boxH); box.Position=UDim2.new(0,boxX,0,boxY)
                box.BackgroundTransparency=1; box.BorderSizePixel=2; box.BorderColor3=col
                box.BackgroundColor3=col; box.BorderMode=Enum.BorderMode.Outline
            elseif obj.box and obj.box.Parent then obj.box:Destroy(); obj.box=nil end

            -- CORNER BOXES
            if ESPConfig.CornerBox then
                local clen=math.min(boxW,boxH)*0.25
                local corners={tl=Vector2.new(boxX,boxY),tr=Vector2.new(boxX+boxW,boxY),bl=Vector2.new(boxX,boxY+boxH),br=Vector2.new(boxX+boxW,boxY+boxH)}
                local cdefs={
                    {n="ctlh",x=corners.tl.X,y=corners.tl.Y,w=clen,h=2},
                    {n="ctlv",x=corners.tl.X,y=corners.tl.Y,w=2,h=clen},
                    {n="ctrh",x=corners.tr.X-clen,y=corners.tr.Y,w=clen,h=2},
                    {n="ctrv",x=corners.tr.X-2,y=corners.tr.Y,w=2,h=clen},
                    {n="cblh",x=corners.bl.X,y=corners.bl.Y-2,w=clen,h=2},
                    {n="cblv",x=corners.bl.X,y=corners.bl.Y-clen,w=2,h=clen},
                    {n="cbrh",x=corners.br.X-clen,y=corners.br.Y-2,w=clen,h=2},
                    {n="cbrv",x=corners.br.X-2,y=corners.br.Y-clen,w=2,h=clen},
                }
                for _,cd in ipairs(cdefs) do
                    local f=getOrCreate(cd.n,"Frame"); f.BackgroundColor3=col; f.BorderSizePixel=0
                    f.Size=UDim2.new(0,cd.w,0,cd.h); f.Position=UDim2.new(0,cd.x,0,cd.y); f.BackgroundTransparency=1-alpha
                end
            end

            -- FILL BOX
            if ESPConfig.FillBox then
                local fill=getOrCreate("fill","Frame")
                fill.Size=UDim2.new(0,boxW,0,boxH); fill.Position=UDim2.new(0,boxX,0,boxY)
                fill.BorderSizePixel=0; fill.BackgroundTransparency=1-(0.25*alpha)
                if ESPConfig.FillGradient then
                    fill.BackgroundColor3=ESPConfig.GradColor1
                    if not obj.grad or not obj.grad.Parent then local g=Instance.new("UIGradient"); g.Parent=fill; obj.grad=g end
                    obj.grad.Color=ColorSequence.new(ESPConfig.GradColor1,ESPConfig.GradColor2); obj.grad.Rotation=90
                else fill.BackgroundColor3=col; if obj.grad and obj.grad.Parent then obj.grad:Destroy(); obj.grad=nil end end
            elseif obj.fill and obj.fill.Parent then obj.fill:Destroy(); obj.fill=nil end

            -- SKELETON
            if ESPConfig.Skeleton then
                for bi,bone in ipairs(SKELETON_BONES) do
                    local p0=char:FindFirstChild(bone[1]); local p1=char:FindFirstChild(bone[2])
                    if p0 and p1 then
                        local s0,on0=cam:WorldToViewportPoint(p0.Position); local s1,on1=cam:WorldToViewportPoint(p1.Position)
                        if on0 and on1 then
                            local bn=getOrCreate("bone"..bi,"Frame")
                            local mid=Vector2.new((s0.X+s1.X)/2,(s0.Y+s1.Y)/2)
                            local len=Vector2.new(s1.X-s0.X,s1.Y-s0.Y).Magnitude
                            local ang=math.atan2(s1.Y-s0.Y,s1.X-s0.X)
                            bn.Size=UDim2.new(0,len,0,2); bn.Position=UDim2.new(0,mid.X-len/2,0,mid.Y-1)
                            bn.Rotation=math.deg(ang); bn.BackgroundColor3=col; bn.BorderSizePixel=0; bn.BackgroundTransparency=1-alpha
                        end
                    end
                end
            end

            -- NAME
            if ESPConfig.NameESP then
                local nl=getOrCreate("name","TextLabel")
                local nameText=getNameText(p)
                if ESPConfig.NameWobbly then
                    local wave="" for i=1,#nameText do wave=wave..nameText:sub(i,i)..string.rep(" ",math.floor(math.abs(math.sin(tick()*3+i))*0.5)) end
                    nl.Text=wave
                else nl.Text=nameText end
                nl.Font=ESPConfig.NameFont; nl.TextSize=14; nl.TextColor3=col; nl.TextStrokeTransparency=0.3
                nl.BackgroundTransparency=1; nl.Size=UDim2.new(0,100,0,18); nl.Position=UDim2.new(0,screenPos.X-50,0,boxY-20)
                nl.TextTransparency=1-alpha
            elseif obj.name and obj.name.Parent then obj.name:Destroy(); obj.name=nil end

            -- DISTANCE
            if ESPConfig.Distance then
                local dl=getOrCreate("dist","TextLabel")
                dl.Text=dist.."m"; dl.Font=Enum.Font.Gotham; dl.TextSize=12; dl.TextColor3=col
                dl.BackgroundTransparency=1; dl.Size=UDim2.new(0,60,0,16); dl.Position=UDim2.new(0,screenPos.X-30,0,boxY+boxH+2)
                dl.TextTransparency=1-alpha
            elseif obj.dist and obj.dist.Parent then obj.dist:Destroy(); obj.dist=nil end

            -- TRACERS
            if ESPConfig.Tracers then
                local tl=getOrCreate("tracer","Frame")
                local startY=vp.Y; local startX=vp.X/2
                local ex=screenPos.X; local ey=screenPos.Y
                local dx=ex-startX; local dy=ey-startY; local len=math.sqrt(dx*dx+dy*dy)
                local ang=math.atan2(dy,dx)
                tl.Size=UDim2.new(0,len,0,1); tl.Position=UDim2.new(0,startX,0,startY)
                tl.Rotation=math.deg(ang); tl.BackgroundColor3=col; tl.BorderSizePixel=0; tl.BackgroundTransparency=1-alpha*0.7
            elseif obj.tracer and obj.tracer.Parent then obj.tracer:Destroy(); obj.tracer=nil end

            -- HEAD DOT
            if ESPConfig.HeadDot and head then
                local hs,hon=cam:WorldToViewportPoint(head.Position)
                if hon then
                    local hd=getOrCreate("headdot","Frame"); hd.Size=UDim2.new(0,8,0,8)
                    hd.Position=UDim2.new(0,hs.X-4,0,hs.Y-4); hd.BackgroundColor3=col; hd.BorderSizePixel=0; hd.BackgroundTransparency=1-alpha; uiCorner(hd,4)
                end
            elseif obj.headdot and obj.headdot.Parent then obj.headdot:Destroy(); obj.headdot=nil end
        end

        -- cleanup left players
        for p,_ in pairs(ESPObjects) do
            if not p.Parent or not p.Character then removeESPForPlayer(p) end
        end
    end)
end

local function toggleESP(enabled) if enabled then startESP() else destroyESP() end end

---------------------------------------------------------------------------
-- CHINA HAT
---------------------------------------------------------------------------
local function startHatRainbow()
    stopRainbowKey("hat")
    RainbowConns["hat"]=RunService.Heartbeat:Connect(function()
        local char=getChar(); if not char or not char:FindFirstChild("ChinaHatCone") then stopRainbowKey("hat"); return end
        local c=Color3.fromHSV((tick()*0.5)%1,1,1)
        local cone=char:FindFirstChild("ChinaHatCone"); local brim=char:FindFirstChild("ChinaHatBrim")
        if cone then cone.Color=c end; if brim then brim.Color=c end
    end)
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

---------------------------------------------------------------------------
-- BOOST FPS
---------------------------------------------------------------------------
local function boostFPS(enabled)
    if enabled then Lighting.GlobalShadows=false; Lighting.Brightness=2
        for _,d in pairs(workspace:GetDescendants()) do if d:IsA("Texture") then d:Destroy() end end
    else Lighting.GlobalShadows=true; Lighting.Brightness=1 end
end

---------------------------------------------------------------------------
-- HEALTH BAR
---------------------------------------------------------------------------
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
    local barW=math.floor(320*ColorStates.HealthBarSize); local barH=math.floor(26*ColorStates.HealthBarSize)
    local sg=Instance.new("ScreenGui"); sg.Name="VenseHealthBar"; sg.ResetOnSpawn=false; sg.DisplayOrder=5; sg.Parent=playerGui; HealthBarGui=sg
    local container=Instance.new("Frame"); container.Size=UDim2.new(0,barW,0,barH); container.Position=UDim2.new(0.5,-barW/2,1,-60)
    container.BackgroundColor3=Color3.fromRGB(15,15,18); container.BorderSizePixel=0; container.BackgroundTransparency=1-ColorStates.HealthBarOpacity; container.Parent=sg; uiCorner(container,14)
    local track=Instance.new("Frame"); track.Size=UDim2.new(1,-8,1,-8); track.Position=UDim2.new(0,4,0,4); track.BackgroundColor3=Color3.fromRGB(35,35,40); track.BorderSizePixel=0; track.Parent=container; uiCorner(track,10)
    local fill=Instance.new("Frame"); fill.Name="Fill"; fill.Size=UDim2.new(1,0,1,0); fill.BackgroundColor3=ColorStates.HealthBarColor; fill.BorderSizePixel=0; fill.Parent=track; uiCorner(fill,10)
    local healthLbl=Instance.new("TextLabel"); healthLbl.Size=UDim2.new(1,0,1,0); healthLbl.BackgroundTransparency=1; healthLbl.Text="100 HP"; healthLbl.TextColor3=Color3.fromRGB(255,255,255); healthLbl.Font=Enum.Font.GothamBold; healthLbl.TextSize=math.floor(12*ColorStates.HealthBarSize); healthLbl.ZIndex=4; healthLbl.Parent=container
    local lastHealth=humanoid.Health
    local function updateBar(hp,maxHp)
        local ratio=math.clamp(hp/math.max(maxHp,1),0,1)
        makeTween(fill,0.35,{Size=UDim2.new(ratio,0,1,0)},Enum.EasingStyle.Quart):Play()
        if not ColorStates.HealthBarRainbow then makeTween(fill,0.35,{BackgroundColor3=Color3.fromRGB(math.floor(220*(1-ratio)+80*ratio),math.floor(200*ratio),50)}):Play() end
        healthLbl.Text=math.floor(hp).." HP"; lastHealth=hp
    end
    updateBar(humanoid.Health,humanoid.MaxHealth)
    Connections.HealthBar=humanoid.HealthChanged:Connect(function(hp) updateBar(math.max(hp,0),humanoid.MaxHealth) end)
    if ColorStates.HealthBarRainbow then RainbowConns["healthbar"]=RunService.Heartbeat:Connect(function() if not Features.HealthBar then stopRainbowKey("healthbar"); return end; fill.BackgroundColor3=Color3.fromHSV((tick()*0.5)%1,1,1) end) end
    container.BackgroundTransparency=1; makeTween(container,0.5,{Position=UDim2.new(0.5,-barW/2,1,-60),BackgroundTransparency=1-ColorStates.HealthBarOpacity},Enum.EasingStyle.Back):Play()
end
local function toggleHealthBar(enabled)
    if enabled then createHealthBar() else
        if HealthBarGui then local cont=HealthBarGui:FindFirstChild("Container"); if cont then local out=makeTween(cont,0.35,{BackgroundTransparency=1}); out:Play(); out.Completed:Connect(function() destroyHealthBar() end) else destroyHealthBar() end
        end
    end
end

---------------------------------------------------------------------------
-- CROSSHAIR
---------------------------------------------------------------------------
local CrosshairGui=nil
local function destroyCrosshair()
    stopRainbowKey("crosshair"); if Connections.CrosshairSpin then Connections.CrosshairSpin:Disconnect(); Connections.CrosshairSpin=nil end
    if CrosshairGui then CrosshairGui:Destroy(); CrosshairGui=nil end
end
local function createCrosshair()
    destroyCrosshair()
    local sg=Instance.new("ScreenGui"); sg.Name="VenseCrosshair"; sg.ResetOnSpawn=false; sg.DisplayOrder=10; sg.IgnoreGuiInset=true; sg.Parent=playerGui; CrosshairGui=sg
    local col=ColorStates.CrosshairColor; local sz=ColorStates.CrosshairSize; local op=1-ColorStates.CrosshairOpacity
    local root=Instance.new("Frame"); root.Name="Root"; root.Size=UDim2.new(0,60*sz,0,60*sz); root.Position=UDim2.new(0.5,-30*sz,0.5,-30*sz); root.BackgroundTransparency=1; root.BorderSizePixel=0; root.Parent=sg
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,5*sz,0,5*sz); dot.Position=UDim2.new(0.5,-2.5*sz,0.5,-2.5*sz); dot.BackgroundColor3=col; dot.BorderSizePixel=0; dot.BackgroundTransparency=op; dot.Parent=root; uiCorner(dot,3)
    local armDefs={{name="Top",size=UDim2.new(0,2*sz,0,14*sz),pos=UDim2.new(0.5,-1*sz,0.5,-22*sz)},{name="Bottom",size=UDim2.new(0,2*sz,0,14*sz),pos=UDim2.new(0.5,-1*sz,0.5,8*sz)},{name="Left",size=UDim2.new(0,14*sz,0,2*sz),pos=UDim2.new(0.5,-22*sz,0.5,-1*sz)},{name="Right",size=UDim2.new(0,14*sz,0,2*sz),pos=UDim2.new(0.5,8*sz,0.5,-1*sz)}}
    local arms={}
    for _,def in ipairs(armDefs) do local arm=Instance.new("Frame"); arm.Name=def.name; arm.Size=def.size; arm.Position=def.pos; arm.BackgroundColor3=col; arm.BorderSizePixel=0; arm.BackgroundTransparency=op; arm.Parent=root; uiCorner(arm,2); arms[def.name]=arm end
    local function applyColor(c) dot.BackgroundColor3=c; for _,arm in pairs(arms) do arm.BackgroundColor3=c end end
    if ColorStates.CrosshairRainbow then RainbowConns["crosshair"]=RunService.Heartbeat:Connect(function() if not Features.Crosshair then stopRainbowKey("crosshair"); return end; applyColor(Color3.fromHSV((tick()*0.6)%1,1,1)) end)
    else applyColor(col) end
    if ColorStates.CrosshairSpin then local angle=0; Connections.CrosshairSpin=RunService.Heartbeat:Connect(function(dt) if not Features.Crosshair then Connections.CrosshairSpin:Disconnect(); Connections.CrosshairSpin=nil; return end; angle=angle+dt*180; root.Rotation=angle%360 end) end
end
local function toggleCrosshair(enabled) if enabled then createCrosshair() else if CrosshairGui then destroyCrosshair() end end end

---------------------------------------------------------------------------
-- PARTICLES
---------------------------------------------------------------------------
local function destroyParticles()
    stopRainbowKey("particles"); if Connections.Particles then Connections.Particles:Disconnect(); Connections.Particles=nil end
    for _,orb in pairs(ParticleOrbs) do if orb and orb.Parent then orb:Destroy() end end; ParticleOrbs={}
end
local function createParticles()
    destroyParticles(); local char=getChar(); if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local NUM=8; local RAD=3.5*ColorStates.ParticlesSize; local ORSZ=0.35*ColorStates.ParticlesSize; local col=ColorStates.ParticlesColor
    for i=1,NUM do
        local orb=Instance.new("Part"); orb.Name="VenseOrb_"..i; orb.Size=Vector3.new(ORSZ,ORSZ,ORSZ); orb.Color=col; orb.Material=Enum.Material.Neon; orb.CanCollide=false; orb.Anchored=true; orb.CastShadow=false; orb.Transparency=1-ColorStates.ParticlesOpacity; orb.Parent=workspace
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=orb; table.insert(ParticleOrbs,orb)
    end
    local st=tick()
    Connections.Particles=RunService.Heartbeat:Connect(function()
        local char2=getChar(); if not char2 or not Features.Particles then destroyParticles(); return end
        local r2=char2:FindFirstChild("HumanoidRootPart"); if not r2 then return end
        local t=tick()-st; local base=r2.Position
        for i,orb in ipairs(ParticleOrbs) do if not orb or not orb.Parent then continue end
            local ao=(i-1)/NUM*math.pi*2; local angle=t*1.2*math.pi*2+ao; local bobY=math.sin(t*0.8*math.pi*2+ao)*1.2
            orb.CFrame=CFrame.new(base.X+math.cos(angle)*RAD,base.Y+1+bobY,base.Z+math.sin(angle)*RAD)
            local pulse=1+math.sin(t*3+ao)*0.15; local sz=ORSZ*pulse; orb.Size=Vector3.new(sz,sz,sz)
            if ColorStates.ParticlesRainbow then local rc=Color3.fromHSV(((t*0.4)+(i-1)/NUM)%1,1,1); orb.Color=rc end
        end
    end)
end
local function toggleParticles(enabled) if enabled then createParticles() else destroyParticles() end end

---------------------------------------------------------------------------
-- WORLD VISUALS
---------------------------------------------------------------------------
local origAmbient=Lighting.Ambient
local origOutdoor=Lighting.OutdoorAmbient
local origBrightness=Lighting.Brightness
local origFOV=Camera.FieldOfView

local function applyWorldColor()
    if WorldConfig.WorldColor then Lighting.Ambient=WorldConfig.WorldColorVal; Lighting.OutdoorAmbient=WorldConfig.WorldColorVal
    else Lighting.Ambient=origAmbient; Lighting.OutdoorAmbient=origOutdoor end
end
local function applySkyColor()
    local sky=Lighting:FindFirstChildOfClass("Sky")
    if WorldConfig.BlackSky then Lighting.Brightness=0; if sky then sky.Transparency=1 end; return end
    if sky then sky.Transparency=WorldConfig.SkyColor and 0 or 0 end
    if WorldConfig.SkyColor then
        if WorldConfig.SkyColorRainbow then
            if not RainbowConns["sky"] then RainbowConns["sky"]=RunService.Heartbeat:Connect(function()
                if not WorldConfig.SkyColor then stopRainbowKey("sky"); return end
                Lighting.FogColor=Color3.fromHSV((tick()*0.3)%1,0.8,1)
                Lighting.Ambient=Color3.fromHSV((tick()*0.3+0.1)%1,0.6,0.8)
            end) end
        else stopRainbowKey("sky"); Lighting.FogColor=WorldConfig.SkyColorVal; Lighting.Ambient=WorldConfig.SkyColorVal end
    else stopRainbowKey("sky"); Lighting.FogColor=Color3.fromRGB(0,0,0) end
end
local function applyFullbright() Lighting.Brightness=WorldConfig.Fullbright and 10 or origBrightness end
local function applyFOV() Camera.FieldOfView=WorldConfig.FOV and WorldConfig.FOVVal or origFOV end
local function applyAspectRatio()
    if WorldConfig.AspectRatio then Camera.DiagonalFieldOfView=WorldConfig.AspectRatioVal*90
    else Camera.DiagonalFieldOfView=nil end
end

---------------------------------------------------------------------------
-- VFUNCS
---------------------------------------------------------------------------
local VFuncs={}

-- TRAIL
VFuncs["Trail"]={
    start=function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
        local a0=Instance.new("Attachment"); a0.Position=Vector3.new(0,1,0); a0.Parent=hrp
        local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,-1,0); a1.Parent=hrp
        local tr=Instance.new("Trail"); tr.Attachment0=a0; tr.Attachment1=a1; tr.Lifetime=0.8; tr.MinLength=0
        tr.Color=ColorSequence.new(s.color); tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1-s.opacity),NumberSequenceKeypoint.new(1,1)})
        tr.WidthScale=NumberSequence.new(s.size*2); tr.LightEmission=1; tr.FaceCamera=true; tr.Parent=hrp; VObjects[k]={a0,a1,tr}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function() if not VEnabled[k] then vStopRainbow(k); return end; tr.Color=ColorSequence.new(rainbowColor()) end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

-- JUMP CIRCLE - fixed: proper flat ring using wedge parts forming a circle
VFuncs["JumpCircle"]={
    start=function(k)
        local hum=getHum(); if not hum then return end
        VConns[k]=hum.Jumping:Connect(function(active)
            if not active then return end; local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]
            local SEGS=32; local RADIUS=4*s.size; local col=vGetColor(k)
            local parts={}
            for i=1,SEGS do
                local ang1=(i-1)/SEGS*math.pi*2; local ang2=i/SEGS*math.pi*2
                local p1=Vector3.new(math.cos(ang1)*RADIUS,0,math.sin(ang1)*RADIUS)
                local p2=Vector3.new(math.cos(ang2)*RADIUS,0,math.sin(ang2)*RADIUS)
                local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                local seg=makePart(Vector3.new(len,0.1,0.15),col)
                seg.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)+mid,hrp.Position-Vector3.new(0,3,0)+mid+Vector3.new(math.cos(ang1+math.pi/SEGS),0,math.sin(ang1+math.pi/SEGS)))
                seg.Transparency=0; table.insert(parts,seg)
            end
            -- expand outward
            local t0=tick(); local DURATION=0.6; local EXPAND=8*s.size
            local expandConn; expandConn=RunService.Heartbeat:Connect(function()
                local elapsed=tick()-t0
                if elapsed>DURATION then expandConn:Disconnect()
                    for _,seg in ipairs(parts) do if seg.Parent then seg:Destroy() end end; return end
                local prog=elapsed/DURATION
                local r=RADIUS+EXPAND*prog
                local alpha=1-prog
                for i,seg in ipairs(parts) do
                    if not seg.Parent then continue end
                    local ang1=(i-1)/SEGS*math.pi*2; local ang2=i/SEGS*math.pi*2
                    local p1=Vector3.new(math.cos(ang1)*r,0,math.sin(ang1)*r)
                    local p2=Vector3.new(math.cos(ang2)*r,0,math.sin(ang2)*r)
                    local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                    seg.Size=Vector3.new(len,0.08*(1-prog*0.5),0.12)
                    seg.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)+mid,hrp.Position-Vector3.new(0,3,0)+mid+Vector3.new(math.cos(ang1+math.pi/SEGS),0,math.sin(ang1+math.pi/SEGS)))
                    seg.Transparency=1-alpha
                end
            end)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

-- SHOCKWAVE - fixed: proper ring segments expanding on ground
VFuncs["Shockwave"]={
    start=function(k)
        local wasInAir=false
        VConns[k]=RunService.Heartbeat:Connect(function()
            if not VEnabled[k] then return end; local h=getHum(); if not h then return end
            local inAir=h:GetState()==Enum.HumanoidStateType.Freefall or h:GetState()==Enum.HumanoidStateType.Jumping
            if wasInAir and not inAir then
                local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local col=vGetColor(k)
                for wave=1,3 do coroutine.wrap(function()
                    task.wait(wave*0.08)
                    local SEGS=32; local RADIUS=1; local MAXR=(5+wave*3)*s.size; local DURATION=0.55
                    local parts={}
                    for i=1,SEGS do
                        local ang1=(i-1)/SEGS*math.pi*2; local ang2=i/SEGS*math.pi*2
                        local p1=Vector3.new(math.cos(ang1),0,math.sin(ang1)); local p2=Vector3.new(math.cos(ang2),0,math.sin(ang2))
                        local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                        local seg=makePart(Vector3.new(len,0.08,0.12),col)
                        seg.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)+mid,hrp.Position-Vector3.new(0,3,0)+mid+Vector3.new(math.cos(ang1+math.pi/SEGS),0,math.sin(ang1+math.pi/SEGS)))
                        table.insert(parts,seg)
                    end
                    local t0=tick(); local expandConn; expandConn=RunService.Heartbeat:Connect(function()
                        local elapsed=tick()-t0
                        if elapsed>DURATION then expandConn:Disconnect()
                            for _,seg in ipairs(parts) do if seg.Parent then seg:Destroy() end end; return end
                        local prog=elapsed/DURATION; local r=RADIUS+MAXR*prog; local alpha=1-prog
                        for i,seg in ipairs(parts) do if not seg.Parent then continue end
                            local ang1=(i-1)/SEGS*math.pi*2; local ang2=i/SEGS*math.pi*2
                            local p1=Vector3.new(math.cos(ang1)*r,0,math.sin(ang1)*r); local p2=Vector3.new(math.cos(ang2)*r,0,math.sin(ang2)*r)
                            local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                            seg.Size=Vector3.new(len,0.06,0.1)
                            seg.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)+mid,hrp.Position-Vector3.new(0,3,0)+mid+Vector3.new(math.cos(ang1+math.pi/SEGS),0,math.sin(ang1+math.pi/SEGS)))
                            seg.Transparency=1-alpha*s.opacity
                        end
                    end)
                end)() end
            end; wasInAir=inAir
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

-- WINGS
VFuncs["Wings"]={
    start=function(k)
        local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local wings={}
        for side=-1,1,2 do for seg=1,4 do
            local w=makePart(Vector3.new(0.15,0.8+seg*0.2,1.2+seg*0.3)*s.size,vGetColor(k)); w.Transparency=1-s.opacity; table.insert(wings,w)
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

-- GROUND GLOW - fixed: proper flat ring using circle segments
VFuncs["GroundGlow"]={
    start=function(k)
        local s=VSettings[k]; local SEGS=48; local parts={}
        for i=1,SEGS do
            local seg=makePart(Vector3.new(0.5,0.1,0.5),vGetColor(k)); seg.Transparency=1-s.opacity*0.7; table.insert(parts,seg)
        end
        VObjects[k]=parts; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            local r=4*s2.size*(1+math.sin(t*2)*0.08); local base=hrp.Position-Vector3.new(0,3,0)
            for i,seg in ipairs(parts) do if not seg.Parent then continue end
                local ang=(i-1)/SEGS*math.pi*2
                local nx=math.cos(ang)*r; local nz=math.sin(ang)*r
                local segLen=2*math.pi*r/SEGS+0.05
                seg.Size=Vector3.new(segLen,0.08,0.15)
                seg.CFrame=CFrame.new(base+Vector3.new(nx,0,nz),base+Vector3.new(math.cos(ang+0.01)*r,0,math.sin(ang+0.01)*r))
                if s2.rainbow then seg.Color=rainbowColor((i-1)/SEGS) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

-- HEAD AURA
VFuncs["HeadAura"]={
    start=function(k)
        local s=VSettings[k]; local aura=makePart(Vector3.new(3,3,3)*s.size,vGetColor(k)); aura.Transparency=1-s.opacity*0.5
        local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=aura
        VObjects[k]={aura}; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
            local s2=VSettings[k]; local t=tick()-t0; local pulse=1+math.sin(t*2.5)*0.08; local sz=3*s2.size*pulse
            aura.Size=Vector3.new(sz,sz,sz); aura.CFrame=CFrame.new(head.Position); if s2.rainbow then aura.Color=rainbowColor() end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

-- FOOT SPARKS - fixed: BillboardGui sparks, always visible
VFuncs["FootSparks"]={
    start=function(k)
        local lastPos=nil; local stepTimer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; stepTimer=stepTimer+dt
            if lastPos and (hrp.Position-lastPos).Magnitude>1.2 and stepTimer>0.1 then
                stepTimer=0; local col=vGetColor(k)
                for _=1,6 do
                    local spark=makePart(Vector3.new(0.12,0.12,0.12)*s.size,col)
                    local foot=hrp.Position-Vector3.new(math.random(-2,2)*0.5,3,math.random(-2,2)*0.5)
                    spark.CFrame=CFrame.new(foot)
                    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,30*s.size,0,30*s.size); bb.Adornee=spark; bb.AlwaysOnTop=false; bb.Parent=spark
                    local img=Instance.new("ImageLabel"); img.Size=UDim2.new(1,0,1,0); img.BackgroundTransparency=1; img.Image="rbxassetid://6407871923"; img.ImageColor3=col; img.ImageTransparency=0; img.Parent=bb
                    local targetCF=CFrame.new(foot+Vector3.new(math.random(-3,3),math.random(2,5),math.random(-3,3)))
                    makeTween(spark,0.35,{CFrame=targetCF,Transparency=1}):Play()
                    makeTween(bb,0.35,{ExtentsOffset=Vector3.new(0,math.random(1,3),0)}):Play()
                    game:GetService("Debris"):AddItem(spark,0.4)
                end
            end; lastPos=hrp.Position
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

-- NAME TAG - with mode config
VFuncs["NameTag"]={
    start=function(k)
        local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end; local s=VSettings[k]
        local sg=Instance.new("BillboardGui"); sg.Size=UDim2.new(0,220*s.size,0,44); sg.StudsOffset=Vector3.new(0,3.5,0); sg.Adornee=head; sg.AlwaysOnTop=true; sg.Parent=head
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=17*s.size; lbl.TextColor3=s.color; lbl.TextStrokeTransparency=0.3; lbl.Parent=sg
        local mode=s.nameMode or "username"
        local function getName()
            if mode=="displayname" then return player.DisplayName
            elseif mode=="custom" then return s.customName or player.Name
            else return player.Name end
        end
        lbl.Text="✦ "..getName().." ✦"
        VObjects[k]={sg}
        if s.rainbow then VRainbow[k]=RunService.Heartbeat:Connect(function() if not VEnabled[k] then vStopRainbow(k); return end; lbl.TextColor3=rainbowColor() end) end
    end,
    stop=function(k) vStopRainbow(k); vCleanObjects(k) end,
}

-- RUNES
VFuncs["Runes"]={
    start=function(k)
        local runeChars={"ᚠ","ᚢ","ᚦ","ᚨ","ᚱ","ᚲ","ᚷ","ᚹ","ᚺ","ᚾ","ᛁ","ᛃ","ᛇ","ᛈ","ᛉ","ᛊ","ᛏ","ᛒ","ᛖ","ᛗ","ᛚ","ᛜ","ᛞ","ᛟ"}
        local s=VSettings[k]; local n=math.floor(s.count); local runes={}
        for i=1,n do
            local part=makePart(Vector3.new(0.1,0.1,0.1),Color3.fromRGB(1,1,1)); part.Transparency=1
            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,40*s.size,0,40*s.size); bb.Adornee=part; bb.Parent=part
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=runeChars[math.random(#runeChars)]; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=28*s.size; lbl.TextColor3=s.color; lbl.TextStrokeTransparency=0.2; lbl.Parent=bb
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

-- LIGHTNING
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

-- SMOKE
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

-- PETALS
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

-- STAR BURST - with delay config
VFuncs["StarBurst"]={
    start=function(k)
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

-- GHOST - with delay config
VFuncs["Ghost"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local char=getChar(); if not char then return end; local s=VSettings[k]; timer=timer+dt
            if timer<(s.delay or 0.12)/s.speed then return end; timer=0
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

-- BUBBLES
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

-- FIRE CROWN
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

-- ICE CRYSTALS - fixed: use Block mesh with elongated parts, WeldConstraint replaced with Heartbeat positioning
VFuncs["IceCrystals"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local crystals={}
        for i=1,n do
            local cry=makePart(Vector3.new(0.2*s.size,1.2*s.size,0.2*s.size),vGetColor(k)); cry.Transparency=1-s.opacity*0.8
            cry.Material=Enum.Material.Glass; table.insert(crystals,cry)
        end
        VObjects[k]=crystals; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            for i,cry in ipairs(crystals) do if not cry.Parent then continue end
                local ao=(i-1)/n*math.pi*2; local angle=t*s2.speed+ao
                local px=hrp.Position.X+math.cos(angle)*3*s2.size
                local py=hrp.Position.Y+math.sin(t*1.5+ao)*0.5
                local pz=hrp.Position.Z+math.sin(angle)*3*s2.size
                cry.CFrame=CFrame.new(px,py,pz)*CFrame.Angles(t*2+ao,math.sin(t+ao)*0.5,t+ao)
                if s2.rainbow then cry.Color=rainbowColor((i-1)/n) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

-- NEON GRID
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

-- HALO - fixed: proper flat ring using circle segments
VFuncs["Halo"]={
    start=function(k)
        local s=VSettings[k]; local SEGS=40; local parts={}
        for i=1,SEGS do
            local seg=makePart(Vector3.new(0.35,0.18,0.18)*s.size,vGetColor(k)); seg.Transparency=1-s.opacity; table.insert(parts,seg)
        end
        VObjects[k]=parts; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local char=getChar(); if not char then return end; local head=char:FindFirstChild("Head"); if not head then return end
            local s2=VSettings[k]; local t=tick()-t0; local r=1.5*s2.size; local tilt=math.rad(15)
            local center=head.Position+Vector3.new(0,1.2+math.sin(t*1.5)*0.12,0)
            for i,seg in ipairs(parts) do if not seg.Parent then continue end
                local ang=(i-1)/SEGS*math.pi*2+t*0.4
                local px=math.cos(ang)*r; local pz=math.sin(ang)*r
                local rotated=Vector3.new(px, pz*math.sin(tilt), pz*math.cos(tilt))
                seg.CFrame=CFrame.new(center+rotated,center+Vector3.new(math.cos(ang+0.01)*r, math.sin(ang+0.01)*r*math.sin(tilt), math.sin(ang+0.01)*r*math.cos(tilt)))
                if s2.rainbow then seg.Color=rainbowColor((i-1)/SEGS) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

-- DRAGON
VFuncs["Dragon"]={
    start=function(k)
        local s=VSettings[k]; local segments=20; local parts={}
        for i=1,segments do local p=makePart(Vector3.new(0.3,0.3,0.3)*s.size,vGetColor(k)); p.Transparency=1-s.opacity*0.7; local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=p; table.insert(parts,p) end
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

-- MUSIC BARS
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

-- GLITCH
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

-- CONSTELLATION
VFuncs["Constellation"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local stars={}; local beams={}
        for i=1,n do local star=makePart(Vector3.new(0.18,0.18,0.18)*s.size,vGetColor(k)); local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=star; table.insert(stars,star) end
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

-- DEATH EXPLOSION
VFuncs["DeathExplosion"]={
    start=function(k)
        local char=getChar(); if not char then return end; local hum=getHum(); if not hum then return end
        VConns[k]=hum.Died:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; local col=vGetColor(k)
            for wave=1,5 do coroutine.wrap(function() task.wait(wave*0.1)
                local SEGS=24; local MAXR=s.size*wave*5; local parts={}
                for i=1,SEGS do
                    local ang=(i-1)/SEGS*math.pi*2; local seg=makePart(Vector3.new(0.4,0.08,0.1),col)
                    seg.CFrame=CFrame.new(hrp.Position,hrp.Position+Vector3.new(math.cos(ang),0,math.sin(ang))); table.insert(parts,seg)
                end
                local t0=tick(); local ec; ec=RunService.Heartbeat:Connect(function()
                    local elapsed=tick()-t0; if elapsed>0.6 then ec:Disconnect(); for _,seg in ipairs(parts) do if seg.Parent then seg:Destroy() end end; return end
                    local prog=elapsed/0.6; local r=MAXR*prog
                    for i,seg in ipairs(parts) do if not seg.Parent then continue end
                        local ang=(i-1)/SEGS*math.pi*2
                        seg.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(ang)*r,0,math.sin(ang)*r),hrp.Position+Vector3.new(math.cos(ang+0.01)*r,0,math.sin(ang+0.01)*r))
                        seg.Transparency=prog
                    end
                end)
            end)() end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

-- SPIRAL VORTEX
VFuncs["SpiralVortex"]={
    start=function(k)
        local s=VSettings[k]; local n=math.floor(s.count); local dots={}
        for i=1,n do local d=makePart(Vector3.new(0.2,0.2,0.2)*s.size,vGetColor(k)); local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=d; table.insert(dots,d) end
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

-- METEORS - fixed: fall DOWN from above
VFuncs["Meteors"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.35/s.speed then return end; timer=0
            local col=vGetColor(k)
            local ox=math.random(-10,10); local oz=math.random(-10,10)
            local startP=hrp.Position+Vector3.new(ox,20,oz)  -- start ABOVE
            local endP=hrp.Position+Vector3.new(ox,-8,oz)     -- end BELOW
            local meteor=makePart(Vector3.new(0.2,0.2,1.5)*s.size,col)
            -- point downward
            meteor.CFrame=CFrame.new(startP,endP)
            -- trail
            local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,0,0.75); a1.Parent=meteor
            local a2=Instance.new("Attachment"); a2.Position=Vector3.new(0,0,-0.75); a2.Parent=meteor
            local tail=Instance.new("Trail"); tail.Attachment0=a1; tail.Attachment1=a2; tail.Lifetime=0.4
            tail.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,col)})
            tail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); tail.LightEmission=1; tail.Parent=meteor
            local duration=0.6/s.speed
            makeTween(meteor,duration,{CFrame=CFrame.new(endP,startP)*CFrame.new(0,0,-(startP-endP).Magnitude)},Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
            makeTween(meteor,duration,{Transparency=0.3}):Play()
            game:GetService("Debris"):AddItem(meteor,duration+0.1)
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

-- AURA - customizable (replaces RainbowAura)
VFuncs["Aura"]={
    start=function(k)
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
                a.Color=col
                local pulse=1+math.sin(t*2+(i-1))*0.04; local sz=(4+i*0.4)*s2.size*pulse; a.Size=Vector3.new(sz,sz*1.2,sz)
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

-- PORTAL RING
VFuncs["PortalRing"]={
    start=function(k)
        local s=VSettings[k]; local SEGS=32; local segments={}
        for i=1,SEGS do local seg=makePart(Vector3.new(0.3,0.2,0.2)*s.size,vGetColor(k)); seg.Transparency=1-s.opacity; table.insert(segments,seg) end
        VObjects[k]=segments; local t0=tick()
        VConns[k]=RunService.Heartbeat:Connect(function()
            local hrp=getHRP(); if not hrp then return end; local s2=VSettings[k]; local t=tick()-t0
            local r=2.5*s2.size
            for i,seg in ipairs(segments) do if not seg.Parent then continue end
                local ao=(i-1)/SEGS*math.pi*2; local angle=ao+t*s2.speed
                local nextAngle=((i)/SEGS)*math.pi*2+t*s2.speed
                local p1=hrp.Position+Vector3.new(math.cos(angle)*r,math.sin(angle)*0.3,math.sin(angle)*r)
                local p2=hrp.Position+Vector3.new(math.cos(nextAngle)*r,math.sin(nextAngle)*0.3,math.sin(nextAngle)*r)
                local mid=(p1+p2)/2; local len=(p2-p1).Magnitude
                seg.Size=Vector3.new(len+0.05,0.18,0.15)
                seg.CFrame=CFrame.new(mid,p2)
                if s2.rainbow then seg.Color=rainbowColor((i-1)/SEGS) end
            end
        end)
    end,
    stop=function(k) vDisconn(k); vCleanObjects(k) end,
}

-- SPARKLE BURST
VFuncs["SparkleBurst"]={
    start=function(k)
        local timer=0
        VConns[k]=RunService.Heartbeat:Connect(function(dt)
            local hrp=getHRP(); if not hrp then return end; local s=VSettings[k]; timer=timer+dt
            if timer<0.05/s.speed then return end; timer=0
            for _=1,3 do
                local col=vGetColor(k); local sparkle=makePart(Vector3.new(0.1,0.1,0.1)*s.size,col)
                sparkle.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-2,2),math.random(-3,3),math.random(-2,2)))
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,18,0,18); bb.Adornee=sparkle; bb.Parent=sparkle
                local img=Instance.new("ImageLabel"); img.Size=UDim2.new(1,0,1,0); img.BackgroundTransparency=1; img.Image="rbxassetid://6407871923"; img.ImageColor3=col; img.ImageTransparency=0; img.Parent=bb
                makeTween(sparkle,0.35,{Size=Vector3.new(0.3,0.3,0.3)*s.size,Transparency=1}):Play(); game:GetService("Debris"):AddItem(sparkle,0.4)
            end
        end)
    end,
    stop=function(k) vDisconn(k) end,
}

local function enableVisual(key)  if VEnabled[key] then return end; VEnabled[key]=true;  if VFuncs[key] then pcall(VFuncs[key].start,key) end end
local function disableVisual(key) if not VEnabled[key] then return end; VEnabled[key]=false; if VFuncs[key] then pcall(VFuncs[key].stop,key) end end

---------------------------------------------------------------------------
-- GUI HELPERS
---------------------------------------------------------------------------
local function uiPad(p,l,r,t,b) local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,l or 0); pad.PaddingRight=UDim.new(0,r or 0); pad.PaddingTop=UDim.new(0,t or 0); pad.PaddingBottom=UDim.new(0,b or 0); pad.Parent=p end

local PRESET_COLORS={
    Color3.fromRGB(220,50,50),Color3.fromRGB(50,120,255),Color3.fromRGB(255,220,30),
    Color3.fromRGB(255,255,255),Color3.fromRGB(20,20,20),Color3.fromRGB(30,160,60),
    Color3.fromRGB(0,255,120),Color3.fromRGB(180,80,255),Color3.fromRGB(255,100,180),Color3.fromRGB(100,200,255),
}

-- mini color row (10 swatches + rainbow) returns Frame
local function makeColorRow(parent,yOff,currentColor,onChange,onRainbow)
    local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,-24,0,32); bg.Position=UDim2.new(0,12,0,yOff); bg.BackgroundTransparency=1; bg.Parent=parent
    local gl=Instance.new("UIGridLayout"); gl.CellSize=UDim2.new(0,22,0,22); gl.CellPadding=UDim2.new(0,4,0,0); gl.SortOrder=Enum.SortOrder.LayoutOrder; gl.VerticalAlignment=Enum.VerticalAlignment.Center; gl.Parent=bg
    for i,col in ipairs(PRESET_COLORS) do
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,22,0,22); btn.BackgroundColor3=col; btn.Text=""; btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.Parent=bg; uiCorner(btn,4)
        btn.MouseButton1Click:Connect(function() onChange(col,false) end)
    end
    local rbtn=Instance.new("TextButton"); rbtn.Size=UDim2.new(0,22,0,22); rbtn.Text=""; rbtn.BorderSizePixel=0; rbtn.LayoutOrder=11; rbtn.Parent=bg; uiCorner(rbtn,4)
    coroutine.wrap(function() while rbtn.Parent do rbtn.BackgroundColor3=rainbowColor(); task.wait(0.05) end end)()
    rbtn.MouseButton1Click:Connect(function() if onRainbow then onRainbow() end end)
    return bg, yOff+40
end

-- slider row
local function makeSlider(parent,yOff,label,initVal,maxVal,fillCol,onChange)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-24,0,36); row.Position=UDim2.new(0,12,0,yOff); row.BackgroundColor3=Config.DarkColor; row.BorderSizePixel=0; row.Parent=parent; uiCorner(row,7)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.5,0,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=Color3.fromRGB(160,160,170); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local track=Instance.new("Frame"); track.Size=UDim2.new(0.44,0,0,5); track.Position=UDim2.new(0.53,0,0.5,-2); track.BackgroundColor3=Color3.fromRGB(40,40,50); track.BorderSizePixel=0; track.Parent=row; uiCorner(track,3)
    local fill=Instance.new("Frame"); fill.Size=UDim2.new(math.clamp(initVal/maxVal,0.02,1),0,1,0); fill.BackgroundColor3=fillCol; fill.BorderSizePixel=0; fill.Parent=track; uiCorner(track,3)
    local handle=Instance.new("TextButton"); handle.Size=UDim2.new(0,12,0,12); handle.Position=UDim2.new(math.clamp(initVal/maxVal,0.02,1),-6,0.5,-6); handle.BackgroundColor3=Color3.fromRGB(240,240,240); handle.Text=""; handle.BorderSizePixel=0; handle.ZIndex=3; handle.Parent=track; uiCorner(handle,6)
    local dragging=false
    handle.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or not track.Parent then return end
        local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0.02,1)
        fill.Size=UDim2.new(rel,0,1,0); handle.Position=UDim2.new(rel,-6,0.5,-6); onChange(rel,lbl)
    end)
    return yOff+44
end

-- toggle button inside a settings panel
local function makeToggleRow(parent,yOff,label,isOn,onChange)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-24,0,34); row.Position=UDim2.new(0,12,0,yOff); row.BackgroundColor3=Config.DarkColor; row.BorderSizePixel=0; row.Parent=parent; uiCorner(row,7)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.7,0,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=Color3.fromRGB(160,160,170); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local ind=Instance.new("TextLabel"); ind.Size=UDim2.new(0.3,0,1,0); ind.Position=UDim2.new(0.7,0,0,0); ind.BackgroundTransparency=1; ind.Text=isOn() and "on" or "off"; ind.TextColor3=isOn() and Config.OnColor or Color3.fromRGB(200,80,80); ind.Font=Enum.Font.GothamBold; ind.TextSize=11; ind.Parent=row
    row.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        onChange(); ind.Text=isOn() and "on" or "off"; ind.TextColor3=isOn() and Config.OnColor or Color3.fromRGB(200,80,80) end end)
    return yOff+42
end

-- popup panel base
local function makePanel(title,w,parent)
    if parent:FindFirstChild("Panel_"..title) then parent["Panel_"..title]:Destroy() end
    local sg=Instance.new("ScreenGui"); sg.Name="Panel_"..title; sg.ResetOnSpawn=false; sg.DisplayOrder=25; sg.Parent=playerGui
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,0,0,0); frame.Position=UDim2.new(0.5,0,0.5,0); frame.BackgroundColor3=Config.MainColor; frame.BorderSizePixel=0; frame.Parent=sg; uiCorner(frame,12)
    local tbar=Instance.new("Frame"); tbar.Size=UDim2.new(1,0,0,40); tbar.BackgroundColor3=Config.AccentColor; tbar.BorderSizePixel=0; tbar.Parent=frame; uiCorner(tbar,12)
    local tlbl=Instance.new("TextLabel"); tlbl.Size=UDim2.new(1,-44,1,0); tlbl.Position=UDim2.new(0,12,0,0); tlbl.BackgroundTransparency=1; tlbl.Text=title; tlbl.TextColor3=Config.TextColor; tlbl.Font=Enum.Font.GothamBold; tlbl.TextSize=14; tlbl.TextXAlignment=Enum.TextXAlignment.Left; tlbl.Parent=tbar
    local xbtn=Instance.new("TextButton"); xbtn.Size=UDim2.new(0,32,0,32); xbtn.Position=UDim2.new(1,-36,0,4); xbtn.BackgroundColor3=Config.DarkColor; xbtn.TextColor3=Config.TextColor; xbtn.Text="x"; xbtn.TextSize=14; xbtn.Font=Enum.Font.GothamBold; xbtn.BorderSizePixel=0; xbtn.Parent=tbar; uiCorner(xbtn,6)
    xbtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    return sg,frame,w
end
local function finalizePanel(sg,frame,w,contentH)
    local H=contentH+54
    makeTween(frame,0.3,{Size=UDim2.new(0,w,0,H),Position=UDim2.new(0.5,-w/2,0.5,-H/2)},Enum.EasingStyle.Back):Play()
    return H
end

---------------------------------------------------------------------------
-- SETTINGS PANELS
---------------------------------------------------------------------------

-- generic visual effect settings panel
local function openVisualSettings(key)
    local s=VSettings[key]
    local sg,frame,w=makePanel("⚙ "..key:lower(),360,playerGui)
    local y=48
    -- color row
    local clbl=Instance.new("TextLabel"); clbl.Size=UDim2.new(1,-24,0,16); clbl.Position=UDim2.new(0,12,0,y); clbl.BackgroundTransparency=1; clbl.Text="color"; clbl.TextColor3=Color3.fromRGB(130,130,145); clbl.Font=Enum.Font.GothamBold; clbl.TextSize=11; clbl.TextXAlignment=Enum.TextXAlignment.Left; clbl.Parent=frame; y=y+18
    local _,ny=makeColorRow(frame,y,s.color,function(col,_) s.color=col; s.rainbow=false end,function() s.rainbow=not s.rainbow end); y=ny
    y=makeSlider(frame,y,"size: "..string.format("%.1f",s.size),s.size,3,Config.AccentColor,function(rel,lbl) s.size=math.floor(rel*30+0.5)/10; lbl.Text="size: "..string.format("%.1f",s.size) end)
    y=makeSlider(frame,y,"opacity: "..string.format("%.2f",s.opacity),s.opacity,1,Color3.fromRGB(200,200,80),function(rel,lbl) s.opacity=rel; lbl.Text="opacity: "..string.format("%.2f",rel) end)
    y=makeSlider(frame,y,"speed: "..string.format("%.1f",s.speed),s.speed,3,Color3.fromRGB(100,220,140),function(rel,lbl) s.speed=rel*3; lbl.Text="speed: "..string.format("%.1f",s.speed) end)
    -- delay config for StarBurst and Ghost
    if key=="StarBurst" or key=="Ghost" then
        y=makeSlider(frame,y,"delay: "..string.format("%.2f",s.delay or 1.5),(s.delay or 1.5),4,Color3.fromRGB(200,120,80),function(rel,lbl) s.delay=rel*4; lbl.Text="delay: "..string.format("%.2f",s.delay) end)
    end
    -- NameTag mode
    if key=="NameTag" then
        local modes={"username","displayname","custom"}
        for _,m in ipairs(modes) do
            local active=function() return (s.nameMode or "username")==m end
            y=makeToggleRow(frame,y,m,active,function() s.nameMode=m; if VEnabled[key] then disableVisual(key); task.wait(0.05); enableVisual(key) end end)
        end
        -- custom name input hint
        local hlbl=Instance.new("TextLabel"); hlbl.Size=UDim2.new(1,-24,0,20); hlbl.Position=UDim2.new(0,12,0,y); hlbl.BackgroundTransparency=1; hlbl.Text="custom name: ".. (s.customName or "set below"); hlbl.TextColor3=Color3.fromRGB(120,120,130); hlbl.Font=Enum.Font.Gotham; hlbl.TextSize=11; hlbl.TextXAlignment=Enum.TextXAlignment.Left; hlbl.Parent=frame; y=y+22
        local tbox=Instance.new("TextBox"); tbox.Size=UDim2.new(1,-24,0,32); tbox.Position=UDim2.new(0,12,0,y); tbox.BackgroundColor3=Config.DarkColor; tbox.BorderSizePixel=0; tbox.PlaceholderText="enter custom name"; tbox.Text=s.customName or ""; tbox.TextColor3=Config.TextColor; tbox.Font=Enum.Font.Gotham; tbox.TextSize=13; tbox.Parent=frame; uiCorner(tbox,6); y=y+40
        tbox.FocusLost:Connect(function() s.customName=tbox.Text; hlbl.Text="custom name: "..tbox.Text; if VEnabled[key] and s.nameMode=="custom" then disableVisual(key); task.wait(0.05); enableVisual(key) end end)
    end
    -- apply & close
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="apply & close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,7)
    doneBtn.MouseButton1Click:Connect(function() if VEnabled[key] then disableVisual(key); task.wait(0.05); enableVisual(key) end; sg:Destroy() end)
    y=y+40; finalizePanel(sg,frame,360,y)
end

-- feature settings (size+opacity for china hat, health bar etc)
local function openFeatureSettings(title,guiName,sizeKey,opacityKey,onApply)
    local sg,frame,w=makePanel(title,340,playerGui)
    local y=48
    y=makeSlider(frame,y,"size: "..string.format("%.1f",ColorStates[sizeKey]),ColorStates[sizeKey],3,Config.AccentColor,function(rel,lbl) ColorStates[sizeKey]=math.floor(rel*30+0.5)/10; lbl.Text="size: "..string.format("%.1f",ColorStates[sizeKey]) end)
    y=makeSlider(frame,y,"opacity: "..string.format("%.2f",ColorStates[opacityKey]),ColorStates[opacityKey],1,Color3.fromRGB(200,200,80),function(rel,lbl) ColorStates[opacityKey]=rel; lbl.Text="opacity: "..string.format("%.2f",rel) end)
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="apply & close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,7)
    doneBtn.MouseButton1Click:Connect(function() if onApply then onApply() end; sg:Destroy() end)
    y=y+40; finalizePanel(sg,frame,340,y)
end

-- ESP config panel
local function openESPConfig()
    local sg,frame,w=makePanel("⚙ esp config",400,playerGui)
    local y=48
    local function tog(key,label) return makeToggleRow(frame,y,label,function() return ESPConfig[key] end,function() ESPConfig[key]=not ESPConfig[key] end) end
    y=tog("Box","esp box"); y=tog("CornerBox","corner boxes"); y=tog("FillBox","fill boxes")
    y=tog("FillGradient","fill gradient")
    -- gradient colors
    local glbl=Instance.new("TextLabel"); glbl.Size=UDim2.new(1,-24,0,14); glbl.Position=UDim2.new(0,12,0,y); glbl.BackgroundTransparency=1; glbl.Text="gradient color 1"; glbl.TextColor3=Color3.fromRGB(120,120,130); glbl.Font=Enum.Font.GothamBold; glbl.TextSize=10; glbl.TextXAlignment=Enum.TextXAlignment.Left; glbl.Parent=frame; y=y+16
    local _,ny=makeColorRow(frame,y,ESPConfig.GradColor1,function(col) ESPConfig.GradColor1=col end,nil); y=ny
    local glbl2=Instance.new("TextLabel"); glbl2.Size=UDim2.new(1,-24,0,14); glbl2.Position=UDim2.new(0,12,0,y); glbl2.BackgroundTransparency=1; glbl2.Text="gradient color 2"; glbl2.TextColor3=Color3.fromRGB(120,120,130); glbl2.Font=Enum.Font.GothamBold; glbl2.TextSize=10; glbl2.TextXAlignment=Enum.TextXAlignment.Left; glbl2.Parent=frame; y=y+16
    local _,ny2=makeColorRow(frame,y,ESPConfig.GradColor2,function(col) ESPConfig.GradColor2=col end,nil); y=ny2
    y=tog("Skeleton","skeleton"); y=tog("NameESP","name esp")
    -- name fonts
    local fontLabel=Instance.new("TextLabel"); fontLabel.Size=UDim2.new(1,-24,0,14); fontLabel.Position=UDim2.new(0,12,0,y); fontLabel.BackgroundTransparency=1; fontLabel.Text="name font"; fontLabel.TextColor3=Color3.fromRGB(120,120,130); fontLabel.Font=Enum.Font.GothamBold; fontLabel.TextSize=10; fontLabel.TextXAlignment=Enum.TextXAlignment.Left; fontLabel.Parent=frame; y=y+16
    local fonts={{"normal",Enum.Font.Gotham},{"bold",Enum.Font.GothamBold},{"italic bold",Enum.Font.GothamBoldItalic},{"thin",Enum.Font.GothamLight},{"wobbly",Enum.Font.Cartoon}}
    for _,fdef in ipairs(fonts) do
        y=makeToggleRow(frame,y,fdef[1],function() return ESPConfig.NameFont==fdef[2] end,function() ESPConfig.NameFont=fdef[2] end)
    end
    y=makeToggleRow(frame,y,"wobbly text",function() return ESPConfig.NameWobbly end,function() ESPConfig.NameWobbly=not ESPConfig.NameWobbly end)
    y=tog("VisCheck","visibility check"); y=tog("Distance","distance"); y=tog("Tracers","tracers"); y=tog("OffArrows","off-screen arrows"); y=tog("HeadDot","head dot")
    -- esp color
    local eclbl=Instance.new("TextLabel"); eclbl.Size=UDim2.new(1,-24,0,14); eclbl.Position=UDim2.new(0,12,0,y); eclbl.BackgroundTransparency=1; eclbl.Text="esp color"; eclbl.TextColor3=Color3.fromRGB(120,120,130); eclbl.Font=Enum.Font.GothamBold; eclbl.TextSize=10; eclbl.TextXAlignment=Enum.TextXAlignment.Left; eclbl.Parent=frame; y=y+16
    local _,ny3=makeColorRow(frame,y,ESPConfig.Color,function(col) ESPConfig.Color=col end,nil); y=ny3
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,7)
    doneBtn.MouseButton1Click:Connect(function() sg:Destroy() end); y=y+40; finalizePanel(sg,frame,400,y)
end

-- Chams config panel
local function openChamsConfig()
    local sg,frame,w=makePanel("⚙ chams config",340,playerGui)
    local y=48
    local clbl=Instance.new("TextLabel"); clbl.Size=UDim2.new(1,-24,0,14); clbl.Position=UDim2.new(0,12,0,y); clbl.BackgroundTransparency=1; clbl.Text="color"; clbl.TextColor3=Color3.fromRGB(120,120,130); clbl.Font=Enum.Font.GothamBold; clbl.TextSize=10; clbl.TextXAlignment=Enum.TextXAlignment.Left; clbl.Parent=frame; y=y+16
    local _,ny=makeColorRow(frame,y,ChamsConfig.Color,function(col) ChamsConfig.Color=col; ChamsConfig.Rainbow=false; if Features.Chams then createChams() end end,function() ChamsConfig.Rainbow=not ChamsConfig.Rainbow; if Features.Chams then createChams() end end); y=ny
    y=makeSlider(frame,y,"opacity: "..string.format("%.2f",ChamsConfig.Opacity),ChamsConfig.Opacity,1,Config.AccentColor,function(rel,lbl) ChamsConfig.Opacity=rel; lbl.Text="opacity: "..string.format("%.2f",rel); if Features.Chams then createChams() end end)
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,7)
    doneBtn.MouseButton1Click:Connect(function() sg:Destroy() end); y=y+40; finalizePanel(sg,frame,340,y)
end

-- color picker popup for original features
local function openColorPicker(title,guiName,onSelect)
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local sg,frame,w=makePanel(title,320,playerGui)
    local y=48
    local clbl=Instance.new("TextLabel"); clbl.Size=UDim2.new(1,-24,0,14); clbl.Position=UDim2.new(0,12,0,y); clbl.BackgroundTransparency=1; clbl.Text="pick color"; clbl.TextColor3=Color3.fromRGB(120,120,130); clbl.Font=Enum.Font.GothamBold; clbl.TextSize=10; clbl.TextXAlignment=Enum.TextXAlignment.Left; clbl.Parent=frame; y=y+16
    local _,ny=makeColorRow(frame,y,Color3.fromRGB(100,200,255),function(col,_) onSelect(col,false,false) end,function() onSelect(Color3.fromRGB(255,0,0),true,true) end); y=ny
    -- neon toggle
    y=makeToggleRow(frame,y,"neon material",function() return false end,function() end)
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,7)
    doneBtn.MouseButton1Click:Connect(function() sg:Destroy() end); y=y+40; finalizePanel(sg,frame,320,y)
end

---------------------------------------------------------------------------
-- RESPAWN HANDLER
---------------------------------------------------------------------------
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Features.Noclip       then toggleNoclip(true) end
    if Features.InfiniteJump then toggleInfiniteJump(true) end
    if Features.Chams        then createChams() end
    if Features.ESP          then startESP() end
    if Features.ChinaHat     then createChinaHat() end
    if Features.HealthBar    then createHealthBar() end
    if Features.Particles    then createParticles() end
    for _,v in ipairs(VisualOrder) do local k=v[1]
        if VEnabled[k] then pcall(VFuncs[k].stop,k); task.wait(0.05); pcall(VFuncs[k].start,k) end
    end
end)

---------------------------------------------------------------------------
-- MAIN GUI
---------------------------------------------------------------------------
local W=Config.W
local BH=Config.BtnH

local function createMinimizedButton()
    if playerGui:FindFirstChild("VenseMinimized") then playerGui.VenseMinimized:Destroy() end
    local sg=Instance.new("ScreenGui"); sg.Name="VenseMinimized"; sg.ResetOnSpawn=false; sg.Parent=playerGui
    local btn=Instance.new("TextButton"); btn.Name="MinBtn"; btn.Size=UDim2.new(0,48,0,48); btn.Position=UDim2.new(0,20,1,-68); btn.BackgroundColor3=Config.AccentColor; btn.TextColor3=Config.TextColor; btn.Text="V"; btn.TextSize=20; btn.Font=Enum.Font.GothamBold; btn.BorderSizePixel=0; btn.Parent=sg; uiCorner(btn,10)
    coroutine.wrap(function() while btn.Parent do makeTween(btn,0.9,{Size=UDim2.new(0,52,0,52)}):Play(); task.wait(0.9); if not btn.Parent then break end; makeTween(btn,0.9,{Size=UDim2.new(0,48,0,48)}):Play(); task.wait(0.9) end end)()
    local clicked=false
    local function open() if clicked then return end; clicked=true; createMainGui(true,sg,btn) end
    btn.MouseButton1Click:Connect(open)
end

function createMainGui(fromMin,minSg,minBtn)
    if playerGui:FindFirstChild("VenseGui") then playerGui.VenseGui:Destroy() end
    if playerGui:FindFirstChild("VenseMinimized") then playerGui.VenseMinimized:Destroy() end
    local sg=Instance.new("ScreenGui"); sg.Name="VenseGui"; sg.ResetOnSpawn=false; sg.Parent=playerGui
    local GH=550
    local canvas=Instance.new("Frame"); canvas.Name="Canvas"; canvas.Size=UDim2.new(0,W,0,GH); canvas.Position=UDim2.new(0.5,-W/2,0.5,-GH/2); canvas.BackgroundTransparency=1; canvas.BorderSizePixel=0; canvas.Parent=sg
    local mainFrame=Instance.new("Frame"); mainFrame.Name="Main"; mainFrame.Size=UDim2.new(1,0,1,0); mainFrame.BackgroundColor3=Config.MainColor; mainFrame.BackgroundTransparency=fromMin and 1 or 0; mainFrame.BorderSizePixel=0; mainFrame.Active=true; mainFrame.Parent=canvas; uiCorner(mainFrame,14)
    if fromMin and minBtn then
        local vp=minBtn.AbsolutePosition; local vs=minBtn.AbsoluteSize
        canvas.Size=UDim2.new(0,vs.X,0,vs.Y); canvas.Position=UDim2.new(0,vp.X,0,vp.Y)
        if minSg then minSg:Destroy() end
        makeTween(canvas,0.4,{Size=UDim2.new(0,W,0,GH),Position=UDim2.new(0.5,-W/2,0.5,-GH/2)},Enum.EasingStyle.Back):Play()
        makeTween(mainFrame,0.3,{BackgroundTransparency=0}):Play()
    end

    -- TITLE BAR
    local tbar=Instance.new("Frame"); tbar.Size=UDim2.new(1,0,0,46); tbar.BackgroundColor3=Config.AccentColor; tbar.BorderSizePixel=0; tbar.Parent=mainFrame; uiCorner(tbar,14)
    local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-100,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.BackgroundTransparency=1; titleLbl.Text="$vense.lua$"; titleLbl.TextColor3=Config.TextColor; titleLbl.TextSize=18; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=tbar

    -- minimize button (—)
    local minBtn2=Instance.new("TextButton"); minBtn2.Size=UDim2.new(0,36,0,36); minBtn2.Position=UDim2.new(1,-82,0,5); minBtn2.BackgroundColor3=Config.DarkColor; minBtn2.TextColor3=Config.TextColor; minBtn2.Text="—"; minBtn2.TextSize=16; minBtn2.Font=Enum.Font.GothamBold; minBtn2.BorderSizePixel=0; minBtn2.Parent=tbar; uiCorner(minBtn2,7)
    -- kill button (x) - removes V button and GUI but keeps effects
    local killBtn=Instance.new("TextButton"); killBtn.Size=UDim2.new(0,36,0,36); killBtn.Position=UDim2.new(1,-42,0,5); killBtn.BackgroundColor3=Color3.fromRGB(180,40,40); killBtn.TextColor3=Config.TextColor; killBtn.Text="x"; killBtn.TextSize=16; killBtn.Font=Enum.Font.GothamBold; killBtn.BorderSizePixel=0; killBtn.Parent=tbar; uiCorner(killBtn,7)

    -- SCROLL FRAME
    local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.new(1,0,1,-46); scroll.Position=UDim2.new(0,0,0,46); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=Config.AccentColor; scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=mainFrame
    uiPad(scroll,14,14,12,12)
    local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,6); list.FillDirection=Enum.FillDirection.Vertical; list.SortOrder=Enum.SortOrder.LayoutOrder; list.Parent=scroll

    -- SECTION LABEL
    local sectionOrder=0
    local function sectionLbl(text)
        sectionOrder=sectionOrder+1
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,16); lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=Color3.fromRGB(100,100,115); lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.LayoutOrder=sectionOrder*100; lbl.Parent=scroll
    end

    -- SIMPLE TOGGLE BUTTON
    local btnOrder=0
    local function makeSimpleBtn(name,desc,featureKey,cb)
        btnOrder=btnOrder+1
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,BH); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.LayoutOrder=btnOrder; btn.Parent=scroll; uiCorner(btn,8)
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.Padding=UDim.new(0,0); hl.Parent=btn; uiPad(btn,12,10,4,4)
        local tbox=Instance.new("Frame"); tbox.Size=UDim2.new(0.78,0,1,0); tbox.BackgroundTransparency=1; tbox.LayoutOrder=1; tbox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.VerticalAlignment=Enum.VerticalAlignment.Center; vl.Parent=tbox
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0,20); nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=Config.AccentColor; nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.LayoutOrder=1; nl.Parent=tbox
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0,16); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(140,140,150); dl.TextSize=10; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.LayoutOrder=2; dl.Parent=tbox
        local ind=Instance.new("TextLabel"); ind.Size=UDim2.new(0.22,0,1,0); ind.BackgroundTransparency=1; ind.Text=Features[featureKey] and "on" or "off"; ind.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); ind.TextSize=13; ind.Font=Enum.Font.GothamBold; ind.LayoutOrder=2; ind.Parent=btn
        btn.MouseButton1Click:Connect(function()
            Features[featureKey]=not Features[featureKey]; ind.Text=Features[featureKey] and "on" or "off"; ind.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); cb(Features[featureKey])
            makeTween(btn,0.15,{BackgroundColor3=Features[featureKey] and Color3.fromRGB(15,28,20) or Config.DarkColor}):Play()
        end)
        btn.MouseEnter:Connect(function() if not Features[featureKey] then makeTween(btn,0.15,{BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end end)
        btn.MouseLeave:Connect(function() if not Features[featureKey] then makeTween(btn,0.15,{BackgroundColor3=Config.DarkColor}):Play() end end)
    end

    -- BUTTON WITH CONFIG (⚙ button on right)
    local function makeConfigBtn(name,desc,featureKey,cb,onConfig)
        btnOrder=btnOrder+1
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,BH); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.LayoutOrder=btnOrder; btn.Parent=scroll; uiCorner(btn,8)
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.Parent=btn; uiPad(btn,12,10,4,4)
        local tbox=Instance.new("Frame"); tbox.Size=UDim2.new(0.62,0,1,0); tbox.BackgroundTransparency=1; tbox.LayoutOrder=1; tbox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.VerticalAlignment=Enum.VerticalAlignment.Center; vl.Parent=tbox
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0,20); nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=Config.AccentColor; nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.LayoutOrder=1; nl.Parent=tbox
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0,16); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(140,140,150); dl.TextSize=10; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.LayoutOrder=2; dl.Parent=tbox
        local right=Instance.new("Frame"); right.Size=UDim2.new(0.38,0,1,0); right.BackgroundTransparency=1; right.LayoutOrder=2; right.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5); rl.Parent=right
        local cfgBtn=Instance.new("TextButton"); cfgBtn.Size=UDim2.new(0,28,0,28); cfgBtn.BackgroundColor3=Config.DarkColor; cfgBtn.TextColor3=Color3.fromRGB(150,150,160); cfgBtn.Text="⚙"; cfgBtn.TextSize=15; cfgBtn.Font=Enum.Font.GothamBold; cfgBtn.BorderSizePixel=0; cfgBtn.LayoutOrder=1; cfgBtn.Parent=right; uiCorner(cfgBtn,6)
        local ind=Instance.new("TextLabel"); ind.Size=UDim2.new(0,38,0,28); ind.BackgroundTransparency=1; ind.Text=Features[featureKey] and "on" or "off"; ind.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); ind.TextSize=13; ind.Font=Enum.Font.GothamBold; ind.LayoutOrder=2; ind.Parent=right
        cfgBtn.MouseButton1Click:Connect(onConfig)
        btn.MouseButton1Click:Connect(function()
            Features[featureKey]=not Features[featureKey]; ind.Text=Features[featureKey] and "on" or "off"; ind.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); cb(Features[featureKey])
            makeTween(btn,0.15,{BackgroundColor3=Features[featureKey] and Color3.fromRGB(15,28,20) or Config.DarkColor}):Play()
        end)
        btn.MouseEnter:Connect(function() if not Features[featureKey] then makeTween(btn,0.15,{BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end end)
        btn.MouseLeave:Connect(function() if not Features[featureKey] then makeTween(btn,0.15,{BackgroundColor3=Config.DarkColor}):Play() end end)
    end

    -- COLOR FEATURE BUTTON (color + ⚙ + toggle)
    local function makeColorFeatureBtn(name,desc,featureKey,cb,colorFn,settingsFn)
        btnOrder=btnOrder+1
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,BH); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.LayoutOrder=btnOrder; btn.Parent=scroll; uiCorner(btn,8)
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.Parent=btn; uiPad(btn,12,10,4,4)
        local tbox=Instance.new("Frame"); tbox.Size=UDim2.new(0.50,0,1,0); tbox.BackgroundTransparency=1; tbox.LayoutOrder=1; tbox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.VerticalAlignment=Enum.VerticalAlignment.Center; vl.Parent=tbox
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0,20); nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=Config.AccentColor; nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.LayoutOrder=1; nl.Parent=tbox
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0,16); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(140,140,150); dl.TextSize=10; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.LayoutOrder=2; dl.Parent=tbox
        local right=Instance.new("Frame"); right.Size=UDim2.new(0.50,0,1,0); right.BackgroundTransparency=1; right.LayoutOrder=2; right.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5); rl.Parent=right
        local colBtn=Instance.new("TextButton"); colBtn.Size=UDim2.new(0,44,0,26); colBtn.BackgroundColor3=Config.AccentColor; colBtn.TextColor3=Config.TextColor; colBtn.Text="color"; colBtn.TextSize=10; colBtn.Font=Enum.Font.GothamBold; colBtn.BorderSizePixel=0; colBtn.LayoutOrder=1; colBtn.Parent=right; uiCorner(colBtn,6)
        local cfgBtn=Instance.new("TextButton"); cfgBtn.Size=UDim2.new(0,26,0,26); cfgBtn.BackgroundColor3=Config.DarkColor; cfgBtn.TextColor3=Color3.fromRGB(150,150,160); cfgBtn.Text="⚙"; cfgBtn.TextSize=14; cfgBtn.Font=Enum.Font.GothamBold; cfgBtn.BorderSizePixel=0; cfgBtn.LayoutOrder=2; cfgBtn.Parent=right; uiCorner(cfgBtn,6)
        local ind=Instance.new("TextLabel"); ind.Size=UDim2.new(0,34,0,26); ind.BackgroundTransparency=1; ind.Text=Features[featureKey] and "on" or "off"; ind.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); ind.TextSize=12; ind.Font=Enum.Font.GothamBold; ind.LayoutOrder=3; ind.Parent=right
        colBtn.MouseButton1Click:Connect(colorFn); cfgBtn.MouseButton1Click:Connect(settingsFn)
        btn.MouseButton1Click:Connect(function()
            Features[featureKey]=not Features[featureKey]; ind.Text=Features[featureKey] and "on" or "off"; ind.TextColor3=Features[featureKey] and Config.OnColor or Color3.fromRGB(200,80,80); cb(Features[featureKey])
            makeTween(btn,0.15,{BackgroundColor3=Features[featureKey] and Color3.fromRGB(15,28,20) or Config.DarkColor}):Play()
        end)
        btn.MouseEnter:Connect(function() if not Features[featureKey] then makeTween(btn,0.15,{BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end end)
        btn.MouseLeave:Connect(function() if not Features[featureKey] then makeTween(btn,0.15,{BackgroundColor3=Config.DarkColor}):Play() end end)
    end

    -- VISUAL EFFECT BUTTON (⚙ + toggle)
    local function makeVisualBtn(name,desc,key)
        btnOrder=btnOrder+1
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,BH); btn.BackgroundColor3=VEnabled[key] and Color3.fromRGB(15,28,20) or Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.LayoutOrder=btnOrder; btn.Parent=scroll; uiCorner(btn,8)
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.Parent=btn; uiPad(btn,12,10,4,4)
        local tbox=Instance.new("Frame"); tbox.Size=UDim2.new(0.65,0,1,0); tbox.BackgroundTransparency=1; tbox.LayoutOrder=1; tbox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.VerticalAlignment=Enum.VerticalAlignment.Center; vl.Parent=tbox
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0,20); nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=Config.AccentColor; nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.LayoutOrder=1; nl.Parent=tbox
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0,16); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(140,140,150); dl.TextSize=10; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.LayoutOrder=2; dl.Parent=tbox
        local right=Instance.new("Frame"); right.Size=UDim2.new(0.35,0,1,0); right.BackgroundTransparency=1; right.LayoutOrder=2; right.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5); rl.Parent=right
        local cfgBtn=Instance.new("TextButton"); cfgBtn.Size=UDim2.new(0,28,0,28); cfgBtn.BackgroundColor3=Config.DarkColor; cfgBtn.TextColor3=Color3.fromRGB(150,150,160); cfgBtn.Text="⚙"; cfgBtn.TextSize=15; cfgBtn.Font=Enum.Font.GothamBold; cfgBtn.BorderSizePixel=0; cfgBtn.LayoutOrder=1; cfgBtn.Parent=right; uiCorner(cfgBtn,6)
        local ind=Instance.new("TextLabel"); ind.Size=UDim2.new(0,38,0,28); ind.BackgroundTransparency=1; ind.Text=VEnabled[key] and "on" or "off"; ind.TextColor3=VEnabled[key] and Config.OnColor or Color3.fromRGB(200,80,80); ind.TextSize=13; ind.Font=Enum.Font.GothamBold; ind.LayoutOrder=2; ind.Parent=right
        cfgBtn.MouseButton1Click:Connect(function() openVisualSettings(key) end)
        btn.MouseButton1Click:Connect(function()
            if VEnabled[key] then disableVisual(key) else enableVisual(key) end
            ind.Text=VEnabled[key] and "on" or "off"; ind.TextColor3=VEnabled[key] and Config.OnColor or Color3.fromRGB(200,80,80)
            makeTween(btn,0.15,{BackgroundColor3=VEnabled[key] and Color3.fromRGB(15,28,20) or Config.DarkColor}):Play()
        end)
        btn.MouseEnter:Connect(function() if not VEnabled[key] then makeTween(btn,0.15,{BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end end)
        btn.MouseLeave:Connect(function() if not VEnabled[key] then makeTween(btn,0.15,{BackgroundColor3=Config.DarkColor}):Play() end end)
    end

    -- WORLD VISUAL TOGGLE (with optional config callback)
    local function makeWorldBtn(name,desc,activeKey,onToggle,onConfig)
        btnOrder=btnOrder+1
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,BH); btn.BackgroundColor3=WorldConfig[activeKey] and Color3.fromRGB(15,28,20) or Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.LayoutOrder=btnOrder; btn.Parent=scroll; uiCorner(btn,8)
        local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.Parent=btn; uiPad(btn,12,10,4,4)
        local tbox=Instance.new("Frame"); tbox.Size=UDim2.new(onConfig and 0.65 or 0.78,0,1,0); tbox.BackgroundTransparency=1; tbox.LayoutOrder=1; tbox.Parent=btn
        local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.VerticalAlignment=Enum.VerticalAlignment.Center; vl.Parent=tbox
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0,20); nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=Config.AccentColor; nl.TextSize=14; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.LayoutOrder=1; nl.Parent=tbox
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0,16); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(140,140,150); dl.TextSize=10; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.LayoutOrder=2; dl.Parent=tbox
        local right=Instance.new("Frame"); right.Size=UDim2.new(onConfig and 0.35 or 0.22,0,1,0); right.BackgroundTransparency=1; right.LayoutOrder=2; right.Parent=btn
        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5); rl.Parent=right
        if onConfig then
            local cfgBtn=Instance.new("TextButton"); cfgBtn.Size=UDim2.new(0,28,0,28); cfgBtn.BackgroundColor3=Config.DarkColor; cfgBtn.TextColor3=Color3.fromRGB(150,150,160); cfgBtn.Text="⚙"; cfgBtn.TextSize=15; cfgBtn.Font=Enum.Font.GothamBold; cfgBtn.BorderSizePixel=0; cfgBtn.LayoutOrder=1; cfgBtn.Parent=right; uiCorner(cfgBtn,6)
            cfgBtn.MouseButton1Click:Connect(onConfig)
        end
        local ind=Instance.new("TextLabel"); ind.Size=UDim2.new(0,38,0,28); ind.BackgroundTransparency=1; ind.Text=WorldConfig[activeKey] and "on" or "off"; ind.TextColor3=WorldConfig[activeKey] and Config.OnColor or Color3.fromRGB(200,80,80); ind.TextSize=13; ind.Font=Enum.Font.GothamBold; ind.LayoutOrder=2; ind.Parent=right
        btn.MouseButton1Click:Connect(function()
            WorldConfig[activeKey]=not WorldConfig[activeKey]; onToggle(); ind.Text=WorldConfig[activeKey] and "on" or "off"; ind.TextColor3=WorldConfig[activeKey] and Config.OnColor or Color3.fromRGB(200,80,80)
            makeTween(btn,0.15,{BackgroundColor3=WorldConfig[activeKey] and Color3.fromRGB(15,28,20) or Config.DarkColor}):Play()
        end)
        btn.MouseEnter:Connect(function() if not WorldConfig[activeKey] then makeTween(btn,0.15,{BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end end)
        btn.MouseLeave:Connect(function() if not WorldConfig[activeKey] then makeTween(btn,0.15,{BackgroundColor3=Config.DarkColor}):Play() end end)
    end

    -- world config panels
    local function openWorldColorPanel()
        local sg2,frame2=makePanel("⚙ world color",340,playerGui)
        local y=48
        local _,ny=makeColorRow(frame2,y,WorldConfig.WorldColorVal,function(col) WorldConfig.WorldColorVal=col; if WorldConfig.WorldColor then applyWorldColor() end end,nil); y=ny
        local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame2; uiCorner(doneBtn,7)
        doneBtn.MouseButton1Click:Connect(function() sg2:Destroy() end); y=y+40; finalizePanel(sg2,frame2,340,y)
    end
    local function openSkyColorPanel()
        local sg2,frame2=makePanel("⚙ sky color",340,playerGui)
        local y=48
        local _,ny=makeColorRow(frame2,y,WorldConfig.SkyColorVal,function(col) WorldConfig.SkyColorVal=col; WorldConfig.SkyColorRainbow=false; if WorldConfig.SkyColor then applySkyColor() end end,function() WorldConfig.SkyColorRainbow=not WorldConfig.SkyColorRainbow; if WorldConfig.SkyColor then applySkyColor() end end); y=ny
        local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame2; uiCorner(doneBtn,7)
        doneBtn.MouseButton1Click:Connect(function() sg2:Destroy() end); y=y+40; finalizePanel(sg2,frame2,340,y)
    end
    local function openFOVPanel()
        local sg2,frame2=makePanel("⚙ fov",320,playerGui)
        local y=48
        y=makeSlider(frame2,y,"fov: "..WorldConfig.FOVVal,WorldConfig.FOVVal,120,Config.AccentColor,function(rel,lbl) WorldConfig.FOVVal=math.floor(rel*120); lbl.Text="fov: "..WorldConfig.FOVVal; if WorldConfig.FOV then applyFOV() end end)
        local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame2; uiCorner(doneBtn,7)
        doneBtn.MouseButton1Click:Connect(function() sg2:Destroy() end); y=y+40; finalizePanel(sg2,frame2,320,y)
    end
    local function openAspectPanel()
        local sg2,frame2=makePanel("⚙ aspect ratio",320,playerGui)
        local y=48
        y=makeSlider(frame2,y,"ratio: "..string.format("%.2f",WorldConfig.AspectRatioVal),WorldConfig.AspectRatioVal,2,Config.AccentColor,function(rel,lbl) WorldConfig.AspectRatioVal=rel*2; lbl.Text="ratio: "..string.format("%.2f",WorldConfig.AspectRatioVal); if WorldConfig.AspectRatio then applyAspectRatio() end end)
        local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,32); doneBtn.Position=UDim2.new(0,12,0,y); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="close"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=13; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame2; uiCorner(doneBtn,7)
        doneBtn.MouseButton1Click:Connect(function() sg2:Destroy() end); y=y+40; finalizePanel(sg2,frame2,320,y)
    end

    ---------------------------------------------------------------------------
    -- BUILD THE LIST
    ---------------------------------------------------------------------------
    sectionLbl("  cheats")
    makeSimpleBtn("noclip","walk through walls","Noclip",toggleNoclip)
    makeSimpleBtn("infinite jump","jump without limit","InfiniteJump",toggleInfiniteJump)
    makeConfigBtn("chams","selection box outline on players","Chams",toggleChams,openChamsConfig)
    makeConfigBtn("esp","extra sensory perception","ESP",toggleESP,openESPConfig)

    sectionLbl("  visuals")
    makeColorFeatureBtn("china hat","china hat on your head","ChinaHat",function(e) if e then createChinaHat() else removeChinaHat() end end,
        function() openColorPicker("hat color","HatColorPicker",function(col,neon,rainbow) ColorStates.ChinaHatColor=col; ColorStates.ChinaHatNeon=neon; ColorStates.ChinaHatRainbow=rainbow; if Features.ChinaHat then createChinaHat() end end) end,
        function() openFeatureSettings("hat settings","HatSettings","ChinaHatSize","ChinaHatOpacity",function() if Features.ChinaHat then createChinaHat() end end) end)
    makeColorFeatureBtn("health bar","animated hp bar","HealthBar",toggleHealthBar,
        function() openColorPicker("healthbar color","HBColorPicker",function(col,neon,rainbow) ColorStates.HealthBarColor=col; ColorStates.HealthBarNeon=neon; ColorStates.HealthBarRainbow=rainbow; if Features.HealthBar then createHealthBar() end end) end,
        function() openFeatureSettings("healthbar settings","HBSettings","HealthBarSize","HealthBarOpacity",function() if Features.HealthBar then createHealthBar() end end) end)
    makeColorFeatureBtn("crosshair","custom crosshair","Crosshair",toggleCrosshair,
        function() openColorPicker("crosshair color","CHColorPicker",function(col,neon,rainbow) ColorStates.CrosshairColor=col; ColorStates.CrosshairNeon=neon; ColorStates.CrosshairRainbow=rainbow; if Features.Crosshair then createCrosshair() end end) end,
        function() openFeatureSettings("crosshair settings","CHSettings","CrosshairSize","CrosshairOpacity",function() if Features.Crosshair then createCrosshair() end end) end)
    makeColorFeatureBtn("particles","glowing orbs orbiting you","Particles",toggleParticles,
        function() openColorPicker("particles color","PCColorPicker",function(col,neon,rainbow) ColorStates.ParticlesColor=col; ColorStates.ParticlesNeon=neon; ColorStates.ParticlesRainbow=rainbow; if Features.Particles then createParticles() end end) end,
        function() openFeatureSettings("particles settings","PCSettings","ParticlesSize","ParticlesOpacity",function() if Features.Particles then createParticles() end end) end)
    for _,v in ipairs(VisualOrder) do makeVisualBtn(v[2],v[3],v[1]) end

    makeWorldBtn("world color","tint the world lighting","WorldColor",applyWorldColor,openWorldColorPanel)
    makeWorldBtn("sky color","tint sky and fog","SkyColor",applySkyColor,openSkyColorPanel)
    makeWorldBtn("black sky","instantly black sky","BlackSky",function() WorldConfig.BlackSky=WorldConfig.BlackSky; applySkyColor() end,nil)
    makeWorldBtn("fullbright","remove all darkness","Fullbright",applyFullbright,nil)
    makeWorldBtn("fov changer","field of view","FOV",applyFOV,openFOVPanel)
    makeWorldBtn("aspect ratio","camera aspect ratio","AspectRatio",applyAspectRatio,openAspectPanel)

    sectionLbl("  performance")
    makeSimpleBtn("boost fps","disable shadows + textures","BoostFPS",boostFPS)

    ---------------------------------------------------------------------------
    -- DRAGGING
    ---------------------------------------------------------------------------
    local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
    mainFrame.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=canvas.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    mainFrame.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end end)
    UserInputService.InputChanged:Connect(function(i)
        if i==dragInput and dragging then local d=i.Position-dragStart; canvas.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
    end)

    -- minimize
    minBtn2.MouseButton1Click:Connect(function()
        makeTween(canvas,0.3,{Size=UDim2.new(0,48,0,48),Position=UDim2.new(0,20,1,-68)},Enum.EasingStyle.Back,Enum.EasingDirection.In):Play()
        makeTween(mainFrame,0.25,{BackgroundTransparency=1}):Play()
        coroutine.wrap(function() task.wait(0.35); sg:Destroy(); createMinimizedButton() end)()
    end)
    -- kill: removes GUI and V button, effects stay
    killBtn.MouseButton1Click:Connect(function()
        makeTween(canvas,0.3,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
        makeTween(mainFrame,0.2,{BackgroundTransparency=1}):Play()
        coroutine.wrap(function() task.wait(0.35); sg:Destroy() end)()
    end)
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
createInjectionAnimation()
task.wait(2)
createMainGui(false,nil,nil)
