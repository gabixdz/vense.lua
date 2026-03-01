--[[ $vense.lua$ — ESP Standalone Test ]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera

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

local PRESETS = {
    { name = "red",     color = Color3.fromRGB(220, 50,  50),  rainbow = false },
    { name = "blue",    color = Color3.fromRGB(50,  120, 255), rainbow = false },
    { name = "yellow",  color = Color3.fromRGB(255, 220, 30),  rainbow = false },
    { name = "white",   color = Color3.fromRGB(255, 255, 255), rainbow = false },
    { name = "black",   color = Color3.fromRGB(20,  20,  20),  rainbow = false },
    { name = "green",   color = Color3.fromRGB(30,  160, 60),  rainbow = false },
    { name = "neon",    color = Color3.fromRGB(0,   255, 120), rainbow = false },
    { name = "rainbow", color = Color3.fromRGB(255, 0,   0),   rainbow = true  },
}

-- ── ESP State ─────────────────────────────────────────────────────────────────
local ESPConfig = {
    Enabled     = false,
    TeamCheck   = false,
    SharedColor = Color3.fromRGB(255, 50, 50),
    SharedRainbow = false,
}

-- per-feature config
local function makeFeatureConfig(defaults)
    return {
        enabled   = false,
        color     = defaults and defaults.color or ESPConfig.SharedColor,
        useShared = true,
        rainbow   = false,
        extra     = defaults and defaults.extra or {},
    }
end

local ESP = {
    Chams       = makeFeatureConfig(),
    Glow        = makeFeatureConfig(),
    Wireframe   = makeFeatureConfig(),
    Highlight   = makeFeatureConfig(),
    Skeleton    = makeFeatureConfig(),
    HeadDot     = makeFeatureConfig(),
    Snaplines   = makeFeatureConfig({ extra = { mode = "bottom" } }),
    FilledBox   = makeFeatureConfig(),
    OutlineBox  = makeFeatureConfig(),
    CornerBox   = makeFeatureConfig(),
    BoxESP      = makeFeatureConfig(),
    NameESP     = makeFeatureConfig({ color = Color3.fromRGB(255,255,255) }),
    DistanceESP = makeFeatureConfig({ color = Color3.fromRGB(200,200,200) }),
    HealthBar   = makeFeatureConfig({ extra = { mode = "side" } }),
}

-- ── ESP Objects (per-player cleanup) ─────────────────────────────────────────
local ESPObjects    = {}  -- [player] = { highlights, drawings, etc. }
local ESPConn       = nil
local DrawingConns  = {}

-- ── Drawing helpers ───────────────────────────────────────────────────────────
local function newDrawing(class, props)
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok then return nil end
    for k, v in pairs(props or {}) do pcall(function() d[k] = v end) end
    return d
end

local function removeDrawing(d)
    if d then pcall(function() d:Remove() end) end
end

local function newHighlight(parent)
    local ok, h = pcall(function()
        local hl = Instance.new("SelectionBox")
        hl.LineThickness = 0.05
        hl.SurfaceTransparency = 0.6
        hl.Parent = parent or workspace
        return hl
    end)
    if ok then return h end
    -- fallback: try Highlight instance
    local ok2, h2 = pcall(function()
        local hl = Instance.new("Highlight")
        hl.Parent = parent or workspace
        return hl
    end)
    if ok2 then return h2 end
    return nil
end

local function getESPColor(key)
    local f = ESP[key]
    if f.useShared then
        if ESPConfig.SharedRainbow then return Color3.fromHSV((tick()*0.4)%1,1,1) end
        return ESPConfig.SharedColor
    end
    if f.rainbow then return Color3.fromHSV((tick()*0.4)%1,1,1) end
    return f.color
end

-- ── World to screen ───────────────────────────────────────────────────────────
local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function getCharParts(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    return hrp, head, hum
end

local function getBoundingBox(char)
    local min, max = Vector3.new(math.huge,math.huge,math.huge), Vector3.new(-math.huge,-math.huge,-math.huge)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local cf, sz = part.CFrame, part.Size/2
            local corners = {
                cf * Vector3.new( sz.X,  sz.Y,  sz.Z),
                cf * Vector3.new(-sz.X,  sz.Y,  sz.Z),
                cf * Vector3.new( sz.X, -sz.Y,  sz.Z),
                cf * Vector3.new(-sz.X, -sz.Y,  sz.Z),
                cf * Vector3.new( sz.X,  sz.Y, -sz.Z),
                cf * Vector3.new(-sz.X,  sz.Y, -sz.Z),
                cf * Vector3.new( sz.X, -sz.Y, -sz.Z),
                cf * Vector3.new(-sz.X, -sz.Y, -sz.Z),
            }
            for _, c in pairs(corners) do
                min = Vector3.new(math.min(min.X,c.X),math.min(min.Y,c.Y),math.min(min.Z,c.Z))
                max = Vector3.new(math.max(max.X,c.X),math.max(max.Y,c.Y),math.max(max.Z,c.Z))
            end
        end
    end
    return min, max
end

-- ── Per-player ESP object management ─────────────────────────────────────────
local function cleanupPlayer(p)
    local objs = ESPObjects[p]
    if not objs then return end
    for _, obj in pairs(objs) do
        if typeof(obj) == "Instance" then pcall(function() obj:Destroy() end)
        elseif type(obj) == "table" and obj.Remove then pcall(function() obj:Remove() end)
        elseif type(obj) == "table" then for _, o in pairs(obj) do
            if typeof(o)=="Instance" then pcall(function() o:Destroy() end)
            elseif type(o)=="table" and o.Remove then pcall(function() o:Remove() end) end
        end end
    end
    ESPObjects[p] = nil
end

local function initPlayer(p)
    cleanupPlayer(p)
    ESPObjects[p] = {}
end

-- ── Skeleton bone connections ─────────────────────────────────────────────────
local BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
-- R6 fallback
local BONES_R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

-- ── Main ESP update ───────────────────────────────────────────────────────────
local function isTeammate(p)
    if not ESPConfig.TeamCheck then return false end
    return p.Team and player.Team and p.Team == player.Team
end

local function updateESP()
    local vp = Camera.ViewportSize
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        if isTeammate(p) then cleanupPlayer(p); continue end

        local char = p.Character
        if not char then cleanupPlayer(p); continue end

        local hrp, head, hum = getCharParts(char)
        if not hrp or not head or not hum then cleanupPlayer(p); continue end
        if hum.Health <= 0 then cleanupPlayer(p); continue end

        if not ESPObjects[p] then initPlayer(p) end
        local objs = ESPObjects[p]

        local hrpPos, onScreen, depth = worldToScreen(hrp.Position)
        local headPos, headOnScreen   = worldToScreen(head.Position + Vector3.new(0, head.Size.Y/2 + 0.15, 0))
        local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)

        -- ── Highlight ────────────────────────────────────────────────────────
        if ESP.Highlight.enabled then
            if not objs.Highlight then
                objs.Highlight = newHighlight(workspace)
                if objs.Highlight then
                    if objs.Highlight:IsA("SelectionBox") then
                        objs.Highlight.Adornee = char
                    else
                        objs.Highlight.Adornee = char
                    end
                end
            end
            if objs.Highlight then
                local col = getESPColor("Highlight")
                pcall(function()
                    if objs.Highlight:IsA("SelectionBox") then
                        objs.Highlight.Color3 = col
                        objs.Highlight.SurfaceColor3 = col
                    else
                        objs.Highlight.FillColor = col
                        objs.Highlight.OutlineColor = col
                    end
                end)
            end
        elseif objs.Highlight then
            pcall(function() objs.Highlight:Destroy() end); objs.Highlight=nil
        end

        -- ── Chams ────────────────────────────────────────────────────────────
        if ESP.Chams.enabled then
            if not objs.Chams then
                local sb = pcall(function()
                    local box = Instance.new("SelectionBox")
                    box.LineThickness = 0
                    box.SurfaceTransparency = 0.4
                    box.Adornee = char
                    box.Parent = workspace
                    objs.Chams = box
                end)
            end
            if objs.Chams then
                local col = getESPColor("Chams")
                pcall(function()
                    objs.Chams.SurfaceColor3 = col
                    objs.Chams.Color3 = col
                end)
            end
        elseif objs.Chams then
            pcall(function() objs.Chams:Destroy() end); objs.Chams=nil
        end

        -- skip 2D drawing if off screen
        if not onScreen then
            for _, key in pairs({"BoxESP","FilledBox","OutlineBox","CornerBox","NameESP","DistanceESP","HeadDot","Snaplines","HealthBar","Skeleton","Glow","Wireframe"}) do
                if objs[key] then
                    if type(objs[key])=="table" then for _,o in pairs(objs[key]) do pcall(function() if o.Remove then o:Remove() elseif o.Visible~=nil then o.Visible=false end end) end
                    elseif objs[key].Visible~=nil then pcall(function() objs[key].Visible=false end) end
                end
            end
            continue
        end

        -- get 2D bounding box
        local minW, maxW = getBoundingBox(char)
        local corners2D  = {}
        local allOn      = true
        local bMin, bMax = Vector2.new(math.huge,math.huge), Vector2.new(-math.huge,-math.huge)
        for _, wx in pairs({minW.X, maxW.X}) do for _, wy in pairs({minW.Y, maxW.Y}) do for _, wz in pairs({minW.Z, maxW.Z}) do
            local sp, on = worldToScreen(Vector3.new(wx,wy,wz))
            if not on then allOn=false end
            bMin=Vector2.new(math.min(bMin.X,sp.X),math.min(bMin.Y,sp.Y))
            bMax=Vector2.new(math.max(bMax.X,sp.X),math.max(bMax.Y,sp.Y))
        end end end
        local boxX, boxY = bMin.X, bMin.Y
        local boxW, boxH = bMax.X-bMin.X, bMax.Y-bMin.Y

        -- ── Box ESP (2D outline) ──────────────────────────────────────────────
        if ESP.BoxESP.enabled then
            if not objs.BoxESP then
                objs.BoxESP = newDrawing("Square",{Filled=false,Thickness=1.5,Visible=true})
            end
            if objs.BoxESP then
                local col=getESPColor("BoxESP")
                pcall(function()
                    objs.BoxESP.Color=col; objs.BoxESP.Position=Vector2.new(boxX,boxY)
                    objs.BoxESP.Size=Vector2.new(boxW,boxH); objs.BoxESP.Visible=true
                end)
            end
        elseif objs.BoxESP then pcall(function() objs.BoxESP.Visible=false end) end

        -- ── Filled Box ───────────────────────────────────────────────────────
        if ESP.FilledBox.enabled then
            if not objs.FilledBox then
                objs.FilledBox = newDrawing("Square",{Filled=true,Transparency=0.5,Visible=true})
            end
            if objs.FilledBox then
                local col=getESPColor("FilledBox")
                pcall(function()
                    objs.FilledBox.Color=col; objs.FilledBox.Position=Vector2.new(boxX,boxY)
                    objs.FilledBox.Size=Vector2.new(boxW,boxH); objs.FilledBox.Visible=true
                end)
            end
        elseif objs.FilledBox then pcall(function() objs.FilledBox.Visible=false end) end

        -- ── Outline Box ──────────────────────────────────────────────────────
        if ESP.OutlineBox.enabled then
            if not objs.OutlineBox then
                objs.OutlineBox = {
                    newDrawing("Square",{Filled=false,Thickness=3,  Color=Color3.new(0,0,0),Visible=true}),
                    newDrawing("Square",{Filled=false,Thickness=1.5,Visible=true}),
                }
            end
            if objs.OutlineBox then
                local col=getESPColor("OutlineBox")
                pcall(function()
                    for i,sq in ipairs(objs.OutlineBox) do
                        sq.Position=Vector2.new(boxX,boxY); sq.Size=Vector2.new(boxW,boxH); sq.Visible=true
                        if i==2 then sq.Color=col end
                    end
                end)
            end
        elseif objs.OutlineBox then for _,o in pairs(objs.OutlineBox or {}) do pcall(function() o.Visible=false end) end end

        -- ── Corner Box ───────────────────────────────────────────────────────
        if ESP.CornerBox.enabled then
            if not objs.CornerBox then
                objs.CornerBox = {}
                for i=1,8 do table.insert(objs.CornerBox, newDrawing("Line",{Thickness=2,Visible=true})) end
            end
            if objs.CornerBox then
                local col=getESPColor("CornerBox")
                local cLen=math.min(boxW,boxH)*0.25
                local corners={
                    {Vector2.new(boxX,boxY),         Vector2.new(boxX+cLen,boxY),          Vector2.new(boxX,boxY),          Vector2.new(boxX,boxY+cLen)},
                    {Vector2.new(boxX+boxW,boxY),     Vector2.new(boxX+boxW-cLen,boxY),     Vector2.new(boxX+boxW,boxY),     Vector2.new(boxX+boxW,boxY+cLen)},
                    {Vector2.new(boxX,boxY+boxH),     Vector2.new(boxX+cLen,boxY+boxH),     Vector2.new(boxX,boxY+boxH),     Vector2.new(boxX,boxY+boxH-cLen)},
                    {Vector2.new(boxX+boxW,boxY+boxH),Vector2.new(boxX+boxW-cLen,boxY+boxH),Vector2.new(boxX+boxW,boxY+boxH),Vector2.new(boxX+boxW,boxY+boxH-cLen)},
                }
                local lineIdx=1
                for _,c in ipairs(corners) do
                    pcall(function()
                        objs.CornerBox[lineIdx].From=c[1]; objs.CornerBox[lineIdx].To=c[2]; objs.CornerBox[lineIdx].Color=col; objs.CornerBox[lineIdx].Visible=true; lineIdx=lineIdx+1
                        objs.CornerBox[lineIdx].From=c[3]; objs.CornerBox[lineIdx].To=c[4]; objs.CornerBox[lineIdx].Color=col; objs.CornerBox[lineIdx].Visible=true; lineIdx=lineIdx+1
                    end)
                end
            end
        elseif objs.CornerBox then for _,o in pairs(objs.CornerBox or {}) do pcall(function() o.Visible=false end) end end

        -- ── Head Dot ─────────────────────────────────────────────────────────
        if ESP.HeadDot.enabled then
            if not objs.HeadDot then objs.HeadDot=newDrawing("Circle",{Filled=true,NumSides=24,Visible=true}) end
            if objs.HeadDot then
                pcall(function()
                    local r=math.max(3, (head.Size.Y/2)/depth*Camera.ViewportSize.Y*0.5)
                    objs.HeadDot.Position=headPos; objs.HeadDot.Radius=r
                    objs.HeadDot.Color=getESPColor("HeadDot"); objs.HeadDot.Visible=true
                end)
            end
        elseif objs.HeadDot then pcall(function() objs.HeadDot.Visible=false end) end

        -- ── Name ESP ─────────────────────────────────────────────────────────
        if ESP.NameESP.enabled then
            if not objs.NameESP then objs.NameESP=newDrawing("Text",{Size=14,Center=true,Outline=true,Visible=true}) end
            if objs.NameESP then
                pcall(function()
                    objs.NameESP.Text=p.DisplayName
                    objs.NameESP.Position=Vector2.new(headPos.X, headPos.Y-16)
                    objs.NameESP.Color=getESPColor("NameESP"); objs.NameESP.Visible=true
                end)
            end
        elseif objs.NameESP then pcall(function() objs.NameESP.Visible=false end) end

        -- ── Distance ESP ─────────────────────────────────────────────────────
        if ESP.DistanceESP.enabled then
            if not objs.DistanceESP then objs.DistanceESP=newDrawing("Text",{Size=12,Center=true,Outline=true,Visible=true}) end
            if objs.DistanceESP then
                pcall(function()
                    local nameOffset = ESP.NameESP.enabled and -28 or -16
                    objs.DistanceESP.Text=dist.."m"
                    objs.DistanceESP.Position=Vector2.new(headPos.X, headPos.Y+nameOffset)
                    objs.DistanceESP.Color=getESPColor("DistanceESP"); objs.DistanceESP.Visible=true
                end)
            end
        elseif objs.DistanceESP then pcall(function() objs.DistanceESP.Visible=false end) end

        -- ── Health Bar ───────────────────────────────────────────────────────
        if ESP.HealthBar.enabled then
            if not objs.HealthBar then
                objs.HealthBar = {
                    bg   = newDrawing("Square",{Filled=true,Color=Color3.new(0,0,0),Transparency=0.5,Visible=true}),
                    fill = newDrawing("Square",{Filled=true,Visible=true}),
                }
            end
            if objs.HealthBar then
                local ratio=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                local hpCol=Color3.fromRGB(math.floor(255*(1-ratio)),math.floor(255*ratio),0)
                if ESP.HealthBar.extra.mode=="gradient" then hpCol=getESPColor("HealthBar") end
                local mode=ESP.HealthBar.extra.mode
                pcall(function()
                    if mode=="side" or mode=="gradient" then
                        local bx=boxX-6; local bw=3; local bh=boxH
                        objs.HealthBar.bg.Position=Vector2.new(bx,boxY); objs.HealthBar.bg.Size=Vector2.new(bw,bh); objs.HealthBar.bg.Visible=true
                        objs.HealthBar.fill.Position=Vector2.new(bx,boxY+bh*(1-ratio)); objs.HealthBar.fill.Size=Vector2.new(bw,bh*ratio); objs.HealthBar.fill.Color=hpCol; objs.HealthBar.fill.Visible=true
                    else -- bottom
                        local bx=boxX; local by=boxY+boxH+2; local bw=boxW; local bh=3
                        objs.HealthBar.bg.Position=Vector2.new(bx,by); objs.HealthBar.bg.Size=Vector2.new(bw,bh); objs.HealthBar.bg.Visible=true
                        objs.HealthBar.fill.Position=Vector2.new(bx,by); objs.HealthBar.fill.Size=Vector2.new(bw*ratio,bh); objs.HealthBar.fill.Color=hpCol; objs.HealthBar.fill.Visible=true
                    end
                end)
            end
        elseif objs.HealthBar then
            pcall(function() objs.HealthBar.bg.Visible=false; objs.HealthBar.fill.Visible=false end)
        end

        -- ── Snaplines ────────────────────────────────────────────────────────
        if ESP.Snaplines.enabled then
            if not objs.Snaplines then objs.Snaplines=newDrawing("Line",{Thickness=1,Visible=true}) end
            if objs.Snaplines then
                local mode=ESP.Snaplines.extra.mode
                local origin
                if mode=="bottom"  then origin=Vector2.new(vp.X/2, vp.Y)
                elseif mode=="center" then origin=Vector2.new(vp.X/2, vp.Y/2)
                else origin=mousePos end
                pcall(function()
                    objs.Snaplines.From=origin; objs.Snaplines.To=hrpPos
                    objs.Snaplines.Color=getESPColor("Snaplines"); objs.Snaplines.Visible=true
                end)
            end
        elseif objs.Snaplines then pcall(function() objs.Snaplines.Visible=false end) end

        -- ── Skeleton ─────────────────────────────────────────────────────────
        if ESP.Skeleton.enabled then
            local boneList = BONES
            -- check R6
            if char:FindFirstChild("Torso") then boneList=BONES_R6 end

            if not objs.Skeleton then
                objs.Skeleton={}
                for i=1,#boneList do table.insert(objs.Skeleton, newDrawing("Line",{Thickness=1.5,Visible=true})) end
            end
            if objs.Skeleton then
                local col=getESPColor("Skeleton")
                for i,bone in ipairs(boneList) do
                    local p0=char:FindFirstChild(bone[1]); local p1=char:FindFirstChild(bone[2])
                    if p0 and p1 then
                        local s0,on0=worldToScreen(p0.Position); local s1,on1=worldToScreen(p1.Position)
                        pcall(function()
                            objs.Skeleton[i].From=s0; objs.Skeleton[i].To=s1
                            objs.Skeleton[i].Color=col; objs.Skeleton[i].Visible=on0 and on1
                        end)
                    elseif objs.Skeleton[i] then pcall(function() objs.Skeleton[i].Visible=false end) end
                end
            end
        elseif objs.Skeleton then for _,o in pairs(objs.Skeleton or {}) do pcall(function() o.Visible=false end) end end

        -- ── Glow (BillboardGui overlay) ───────────────────────────────────────
        if ESP.Glow.enabled then
            if not objs.Glow then
                local ok,bb=pcall(function()
                    local b=Instance.new("BillboardGui"); b.Size=UDim2.new(8,0,8,0); b.AlwaysOnTop=true; b.Adornee=hrp; b.Parent=hrp
                    local img=Instance.new("ImageLabel"); img.Size=UDim2.new(1,0,1,0); img.BackgroundTransparency=1; img.Image="rbxassetid://6407871923"; img.ImageTransparency=0.35; img.Parent=b
                    return {gui=b, img=img}
                end)
                if ok then objs.Glow=bb end
            end
            if objs.Glow then
                pcall(function() objs.Glow.img.ImageColor3=getESPColor("Glow") end)
            end
        elseif objs.Glow then
            pcall(function() objs.Glow.gui:Destroy() end); objs.Glow=nil
        end

        -- ── Wireframe (neon outline parts) ────────────────────────────────────
        if ESP.Wireframe.enabled then
            if not objs.Wireframe then
                objs.Wireframe = {}
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local ok,sb=pcall(function()
                            local s=Instance.new("SelectionBox"); s.LineThickness=0.02; s.SurfaceTransparency=1; s.Adornee=part; s.Parent=workspace; return s
                        end)
                        if ok then table.insert(objs.Wireframe, sb) end
                    end
                end
            end
            if objs.Wireframe then
                local col=getESPColor("Wireframe")
                for _,sb in pairs(objs.Wireframe) do pcall(function() sb.Color3=col end) end
            end
        elseif objs.Wireframe then
            for _,sb in pairs(objs.Wireframe or {}) do pcall(function() sb:Destroy() end) end; objs.Wireframe=nil
        end
    end
end

-- ── Start / Stop ESP ──────────────────────────────────────────────────────────
local function startESP()
    if ESPConn then ESPConn:Disconnect() end
    for _, p in pairs(Players:GetPlayers()) do if p ~= player then initPlayer(p) end end
    ESPConn = RunService.Heartbeat:Connect(function()
        if not ESPConfig.Enabled then return end
        pcall(updateESP)
    end)
end

local function stopESP()
    if ESPConn then ESPConn:Disconnect(); ESPConn=nil end
    for _, p in pairs(Players:GetPlayers()) do cleanupPlayer(p) end
end

Players.PlayerRemoving:Connect(function(p) cleanupPlayer(p) end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════════════════════════════════════════════

local function uiCorner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius or 8); c.Parent=parent
end
local function makeTween(obj,t,props,style,dir)
    return TweenService:Create(obj,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props)
end

-- ── Color picker ──────────────────────────────────────────────────────────────
local function createColorPicker(title, guiName, onSelect)
    if playerGui:FindFirstChild(guiName) then playerGui[guiName]:Destroy(); return end
    local sg=Instance.new("ScreenGui"); sg.Name=guiName; sg.ResetOnSpawn=false; sg.DisplayOrder=30; sg.Parent=playerGui
    local H=280
    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,0,0,0); frame.Position=UDim2.new(0.5,0,0.5,0); frame.BackgroundColor3=Config.MainColor; frame.BorderSizePixel=0; frame.Parent=sg; uiCorner(frame,12)
    makeTween(frame,0.3,{Size=UDim2.new(0,340,0,H),Position=UDim2.new(0.5,-170,0.5,-H/2)},Enum.EasingStyle.Back):Play()
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,44); titleBar.BackgroundColor3=Config.AccentColor; titleBar.BorderSizePixel=0; titleBar.Parent=frame; uiCorner(titleBar,12)
    local tLbl=Instance.new("TextLabel"); tLbl.Size=UDim2.new(1,-50,1,0); tLbl.Position=UDim2.new(0,14,0,0); tLbl.BackgroundTransparency=1; tLbl.Text=title; tLbl.TextColor3=Config.TextColor; tLbl.Font=Enum.Font.GothamBold; tLbl.TextSize=15; tLbl.TextXAlignment=Enum.TextXAlignment.Left; tLbl.Parent=titleBar
    local closeX=Instance.new("TextButton"); closeX.Size=UDim2.new(0,36,0,36); closeX.Position=UDim2.new(1,-40,0,4); closeX.BackgroundColor3=Config.DarkColor; closeX.TextColor3=Config.TextColor; closeX.Text="x"; closeX.TextSize=18; closeX.Font=Enum.Font.GothamBold; closeX.BorderSizePixel=0; closeX.Parent=titleBar; uiCorner(closeX,6)
    closeX.MouseButton1Click:Connect(function() sg:Destroy() end)
    local grid=Instance.new("Frame"); grid.Size=UDim2.new(1,-24,0,170); grid.Position=UDim2.new(0,12,0,54); grid.BackgroundTransparency=1; grid.Parent=frame
    local gl=Instance.new("UIGridLayout"); gl.CellSize=UDim2.new(0,66,0,40); gl.CellPadding=UDim2.new(0,8,0,8); gl.SortOrder=Enum.SortOrder.LayoutOrder; gl.Parent=grid
    local selectedBtn=nil
    for i,preset in ipairs(PRESETS) do
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,66,0,40); btn.BackgroundColor3=preset.rainbow and Color3.fromRGB(255,80,80) or preset.color; btn.BorderSizePixel=0; btn.Text=preset.name; btn.TextColor3=(preset.name=="white" or preset.name=="yellow") and Color3.fromRGB(30,30,30) or Color3.fromRGB(255,255,255); btn.TextSize=11; btn.Font=Enum.Font.GothamBold; btn.LayoutOrder=i; btn.Parent=grid; uiCorner(btn,7)
        if preset.rainbow then coroutine.wrap(function() while btn.Parent do btn.BackgroundColor3=Color3.fromHSV((tick()*0.5)%1,1,1); RunService.Heartbeat:Wait() end end)() end
        btn.MouseButton1Click:Connect(function() if selectedBtn then selectedBtn.BorderSizePixel=0 end; btn.BorderSizePixel=2; selectedBtn=btn; onSelect(preset) end)
        btn.MouseEnter:Connect(function() makeTween(btn,0.12,{Size=UDim2.new(0,70,0,44)}):Play() end)
        btn.MouseLeave:Connect(function() makeTween(btn,0.12,{Size=UDim2.new(0,66,0,40)}):Play() end)
    end
    local doneBtn=Instance.new("TextButton"); doneBtn.Size=UDim2.new(1,-24,0,34); doneBtn.Position=UDim2.new(0,12,1,-46); doneBtn.BackgroundColor3=Config.AccentColor; doneBtn.TextColor3=Config.TextColor; doneBtn.Text="done"; doneBtn.Font=Enum.Font.GothamBold; doneBtn.TextSize=14; doneBtn.BorderSizePixel=0; doneBtn.Parent=frame; uiCorner(doneBtn,8)
    doneBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- ── Main GUI ──────────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name="VenseESPTest"; sg.ResetOnSpawn=false; sg.Parent=playerGui

