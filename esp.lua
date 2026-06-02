-- ============================================================
-- FATALITY MENU - PART 1/3
-- ============================================================
local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/afgan32/fata/refs/heads/main/src/source.luau?t=" .. tostring(tick())))();
Fatality:PrintUpdateVersion()
local Notification = Fatality:CreateNotifier();

local CleanupTasks = {}
local function RegisterCleanup(fn) table.insert(CleanupTasks, fn) end
local function RunCleanup()
	for i = #CleanupTasks, 1, -1 do pcall(CleanupTasks[i]) end
	CleanupTasks = {}
end

Fatality:Loader({ Name = "FATALITY", Duration = 4 });
Notification:Notify({
	Title = "FATALITY",
	Content = "Hello, "..game.Players.LocalPlayer.DisplayName..' Welcome back!',
	Icon = "clipboard"
})

local Window = Fatality.new({ Name = "FATALITY", Expire = "never" });
local Rage = Window:AddMenu({ Name = "RAGE", Icon = "skull" })
local Legit = Window:AddMenu({ Name = "LEGIT", Icon = "target" })
local Visual = Window:AddMenu({ Name = "VISUAL", Icon = "eye" })
local Misc = Window:AddMenu({ Name = "MISC", Icon = "settings" })
local Skins = Window:AddMenu({ Name = "SKINS", Icon = "palette" })
local Lua = Window:AddMenu({ Name = "LUA", Icon = "code" })

-- ============================================================
-- ESP CORE SYSTEM
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local hasDrawing = pcall(function()
	local t = Drawing.new("Line")
	t:Remove()
end)

-- ESP Positions are now stored locally in each S table

local function newSettings()
	return {
		Enabled = false, MaxDistance = 1000, ShowOffscreen = false,
		BoxEnabled = false, BoxMode = "Corner",
		BoxColor = Color3.fromRGB(255, 75, 75),
		BoxOutlineColor = Color3.fromRGB(0, 0, 0),
		BoxThickness = 1, BoxFilled = false, BoxFillTransparency = 0.8,

		NameEnabled = false, NameColor = Color3.fromRGB(255, 255, 255),
		NameSize = 13, NameFont = 2,

		HealthBarEnabled = false, HealthBarThickness = 4,
		HealthBarBgColor = Color3.fromRGB(0, 0, 0), HealthBarOutline = true,

		HealthTextEnabled = false, HealthTextColor = Color3.fromRGB(255, 255, 255),
		HealthTextSize = 13,

		ChamsEnabled = false,
		ChamsFillColor = Color3.fromRGB(255, 0, 85),
		ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
		ChamsFillTransparency = 0.5, ChamsOutlineTransparency = 0,
		ChamsDepthMode = "AlwaysOnTop",

		SkeletonEnabled = false, SkeletonColor = Color3.fromRGB(255,255,255),
		SkeletonThickness = 1,

		HeadCircleEnabled = false, HeadCircleColor = Color3.fromRGB(255,255,255),
		HeadCircleThickness = 1, HeadCircleFilled = false, HeadCircleSides = 16,

		WeaponEnabled = false, WeaponColor = Color3.fromRGB(200,200,200), WeaponSize = 12,

		FlagsEnabled = false, FlagsColor = Color3.fromRGB(255,255,255), FlagsSize = 12,
		FlagsShowSitting = true, FlagsShowAir = true, FlagsShowLowHP = true,
		FlagsShowVehicle = true, FlagsShowWeapon = false,

		DistanceEnabled = false, DistanceColor = Color3.fromRGB(200,200,200), DistanceSize = 12,

		LookVectorEnabled = false, LookVectorColor = Color3.fromRGB(255,255,0), LookVectorLength = 10,

		TracerEnabled = false, TracerColor = Color3.fromRGB(255,255,255),
		TracerOrigin = "Bottom", TracerThickness = 1,

		OutOfViewArrow = false, ArrowColor = Color3.fromRGB(255,255,255), ArrowSize = 15,

		ESP_POSITIONS = {
			Name        = {anchor = "top",     stackIndex = 0},
			HealthBar   = {anchor = "barleft"},
			HealthText  = {anchor = "left",    stackIndex = 0},
			Flags       = {anchor = "right",   stackIndex = 0},
			Weapon      = {anchor = "bottom",  stackIndex = 0},
			Distance    = {anchor = "bottom",  stackIndex = 1},
		},
	}
end

local ENEMY = newSettings()
local TEAM = newSettings()
local LOCAL = newSettings()