local canvas = Instance.new("Frame")
canvas.Name="Canvas"; canvas.Size=UDim2.new(0,340,0,520)
canvas.Position=UDim2.new(0.5,-170,0.5,-260)
canvas.BackgroundTransparency=1; canvas.BorderSizePixel=0; canvas.Parent=sg

local mainFrame = Instance.new("Frame")
mainFrame.Name="MainFrame"; mainFrame.Size=UDim2.new(1,0,1,0)
mainFrame.BackgroundColor3=Config.MainColor; mainFrame.BorderSizePixel=0
mainFrame.Active=true; mainFrame.Parent=canvas; uiCorner(mainFrame,12)

-- title bar
local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,50); titleBar.BackgroundColor3=Config.AccentColor; titleBar.BorderSizePixel=0; titleBar.Parent=mainFrame; uiCorner(titleBar,12)
local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-20,1,0); titleLbl.Position=UDim2.new(0,14,0,0); titleLbl.BackgroundTransparency=1; titleLbl.Text="$vense.lua$  —  esp test"; titleLbl.TextColor3=Config.TextColor; titleLbl.TextSize=16; titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar

-- scroll
local scrollFrame=Instance.new("ScrollingFrame"); scrollFrame.Size=UDim2.new(1,0,1,-50); scrollFrame.Position=UDim2.new(0,0,0,50); scrollFrame.BackgroundTransparency=1; scrollFrame.BorderSizePixel=0; scrollFrame.ScrollBarThickness=3; scrollFrame.ScrollBarImageColor3=Config.AccentColor; scrollFrame.CanvasSize=UDim2.new(0,0,0,0); scrollFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y; scrollFrame.Parent=mainFrame
local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,15); pad.PaddingRight=UDim.new(0,15); pad.PaddingTop=UDim.new(0,15); pad.PaddingBottom=UDim.new(0,15); pad.Parent=scrollFrame
local listLayout=Instance.new("UIListLayout"); listLayout.Padding=UDim.new(0,12); listLayout.FillDirection=Enum.FillDirection.Vertical; listLayout.SortOrder=Enum.SortOrder.LayoutOrder; listLayout.Parent=scrollFrame

-- dragging
local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
mainFrame.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=canvas.Position
        input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and dragging then
        local d=input.Position-dragStart
        canvas.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- ── GUI builders ──────────────────────────────────────────────────────────────
local function sectionLabel(text)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,18); lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=Color3.fromRGB(120,120,130); lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=scrollFrame
end

-- simple on/off button (70px)
local function makeToggleBtn(name, desc, getState, onToggle)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)
    local bp=Instance.new("UIPadding"); bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12); bp.PaddingTop=UDim.new(0,8); bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn
    local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn
    local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.82,0,1,0); textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
    local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox
    local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25); nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor; nameLbl.TextSize=15; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox
    local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35); descLbl.BackgroundTransparency=1; descLbl.Text=desc; descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=11; descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox
    local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,40,1,0); indicator.BackgroundTransparency=1; indicator.Text=getState() and "on" or "off"; indicator.TextColor3=getState() and Config.OnColor or Color3.fromRGB(200,80,80); indicator.TextSize=13; indicator.Font=Enum.Font.GothamBold; indicator.LayoutOrder=2; indicator.Parent=btn
    local function refresh() indicator.Text=getState() and "on" or "off"; indicator.TextColor3=getState() and Config.OnColor or Color3.fromRGB(200,80,80) end
    btn.MouseButton1Click:Connect(function() onToggle(); refresh() end)
    btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
    btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)
    return refresh