local R15Bones = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6Bones = {
	{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
	{"Torso","Left Leg"},{"Torso","Right Leg"},
}

local espObjects = {}

local function makeDrawing(class, props)
	local d = Drawing.new(class)
	if props then for k, v in pairs(props) do pcall(function() d[k] = v end) end end
	return d
end

local function newESP()
	local e = {}
	e.box = {}
	for i = 1, 12 do e.box[i] = makeDrawing("Line", {Visible=false,Thickness=1}) end
	e.boxFill = makeDrawing("Square", {Visible=false,Filled=true,Thickness=1,Transparency=0.5})
	e.boxOutline = {}
	for i = 1, 4 do e.boxOutline[i] = makeDrawing("Line", {Visible=false,Thickness=3,Color=Color3.new(0,0,0)}) end
	e.skel = {}
	for i = 1, 14 do e.skel[i] = makeDrawing("Line", {Visible=false,Thickness=1}) end
	e.name = makeDrawing("Text", {Visible=false,Center=true,Outline=true,Size=13})
	e.hpText = makeDrawing("Text", {Visible=false,Center=false,Outline=true,Size=13})
	e.hpBg = makeDrawing("Line", {Visible=false,Thickness=4,Color=Color3.new(0,0,0)})
	e.hpFill = makeDrawing("Line", {Visible=false,Thickness=2})
	e.headCircle = makeDrawing("Circle", {Visible=false,Thickness=1,Filled=false,NumSides=16})
	e.weapon = makeDrawing("Text", {Visible=false,Center=true,Outline=true,Size=12})
	e.flags = {}
	for i = 1, 5 do e.flags[i] = makeDrawing("Text", {Visible=false,Center=false,Outline=true,Size=12}) end
	e.distance = makeDrawing("Text", {Visible=false,Center=true,Outline=true,Size=12})
	e.lookVec = makeDrawing("Line", {Visible=false,Thickness=1})
	e.tracer = makeDrawing("Line", {Visible=false,Thickness=1})
	e.arrow = makeDrawing("Triangle", {Visible=false,Filled=true,Thickness=1})
	e.chams = nil
	return e
end

local function hideESP(e)
	for _,l in pairs(e.box) do l.Visible=false end
	for _,l in pairs(e.boxOutline) do l.Visible=false end
	e.boxFill.Visible=false
	for _,l in pairs(e.skel) do l.Visible=false end
	e.name.Visible=false; e.hpText.Visible=false
	e.hpBg.Visible=false; e.hpFill.Visible=false
	e.headCircle.Visible=false; e.weapon.Visible=false
	for _,l in pairs(e.flags) do l.Visible=false end
	e.distance.Visible=false; e.lookVec.Visible=false
	e.tracer.Visible=false; e.arrow.Visible=false
	if e.chams then pcall(function() e.chams:Destroy() end); e.chams=nil end
end

local function removeESP(e)
	for _,l in pairs(e.box) do pcall(function() l:Remove() end) end
	for _,l in pairs(e.boxOutline) do pcall(function() l:Remove() end) end
	pcall(function() e.boxFill:Remove() end)
	for _,l in pairs(e.skel) do pcall(function() l:Remove() end) end
	pcall(function() e.name:Remove() end); pcall(function() e.hpText:Remove() end)
	pcall(function() e.hpBg:Remove() end); pcall(function() e.hpFill:Remove() end)
	pcall(function() e.headCircle:Remove() end); pcall(function() e.weapon:Remove() end)
	for _,l in pairs(e.flags) do pcall(function() l:Remove() end) end
	pcall(function() e.distance:Remove() end); pcall(function() e.lookVec:Remove() end)
	pcall(function() e.tracer:Remove() end); pcall(function() e.arrow:Remove() end)
	if e.chams then pcall(function() e.chams:Destroy() end) end
end

local function getBoundingBox(char)
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return nil end
	local topW = head.Position + Vector3.new(0, head.Size.Y/2 + 0.3, 0)
	local lf = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
	local rf = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
	local botW
	if lf and rf then
		botW = Vector3.new(hrp.Position.X, math.min(lf.Position.Y-lf.Size.Y/2, rf.Position.Y-rf.Size.Y/2), hrp.Position.Z)
	else
		botW = hrp.Position - Vector3.new(0,3,0)
	end
	local ts, tOn = Camera:WorldToViewportPoint(topW)
	local bs, bOn = Camera:WorldToViewportPoint(botW)
	local h = bs.Y - ts.Y
	if h < 4 then return nil end
	local w = h * 0.55
	local cx = (ts.X + bs.X) / 2
	return {
		x=cx-w/2, y=ts.Y, w=w, h=h, cx=cx, cy=(ts.Y+bs.Y)/2,
		char=char, hrp=hrp, head=head,
		dist=(Camera.CFrame.Position-hrp.Position).Magnitude,
		onScreen=tOn and bOn, worldPos=hrp.Position
	}
end

-- Получить позицию из ESP_POSITIONS
local function getAnchorPos(key, b, S)
	local pos = S.ESP_POSITIONS[key] or {anchor="top", stackIndex=0}
	local stack = pos.stackIndex or 0
	local STACK_H = 14
	local x, y = b.cx, b.y
	if pos.anchor == "top" then
		x = b.cx; y = b.y - 14 - stack * STACK_H
	elseif pos.anchor == "bottom" then
		x = b.cx; y = b.y + b.h + 2 + stack * STACK_H
	elseif pos.anchor == "left" then
		x = b.x - 4; y = b.y + 2 + stack * STACK_H
	elseif pos.anchor == "right" then
		x = b.x + b.w + 4; y = b.y + 2 + stack * STACK_H
	end
	return Vector2.new(x, y), pos.anchor
end

local function drawBox2D(e, b, S)
	for i=1,12 do e.box[i].Visible=false end
	for i=1,4 do e.boxOutline[i].Visible=false end
	e.boxFill.Visible=false
	local tl=Vector2.new(b.x,b.y); local tr=Vector2.new(b.x+b.w,b.y)
	local bl=Vector2.new(b.x,b.y+b.h); local br=Vector2.new(b.x+b.w,b.y+b.h)
	if S.BoxFilled then
		e.boxFill.Size=Vector2.new(b.w,b.h); e.boxFill.Position=tl
		e.boxFill.Color=S.BoxColor; e.boxFill.Transparency=1-S.BoxFillTransparency
		e.boxFill.Visible=true
	end
	e.boxOutline[1].From=tl; e.boxOutline[1].To=tr
	e.boxOutline[2].From=tr; e.boxOutline[2].To=br
	e.boxOutline[3].From=br; e.boxOutline[3].To=bl
	e.boxOutline[4].From=bl; e.boxOutline[4].To=tl
	for i=1,4 do e.boxOutline[i].Color=S.BoxOutlineColor; e.boxOutline[i].Thickness=S.BoxThickness+2; e.boxOutline[i].Visible=true end
	e.box[1].From=tl; e.box[1].To=tr
	e.box[2].From=tr; e.box[2].To=br
	e.box[3].From=br; e.box[3].To=bl
	e.box[4].From=bl; e.box[4].To=tl
	for i=1,4 do e.box[i].Color=S.BoxColor; e.box[i].Thickness=S.BoxThickness; e.box[i].Visible=true end
end

local function drawBoxCorner(e, b, S)
	for i=1,12 do e.box[i].Visible=false end
	for i=1,4 do e.boxOutline[i].Visible=false end
	e.boxFill.Visible=false
	local tl=Vector2.new(b.x,b.y); local tr=Vector2.new(b.x+b.w,b.y)
	local bl=Vector2.new(b.x,b.y+b.h); local br=Vector2.new(b.x+b.w,b.y+b.h)
	local ln=math.max(b.w,b.h)*0.2
	if S.BoxFilled then
		e.boxFill.Size=Vector2.new(b.w,b.h); e.boxFill.Position=tl
		e.boxFill.Color=S.BoxColor; e.boxFill.Transparency=1-S.BoxFillTransparency
		e.boxFill.Visible=true
	end
	-- Outline (thicker, behind)
	e.boxOutline[1].From=tl+Vector2.new(-1,-1); e.boxOutline[1].To=tl+Vector2.new(ln+1,-1)
	e.boxOutline[2].From=tr+Vector2.new(1,-1); e.boxOutline[2].To=tr+Vector2.new(-ln-1,-1)
	e.boxOutline[3].From=bl+Vector2.new(-1,1); e.boxOutline[3].To=bl+Vector2.new(ln+1,1)
	e.boxOutline[4].From=br+Vector2.new(1,1); e.boxOutline[4].To=br+Vector2.new(-ln-1,1)
	for i=1,4 do e.boxOutline[i].Color=S.BoxOutlineColor; e.boxOutline[i].Thickness=S.BoxThickness+2; e.boxOutline[i].Visible=true end
	e.box[1].From=tl; e.box[1].To=tl+Vector2.new(ln,0)
	e.box[2].From=tl; e.box[2].To=tl+Vector2.new(0,ln)
	e.box[3].From=tr; e.box[3].To=tr+Vector2.new(-ln,0)
	e.box[4].From=tr; e.box[4].To=tr+Vector2.new(0,ln)
	e.box[5].From=bl; e.box[5].To=bl+Vector2.new(ln,0)
	e.box[6].From=bl; e.box[6].To=bl+Vector2.new(0,-ln)
	e.box[7].From=br; e.box[7].To=br+Vector2.new(-ln,0)
	e.box[8].From=br; e.box[8].To=br+Vector2.new(0,-ln)
	for i=1,8 do e.box[i].Color=S.BoxColor; e.box[i].Thickness=S.BoxThickness; e.box[i].Visible=true end
end

local function drawBox3D(e, b, S)
	for i=1,12 do e.box[i].Visible=false end
	for i=1,4 do e.boxOutline[i].Visible=false end
	e.boxFill.Visible=false
	local hrp=b.hrp; if not hrp then return end
	local cf=hrp.CFrame
	local sx,sy,sz=2.5,5,2.5
	local c3={
		cf*Vector3.new(-sx/2,-sy/2,-sz/2),cf*Vector3.new(sx/2,-sy/2,-sz/2),
		cf*Vector3.new(sx/2,-sy/2,sz/2),cf*Vector3.new(-sx/2,-sy/2,sz/2),
		cf*Vector3.new(-sx/2,sy/2,-sz/2),cf*Vector3.new(sx/2,sy/2,-sz/2),
		cf*Vector3.new(sx/2,sy/2,sz/2),cf*Vector3.new(-sx/2,sy/2,sz/2),
	}
	local p={}
	for i,v in ipairs(c3) do local s=Camera:WorldToViewportPoint(v); p[i]=Vector2.new(s.X,s.Y) end
	local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
	for i,ed in ipairs(edges) do
		e.box[i].From=p[ed[1]]; e.box[i].To=p[ed[2]]
		e.box[i].Color=S.BoxColor; e.box[i].Thickness=S.BoxThickness; e.box[i].Visible=true
	end
end

local function drawSkeleton(e, char, S)
	local r15 = char:FindFirstChild("UpperTorso") ~= nil
	local bones = r15 and R15Bones or R6Bones
	for i, bone in ipairs(bones) do
		local p1=char:FindFirstChild(bone[1]); local p2=char:FindFirstChild(bone[2])
		if p1 and p2 then
			local s1,o1=Camera:WorldToViewportPoint(p1.Position)
			local s2,o2=Camera:WorldToViewportPoint(p2.Position)
			if o1 and o2 then
				e.skel[i].From=Vector2.new(s1.X,s1.Y); e.skel[i].To=Vector2.new(s2.X,s2.Y)
				e.skel[i].Color=S.SkeletonColor; e.skel[i].Thickness=S.SkeletonThickness
				e.skel[i].Visible=true
			else e.skel[i].Visible=false end
		else e.skel[i].Visible=false end
	end
	for i=#bones+1,14 do e.skel[i].Visible=false end
end

local function isInVehicle(char)
	local hum=char:FindFirstChildOfClass("Humanoid")
	return hum and hum.SeatPart ~= nil
end

local function getFlagsList(char, hum, S)
	local fl = {}
	if S.FlagsShowSitting and hum.Sit then table.insert(fl,"sit") end
	if S.FlagsShowAir and hum.FloorMaterial==Enum.Material.Air and not hum.Sit then table.insert(fl,"air") end
	if S.FlagsShowLowHP and hum.Health < hum.MaxHealth*0.3 then table.insert(fl,"low") end
	if S.FlagsShowVehicle and isInVehicle(char) then table.insert(fl,"veh") end
	if S.FlagsShowWeapon then
		local t=char:FindFirstChildOfClass("Tool")
		if t then table.insert(fl, t.Name:lower()) end
	end
	return fl
end

local function updatePlayer(player, e, S)
	local char = player.Character
	if not char then hideESP(e); return end
	local hum=char:FindFirstChildOfClass("Humanoid")
	local hrp=char:FindFirstChild("HumanoidRootPart")
	local head=char:FindFirstChild("Head")
	if not hum or not hrp or not head or hum.Health<=0 then hideESP(e); return end
	local dist=(Camera.CFrame.Position-hrp.Position).Magnitude
	if dist>S.MaxDistance then hideESP(e); return end
	local b=getBoundingBox(char)
	if not b then hideESP(e); return end

	if not b.onScreen and not S.ShowOffscreen then
		hideESP(e)
		if S.OutOfViewArrow then
			local sc=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
			local dir=(Vector2.new(b.cx,b.cy)-sc).Unit
			local ap=sc+dir*200
			local sz=S.ArrowSize
			local perp=Vector2.new(-dir.Y,dir.X)
			e.arrow.PointA=ap+dir*sz
			e.arrow.PointB=ap-dir*sz*0.5+perp*sz*0.5
			e.arrow.PointC=ap-dir*sz*0.5-perp*sz*0.5
			e.arrow.Color=S.ArrowColor; e.arrow.Visible=true
		else e.arrow.Visible=false end
		return
	end
	e.arrow.Visible=false

	-- Box
	for i=1,12 do e.box[i].Visible=false end
	for i=1,4 do e.boxOutline[i].Visible=false end
	e.boxFill.Visible=false
	if S.BoxEnabled then
		if S.BoxMode=="2D" then drawBox2D(e,b,S)
		elseif S.BoxMode=="Corner" then drawBoxCorner(e,b,S)
		elseif S.BoxMode=="3D" then drawBox3D(e,b,S) end
	end

	-- Name
	if S.NameEnabled then
		local pos = getAnchorPos("Name", b, S)
		e.name.Text = player.DisplayName
		e.name.Color = S.NameColor
		e.name.Size = S.NameSize
		e.name.Font = S.NameFont
		e.name.Position = pos
		e.name.Visible = true
	else e.name.Visible = false end

	-- Health Bar (с поддержкой 4 сторон)
	if S.HealthBarEnabled then
		local pct = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
		local barPos = S.ESP_POSITIONS.HealthBar or {anchor="barleft"}
		if barPos.anchor == "barleft" then
			local bx = b.x - 5
			e.hpBg.From=Vector2.new(bx,b.y); e.hpBg.To=Vector2.new(bx,b.y+b.h)
			e.hpFill.From=Vector2.new(bx,b.y+b.h*(1-pct)); e.hpFill.To=Vector2.new(bx,b.y+b.h)
		elseif barPos.anchor == "barright" then
			local bx = b.x + b.w + 3
			e.hpBg.From=Vector2.new(bx,b.y); e.hpBg.To=Vector2.new(bx,b.y+b.h)
			e.hpFill.From=Vector2.new(bx,b.y+b.h*(1-pct)); e.hpFill.To=Vector2.new(bx,b.y+b.h)
		elseif barPos.anchor == "bartop" then
			local by = b.y - 5
			e.hpBg.From=Vector2.new(b.x,by); e.hpBg.To=Vector2.new(b.x+b.w,by)
			e.hpFill.From=Vector2.new(b.x,by); e.hpFill.To=Vector2.new(b.x+b.w*pct,by)
		elseif barPos.anchor == "barbottom" then
			local by = b.y + b.h + 3
			e.hpBg.From=Vector2.new(b.x,by); e.hpBg.To=Vector2.new(b.x+b.w,by)
			e.hpFill.From=Vector2.new(b.x,by); e.hpFill.To=Vector2.new(b.x+b.w*pct,by)
		end
		e.hpBg.Color=S.HealthBarBgColor; e.hpBg.Thickness=S.HealthBarThickness
		e.hpBg.Visible=S.HealthBarOutline
		e.hpFill.Color=Color3.fromRGB(255*(1-pct),255*pct,0)
		e.hpFill.Thickness=math.max(1,S.HealthBarThickness-2)
		e.hpFill.Visible=true
	else e.hpBg.Visible=false; e.hpFill.Visible=false end

	-- Health Text (только число)
	if S.HealthTextEnabled then
		local pos = getAnchorPos("HealthText", b, S)
		e.hpText.Text = tostring(math.floor(hum.Health))
		e.hpText.Color = S.HealthTextColor
		e.hpText.Size = S.HealthTextSize
		e.hpText.Position = pos
		e.hpText.Visible = true
	else e.hpText.Visible = false end

	-- Head Circle
	if S.HeadCircleEnabled then
		local hs,on=Camera:WorldToViewportPoint(head.Position)
		if on then
			local ht=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,head.Size.Y/2,0))
			e.headCircle.Position=Vector2.new(hs.X,hs.Y)
			e.headCircle.Radius=math.max(math.abs(ht.Y-hs.Y),5)
			e.headCircle.Color=S.HeadCircleColor
			e.headCircle.Thickness=S.HeadCircleThickness
			e.headCircle.Filled=S.HeadCircleFilled
			e.headCircle.NumSides=S.HeadCircleSides
			e.headCircle.Visible=true
		else e.headCircle.Visible=false end
	else e.headCircle.Visible=false end

	-- Skeleton
	if S.SkeletonEnabled then drawSkeleton(e,char,S)
	else for _,l in pairs(e.skel) do l.Visible=false end end

	-- Weapon
	if S.WeaponEnabled then
		local tool=char:FindFirstChildOfClass("Tool")
		if tool then
			local pos = getAnchorPos("Weapon", b, S)
			e.weapon.Text=tool.Name; e.weapon.Color=S.WeaponColor
			e.weapon.Size=S.WeaponSize
			e.weapon.Position=pos; e.weapon.Visible=true
		else e.weapon.Visible=false end
	else e.weapon.Visible=false end

	-- Flags (несколько строк, каждая = свой Drawing)
	for i=1,5 do e.flags[i].Visible=false end
	if S.FlagsEnabled then
		local fl = getFlagsList(char, hum, S)
		local basePos = getAnchorPos("Flags", b, S)
		for i, flag in ipairs(fl) do
			if i > 5 then break end
			e.flags[i].Text = flag
			e.flags[i].Color = S.FlagsColor
			e.flags[i].Size = S.FlagsSize
			e.flags[i].Position = Vector2.new(basePos.X, basePos.Y + (i-1) * 13)
			e.flags[i].Visible = true
		end
	end

	-- Distance
	if S.DistanceEnabled then
		local pos = getAnchorPos("Distance", b, S)
		e.distance.Text = math.floor(dist).."m"
		e.distance.Color = S.DistanceColor
		e.distance.Size = S.DistanceSize
		e.distance.Position = pos
		e.distance.Visible = true
	else e.distance.Visible = false end

	-- LookVector
	if S.LookVectorEnabled then
		local fwd=hrp.CFrame.LookVector*S.LookVectorLength
		local ep=hrp.Position+fwd
		local s1,o1=Camera:WorldToViewportPoint(hrp.Position)
		local s2,o2=Camera:WorldToViewportPoint(ep)
		if o1 and o2 then
			e.lookVec.From=Vector2.new(s1.X,s1.Y); e.lookVec.To=Vector2.new(s2.X,s2.Y)
			e.lookVec.Color=S.LookVectorColor; e.lookVec.Visible=true
		else e.lookVec.Visible=false end
	else e.lookVec.Visible=false end

	-- Tracer
	if S.TracerEnabled then
		local origin
		if S.TracerOrigin=="Bottom" then origin=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
		elseif S.TracerOrigin=="Top" then origin=Vector2.new(Camera.ViewportSize.X/2,0)
		elseif S.TracerOrigin=="Mouse" then origin=UserInputService:GetMouseLocation()
		else origin=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) end
		e.tracer.From=origin; e.tracer.To=Vector2.new(b.cx,b.cy+b.h/2)
		e.tracer.Color=S.TracerColor; e.tracer.Thickness=S.TracerThickness
		e.tracer.Visible=true
	else e.tracer.Visible=false end

	-- Chams
	if S.ChamsEnabled then
		if not e.chams or not e.chams.Parent then
			e.chams=Instance.new("Highlight"); e.chams.Parent=game:GetService("CoreGui")
		end
		e.chams.Adornee=char
		e.chams.FillColor=S.ChamsFillColor
		e.chams.OutlineColor=S.ChamsOutlineColor
		e.chams.FillTransparency=S.ChamsFillTransparency
		e.chams.OutlineTransparency=S.ChamsOutlineTransparency
		e.chams.DepthMode = S.ChamsDepthMode=="AlwaysOnTop" and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	else
		if e.chams then pcall(function() e.chams:Destroy() end); e.chams=nil end
	end
end

local function getCategory(player)
	if player == LocalPlayer then return "local" end
	if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return "team" end
	return "enemy"
end

if hasDrawing then
	local renderConn = RunService.RenderStepped:Connect(function()
		Camera = workspace.CurrentCamera
		for _, player in ipairs(Players:GetPlayers()) do
			local cat = getCategory(player)
			local S = cat=="local" and LOCAL or cat=="team" and TEAM or ENEMY
			if not S.Enabled then
				if espObjects[player] then hideESP(espObjects[player]) end
			else
				if not espObjects[player] then espObjects[player] = newESP() end
				updatePlayer(player, espObjects[player], S)
			end
		end
	end)
	local removeConn = Players.PlayerRemoving:Connect(function(player)
		if espObjects[player] then removeESP(espObjects[player]); espObjects[player]=nil end
	end)
	RegisterCleanup(function()
		renderConn:Disconnect(); removeConn:Disconnect()
		for _,e in pairs(espObjects) do removeESP(e) end
		espObjects = {}
	end)
end

-- RAGE
do
	Rage:AddSection({ Position = 'left', Name = "WEAPON" })
	Rage:AddSection({ Position = 'center', Name = "EXTRA" })
	Rage:AddSection({ Position = 'right', Name = "GENERAL" })
end

-- LEGIT
do
	Legit:AddSection({ Position = 'left', Name = "AIM" })
	Legit:AddSection({ Position = 'left', Name = "RCS" })
	Legit:AddSection({ Position = 'center', Name = "TRIGGER" })
	Legit:AddSection({ Position = 'center', Name = "BACKTRACK" })
	Legit:AddSection({ Position = 'right', Name = "GENERAL" })