end

-- ESP feature button: on/off + color + "shared" toggle
local function makeESPBtn(name, desc, espKey, extraFn)
    local f = ESP[espKey]
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,70); btn.BackgroundColor3=Config.DarkColor; btn.BorderSizePixel=0; btn.TextTransparency=1; btn.Parent=scrollFrame; uiCorner(btn,8)
    local bp=Instance.new("UIPadding"); bp.PaddingLeft=UDim.new(0,12); bp.PaddingRight=UDim.new(0,12); bp.PaddingTop=UDim.new(0,8); bp.PaddingBottom=UDim.new(0,8); bp.Parent=btn
    local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btn

    local textBox=Instance.new("Frame"); textBox.Size=UDim2.new(0.50,0,1,0); textBox.BackgroundTransparency=1; textBox.LayoutOrder=1; textBox.Parent=btn
    local vl=Instance.new("UIListLayout"); vl.FillDirection=Enum.FillDirection.Vertical; vl.SortOrder=Enum.SortOrder.LayoutOrder; vl.Parent=textBox
    local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,0,0,25); nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=Config.AccentColor; nameLbl.TextSize=15; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.LayoutOrder=1; nameLbl.Parent=textBox
    local descLbl=Instance.new("TextLabel"); descLbl.Size=UDim2.new(1,0,0,35); descLbl.BackgroundTransparency=1; descLbl.Text=desc; descLbl.TextColor3=Color3.fromRGB(170,170,175); descLbl.TextSize=10; descLbl.Font=Enum.Font.Gotham; descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.LayoutOrder=2; descLbl.Parent=textBox

    local rightSide=Instance.new("Frame"); rightSide.Size=UDim2.new(0.50,0,1,0); rightSide.BackgroundTransparency=1; rightSide.LayoutOrder=2; rightSide.Parent=btn
    local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.HorizontalAlignment=Enum.HorizontalAlignment.Right; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,4); rl.Parent=rightSide

    -- color button
    local colorBtn=Instance.new("TextButton"); colorBtn.Size=UDim2.new(0,42,0,26); colorBtn.BackgroundColor3=f.useShared and ESPConfig.SharedColor or f.color; colorBtn.TextColor3=Config.TextColor; colorBtn.Text="col"; colorBtn.TextSize=9; colorBtn.Font=Enum.Font.GothamBold; colorBtn.BorderSizePixel=0; colorBtn.LayoutOrder=1; colorBtn.Parent=rightSide; uiCorner(colorBtn,5)

    -- shared toggle
    local sharedBtn=Instance.new("TextButton"); sharedBtn.Size=UDim2.new(0,42,0,26); sharedBtn.BackgroundColor3=f.useShared and Config.OnColor or Config.DarkColor; sharedBtn.TextColor3=Config.TextColor; sharedBtn.Text=f.useShared and "shared" or "own"; sharedBtn.TextSize=9; sharedBtn.Font=Enum.Font.GothamBold; sharedBtn.BorderSizePixel=0; sharedBtn.LayoutOrder=2; sharedBtn.Parent=rightSide; uiCorner(sharedBtn,5)

    -- on/off
    local indicator=Instance.new("TextLabel"); indicator.Size=UDim2.new(0,30,0,26); indicator.BackgroundTransparency=1; indicator.Text=f.enabled and "on" or "off"; indicator.TextColor3=f.enabled and Config.OnColor or Color3.fromRGB(200,80,80); indicator.TextSize=12; indicator.Font=Enum.Font.GothamBold; indicator.LayoutOrder=3; indicator.Parent=rightSide

    -- live color preview on button
    coroutine.wrap(function()
        while colorBtn.Parent do
            if f.useShared then
                colorBtn.BackgroundColor3=ESPConfig.SharedRainbow and Color3.fromHSV((tick()*0.4)%1,1,1) or ESPConfig.SharedColor
            else
                colorBtn.BackgroundColor3=f.rainbow and Color3.fromHSV((tick()*0.4)%1,1,1) or f.color
            end
            RunService.Heartbeat:Wait()
        end
    end)()

    colorBtn.MouseButton1Click:Connect(function()
        createColorPicker(name.." color","ESPPicker_"..espKey,function(preset)
            f.color=preset.color; f.rainbow=preset.rainbow; f.useShared=false
            makeTween(sharedBtn,0.2,{BackgroundColor3=Config.DarkColor}):Play(); sharedBtn.Text="own"
        end)
    end)
    sharedBtn.MouseButton1Click:Connect(function()
        f.useShared=not f.useShared
        makeTween(sharedBtn,0.2,{BackgroundColor3=f.useShared and Config.OnColor or Config.DarkColor}):Play()
        sharedBtn.Text=f.useShared and "shared" or "own"
    end)
    btn.MouseButton1Click:Connect(function()
        f.enabled=not f.enabled
        indicator.Text=f.enabled and "on" or "off"; indicator.TextColor3=f.enabled and Config.OnColor or Color3.fromRGB(200,80,80)
    end)
    btn.MouseEnter:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Color3.fromRGB(38,38,48)}):Play() end)
    btn.MouseLeave:Connect(function() makeTween(btn,0.18,{BackgroundColor3=Config.DarkColor}):Play() end)

    if extraFn then extraFn(btn) end