end
-- ============================================================
-- ESP UI BUILDER (общий для Enemy/Team/Local)
-- ============================================================
local function buildESPUI(subtab, S)
	local Gen = subtab:AddSection({ Name = "GENERAL", Position = 'left' })
	local Box = subtab:AddSection({ Name = "BOX", Position = 'left' })
	local Info = subtab:AddSection({ Name = "INFO", Position = 'right' })
	local Effects = subtab:AddSection({ Name = "EFFECTS", Position = 'right' })
	local Extra = subtab:AddSection({ Name = "EXTRA", Position = 'right' })

	-- GENERAL
	Gen:AddToggle({ Name = "Enabled", Callback = function(v) S.Enabled = v end })
	Gen:AddSlider({ Name = "Max distance", Default = 1000, Min = 50, Max = 5000, Round = 0, Callback = function(v) S.MaxDistance = v end })
	Gen:AddToggle({ Name = "Show off-screen", Callback = function(v) S.ShowOffscreen = v end })
	local ArrowT = Gen:AddToggle({ Name = "Off-view arrow", Option = true, Callback = function(v) S.OutOfViewArrow = v end })
	ArrowT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.ArrowColor = c end })
	ArrowT.Option:AddSlider({ Name = "Size", Default = 15, Min = 5, Max = 40, Round = 0, Callback = function(v) S.ArrowSize = v end })

	-- BOX
	local BoxT = Box:AddToggle({ Name = "Box", Option = true, Callback = function(v) S.BoxEnabled = v end })
	BoxT.Option:AddColorPicker({ Name = "Color", Default = S.BoxColor, Callback = function(c) S.BoxColor = c end })
	BoxT.Option:AddColorPicker({ Name = "Outline", Default = Color3.fromRGB(0,0,0), Callback = function(c) S.BoxOutlineColor = c end })

	Box:AddDropdown({ Name = "Mode", Default = "Corner", Values = {"2D","Corner","3D"}, Callback = function(v) S.BoxMode = v end })
	Box:AddSlider({ Name = "Thickness", Default = 1, Min = 1, Max = 5, Round = 0, Callback = function(v) S.BoxThickness = v end })

	local Fill = Box:AddToggle({ Name = "Box filled", Option = true, Callback = function(v) S.BoxFilled = v end })
	Fill.Option:AddSlider({ Name = "Opacity", Default = 80, Min = 0, Max = 100, Round = 0, Callback = function(v) S.BoxFillTransparency = v/100 end })

	-- INFO
	local NameT = Info:AddToggle({ Name = "Name", Option = true, Callback = function(v) S.NameEnabled = v end })
	NameT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.NameColor = c end })
	NameT.Option:AddSlider({ Name = "Size", Default = 13, Min = 8, Max = 24, Round = 0, Callback = function(v) S.NameSize = v end })
	NameT.Option:AddDropdown({ Name = "Font", Default = "Plex", Values = {"UI","System","Plex","Mono"}, Callback = function(v)
		local m = {UI=0,System=1,Plex=2,Mono=3}; S.NameFont = m[v] or 2
	end })

	local HT = Info:AddToggle({ Name = "Health text", Option = true, Callback = function(v) S.HealthTextEnabled = v end })
	HT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.HealthTextColor = c end })
	HT.Option:AddSlider({ Name = "Size", Default = 13, Min = 8, Max = 24, Round = 0, Callback = function(v) S.HealthTextSize = v end })

	local HB = Info:AddToggle({ Name = "Health bar", Option = true, Callback = function(v) S.HealthBarEnabled = v end })
	HB.Option:AddColorPicker({ Name = "Bg color", Default = Color3.fromRGB(0,0,0), Callback = function(c) S.HealthBarBgColor = c end })
	HB.Option:AddToggle({ Name = "Outline", Callback = function(v) S.HealthBarOutline = v end })
	HB.Option:AddSlider({ Name = "Thickness", Default = 4, Min = 2, Max = 10, Round = 0, Callback = function(v) S.HealthBarThickness = v end })

	local WepT = Info:AddToggle({ Name = "Weapon", Option = true, Callback = function(v) S.WeaponEnabled = v end })
	WepT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(200,200,200), Callback = function(c) S.WeaponColor = c end })
	WepT.Option:AddSlider({ Name = "Size", Default = 12, Min = 8, Max = 22, Round = 0, Callback = function(v) S.WeaponSize = v end })

	local DistT = Info:AddToggle({ Name = "Distance", Option = true, Callback = function(v) S.DistanceEnabled = v end })
	DistT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(200,200,200), Callback = function(c) S.DistanceColor = c end })

	local FlagsT = Info:AddToggle({ Name = "Flags", Option = true, Callback = function(v) S.FlagsEnabled = v end })
	FlagsT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.FlagsColor = c end })
	FlagsT.Option:AddToggle({ Name = "Sitting", Callback = function(v) S.FlagsShowSitting = v end })
	FlagsT.Option:AddToggle({ Name = "In air", Callback = function(v) S.FlagsShowAir = v end })
	FlagsT.Option:AddToggle({ Name = "Low HP", Callback = function(v) S.FlagsShowLowHP = v end })
	FlagsT.Option:AddToggle({ Name = "Vehicle", Callback = function(v) S.FlagsShowVehicle = v end })
	FlagsT.Option:AddToggle({ Name = "Weapon name", Callback = function(v) S.FlagsShowWeapon = v end })

	-- EFFECTS
	local ChamsT = Effects:AddToggle({ Name = "Chams", Option = true, Callback = function(v) S.ChamsEnabled = v end })
	ChamsT.Option:AddColorPicker({ Name = "Fill", Default = Color3.fromRGB(255,0,85), Callback = function(c) S.ChamsFillColor = c end })
	ChamsT.Option:AddColorPicker({ Name = "Outline", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.ChamsOutlineColor = c end })
	ChamsT.Option:AddSlider({ Name = "Fill alpha", Default = 50, Min = 0, Max = 100, Round = 0, Callback = function(v) S.ChamsFillTransparency = v/100 end })
	ChamsT.Option:AddSlider({ Name = "Outline alpha", Default = 0, Min = 0, Max = 100, Round = 0, Callback = function(v) S.ChamsOutlineTransparency = v/100 end })
	ChamsT.Option:AddDropdown({ Name = "Mode", Default = "AlwaysOnTop", Values = {"AlwaysOnTop","Occluded"}, Callback = function(v) S.ChamsDepthMode = v end })

	local SkelT = Effects:AddToggle({ Name = "Skeleton", Option = true, Callback = function(v) S.SkeletonEnabled = v end })
	SkelT.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.SkeletonColor = c end })
	SkelT.Option:AddSlider({ Name = "Thickness", Default = 1, Min = 1, Max = 4, Round = 0, Callback = function(v) S.SkeletonThickness = v end })

	local HC = Effects:AddToggle({ Name = "Head circle", Option = true, Callback = function(v) S.HeadCircleEnabled = v end })
	HC.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.HeadCircleColor = c end })
	HC.Option:AddSlider({ Name = "Thickness", Default = 1, Min = 1, Max = 4, Round = 0, Callback = function(v) S.HeadCircleThickness = v end })
	HC.Option:AddToggle({ Name = "Filled", Callback = function(v) S.HeadCircleFilled = v end })
	HC.Option:AddSlider({ Name = "Sides", Default = 16, Min = 3, Max = 32, Round = 0, Callback = function(v) S.HeadCircleSides = v end })

	-- EXTRA
	local LV = Extra:AddToggle({ Name = "Look vector", Option = true, Callback = function(v) S.LookVectorEnabled = v end })
	LV.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,0), Callback = function(c) S.LookVectorColor = c end })
	LV.Option:AddSlider({ Name = "Length", Default = 10, Min = 1, Max = 30, Round = 0, Callback = function(v) S.LookVectorLength = v end })

	local Tr = Extra:AddToggle({ Name = "Tracer", Option = true, Callback = function(v) S.TracerEnabled = v end })
	Tr.Option:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) S.TracerColor = c end })
	Tr.Option:AddDropdown({ Name = "Origin", Default = "Bottom", Values = {"Bottom","Top","Mouse"}, Callback = function(v) S.TracerOrigin = v end })
	Tr.Option:AddSlider({ Name = "Thickness", Default = 1, Min = 1, Max = 4, Round = 0, Callback = function(v) S.TracerThickness = v end })
end