end

-- sub-option row (mode picker, shown below a feature btn)
local function makeSubOption(label, options, getCurrent, onPick)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=Color3.fromRGB(22,22,28); row.BorderSizePixel=0; row.Parent=scrollFrame; uiCorner(row,6)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.3,0,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=Color3.fromRGB(130,130,140); lbl.TextSize=10; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local btnRow=Instance.new("Frame"); btnRow.Size=UDim2.new(0.68,0,0.75,0); btnRow.Position=UDim2.new(0.3,0,0.125,0); btnRow.BackgroundTransparency=1; btnRow.Parent=row
    local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal; hl.Padding=UDim.new(0,5); hl.SortOrder=Enum.SortOrder.LayoutOrder; hl.Parent=btnRow
    local btns={}
    for i,opt in ipairs(options) do
        local ob=Instance.new("TextButton"); ob.Size=UDim2.new(0,64,1,0); ob.BorderSizePixel=0; ob.Text=opt; ob.TextSize=10; ob.Font=Enum.Font.GothamBold; ob.TextColor3=Config.TextColor; ob.LayoutOrder=i; ob.Parent=btnRow; uiCorner(ob,5)
        ob.BackgroundColor3=getCurrent()==opt and Config.AccentColor or Config.DarkColor
        table.insert(btns,{btn=ob,opt=opt})
        ob.MouseButton1Click:Connect(function()
            onPick(opt)
            for _,b in pairs(btns) do makeTween(b.btn,0.15,{BackgroundColor3=b.opt==opt and Config.AccentColor or Config.DarkColor}):Play() end
        end)
    end
end

-- ── Build all buttons ─────────────────────────────────────────────────────────

-- ESP master + team check
sectionLabel("  cheats")

makeToggleBtn("ESP", "master toggle for all esp features", function() return ESPConfig.Enabled end, function()
    ESPConfig.Enabled = not ESPConfig.Enabled
    if ESPConfig.Enabled then startESP() else stopESP() end
end)

makeToggleBtn("team check", "skip players on your team", function() return ESPConfig.TeamCheck end, function()
    ESPConfig.TeamCheck = not ESPConfig.TeamCheck
end)

-- shared color
local sharedRow=Instance.new("Frame"); sharedRow.Size=UDim2.new(1,0,0,44); sharedRow.BackgroundColor3=Config.DarkColor; sharedRow.BorderSizePixel=0; sharedRow.Parent=scrollFrame; uiCorner(sharedRow,8)
local sharedLbl=Instance.new("TextLabel"); sharedLbl.Size=UDim2.new(0.55,0,1,0); sharedLbl.Position=UDim2.new(0,12,0,0); sharedLbl.BackgroundTransparency=1; sharedLbl.Text="shared esp color"; sharedLbl.TextColor3=Color3.fromRGB(170,170,175); sharedLbl.TextSize=12; sharedLbl.Font=Enum.Font.GothamBold; sharedLbl.TextXAlignment=Enum.TextXAlignment.Left; sharedLbl.Parent=sharedRow
local sharedColorBtn=Instance.new("TextButton"); sharedColorBtn.Size=UDim2.new(0,80,0,30); sharedColorBtn.Position=UDim2.new(1,-92,0.5,-15); sharedColorBtn.BackgroundColor3=ESPConfig.SharedColor; sharedColorBtn.TextColor3=Config.TextColor; sharedColorBtn.Text="pick color"; sharedColorBtn.TextSize=10; sharedColorBtn.Font=Enum.Font.GothamBold; sharedColorBtn.BorderSizePixel=0; sharedColorBtn.Parent=sharedRow; uiCorner(sharedColorBtn,6)
sharedColorBtn.MouseButton1Click:Connect(function()
    createColorPicker("shared color","ESPSharedPicker",function(preset)
        ESPConfig.SharedColor=preset.color; ESPConfig.SharedRainbow=preset.rainbow
    end)
end)
coroutine.wrap(function() while sharedColorBtn.Parent do sharedColorBtn.BackgroundColor3=ESPConfig.SharedRainbow and Color3.fromHSV((tick()*0.4)%1,1,1) or ESPConfig.SharedColor; RunService.Heartbeat:Wait() end end)()