-- ============================================================
-- EMBEDDED PREVIEW (внутри центра subtab'а)
-- ============================================================
local function buildEmbeddedPreview(subtab, S)
	local PreviewSection = subtab:AddSection({ Name = "PREVIEW", Position = 'center' })
	task.wait(0.1)

	local sectionFrame = nil
	if typeof(PreviewSection) == "Instance" then
		sectionFrame = PreviewSection
	elseif type(PreviewSection) == "table" then
		for k, v in pairs(PreviewSection) do
			if typeof(v) == "Instance" and (v:IsA("Frame") or v:IsA("ScrollingFrame")) then
				sectionFrame = v; break
			end
		end
	end
	if not sectionFrame then
		pcall(function()
			local candidates = {}
			for _, v in pairs(Fatality.SectionColumnFrames or {}) do
				if typeof(v) == "Instance" and v:IsA("GuiObject") then
					table.insert(candidates, v)
				end
			end
			sectionFrame = candidates[#candidates]
		end)
	end
	if not sectionFrame then return end
	pcall(function() Fatality:AddDragBlacklist(sectionFrame) end)

	-- Превью на всю высоту
	local preview = Instance.new("Frame")
	preview.Name = "ESPPreviewEmbed"
	preview.BackgroundTransparency = 1
	preview.BorderSizePixel = 0
	preview.Size = UDim2.new(1, -4, 1, -8)
	preview.Position = UDim2.new(0, 2, 0, 4)
	preview.ClipsDescendants = false
	preview.ZIndex = 50
	preview.Active = true
	preview.Parent = sectionFrame
	pcall(function() Fatality:AddDragBlacklist(preview) end)

	-- Reset button
	local resetBtn = Instance.new("TextButton")
	resetBtn.Text = "reset"
	resetBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
	resetBtn.Font = Enum.Font.Code; resetBtn.TextSize = 9
	resetBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	resetBtn.BorderSizePixel = 0
	resetBtn.Size = UDim2.new(0, 36, 0, 14)
	resetBtn.Position = UDim2.new(0, 2, 0, 2)
	resetBtn.ZIndex = 80
	resetBtn.AutoButtonColor = true
	resetBtn.Active = true
	resetBtn.Parent = preview
	local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 2); rc.Parent = resetBtn
	pcall(function() Fatality:AddDragBlacklist(resetBtn) end)

	-- Размеры бокса (константы для позиционирования)
	local BOX_W = 140
	local BOX_H = 320
	local BOX_OX = -BOX_W/2  -- -70
	local BOX_OY = -BOX_H/2  -- -160

	-- Аватар во весь рост
	local avatar = Instance.new("ImageLabel")
	avatar.BackgroundTransparency = 1
	avatar.Size = UDim2.new(0, 340, 0, 490)
	avatar.Position = UDim2.new(0.5, -170, 0.5, -245)
	avatar.ZIndex = 51
	avatar.ScaleType = Enum.ScaleType.Fit
	avatar.Image = "rbxthumb://type=Avatar&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
	avatar.Parent = preview

	local chams = Instance.new("ImageLabel")
	chams.BackgroundTransparency = 1
	chams.Size = avatar.Size
	chams.Position = avatar.Position
	chams.ZIndex = 52
	chams.ScaleType = Enum.ScaleType.Fit
	chams.Image = avatar.Image
	chams.Visible = false
	chams.Parent = preview

	local headCircle = Instance.new("Frame")
	headCircle.BackgroundTransparency = 1
	headCircle.Size = UDim2.new(0, 40, 0, 40)
	headCircle.Position = UDim2.new(0.5, -20, 0.5, -135)
	headCircle.ZIndex = 53
	headCircle.Visible = false
	headCircle.Parent = preview
	local headStroke = Instance.new("UIStroke", headCircle)
	headStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local headCorner = Instance.new("UICorner", headCircle)
	headCorner.CornerRadius = UDim.new(1, 0)
	
	local skeletonLines = {}
	-- spine, arms, legs
	local skData = {
		{UDim2.new(0.5, 0, 0.5, -90), UDim2.new(0, 2, 0, 80)}, -- spine
		{UDim2.new(0.5, -30, 0.5, -90), UDim2.new(0, 60, 0, 2)}, -- shoulders
		{UDim2.new(0.5, -30, 0.5, -90), UDim2.new(0, 2, 0, 60)}, -- left arm
		{UDim2.new(0.5, 30, 0.5, -90), UDim2.new(0, 2, 0, 60)}, -- right arm
		{UDim2.new(0.5, -15, 0.5, -10), UDim2.new(0, 2, 0, 80)}, -- left leg
		{UDim2.new(0.5, 15, 0.5, -10), UDim2.new(0, 2, 0, 80)}, -- right leg
	}
	for _, d in ipairs(skData) do
		local line = Instance.new("Frame")
		line.BorderSizePixel = 0
		line.ZIndex = 53
		line.Visible = false
		line.Position = d[1]
		line.Size = d[2]
		line.Parent = preview
		table.insert(skeletonLines, line)
	end

	-- Бокс
	local boxFrame = Instance.new("Frame")
	boxFrame.BackgroundTransparency = 1
	boxFrame.BorderSizePixel = 0
	boxFrame.Size = UDim2.new(0, BOX_W, 0, BOX_H)
	boxFrame.Position = UDim2.new(0.5, BOX_OX, 0.5, BOX_OY)
	boxFrame.ZIndex = 52
	boxFrame.Parent = preview

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(255, 60, 60)
	boxStroke.Thickness = 1
	boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	boxStroke.Parent = boxFrame

	-- Snap zones (показываются при драге) — дочерние preview, позиция через Scale
	local snapZones = {}
	local function createSnapZone(name, offX, offY, w, h, type_)
		local z = Instance.new("Frame")
		z.Name = "SnapZone_"..name
		z.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		z.BackgroundTransparency = 0.6
		z.BorderSizePixel = 0
		z.Size = UDim2.new(0, w, 0, h)
		z.Position = UDim2.new(0.5, BOX_OX + offX, 0.5, BOX_OY + offY)
		z.ZIndex = 54
		z.Visible = false
		z.Parent = preview
		snapZones[name] = {frame=z, type=type_, offX=offX, offY=offY, w=w, h=h}
		return z
	end

	task.wait()
	-- Bar зоны (только для health bar)
	createSnapZone("bar_left",   -6, 0,     4,     BOX_H, "bar_side")
	createSnapZone("bar_right",  BOX_W+2, 0, 4,     BOX_H, "bar_side")
	createSnapZone("bar_top",    0, -6,     BOX_W,  4,     "bar_side")
	createSnapZone("bar_bottom", 0, BOX_H+2,BOX_W,  4,     "bar_side")

	-- Текстовые зоны
	createSnapZone("text_top",    -30, -28, BOX_W+60, 22, "text_stack")
	createSnapZone("text_bottom", -30, BOX_H+6, BOX_W+60, 22, "text_stack")
	createSnapZone("text_left",   -110, 0,  104, BOX_H, "text_stack")
	createSnapZone("text_right",  BOX_W+6, 0, 104, BOX_H, "text_stack")

	-- Draggable elements
	local DRAG_ELEMENTS = {
		{key="Name",       text="player",  isBar=false, color=Color3.fromRGB(255,255,255)},
		{key="HealthText", text="100",     isBar=false, color=Color3.fromRGB(255,255,255)},
		{key="HealthBar",  text="",        isBar=true,  color=Color3.fromRGB(0,255,0)},
		{key="Weapon",     text="AK-74",   isBar=false, color=Color3.fromRGB(255,255,255)},
		{key="Flags",      text="veh",     isBar=false, color=Color3.fromRGB(255,255,255)},
		{key="Distance",   text="10m",     isBar=false, color=Color3.fromRGB(200,200,200)},
	}

	local labels = {}

	local function getDefaults()
		return {
			Name        = {anchor = "top",     stackIndex = 0},
			HealthBar   = {anchor = "barleft"},
			HealthText  = {anchor = "left",    stackIndex = 0},
			Flags       = {anchor = "right",   stackIndex = 0},
			Weapon      = {anchor = "bottom",  stackIndex = 0},
			Distance    = {anchor = "bottom",  stackIndex = 1},
			_init = true,
		}
	end

	local function applyPos(lbl, key, isBar)
		local data = S.ESP_POSITIONS[key]
		if not data then return end
		local stack = data.stackIndex or 0
		local STACK_H = 14

		if isBar then
			if data.anchor == "barleft" then
				lbl.Position = UDim2.new(0.5, BOX_OX - 5, 0.5, BOX_OY)
				lbl.Size = UDim2.new(0, 3, 0, BOX_H)
			elseif data.anchor == "barright" then
				lbl.Position = UDim2.new(0.5, BOX_OX + BOX_W + 2, 0.5, BOX_OY)
				lbl.Size = UDim2.new(0, 3, 0, BOX_H)
			elseif data.anchor == "bartop" then
				lbl.Position = UDim2.new(0.5, BOX_OX, 0.5, BOX_OY - 5)
				lbl.Size = UDim2.new(0, BOX_W, 0, 3)
			elseif data.anchor == "barbottom" then
				lbl.Position = UDim2.new(0.5, BOX_OX, 0.5, BOX_OY + BOX_H + 2)
				lbl.Size = UDim2.new(0, BOX_W, 0, 3)
			end
			return
		end

		if data.anchor == "top" then
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.Size = UDim2.new(0, BOX_W + 60, 0, 14)
			lbl.Position = UDim2.new(0.5, -(BOX_W+60)/2, 0.5, BOX_OY - 16 - stack * STACK_H)
		elseif data.anchor == "bottom" then
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.Size = UDim2.new(0, BOX_W + 60, 0, 14)
			lbl.Position = UDim2.new(0.5, -(BOX_W+60)/2, 0.5, BOX_OY + BOX_H + 4 + stack * STACK_H)
		elseif data.anchor == "left" then
			lbl.TextXAlignment = Enum.TextXAlignment.Right
			lbl.Size = UDim2.new(0, 100, 0, 14)
			lbl.Position = UDim2.new(0.5, BOX_OX - 108, 0.5, BOX_OY + 2 + stack * STACK_H)
		elseif data.anchor == "right" then
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Size = UDim2.new(0, 100, 0, 14)
			lbl.Position = UDim2.new(0.5, BOX_OX + BOX_W + 8, 0.5, BOX_OY + 2 + stack * STACK_H)
		end
	end

	local activeDrag = nil

	for _, el in ipairs(DRAG_ELEMENTS) do
		local lbl
		if el.isBar then
			lbl = Instance.new("Frame")
			lbl.BackgroundColor3 = el.color
			lbl.Size = UDim2.new(0, 3, 0, BOX_H)
			lbl.BorderSizePixel = 0
		else
			lbl = Instance.new("TextLabel")
			lbl.Text = el.text
			lbl.TextColor3 = el.color
			lbl.Font = Enum.Font.Code
			lbl.TextSize = 11
			lbl.BackgroundTransparency = 1
			lbl.TextStrokeTransparency = 0.5
			lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
			lbl.Size = UDim2.new(0, 100, 0, 14)
		end
		lbl.Name = el.key
		lbl.ZIndex = 60
		lbl.Active = true
		lbl.Parent = preview
		labels[el.key] = {label=lbl, isBar=el.isBar, element=el}
		pcall(function() Fatality:AddDragBlacklist(lbl) end)

		task.wait()
		applyPos(lbl, el.key, el.isBar)

		lbl.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				activeDrag = {
					lbl = lbl, key = el.key, isBar = el.isBar,
					dragStart = input.Position, startPos = lbl.Position
				}
				for _, zone in pairs(snapZones) do
					if el.isBar and zone.type == "bar_side" then zone.frame.Visible = true
					elseif not el.isBar and zone.type == "text_stack" then zone.frame.Visible = true end
				end
			end
		end)
	end

	-- Глобальный move (троттлинг)
	local lastMoveTime = 0
	local moveConn = UserInputService.InputChanged:Connect(function(input)
		if not activeDrag then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local now = tick()
		if now - lastMoveTime < 0.008 then return end
		lastMoveTime = now
		local lbl = activeDrag.lbl
		if not lbl or not lbl.Parent then activeDrag = nil; return end
		local delta = input.Position - activeDrag.dragStart
		lbl.Position = UDim2.new(
			activeDrag.startPos.X.Scale, activeDrag.startPos.X.Offset + delta.X,
			activeDrag.startPos.Y.Scale, activeDrag.startPos.Y.Offset + delta.Y)
	end)

	local function findSnapZone(lx, ly, isBar)
		local bestName, bestDist = nil, math.huge
		for name, zone in pairs(snapZones) do
			if isBar and zone.type ~= "bar_side" then continue end
			if not isBar and zone.type ~= "text_stack" then continue end
			local zX = preview.AbsoluteSize.X / 2 + BOX_OX + zone.offX
			local zY = preview.AbsoluteSize.Y / 2 + BOX_OY + zone.offY
			if lx >= zX and lx <= zX + zone.w and ly >= zY and ly <= zY + zone.h then
				return name
			end
			local zCx = zX + zone.w/2; local zCy = zY + zone.h/2
			local dx = lx - zCx; local dy = ly - zCy
			local d = math.sqrt(dx*dx + dy*dy)
			if d < bestDist then bestDist = d; bestName = name end
		end
		return bestName
	end

	local function recomputeStacks(dropKey, dropY)
		local anchors = {"top", "bottom", "left", "right"}
		for _, anch in ipairs(anchors) do
			local items = {}
			for k, data in pairs(S.ESP_POSITIONS) do
				if type(data) == "table" and data.anchor == anch and k ~= "_init" then
					if k == dropKey then
						table.insert(items, {key=k, y=dropY})
					else
						local lbl = labels[k] and labels[k].label
						local y = lbl and lbl.AbsolutePosition.Y or 0
						table.insert(items, {key=k, y=y})
					end
				end
			end
			table.sort(items, function(a, b)
				if anch == "top" then return a.y > b.y else return a.y < b.y end
			end)
			for i, item in ipairs(items) do
				S.ESP_POSITIONS[item.key].stackIndex = i - 1
			end
		end
	end

	local endConn = UserInputService.InputEnded:Connect(function(input)
		if not activeDrag then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local lbl = activeDrag.lbl
		local key = activeDrag.key
		local isBar = activeDrag.isBar
		activeDrag = nil
		for _, zone in pairs(snapZones) do zone.frame.Visible = false end
		if not lbl or not lbl.Parent then return end

		local lx = lbl.AbsolutePosition.X - preview.AbsolutePosition.X + lbl.AbsoluteSize.X / 2
		local ly = lbl.AbsolutePosition.Y - preview.AbsolutePosition.Y + lbl.AbsoluteSize.Y / 2
		local zoneName = findSnapZone(lx, ly, isBar)
		if not zoneName then
			applyPos(lbl, key, isBar)
			return
		end

		local anchor
		if isBar then
			if zoneName == "bar_left" then anchor = "barleft"
			elseif zoneName == "bar_right" then anchor = "barright"
			elseif zoneName == "bar_top" then anchor = "bartop"
			elseif zoneName == "bar_bottom" then anchor = "barbottom" end
			S.ESP_POSITIONS[key] = {anchor = anchor}
		else
			if zoneName == "text_top" then anchor = "top"
			elseif zoneName == "text_bottom" then anchor = "bottom"
			elseif zoneName == "text_left" then anchor = "left"
			elseif zoneName == "text_right" then anchor = "right" end
			S.ESP_POSITIONS[key] = {anchor = anchor}
			recomputeStacks(key, ly)
		end

		-- Перестраиваем все
		for k, info in pairs(labels) do
			applyPos(info.label, k, info.isBar)
		end
	end)

	resetBtn.MouseButton1Click:Connect(function()
		S.ESP_POSITIONS = getDefaults()
		for k, info in pairs(labels) do
			applyPos(info.label, k, info.isBar)
		end
	end)

	task.wait(0.05)
	if not S.ESP_POSITIONS or not S.ESP_POSITIONS._init then
		S.ESP_POSITIONS = getDefaults()
	end
	for k, info in pairs(labels) do
		applyPos(info.label, k, info.isBar)
	end

	local renderLoop = task.spawn(function()
		local visMap = {
			Name = "NameEnabled",
			HealthText = "HealthTextEnabled",
			HealthBar = "HealthBarEnabled",
			Weapon = "WeaponEnabled",
			Flags = "FlagsEnabled",
			Distance = "DistanceEnabled"
		}
		while true do
			task.wait(0.1)
			if not preview.Parent then break end
			
			boxFrame.Visible = S.BoxEnabled
			if S.BoxEnabled then
				boxStroke.Color = S.BoxColor
				boxStroke.Thickness = S.BoxThickness
				boxFrame.BackgroundColor3 = S.BoxColor
				boxFrame.BackgroundTransparency = S.BoxFilled and (1 - S.BoxFillTransparency) or 1
				
				if S.BoxMode == "3D" then
					boxStroke.Visible = false
				elseif S.BoxMode == "Corner" then
					boxStroke.Visible = true
				else
					boxStroke.Visible = true
				end
			end
			
			chams.Visible = S.ChamsEnabled
			if S.ChamsEnabled then
				chams.ImageColor3 = S.ChamsFillColor
				chams.ImageTransparency = 1 - S.ChamsFillTransparency
			end

			headCircle.Visible = S.HeadCircleEnabled
			if S.HeadCircleEnabled then
				headStroke.Color = S.HeadCircleColor
				headStroke.Thickness = S.HeadCircleThickness
				if S.HeadCircleFilled then
					headCircle.BackgroundColor3 = S.HeadCircleColor
					headCircle.BackgroundTransparency = 0.5
				else
					headCircle.BackgroundTransparency = 1
				end
			end

			for _, line in ipairs(skeletonLines) do
				line.Visible = S.SkeletonEnabled
				if S.SkeletonEnabled then
					line.BackgroundColor3 = S.SkeletonColor
				end
			end
			
			for k, info in pairs(labels) do
				local stateKey = visMap[k]
				if stateKey then
					info.label.Visible = S[stateKey]
				end
			end
		end
	end)

	RegisterCleanup(function()
		if moveConn then pcall(function() moveConn:Disconnect() end) end
		if endConn then pcall(function() endConn:Disconnect() end) end
		if renderLoop then task.cancel(renderLoop) end
		pcall(function() preview:Destroy() end)
	end)