sectionLabel("  esp features")

-- all ESP features
makeESPBtn("chams",        "colored overlay visible through walls",           "Chams")
makeESPBtn("glow",         "glowing aura around players",                     "Glow")
makeESPBtn("wireframe",    "wire outline on every body part",                 "Wireframe")
makeESPBtn("highlight",    "filled highlight on whole character",             "Highlight")
makeESPBtn("skeleton",     "bone lines connecting body parts",                "Skeleton")
makeESPBtn("head dot",     "dot drawn on player head position",               "HeadDot")
makeESPBtn("filled box",   "filled 2d box around player",                     "FilledBox")
makeESPBtn("outline box",  "outlined box with dark outer edge",               "OutlineBox")
makeESPBtn("corner box",   "corner brackets around player",                   "CornerBox")
makeESPBtn("box esp",      "standard 2d bounding box",                        "BoxESP")
makeESPBtn("name esp",     "display name above player head",                  "NameESP")
makeESPBtn("distance esp", "distance in meters below name",                   "DistanceESP")

makeESPBtn("snaplines",    "line drawn from origin to player",                "Snaplines")
makeSubOption("origin:", {"bottom","center","mouse"},
    function() return ESP.Snaplines.extra.mode end,
    function(v) ESP.Snaplines.extra.mode=v end)

makeESPBtn("health bar",   "health bar beside or below player",               "HealthBar")
makeSubOption("position:", {"side","bottom","gradient"},
    function() return ESP.HealthBar.extra.mode end,
    function(v) ESP.HealthBar.extra.mode=v end)