end
-- ============================================================
-- VISUAL
-- ============================================================
do
	local SubTabs = Visual:AddSubTabs({"Local", "Enemy", "Team", "World"})

	-- LOCAL TAB
	buildESPUI(SubTabs["Local"], LOCAL)
	buildEmbeddedPreview(SubTabs["Local"], LOCAL)

	-- ENEMY TAB
	buildESPUI(SubTabs["Enemy"], ENEMY)
	buildEmbeddedPreview(SubTabs["Enemy"], ENEMY)

	-- TEAM TAB
	buildESPUI(SubTabs["Team"], TEAM)
	buildEmbeddedPreview(SubTabs["Team"], TEAM)

	-- ==================== WORLD ====================
	local Lighting = game:GetService("Lighting")

	local Originals = {
		Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
		Brightness = Lighting.Brightness, FogColor = Lighting.FogColor,
		FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
		ClockTime = Lighting.ClockTime, ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom, ExposureCompensation = Lighting.ExposureCompensation,
	}

	local OriginalEffects = {}
	for _, eff in pairs(Lighting:GetChildren()) do
		if eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or eff:IsA("ColorCorrectionEffect") or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
			OriginalEffects[eff] = eff.Enabled
		end
	end

	local worldEnabled, ambientEnabled, fogEnabled, timeEnabled = false, false, false, false
	local fullbrightEnabled, glowEnabled, propsColorEnabled = false, false, false
	local fullbrightMode, fbGamma, nvGamma = "Standard", 2, 1.5
	local fogColorVal, fogStartVal, fogEndVal = Lighting.FogColor, Originals.FogStart, Originals.FogEnd
	local ambientCol, outdoorCol = Lighting.Ambient, Lighting.OutdoorAmbient
	local skyTopCol, skyBotCol = Lighting.ColorShift_Top, Lighting.ColorShift_Bottom
	local timeVal, exposureVal, brightnessVal = Originals.ClockTime, 0, Originals.Brightness
	local propsColor = Color3.fromRGB(255, 255, 255)
	local originalPartColors = {}

	local ccEffect = Instance.new("ColorCorrectionEffect"); ccEffect.Name = "FatalityCCEffect"; ccEffect.Parent = Lighting; ccEffect.Enabled = false
	local glowEffect = Instance.new("BloomEffect"); glowEffect.Name = "FatalityGlow"; glowEffect.Parent = Lighting; glowEffect.Enabled = false; glowEffect.Intensity = 0.5; glowEffect.Size = 24; glowEffect.Threshold = 0.8

	local function applyFullbright()
		if not fullbrightEnabled or not worldEnabled then ccEffect.Enabled = false; return end
		ccEffect.Enabled = true
		if fullbrightMode == "Standard" then
			ccEffect.Brightness = fbGamma/10; ccEffect.Contrast = fbGamma/10; ccEffect.Saturation = 0; ccEffect.TintColor = Color3.new(1,1,1)
		else
			ccEffect.Brightness = (nvGamma/25)-0.1; ccEffect.Contrast = nvGamma/20; ccEffect.Saturation = 0; ccEffect.TintColor = Color3.new(1,1,1)
		end
	end

	local function pushFog()
		if worldEnabled and fogEnabled then
			if Lighting.FogColor ~= fogColorVal then Lighting.FogColor=fogColorVal end
			if Lighting.FogStart ~= fogStartVal then Lighting.FogStart=fogStartVal end
			if Lighting.FogEnd ~= fogEndVal then Lighting.FogEnd=fogEndVal end
		end
	end
	local function pushAmbient()
		if worldEnabled and ambientEnabled then
			if Lighting.Ambient ~= ambientCol then Lighting.Ambient=ambientCol end
			if Lighting.OutdoorAmbient ~= outdoorCol then Lighting.OutdoorAmbient=outdoorCol end
			if Lighting.ColorShift_Top ~= skyTopCol then Lighting.ColorShift_Top=skyTopCol end
			if Lighting.ColorShift_Bottom ~= skyBotCol then Lighting.ColorShift_Bottom=skyBotCol end
		end
	end
	local function pushTime()
		if worldEnabled and timeEnabled then
			if Lighting.ClockTime ~= timeVal then Lighting.ClockTime=timeVal end
		end
	end
	local function pushBrightness()
		if worldEnabled then
			if fullbrightEnabled and fullbrightMode == "Standard" then
				if Lighting.Brightness ~= brightnessVal+fbGamma*2 then Lighting.Brightness=brightnessVal+fbGamma*2 end
				if Lighting.Ambient ~= Color3.new(1,1,1) then Lighting.Ambient=Color3.new(1,1,1) end
				if Lighting.OutdoorAmbient ~= Color3.new(1,1,1) then Lighting.OutdoorAmbient=Color3.new(1,1,1) end
			elseif fullbrightEnabled and fullbrightMode == "Night Vision" then
				if Lighting.Brightness ~= brightnessVal+nvGamma*0.6 then Lighting.Brightness=brightnessVal+nvGamma*0.6 end
				local d=math.clamp(math.floor(120+nvGamma*20),80,200)
				local targetCol = Color3.fromRGB(d,d,d)
				if Lighting.Ambient ~= targetCol then Lighting.Ambient=targetCol end
				if Lighting.OutdoorAmbient ~= targetCol then Lighting.OutdoorAmbient=targetCol end
			else
				if Lighting.Brightness ~= brightnessVal then Lighting.Brightness=brightnessVal end
			end
			if Lighting.ExposureCompensation ~= exposureVal then Lighting.ExposureCompensation=exposureVal end
		end
	end

	local worldConn = RunService.RenderStepped:Connect(function()
		if not worldEnabled then return end
		pushFog(); pushAmbient(); pushTime(); pushBrightness()
		if fullbrightEnabled then applyFullbright() end
	end)
	RegisterCleanup(function() if worldConn then worldConn:Disconnect() end end)

	local function restoreWorld()
		Lighting.Ambient=Originals.Ambient; Lighting.OutdoorAmbient=Originals.OutdoorAmbient
		Lighting.Brightness=Originals.Brightness; Lighting.FogColor=Originals.FogColor
		Lighting.FogEnd=Originals.FogEnd; Lighting.FogStart=Originals.FogStart
		Lighting.ClockTime=Originals.ClockTime; Lighting.ColorShift_Top=Originals.ColorShift_Top
		Lighting.ColorShift_Bottom=Originals.ColorShift_Bottom; Lighting.ExposureCompensation=Originals.ExposureCompensation
		ccEffect.Enabled=false; glowEffect.Enabled=false
		for eff, orig in pairs(OriginalEffects) do if eff and eff.Parent then eff.Enabled=orig end end
	end

	local function applyPropsColor()
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not Players:GetPlayerFromCharacter(obj.Parent) and not Players:GetPlayerFromCharacter(obj.Parent and obj.Parent.Parent) then
				if not originalPartColors[obj] then originalPartColors[obj] = obj.Color end
				obj.Color = propsColor
			end
		end
	end

	local function restorePropsColor()
		for obj, col in pairs(originalPartColors) do if obj and obj.Parent then obj.Color = col end end
		originalPartColors = {}
	end

	RegisterCleanup(function()
		restoreWorld(); restorePropsColor()
		if ccEffect and ccEffect.Parent then ccEffect:Destroy() end
		if glowEffect and glowEffect.Parent then glowEffect:Destroy() end
	end)

	local WorldGeneral = SubTabs["World"]:AddSection({ Name = "GENERAL", Position = 'left' })
	local WorldLighting = SubTabs["World"]:AddSection({ Name = "LIGHTING", Position = 'center' })
	local WorldEffects = SubTabs["World"]:AddSection({ Name = "EFFECTS", Position = 'right' })

	WorldGeneral:AddToggle({ Name = "Enabled", Callback = function(v) worldEnabled=v; if not v then restoreWorld(); if propsColorEnabled then restorePropsColor() end end end })

	local AT = WorldGeneral:AddToggle({ Name = "Custom ambient", Option = true, Callback = function(v) ambientEnabled=v; if not v and worldEnabled then Lighting.Ambient=Originals.Ambient; Lighting.OutdoorAmbient=Originals.OutdoorAmbient; Lighting.ColorShift_Top=Originals.ColorShift_Top; Lighting.ColorShift_Bottom=Originals.ColorShift_Bottom end end })
	AT.Option:AddColorPicker({ Name = "Ambient", Default = Lighting.Ambient, Callback = function(c) ambientCol=c; pushAmbient() end })
	AT.Option:AddColorPicker({ Name = "Outdoor", Default = Lighting.OutdoorAmbient, Callback = function(c) outdoorCol=c; pushAmbient() end })
	AT.Option:AddColorPicker({ Name = "Sky Top", Default = Lighting.ColorShift_Top, Callback = function(c) skyTopCol=c; pushAmbient() end })
	AT.Option:AddColorPicker({ Name = "Sky Bottom", Default = Lighting.ColorShift_Bottom, Callback = function(c) skyBotCol=c; pushAmbient() end })

	local FT = WorldGeneral:AddToggle({ Name = "Custom fog", Option = true, Callback = function(v) fogEnabled=v; if not v and worldEnabled then Lighting.FogColor=Originals.FogColor; Lighting.FogEnd=Originals.FogEnd; Lighting.FogStart=Originals.FogStart else pushFog() end end })
	FT.Option:AddColorPicker({ Name = "Fog color", Default = Lighting.FogColor, Callback = function(c) fogColorVal=c; pushFog() end })
	WorldGeneral:AddSlider({ Name = "Fog start", Default = math.floor(Originals.FogStart), Min = 0, Max = 5000, Round = 0, Callback = function(v) fogStartVal=v; pushFog() end })
	WorldGeneral:AddSlider({ Name = "Fog end", Default = math.min(10000, math.floor(Originals.FogEnd)), Min = 0, Max = 10000, Round = 0, Callback = function(v) fogEndVal=v; pushFog() end })

	WorldGeneral:AddToggle({ Name = "Custom time", Callback = function(v) timeEnabled=v; if not v and worldEnabled then Lighting.ClockTime=Originals.ClockTime else pushTime() end end })
	WorldGeneral:AddSlider({ Name = "Time of day", Default = math.floor(Originals.ClockTime), Min = 0, Max = 24, Round = 1, Callback = function(v) timeVal=v; pushTime() end })
	WorldGeneral:AddSlider({ Name = "Exposure", Default = 0, Min = -3, Max = 3, Round = 1, Callback = function(v) exposureVal=v; pushBrightness() end })
	WorldGeneral:AddSlider({ Name = "Brightness", Default = math.floor(Originals.Brightness), Min = 0, Max = 10, Round = 1, Callback = function(v) brightnessVal=v; pushBrightness() end })

	local fbS, nvS
	WorldLighting:AddToggle({ Name = "Fullbright", Callback = function(v) fullbrightEnabled=v; if worldEnabled then if v then applyFullbright() else ccEffect.Enabled=false; Lighting.Ambient=ambientEnabled and ambientCol or Originals.Ambient; Lighting.OutdoorAmbient=ambientEnabled and outdoorCol or Originals.OutdoorAmbient; Lighting.Brightness=brightnessVal end end end })
	WorldLighting:AddDropdown({ Name = "Mode", Default = "Standard", Values = {"Standard","Night Vision"}, Callback = function(v) fullbrightMode=v; if fbS and fbS.SetVisible then fbS:SetVisible(v=="Standard") end; if nvS and nvS.SetVisible then nvS:SetVisible(v=="Night Vision") end; if worldEnabled and fullbrightEnabled then applyFullbright() end end })
	fbS = WorldLighting:AddSlider({ Name = "FB Gamma", Default = 2, Min = 0, Max = 5, Round = 1, Callback = function(v) fbGamma=v; if worldEnabled and fullbrightEnabled and fullbrightMode=="Standard" then applyFullbright() end end })
	nvS = WorldLighting:AddSlider({ Name = "NV Gamma", Default = 1.5, Min = 0, Max = 5, Round = 1, Callback = function(v) nvGamma=v; if worldEnabled and fullbrightEnabled and fullbrightMode=="Night Vision" then applyFullbright() end end })
	if nvS and nvS.SetVisible then nvS:SetVisible(false) end
	WorldLighting:AddToggle({ Name = "Remove effects", Callback = function(v) if worldEnabled then for eff,orig in pairs(OriginalEffects) do if eff and eff.Parent then eff.Enabled = v and false or orig end end end end })

	local GT = WorldEffects:AddToggle({ Name = "Glow", Option = true, Callback = function(v) glowEnabled=v; glowEffect.Enabled = worldEnabled and v end })
	GT.Option:AddColorPicker({ Name = "Tint", Default = Color3.new(1,1,1), Callback = function(c) if worldEnabled and glowEnabled then ccEffect.TintColor=c end end })
	WorldEffects:AddSlider({ Name = "Glow intensity", Default = 1, Min = 0, Max = 3, Round = 1, Callback = function(v) glowEffect.Intensity=v end })
	WorldEffects:AddSlider({ Name = "Glow size", Default = 24, Min = 1, Max = 56, Round = 0, Callback = function(v) glowEffect.Size=v end })
	WorldEffects:AddSlider({ Name = "Glow threshold", Default = 1, Min = 0, Max = 2, Round = 1, Callback = function(v) glowEffect.Threshold=v end })

	local PT = WorldEffects:AddToggle({ Name = "Props color", Option = true, Callback = function(v) propsColorEnabled=v; if v and worldEnabled then applyPropsColor() else restorePropsColor() end end })
	PT.Option:AddColorPicker({ Name = "Color", Default = Color3.new(1,1,1), Callback = function(c) propsColor=c; if propsColorEnabled and worldEnabled then applyPropsColor() end end })
	WorldEffects:AddButton({ Name = "Refresh props", Callback = function() if propsColorEnabled and worldEnabled then restorePropsColor(); applyPropsColor() end end })
	WorldEffects:AddButton({ Name = "Reset world", Callback = function() restoreWorld(); restorePropsColor() end })
end

-- ============================================================
-- MISC
-- ============================================================
do
	local Settings = Misc:AddSection({ Name = "SETTINGS", Position = 'left' })

	Settings:AddSlider({ Name = "DPI Scale", Default = 1.1, Min = 0.5, Max = 1.5, Round = 1, Callback = function(v) if typeof(Fatality.SetGlobalDPIScale)=="function" then Fatality:SetGlobalDPIScale(v) end end })
	Settings:AddSlider({ Name = "Menu Width", Default = 780, Min = 500, Max = 1100, Round = 0, Callback = function(v) Window:SetSize(v, nil) end })
	Settings:AddSlider({ Name = "Menu Height", Default = 540, Min = 350, Max = 750, Round = 0, Callback = function(v) Window:SetSize(nil, v) end })
	Settings:AddSlider({ Name = "Menu Position X", Default = 50, Min = 0, Max = 100, Round = 0, Callback = function(v) Window:SetPosition(v/100, nil) end })
	Settings:AddSlider({ Name = "Menu Position Y", Default = 20, Min = 0, Max = 90, Round = 0, Callback = function(v) Window:SetPosition(nil, v/100) end })
	Settings:AddSlider({ Name = "Header Height", Default = 48, Min = 28, Max = 70, Round = 0, Callback = function(v) Window:SetHeaderHeight(v) end })
	Settings:AddSlider({ Name = "Section Column Width", Default = 31, Min = 20, Max = 45, Round = 0, Callback = function(v) Window:SetSectionColumnWidth(v/100) end })
	Settings:AddSlider({ Name = "Sub-Tab Column Width", Default = 27, Min = 20, Max = 45, Round = 0, Callback = function(v) Fatality:SetSubTabColumnWidth(v/100) end })
	Settings:AddSlider({ Name = "Section Y Spacing", Default = 14, Min = 0, Max = 40, Round = 0, Callback = function(v) Fatality:SetSectionPadding(v) end })
	Settings:AddSlider({ Name = "Slider Width", Default = 88, Min = 50, Max = 150, Round = 0, Callback = function(v) Fatality:SetGlobalSliderWidth(v) end })
	Settings:AddSlider({ Name = "Slider Height", Default = 14, Min = 6, Max = 20, Round = 0, Callback = function(v) Fatality:SetGlobalSliderHeight(v) end })
	Settings:AddSlider({ Name = "Combobox Width", Default = 88, Min = 40, Max = 130, Round = 0, Callback = function(v) Fatality:SetGlobalDropdownWidth(v) end })
	Settings:AddSlider({ Name = "Combobox Height", Default = 20, Min = 12, Max = 36, Round = 0, Callback = function(v) Fatality:SetGlobalDropdownHeight(v) end })
	Settings:AddSlider({ Name = "Section Name Y Offset", Default = -8, Min = -30, Max = 10, Round = 0, Callback = function(v) Fatality:SetSectionNameYOffset(v) end })
	Settings:AddSlider({ Name = "Section Name X Offset", Default = 10, Min = -20, Max = 50, Round = 0, Callback = function(v) Fatality:SetSectionNameXOffset(v) end })
	Settings:AddSlider({ Name = "Section Name Size", Default = 12, Min = 8, Max = 20, Round = 0, Callback = function(v) Fatality:SetSectionNameTextSize(v) end })
	Settings:AddSlider({ Name = "Checkbox Scale", Default = 90, Min = 40, Max = 100, Round = 0, Suffix = "%", Callback = function(v) Fatality:SetCheckboxScale(v/100) end })
	Settings:AddSlider({ Name = "Settings Icon Scale", Default = 92, Min = 40, Max = 100, Round = 0, Suffix = "%", Callback = function(v) Fatality:SetOptionIconScale(v/100) end })
	Settings:AddSlider({ Name = "Dropdown Popup X Offset", Default = 0, Min = -50, Max = 50, Round = 0, Callback = function(v) Fatality:SetDropdownPopupXOffset(v) end })
	Settings:AddSlider({ Name = "Keybind Slider X Offset", Default = 36, Min = -20, Max = 150, Round = 0, Callback = function(v) Fatality.KeybindSliderXOffset = v end })
	Settings:AddSlider({ Name = "Keybind Slider Y Offset", Default = 0, Min = -40, Max = 40, Round = 0, Callback = function(v) Fatality.KeybindSliderYOffset = v end })
	Settings:AddSlider({ Name = "Keybind Checkbox X Offset", Default = 78, Min = -20, Max = 150, Round = 0, Callback = function(v) Fatality.KeybindCheckboxXOffset = v end })
	Settings:AddSlider({ Name = "Keybind Checkbox Y Offset", Default = 0, Min = -40, Max = 40, Round = 0, Callback = function(v) Fatality.KeybindCheckboxYOffset = v end })
	Settings:AddSlider({ Name = "Sub-Tab Area Width", Default = 105, Min = 40, Max = 150, Round = 0, Callback = function(v) _G.FatalitySubTabWidth=v; Fatality:SetSubTabWidth(v) end })

	Settings:AddButton({ Name = "Unload", Callback = function()
		Notification:Notify({Title="FATALITY",Content="Unloading...",Duration=1,Icon="info"})
		task.wait(0.3)
		RunCleanup()
		for _, win in pairs(Fatality.Windows) do
			if type(win)=="table" then for k,v in pairs(win) do
				if typeof(v)=="Instance" and v:IsA("ScreenGui") then v:Destroy() end
				if typeof(v)=="Instance" and v:IsA("Frame") then local p=v.Parent; if p and p:IsA("ScreenGui") then p:Destroy() end end
			end end
			if typeof(win)=="Instance" then win:Destroy() end
		end
		for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do pcall(function() if gui:IsA("ScreenGui") and (gui:FindFirstChild("Main") or gui.Name:lower():find("fatal")) then gui:Destroy() end end) end
		pcall(function() for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do pcall(function() if gui:IsA("ScreenGui") and (gui:FindFirstChild("Main") or gui.Name:lower():find("fatal")) then gui:Destroy() end end) end end)
		task.wait(0.2)
		pcall(function()
			for k in pairs(Fatality.Windows) do Fatality.Windows[k]=nil end
			for k in pairs(Fatality.Flags or {}) do Fatality.Flags[k]=nil end
			for k in pairs(Fatality.MenuIcons or {}) do Fatality.MenuIcons[k]=nil end
		end)
		_G.FatalitySubTabWidth=nil
		Window=nil; Fatality=nil; CleanupTasks=nil
		for i=1,3 do pcall(function() collectgarbage("collect") end); task.wait(0.05) end
	end })

	local TabNames = Misc:AddSection({ Name = "TAB NAMES", Position = 'center' })
	TabNames:AddSlider({ Name = "Name Size", Default = 11, Min = 5, Max = 25, Round = 0, Callback = function(v) Fatality:SetMenuLabelTextSize(v) end })

	for _, mn in ipairs({"RAGE","LEGIT","VISUAL"}) do
		local sec = Misc:AddSection({ Name = mn.." ICON", Position = 'center' })
		sec:AddSlider({ Name = "Size X", Default = 20, Min = 5, Max = 50, Round = 0, Callback = function(v) local y = Fatality.MenuIcons[mn] and Fatality.MenuIcons[mn].Size.Y.Offset or 20; if y==0 then y=20 end; Fatality:SetMenuIconSize(mn,v,y) end })
		sec:AddSlider({ Name = "Size Y", Default = 20, Min = 5, Max = 50, Round = 0, Callback = function(v) local x = Fatality.MenuIcons[mn] and Fatality.MenuIcons[mn].Size.X.Offset or 20; if x==0 then x=20 end; Fatality:SetMenuIconSize(mn,x,v) end })
		sec:AddSlider({ Name = "Position X", Default = 5, Min = 0, Max = 30, Round = 0, Callback = function(v) Fatality:SetMenuIconPositionX(mn,v) end })
	end

	for _, mn in ipairs({"MISC","SKINS","LUA"}) do
		local sec = Misc:AddSection({ Name = mn.." ICON", Position = 'right' })
		sec:AddSlider({ Name = "Size X", Default = 20, Min = 5, Max = 50, Round = 0, Callback = function(v) local y = Fatality.MenuIcons[mn] and Fatality.MenuIcons[mn].Size.Y.Offset or 20; if y==0 then y=20 end; Fatality:SetMenuIconSize(mn,v,y) end })
		sec:AddSlider({ Name = "Size Y", Default = 20, Min = 5, Max = 50, Round = 0, Callback = function(v) local x = Fatality.MenuIcons[mn] and Fatality.MenuIcons[mn].Size.X.Offset or 20; if x==0 then x=20 end; Fatality:SetMenuIconSize(mn,x,v) end })
		sec:AddSlider({ Name = "Position X", Default = 5, Min = 0, Max = 30, Round = 0, Callback = function(v) Fatality:SetMenuIconPositionX(mn,v) end })
	end
end

-- ============================================================
-- FORCE Sub-Tab Area Width
-- ============================================================
do
	local RS = game:GetService("RunService")
	_G.FatalitySubTabWidth = _G.FatalitySubTabWidth or 105
	for i=1,10 do pcall(function() Fatality:SetSubTabWidth(_G.FatalitySubTabWidth or 105) end) end

	local origSTW = Fatality.SetSubTabWidth
	local intCall = false
	Fatality.SetSubTabWidth = function(self, value)
		if intCall then return origSTW(self, value) end
		return origSTW(self, _G.FatalitySubTabWidth or 105)
	end

	local origCA = Fatality.CreateAnimation
	local tracked = {}
	pcall(function()
		if Fatality._SubTabReposition then
			for _, v in pairs(Fatality._SubTabReposition) do
				if typeof(v)=="Instance" then tracked[v]=true
				elseif type(v)=="table" then for _,f in pairs(v) do if typeof(f)=="Instance" then tracked[f]=true end end end
			end
		end
	end)

	Fatality.CreateAnimation = function(self, obj, dur, props, ...)
		if tracked[obj] and type(props)=="table" and props.Size and typeof(props.Size)=="UDim2" then
			props.Size = UDim2.new(props.Size.X.Scale, _G.FatalitySubTabWidth or 105, props.Size.Y.Scale, props.Size.Y.Offset)
			dur = 0
		end
		return origCA(self, obj, dur, props, ...)
	end

	local c1 = RS.RenderStepped:Connect(function()
		intCall=true; pcall(function() origSTW(Fatality, _G.FatalitySubTabWidth or 105) end); intCall=false
		pcall(function()
			if Fatality._SubTabReposition then
				for _, v in pairs(Fatality._SubTabReposition) do
					if typeof(v)=="Instance" then tracked[v]=true
					elseif type(v)=="table" then for _,f in pairs(v) do if typeof(f)=="Instance" then tracked[f]=true end end end
				end
			end
		end)
	end)

	RegisterCleanup(function()
		pcall(function() c1:Disconnect() end)
		pcall(function() Fatality.SetSubTabWidth = origSTW end)
		pcall(function() Fatality.CreateAnimation = origCA end)
	end)
end
