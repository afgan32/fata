local Fatality = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/afgan32/fata/refs/heads/main/src/source.luau?t=" .. tostring(tick())
))();
Fatality:PrintUpdateVersion()
local Notification = Fatality:CreateNotifier();

Fatality:Loader({ Name = "FATALITY", Duration = 4 });

Notification:Notify({
    Title   = "FATALITY",
    Content = "Hello, " .. game.Players.LocalPlayer.DisplayName .. " Welcome back!",
    Icon    = "clipboard"
})

local Window = Fatality.new({ Name = "FATALITY", Expire = "never" })
local Visual = Window:AddMenu({ Name = "VISUAL", Icon = "eye"      })
local Misc   = Window:AddMenu({ Name = "MISC",   Icon = "settings" })

-- ============================================================
--  THEME SYSTEM (прямая модификация GUI)
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Lucide иконки (URL маппинг)
local LUCIDE_ICONS = {
    ["eye"]        = "rbxassetid://18838168638",
    ["settings"]   = "rbxassetid://18838244498",
    ["scan-eye"]   = "rbxassetid://18838237498",
    ["radar"]      = "rbxassetid://18838228018",
    ["crosshair"]  = "rbxassetid://18838155498",
    ["wrench"]     = "rbxassetid://18838261698",
    ["cog"]        = "rbxassetid://18838150498",
    ["shield"]     = "rbxassetid://18838241498",
    ["skull"]      = "rbxassetid://18838243498",
    ["target"]     = "rbxassetid://18838252498",
    ["palette"]    = "rbxassetid://18838222018",
    ["code"]       = "rbxassetid://18838149498",
    ["monitor"]    = "rbxassetid://18838210018",
    ["zap"]        = "rbxassetid://18838264698",
    ["flame"]      = "rbxassetid://18838170638",
    ["swords"]     = "rbxassetid://18838250498",
    ["gem"]        = "rbxassetid://18838173638",
    ["crown"]      = "rbxassetid://18838156498",
    ["heart"]      = "rbxassetid://18838176638",
    ["star"]       = "rbxassetid://18838246498",
    ["bolt"]       = "rbxassetid://18838147498",
    ["aperture"]   = "rbxassetid://18838141498",
    ["activity"]   = "rbxassetid://18838138498",
    ["compass"]    = "rbxassetid://18838152498",
    ["navigation"] = "rbxassetid://18838214018",
    ["satellite"]  = "rbxassetid://18838234498",
    ["radio"]      = "rbxassetid://18838226018",
    ["telescope"]  = "rbxassetid://18838254498",
    ["binoculars"] = "rbxassetid://18838145498",
    ["layers"]     = "rbxassetid://18838197498",
    ["box"]        = "rbxassetid://18838148498",
    ["cpu"]        = "rbxassetid://18838154498",
    ["terminal"]   = "rbxassetid://18838255498",
    ["binary"]     = "rbxassetid://18838144498",
    ["bug"]        = "rbxassetid://18838149000",
    ["shield-alert"] = "rbxassetid://18838240498",
}

local currentTheme = "Default"

-- Находим ScreenGui библиотеки
local function findFatalityGui()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- Ищем GUI с характерными элементами Fatality
            local found = gui:FindFirstChild("Main", true) or gui:FindFirstChild("Container", true)
            if found then return gui end
            -- Проверяем по имени
            if gui.Name:lower():find("fatal") or gui.Name:lower():find("menu") then
                return gui
            end
        end
    end
    -- Берём последний созданный ScreenGui (обычно это меню)
    local guis = PlayerGui:GetChildren()
    for i = #guis, 1, -1 do
        if guis[i]:IsA("ScreenGui") and guis[i].Name ~= "Chat" and guis[i].Name ~= "PlayerList" then
            return guis[i]
        end
    end
    return nil
end

-- Рекурсивный обход всех UI элементов
local function getAllDescendants(parent, list)
    list = list or {}
    for _, child in ipairs(parent:GetChildren()) do
        list[#list+1] = child
        getAllDescendants(child, list)
    end
    return list
end

-- Определяем тип элемента по свойствам
local function isBackground(obj)
    if not obj:IsA("Frame") and not obj:IsA("ScrollingFrame") then return false end
    if obj.AbsoluteSize.X > 200 and obj.AbsoluteSize.Y > 200 then return true end
    return false
end

local function isSectionFrame(obj)
    if not obj:IsA("Frame") then return false end
    local s = obj.AbsoluteSize
    if s.X > 100 and s.Y > 50 and s.X < 500 then return true end
    return false
end

-- Тема: таблица цветов
local ThemeColors = {
    ["Default"] = {
        -- Оригинальные цвета (не трогаем)
        apply = false,
    },
    ["Dark"] = {
        apply = true,
        bg           = Color3.fromRGB(10, 10, 10),
        bgDark       = Color3.fromRGB(6, 6, 6),
        section      = Color3.fromRGB(16, 16, 16),
        sectionBorder= Color3.fromRGB(32, 32, 32),
        header       = Color3.fromRGB(8, 8, 8),
        accent       = Color3.fromRGB(255, 45, 45),
        text         = Color3.fromRGB(220, 220, 220),
        textDim      = Color3.fromRGB(130, 130, 130),
        slider       = Color3.fromRGB(255, 45, 45),
        toggleOn     = Color3.fromRGB(255, 45, 45),
        toggleOff    = Color3.fromRGB(35, 35, 35),
        border       = Color3.fromRGB(38, 38, 38),
        dropdown     = Color3.fromRGB(20, 20, 20),
        scrollbar    = Color3.fromRGB(50, 50, 50),
        icons = {
            VISUAL   = "crosshair",
            MISC     = "wrench",
        },
    },
    ["Midnight"] = {
        apply = true,
        bg           = Color3.fromRGB(8, 12, 24),
        bgDark       = Color3.fromRGB(4, 8, 18),
        section      = Color3.fromRGB(12, 18, 35),
        sectionBorder= Color3.fromRGB(25, 40, 75),
        header       = Color3.fromRGB(6, 10, 20),
        accent       = Color3.fromRGB(40, 120, 255),
        text         = Color3.fromRGB(190, 210, 255),
        textDim      = Color3.fromRGB(100, 130, 180),
        slider       = Color3.fromRGB(40, 120, 255),
        toggleOn     = Color3.fromRGB(40, 120, 255),
        toggleOff    = Color3.fromRGB(20, 30, 55),
        border       = Color3.fromRGB(30, 45, 80),
        dropdown     = Color3.fromRGB(14, 20, 38),
        scrollbar    = Color3.fromRGB(40, 60, 100),
        icons = {
            VISUAL   = "radar",
            MISC     = "compass",
        },
    },
    ["Blood"] = {
        apply = true,
        bg           = Color3.fromRGB(14, 4, 4),
        bgDark       = Color3.fromRGB(8, 2, 2),
        section      = Color3.fromRGB(22, 6, 6),
        sectionBorder= Color3.fromRGB(60, 15, 15),
        header       = Color3.fromRGB(10, 2, 2),
        accent       = Color3.fromRGB(180, 0, 0),
        text         = Color3.fromRGB(255, 200, 200),
        textDim      = Color3.fromRGB(150, 90, 90),
        slider       = Color3.fromRGB(180, 0, 0),
        toggleOn     = Color3.fromRGB(180, 0, 0),
        toggleOff    = Color3.fromRGB(40, 10, 10),
        border       = Color3.fromRGB(70, 18, 18),
        dropdown     = Color3.fromRGB(18, 5, 5),
        scrollbar    = Color3.fromRGB(80, 20, 20),
        icons = {
            VISUAL   = "flame",
            MISC     = "shield",
        },
    },
    ["Emerald"] = {
        apply = true,
        bg           = Color3.fromRGB(4, 14, 8),
        bgDark       = Color3.fromRGB(2, 8, 4),
        section      = Color3.fromRGB(6, 22, 12),
        sectionBorder= Color3.fromRGB(15, 60, 25),
        header       = Color3.fromRGB(2, 10, 6),
        accent       = Color3.fromRGB(0, 200, 80),
        text         = Color3.fromRGB(200, 255, 220),
        textDim      = Color3.fromRGB(90, 150, 110),
        slider       = Color3.fromRGB(0, 200, 80),
        toggleOn     = Color3.fromRGB(0, 200, 80),
        toggleOff    = Color3.fromRGB(10, 40, 18),
        border       = Color3.fromRGB(18, 70, 30),
        dropdown     = Color3.fromRGB(5, 18, 10),
        scrollbar    = Color3.fromRGB(20, 80, 40),
        icons = {
            VISUAL   = "gem",
            MISC     = "layers",
        },
    },
}

-- Сохраняем оригинальные цвета при первом запуске
local originalColors = {}
local originalSaved = false

local function saveOriginalColors(gui)
    if originalSaved then return end
    originalSaved = true
    for _, obj in ipairs(getAllDescendants(gui)) do
        local info = {}
        if obj:IsA("GuiObject") then
            info.BackgroundColor3 = obj.BackgroundColor3
            info.BackgroundTransparency = obj.BackgroundTransparency
            if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
                pcall(function()
                    if obj.BorderSizePixel > 0 then
                        info.BorderColor3 = obj.BorderColor3
                    end
                end)
            end
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            info.TextColor3 = obj.TextColor3
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            info.ImageColor3 = obj.ImageColor3
            info.Image = obj.Image
        end
        if obj:IsA("UIStroke") then
            info.Color = obj.Color
        end
        if obj:IsA("ScrollingFrame") then
            info.ScrollBarImageColor3 = obj.ScrollBarImageColor3
        end
        originalColors[obj] = info
    end
end

local function restoreOriginalColors(gui)
    for obj, info in pairs(originalColors) do
        if obj and obj.Parent then
            pcall(function()
                if info.BackgroundColor3 then obj.BackgroundColor3 = info.BackgroundColor3 end
                if info.BackgroundTransparency then obj.BackgroundTransparency = info.BackgroundTransparency end
                if info.BorderColor3 then obj.BorderColor3 = info.BorderColor3 end
                if info.TextColor3 then obj.TextColor3 = info.TextColor3 end
                if info.ImageColor3 then obj.ImageColor3 = info.ImageColor3 end
                if info.Image then obj.Image = info.Image end
                if info.Color then obj.Color = info.Color end
                if info.ScrollBarImageColor3 then obj.ScrollBarImageColor3 = info.ScrollBarImageColor3 end
            end)
        end
    end
end

-- Определяем яркость цвета
local function brightness(c)
    return c.R * 0.299 + c.G * 0.587 + c.B * 0.114
end

local function isColorDark(c)
    return brightness(c) < 0.35
end

local function isColorLight(c)
    return brightness(c) > 0.6
end

local function isAccentLike(c)
    -- Яркий насыщенный цвет (не серый, не чёрный, не белый)
    local h, s, v = Color3.toHSV(c)
    return s > 0.4 and v > 0.3
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpColor(c1, c2, t)
    return Color3.new(lerp(c1.R, c2.R, t), lerp(c1.G, c2.G, t), lerp(c1.B, c2.B, t))
end

local function applyTheme(themeName)
    currentTheme = themeName
    local theme = ThemeColors[themeName]
    if not theme then return end

    local gui = findFatalityGui()
    if not gui then
        Notification:Notify({
            Title = "Theme", Content = "GUI not found!", Duration = 3, Icon = "info"
        })
        return
    end

    saveOriginalColors(gui)

    if not theme.apply then
        -- Default: восстанавливаем оригинал
        restoreOriginalColors(gui)
        Notification:Notify({
            Title = "Theme", Content = "Restored: Default", Duration = 3, Icon = "palette"
        })
        return
    end

    local all = getAllDescendants(gui)

    for _, obj in ipairs(all) do
        pcall(function()
            -- Фреймы и фоны
            if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                local bg = obj.BackgroundColor3
                local trans = obj.BackgroundTransparency

                if trans < 0.95 then
                    local b = brightness(bg)

                    if b < 0.06 then
                        -- Очень тёмный (основной фон)
                        obj.BackgroundColor3 = theme.bgDark
                    elseif b < 0.12 then
                        -- Тёмный (фон секций)
                        obj.BackgroundColor3 = theme.bg
                    elseif b < 0.22 then
                        -- Средне-тёмный (секции, панели)
                        obj.BackgroundColor3 = theme.section
                    elseif b < 0.35 then
                        -- Средний (бордеры, разделители)
                        obj.BackgroundColor3 = theme.border
                    elseif isAccentLike(bg) then
                        -- Акцентный цвет (слайдеры, тогглы включённые)
                        obj.BackgroundColor3 = theme.accent
                    elseif b < 0.5 then
                        obj.BackgroundColor3 = theme.dropdown
                    end
                end

                -- Бордер
                if obj.BorderSizePixel > 0 then
                    obj.BorderColor3 = theme.border
                end
            end

            -- ScrollBar
            if obj:IsA("ScrollingFrame") then
                obj.ScrollBarImageColor3 = theme.scrollbar
            end

            -- Текст
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local tc = obj.TextColor3
                local tb = brightness(tc)
                local bg = obj.BackgroundColor3
                local bgTrans = obj.BackgroundTransparency

                -- Текст
                if tb > 0.7 then
                    obj.TextColor3 = theme.text
                elseif tb > 0.4 then
                    obj.TextColor3 = theme.textDim
                elseif isAccentLike(tc) then
                    obj.TextColor3 = theme.accent
                end

                -- Фон текстовых элементов
                if bgTrans < 0.95 then
                    local b = brightness(bg)
                    if b < 0.15 then
                        obj.BackgroundColor3 = theme.section
                    elseif isAccentLike(bg) then
                        obj.BackgroundColor3 = theme.accent
                    end
                end
            end

            -- Иконки (ImageLabel / ImageButton)
            if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                local ic = obj.ImageColor3
                if isAccentLike(ic) then
                    obj.ImageColor3 = theme.accent
                elseif brightness(ic) > 0.7 then
                    obj.ImageColor3 = theme.text
                elseif brightness(ic) > 0.35 then
                    obj.ImageColor3 = theme.textDim
                end
            end

            -- UIStroke
            if obj:IsA("UIStroke") then
                local sc = obj.Color
                if isAccentLike(sc) then
                    obj.Color = theme.accent
                elseif brightness(sc) < 0.3 then
                    obj.Color = theme.border
                end
            end

            -- UIGradient — акцентные градиенты
            if obj:IsA("UIGradient") then
                local cs = obj.Color
                local kps = cs.Keypoints
                local newKps = {}
                local changed = false
                for _, kp in ipairs(kps) do
                    if isAccentLike(kp.Value) then
                        newKps[#newKps+1] = ColorSequenceKeypoint.new(kp.Time, theme.accent)
                        changed = true
                    else
                        newKps[#newKps+1] = kp
                    end
                end
                if changed and #newKps >= 2 then
                    obj.Color = ColorSequence.new(newKps)
                end
            end
        end)
    end

    -- Меняем иконки табов
    if theme.icons then
        for menuName, iconKey in pairs(theme.icons) do
            -- Ищем иконку таба в GUI
            local iconId = LUCIDE_ICONS[iconKey]
            if iconId and Fatality.MenuIcons and Fatality.MenuIcons[menuName] then
                pcall(function()
                    Fatality.MenuIcons[menuName].Image = iconId
                end)
            end
        end
    end

    Notification:Notify({
        Title    = "Theme",
        Content  = "Applied: " .. themeName,
        Duration = 3,
        Icon     = "palette"
    })
end

-- ============================================================
--  Константы
-- ============================================================
local STUDS_TO_METERS = 0.28
local function studsToMeters(studs) return studs * STUDS_TO_METERS end

-- ============================================================
--  ESP конфиг
-- ============================================================
local ESP = {
    Enabled                = false,
    BoxStyle               = "2D Box",
    Outline                = true,
    ShowName               = true,
    ShowDist               = true,
    TextSize               = 14,
    TextColor              = Color3.fromRGB(255, 255, 255),
    MaxDist                = 500,
    HighlightEnabled       = false,
    HighlightFillTransp    = 1.0,
    HighlightFillColor     = Color3.fromRGB(255, 255, 255),
    HighlightOutlineTransp = 0.0,
    VehicleName = {
        Enabled  = false,
        TextSize = 16,
        Color    = Color3.fromRGB(255, 255, 255),
        Offset   = 4,
    },
    Modules = {
        Ammo         = { Enabled = true, Color = Color3.fromRGB(255, 60,  60),  Thickness = 1 },
        Fueltank     = { Enabled = true, Color = Color3.fromRGB(255, 200, 40),  Thickness = 1 },
        Engine       = { Enabled = true, Color = Color3.fromRGB(80,  200, 80),  Thickness = 1 },
        ATGMLauncher = { Enabled = true, Color = Color3.fromRGB(80,  180, 255), Thickness = 1 },
        ATGM         = { Enabled = true, Color = Color3.fromRGB(200, 80,  255), Thickness = 1 },
    },
    PropFilter = {},
    TeamFilter = {},
}

local BuildESP = {
    Enabled  = false,
    ShowDist = true,
    TextSize = 14,
    Color    = Color3.fromRGB(255, 200, 80),
    MaxDist  = 800,
}

-- ============================================================
--  Паттерны модулей
-- ============================================================
local NAME_PATTERNS = {
    { pattern = "^[Aa]mmo[Mm]odel%d+$", key = "Ammo"         },
    { pattern = "^[Ff]uel[Tt]ank$",     key = "Fueltank"     },
    { pattern = "^[Ee]ngine$",           key = "Engine"       },
    { pattern = "^ATGMLauncher$",        key = "ATGMLauncher" },
}

local function getModuleType(name)
    for _, p in ipairs(NAME_PATTERNS) do
        if name:match(p.pattern) then return p.key end
    end
    return nil
end

-- ============================================================
--  Детект команд
-- ============================================================
local Teams = game:GetService("Teams")
local FALLBACK_TEAMS = {"Hawk Republic","Fish State","Eagle","Spectators","Neutral"}

local function getTeamNames()
    local found, seen = {}, {}
    for _, t in ipairs(Teams:GetTeams()) do
        if not seen[t.Name] then seen[t.Name]=true; found[#found+1]=t.Name end
    end
    local sv = workspace:FindFirstChild("SpawnedVehicles")
    if sv then
        for _, v in ipairs(sv:GetChildren()) do
            local team = v:GetAttribute("Team")
                or (v:FindFirstChild("Team") and v:FindFirstChild("Team").Value)
            if team and team ~= "" and not seen[team] then
                seen[team]=true; found[#found+1]=team
            end
        end
    end
    if #found == 0 then
        for _, tn in ipairs(FALLBACK_TEAMS) do
            if not seen[tn] then seen[tn]=true; found[#found+1]=tn end
        end
    end
    return found
end

local teamNames = getTeamNames()

local function getVehicleTeam(vehicle)
    local attr = vehicle:GetAttribute("Team")
    if attr and attr ~= "" then return attr end
    local tv = vehicle:FindFirstChild("Team")
    if tv then
        local val = (tv:IsA("StringValue") and tv.Value) or tv.Name
        if val and val ~= "" then return val end
    end
    return nil
end

-- ============================================================
--  VISUAL
-- ============================================================
do
    local WorldVehicle = Visual:AddSection({ Name = "VEHICLE ESP",   Position = "left"   })
    local WorldModules = Visual:AddSection({ Name = "MODULE STYLE",  Position = "center" })
    local WorldFilter  = Visual:AddSection({ Name = "FILTERS",       Position = "right"  })
    local WorldBuild   = Visual:AddSection({ Name = "BUILDINGS ESP", Position = "right"  })

    WorldVehicle:AddToggle({
        Name = "Enable Vehicle ESP", Default = false,
        Callback = function(v) ESP.Enabled = v end
    })
    WorldVehicle:AddDropdown({
        Name = "Box Style", Default = "2D Box",
        Values = {"None","2D Box","3D Box","Corner 2D","Corner 3D"},
        Callback = function(v) ESP.BoxStyle = v end
    })
    WorldVehicle:AddToggle({
        Name = "Box Outline", Default = true,
        Callback = function(v) ESP.Outline = v end
    })

    local hlTog = WorldVehicle:AddToggle({
        Name = "Model Highlight", Default = false, Option = true,
        Callback = function(v) ESP.HighlightEnabled = v end
    })
    hlTog.Option:AddColorPicker({
        Name = "Fill Color", Default = Color3.fromRGB(255,255,255),
        Callback = function(c) ESP.HighlightFillColor = c end
    })
    hlTog.Option:AddSlider({
        Name = "Fill %", Default = 0, Min = 0, Max = 100, Round = 0, Type = "%",
        Callback = function(v) ESP.HighlightFillTransp = 1 - (v / 100) end
    })
    hlTog.Option:AddSlider({
        Name = "Outline %", Default = 100, Min = 0, Max = 100, Round = 0, Type = "%",
        Callback = function(v) ESP.HighlightOutlineTransp = 1 - (v / 100) end
    })

    local vnTog = WorldVehicle:AddToggle({
        Name = "Vehicle Name", Default = false, Option = true,
        Callback = function(v) ESP.VehicleName.Enabled = v end
    })
    vnTog.Option:AddColorPicker({
        Name = "Name Color", Default = Color3.fromRGB(255,255,255),
        Callback = function(c) ESP.VehicleName.Color = c end
    })
    vnTog.Option:AddSlider({
        Name = "Name Size", Default = 16, Min = 8, Max = 32, Round = 0,
        Callback = function(v) ESP.VehicleName.TextSize = v end
    })
    vnTog.Option:AddSlider({
        Name = "Name Offset", Default = 4, Min = 0, Max = 30, Round = 0,
        Callback = function(v) ESP.VehicleName.Offset = v end
    })

    local txtTog = WorldVehicle:AddToggle({
        Name = "Module Name / Dist", Default = true, Option = true,
        Callback = function(v) ESP.ShowName = v; ESP.ShowDist = v end
    })
    txtTog.Option:AddColorPicker({
        Name = "Text Color", Default = Color3.fromRGB(255,255,255),
        Callback = function(c) ESP.TextColor = c end
    })
    txtTog.Option:AddSlider({
        Name = "Text Size", Default = 14, Min = 8, Max = 24, Round = 0,
        Callback = function(v) ESP.TextSize = v end
    })

    WorldVehicle:AddSlider({
        Name = "Max Distance", Default = 500, Min = 50, Max = 2000, Round = 0, Type = "m",
        Callback = function(v) ESP.MaxDist = v end
    })

    -- MODULE STYLE
    local function addModTog(sec, label, key, defCol)
        local tog = sec:AddToggle({
            Name = label, Default = true, Option = true,
            Callback = function(v) ESP.Modules[key].Enabled = v end
        })
        tog.Option:AddColorPicker({
            Name = "Color", Default = defCol,
            Callback = function(c) ESP.Modules[key].Color = c end
        })
        tog.Option:AddSlider({
            Name = "Thickness", Default = 1, Min = 1, Max = 5, Round = 0,
            Callback = function(v) ESP.Modules[key].Thickness = v end
        })
    end

    addModTog(WorldModules, "AmmoModel ESP",    "Ammo",         Color3.fromRGB(255, 60,  60))
    addModTog(WorldModules, "Fueltank ESP",     "Fueltank",     Color3.fromRGB(255, 200, 40))
    addModTog(WorldModules, "Engine ESP",       "Engine",       Color3.fromRGB(80,  200, 80))
    addModTog(WorldModules, "ATGMLauncher ESP", "ATGMLauncher", Color3.fromRGB(80,  180, 255))
    addModTog(WorldModules, "ATGM Missile ESP", "ATGM",        Color3.fromRGB(200, 80,  255))

    -- FILTERS
    local function scanLivePropNames()
        local names, seen = {}, {}
        local sv = workspace:FindFirstChild("SpawnedVehicles")
        if sv then
            for _, vehicle in ipairs(sv:GetChildren()) do
                local dm = vehicle:FindFirstChild("DamageModules")
                if dm then
                    for _, subFolder in ipairs(dm:GetDescendants()) do
                        local mt = getModuleType(subFolder.Name)
                        if mt and not seen[subFolder.Name] then
                            seen[subFolder.Name] = true
                            names[#names+1] = subFolder.Name
                        end
                    end
                end
            end
        end
        if #names == 0 then
            names = {"AmmoModel1","AmmoModel2","AmmoModel3","AmmoModel4","FuelTank","Engine","ATGMLauncher"}
        end
        table.sort(names)
        return names
    end

    local livePropNames = scanLivePropNames()

    WorldFilter:AddDropdown({
        Name  = "Prop Filter", Multi = true,
        Default = (function()
            local d = {}
            for _, n in ipairs(livePropNames) do d[n] = true end
            return d
        end)(),
        Values   = livePropNames,
        Callback = function(sel)
            for k in pairs(ESP.PropFilter) do ESP.PropFilter[k] = nil end
            for _, n in ipairs(livePropNames) do
                if not sel[n] then ESP.PropFilter[n] = false end
            end
        end
    })

    WorldFilter:AddDropdown({
        Name  = "Team Filter", Multi = true,
        Default = (function()
            local d = {}
            for _, tn in ipairs(teamNames) do d[tn] = true end
            return d
        end)(),
        Values   = teamNames,
        Callback = function(sel)
            for k in pairs(ESP.TeamFilter) do ESP.TeamFilter[k] = nil end
            for _, tn in ipairs(teamNames) do
                if not sel[tn] then ESP.TeamFilter[tn] = false end
            end
        end
    })

    -- BUILDINGS ESP
    WorldBuild:AddToggle({
        Name = "Enable Buildings ESP", Default = false,
        Callback = function(v) BuildESP.Enabled = v end
    })

    local buildTog = WorldBuild:AddToggle({
        Name = "Building Name / Dist", Default = true, Option = true,
        Callback = function(v) BuildESP.ShowDist = v end
    })
    buildTog.Option:AddColorPicker({
        Name = "Text Color", Default = Color3.fromRGB(255, 200, 80),
        Callback = function(c) BuildESP.Color = c end
    })
    buildTog.Option:AddSlider({
        Name = "Text Size", Default = 14, Min = 8, Max = 28, Round = 0,
        Callback = function(v) BuildESP.TextSize = v end
    })

    WorldBuild:AddSlider({
        Name = "Buildings Max Dist", Default = 800, Min = 50, Max = 3000, Round = 0, Type = "m",
        Callback = function(v) BuildESP.MaxDist = v end
    })
end

-- ============================================================
--  MISC
-- ============================================================
do
    -- ── THEME ────────────────────────────────────────────────
    local ThemeSec = Misc:AddSection({
        Name = "THEME",
        Position = "left"
    })

    ThemeSec:AddDropdown({
        Name     = "Menu Theme",
        Default  = "Default",
        Values   = {"Default", "Dark", "Midnight", "Blood", "Emerald"},
        Callback = function(v)
            -- Небольшая задержка чтобы GUI успел отрисоваться
            task.delay(0.1, function()
                applyTheme(v)
            end)
        end
    })

    ThemeSec:AddButton({
        Name = "Reapply Theme",
        Callback = function()
            applyTheme(currentTheme)
        end
    })

    -- ── SETTINGS ─────────────────────────────────────────────
    local Settings = Misc:AddSection({
        Name = "SETTINGS",
        Position = "left"
    })

    Settings:AddSlider({
        Name = "DPI Scale", Default = 1.1, Min = 0.5, Max = 1.5, Round = 1,
        ApplyOnRelease = true,
        Callback = function(v)
            if typeof(Fatality.SetGlobalDPIScale) == "function" then
                Fatality:SetGlobalDPIScale(v)
            end
        end
    })

    Settings:AddSlider({ Name = "Menu Width", Default = 780, Min = 500, Max = 1100, Round = 0,
        Callback = function(v) Window:SetSize(v, nil) end })
    Settings:AddSlider({ Name = "Menu Height", Default = 540, Min = 350, Max = 750, Round = 0,
        Callback = function(v) Window:SetSize(nil, v) end })
    Settings:AddSlider({ Name = "Menu Position X", Default = 50, Min = 0, Max = 100, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Window:SetPosition(v / 100, nil) end })
    Settings:AddSlider({ Name = "Menu Position Y", Default = 20, Min = 0, Max = 90, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Window:SetPosition(nil, v / 100) end })
    Settings:AddSlider({ Name = "Header Height", Default = 48, Min = 28, Max = 70, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Window:SetHeaderHeight(v) end })
    Settings:AddSlider({ Name = "Section Column Width", Default = 31, Min = 20, Max = 45, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Window:SetSectionColumnWidth(v / 100) end })
    Settings:AddSlider({ Name = "Sub-Tab Column Width", Default = 27, Min = 20, Max = 45, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetSubTabColumnWidth(v / 100) end })
    Settings:AddSlider({ Name = "Section Y Spacing", Default = 14, Min = 0, Max = 40, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetSectionPadding(v) end })
    Settings:AddSlider({ Name = "Slider Width", Default = 88, Min = 50, Max = 150, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetGlobalSliderWidth(v) end })
    Settings:AddSlider({ Name = "Slider Height", Default = 14, Min = 6, Max = 20, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetGlobalSliderHeight(v) end })
    Settings:AddSlider({ Name = "Combobox Width", Default = 88, Min = 40, Max = 130, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetGlobalDropdownWidth(v) end })
    Settings:AddSlider({ Name = "Combobox Height", Default = 20, Min = 12, Max = 36, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetGlobalDropdownHeight(v) end })
    Settings:AddSlider({ Name = "Section Name Y Offset", Default = -8, Min = -30, Max = 10, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetSectionNameYOffset(v) end })
    Settings:AddSlider({ Name = "Section Name X Offset", Default = 10, Min = -20, Max = 50, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetSectionNameXOffset(v) end })
    Settings:AddSlider({ Name = "Section Name Size", Default = 12, Min = 8, Max = 20, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetSectionNameTextSize(v) end })
    Settings:AddSlider({ Name = "Checkbox Scale", Default = 90, Min = 40, Max = 100, Round = 0, Suffix = "%", ApplyOnRelease = true,
        Callback = function(v) Fatality:SetCheckboxScale(v / 100) end })
    Settings:AddSlider({ Name = "Settings Icon Scale", Default = 92, Min = 40, Max = 100, Round = 0, Suffix = "%", ApplyOnRelease = true,
        Callback = function(v) Fatality:SetOptionIconScale(v / 100) end })
    Settings:AddSlider({ Name = "Dropdown Popup X Offset", Default = 0, Min = -50, Max = 50, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetDropdownPopupXOffset(v) end })
    Settings:AddSlider({ Name = "Keybind Slider X Offset", Default = 36, Min = -20, Max = 150, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality.KeybindSliderXOffset = v end })
    Settings:AddSlider({ Name = "Keybind Slider Y Offset", Default = 0, Min = -40, Max = 40, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality.KeybindSliderYOffset = v end })
    Settings:AddSlider({ Name = "Keybind Checkbox X Offset", Default = 78, Min = -20, Max = 150, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality.KeybindCheckboxXOffset = v end })
    Settings:AddSlider({ Name = "Keybind Checkbox Y Offset", Default = 0, Min = -40, Max = 40, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality.KeybindCheckboxYOffset = v end })
    Settings:AddSlider({ Name = "Sub-Tab Area Width", Default = 105, Min = 40, Max = 150, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetSubTabWidth(v) end })

    -- TAB NAMES
    local TabNames = Misc:AddSection({ Name = "TAB NAMES", Position = "center" })
    TabNames:AddSlider({ Name = "Name Size", Default = 11, Min = 5, Max = 25, Round = 0, ApplyOnRelease = true,
        Callback = function(v) Fatality:SetMenuLabelTextSize(v) end })

    -- MENU ICONS
    local menusCenter = {"VISUAL"}
    for _, menuName in ipairs(menusCenter) do
        local sec = Misc:AddSection({ Name = menuName .. " ICON", Position = "center" })
        sec:AddSlider({ Name = "Size X", Default = 20, Min = 5, Max = 50, Round = 0, ApplyOnRelease = true,
            Callback = function(v)
                local y = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.Y.Offset or 20
                if y == 0 then y = 20 end
                Fatality:SetMenuIconSize(menuName, v, y)
            end })
        sec:AddSlider({ Name = "Size Y", Default = 20, Min = 5, Max = 50, Round = 0, ApplyOnRelease = true,
            Callback = function(v)
                local x = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.X.Offset or 20
                if x == 0 then x = 20 end
                Fatality:SetMenuIconSize(menuName, x, v)
            end })
        sec:AddSlider({ Name = "Position X", Default = 5, Min = 0, Max = 30, Round = 0, ApplyOnRelease = true,
            Callback = function(v) Fatality:SetMenuIconPositionX(menuName, v) end })
    end

    local menusRight = {"MISC"}
    for _, menuName in ipairs(menusRight) do
        local sec = Misc:AddSection({ Name = menuName .. " ICON", Position = "right" })
        sec:AddSlider({ Name = "Size X", Default = 20, Min = 5, Max = 50, Round = 0, ApplyOnRelease = true,
            Callback = function(v)
                local y = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.Y.Offset or 20
                if y == 0 then y = 20 end
                Fatality:SetMenuIconSize(menuName, v, y)
            end })
        sec:AddSlider({ Name = "Size Y", Default = 20, Min = 5, Max = 50, Round = 0, ApplyOnRelease = true,
            Callback = function(v)
                local x = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.X.Offset or 20
                if x == 0 then x = 20 end
                Fatality:SetMenuIconSize(menuName, x, v)
            end })
        sec:AddSlider({ Name = "Position X", Default = 5, Min = 0, Max = 30, Round = 0, ApplyOnRelease = true,
            Callback = function(v) Fatality:SetMenuIconPositionX(menuName, v) end })
    end

    -- DEBUG
    local DebugSec = Misc:AddSection({ Name = "DEBUG", Position = "right" })
    DebugSec:AddButton({
        Name = "Print GUI Structure",
        Callback = function()
            local gui = findFatalityGui()
            if gui then
                print("=== FATALITY GUI: " .. gui.Name .. " ===")
                for _, obj in ipairs(getAllDescendants(gui)) do
                    if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("ImageLabel") then
                        print(obj.ClassName .. " | " .. obj:GetFullName():sub(#gui:GetFullName()+2))
                    end
                end
            else
                print("GUI NOT FOUND")
            end
        end
    })
end

-- ============================================================
--  Утилиты рисовалки
-- ============================================================
local Camera     = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function getBoundingBox(obj)
    if obj:IsA("Model") then
        local ok, cf, sz = pcall(function() return obj:GetBoundingBox() end)
        if ok and sz and sz.Magnitude > 0 then return cf, sz end
    elseif obj:IsA("BasePart") then
        return obj.CFrame, obj.Size
    end
    return nil, nil
end

local function getCorners(cf, sz)
    local h = sz * 0.5
    local out = {}
    for _, s in ipairs({
        Vector3.new(-1,-1,-1), Vector3.new(1,-1,-1),
        Vector3.new(-1, 1,-1), Vector3.new(1, 1,-1),
        Vector3.new(-1,-1, 1), Vector3.new(1,-1, 1),
        Vector3.new(-1, 1, 1), Vector3.new(1, 1, 1),
    }) do out[#out+1] = cf * (h * s) end
    return out
end

local function screenBounds(corners)
    local mnX,mnY =  math.huge,  math.huge
    local mxX,mxY = -math.huge, -math.huge
    local any = false
    for _, wp in ipairs(corners) do
        local sp, vis = Camera:WorldToViewportPoint(wp)
        if vis and sp.Z > 0 then
            any = true
            if sp.X < mnX then mnX=sp.X end
            if sp.Y < mnY then mnY=sp.Y end
            if sp.X > mxX then mxX=sp.X end
            if sp.Y > mxY then mxY=sp.Y end
        end
    end
    if not any then return nil end
    return mnX, mnY, mxX, mxY
end

local function screenPts(corners)
    local pts = {}
    for _, wp in ipairs(corners) do
        local sp, vis = Camera:WorldToViewportPoint(wp)
        pts[#pts+1] = { x=sp.X, y=sp.Y, ok=vis and sp.Z>0 }
    end
    return pts
end

local function newLine(col, th)
    local l=Drawing.new("Line"); l.Color=col; l.Thickness=th; l.Visible=false; return l
end
local function newSquare(col, th)
    local s=Drawing.new("Square"); s.Color=col; s.Thickness=th; s.Filled=false; s.Visible=false; return s
end
local function newText(sz, col)
    local t=Drawing.new("Text"); t.Size=sz; t.Color=col
    t.Outline=true; t.OutlineColor=Color3.new(0,0,0); t.Center=true; t.Visible=false; return t
end

local EDGES = {
    {1,2},{2,6},{6,5},{5,1},
    {3,4},{4,8},{8,7},{7,3},
    {1,3},{2,4},{5,7},{6,8},
}

local function drawBox(style, outl, corners, col, th,
                       sq, sqO, ln3d, ln3dO, cnr2d, cnr2dO, cnr3d, cnr3dO)
    sq.Color=col; sq.Thickness=th; sqO.Thickness=th+2
    if ln3d  then for i=1,#ln3d  do ln3d[i].Color=col;  ln3d[i].Thickness=th;  ln3dO[i].Thickness=th+2  end end
    if cnr2d then for i=1,#cnr2d do cnr2d[i].Color=col; cnr2d[i].Thickness=th; cnr2dO[i].Thickness=th+2 end end
    if cnr3d then for i=1,#cnr3d do cnr3d[i].Color=col; cnr3d[i].Thickness=th; cnr3dO[i].Thickness=th+2 end end

    if style == "2D Box" then
        local x0,y0,x1,y1 = screenBounds(corners)
        if not x0 then return nil end
        if outl then sqO.Position=Vector2.new(x0-1,y0-1); sqO.Size=Vector2.new(x1-x0+2,y1-y0+2); sqO.Visible=true end
        sq.Position=Vector2.new(x0,y0); sq.Size=Vector2.new(x1-x0,y1-y0); sq.Visible=true
        return x0,y0,x1,y1
    elseif style == "3D Box" then
        local pts = screenPts(corners)
        for i,edge in ipairs(EDGES) do
            local a,b=pts[edge[1]],pts[edge[2]]
            local function sL(l) l.From=Vector2.new(a.x,a.y); l.To=Vector2.new(b.x,b.y); l.Visible=true end
            if outl then sL(ln3dO[i]) end; sL(ln3d[i])
        end
        return screenBounds(corners)
    elseif style == "Corner 2D" then
        local x0,y0,x1,y1 = screenBounds(corners)
        if not x0 then return nil end
        local cL = math.max(4, math.min(x1-x0,y1-y0)*0.22)
        local segs = {
            {Vector2.new(x0,y0),Vector2.new(x0+cL,y0)},{Vector2.new(x0,y0),Vector2.new(x0,y0+cL)},
            {Vector2.new(x1,y0),Vector2.new(x1-cL,y0)},{Vector2.new(x1,y0),Vector2.new(x1,y0+cL)},
            {Vector2.new(x0,y1),Vector2.new(x0+cL,y1)},{Vector2.new(x0,y1),Vector2.new(x0,y1-cL)},
            {Vector2.new(x1,y1),Vector2.new(x1-cL,y1)},{Vector2.new(x1,y1),Vector2.new(x1,y1-cL)},
        }
        for i,seg in ipairs(segs) do
            local function sL(l) l.From=seg[1]; l.To=seg[2]; l.Visible=true end
            if outl then sL(cnr2dO[i]) end; sL(cnr2d[i])
        end
        return x0,y0,x1,y1
    elseif style == "Corner 3D" then
        local pts = screenPts(corners)
        for i,edge in ipairs(EDGES) do
            if i>12 then break end
            local a,b=pts[edge[1]],pts[edge[2]]
            local L=0.25
            local function sL(l)
                l.From=Vector2.new(a.x,a.y)
                l.To=Vector2.new(a.x+(b.x-a.x)*L,a.y+(b.y-a.y)*L)
                l.Visible=true
            end
            if outl then sL(cnr3dO[i]) end; sL(cnr3d[i])
        end
        return screenBounds(corners)
    end
    return nil
end

-- ============================================================
--  Кэши
-- ============================================================
local HLFolder = Instance.new("Folder")
HLFolder.Name="FatalityESP_HL"; HLFolder.Parent=workspace

local espCache   = {}
local vnCache    = {}
local buildCache = {}

local function makeEntry(modType)
    local col = ESP.Modules[modType].Color
    local th  = ESP.Modules[modType].Thickness
    local blk = Color3.new(0,0,0)
    local e = {
        modType = modType,
        box2d   = newSquare(col,th), boxOutl = newSquare(blk,th+2),
        ln3d={}, ln3dO={}, cnr2d={}, cnr2dO={}, cnr3d={}, cnr3dO={},
        txt       = newText(ESP.TextSize, ESP.TextColor),
        highlight = nil,
    }
    for i=1,12 do e.ln3d[i]=newLine(col,th);  e.ln3dO[i]=newLine(blk,th+2) end
    for i=1,8  do e.cnr2d[i]=newLine(col,th); e.cnr2dO[i]=newLine(blk,th+2) end
    for i=1,12 do e.cnr3d[i]=newLine(col,th); e.cnr3dO[i]=newLine(blk,th+2) end
    return e
end

local function hideEntry(e)
    e.box2d.Visible=false; e.boxOutl.Visible=false; e.txt.Visible=false
    for _,l in ipairs(e.ln3d)   do l.Visible=false end
    for _,l in ipairs(e.ln3dO)  do l.Visible=false end
    for _,l in ipairs(e.cnr2d)  do l.Visible=false end
    for _,l in ipairs(e.cnr2dO) do l.Visible=false end
    for _,l in ipairs(e.cnr3d)  do l.Visible=false end
    for _,l in ipairs(e.cnr3dO) do l.Visible=false end
    if e.highlight then e.highlight.Enabled=false end
end

local function removeEntry(e)
    hideEntry(e)
    e.box2d:Remove(); e.boxOutl:Remove(); e.txt:Remove()
    for _,l in ipairs(e.ln3d)   do l:Remove() end
    for _,l in ipairs(e.ln3dO)  do l:Remove() end
    for _,l in ipairs(e.cnr2d)  do l:Remove() end
    for _,l in ipairs(e.cnr2dO) do l:Remove() end
    for _,l in ipairs(e.cnr3d)  do l:Remove() end
    for _,l in ipairs(e.cnr3dO) do l:Remove() end
    if e.highlight then e.highlight:Destroy(); e.highlight=nil end
end

local function getOrMakeVNText(v)
    if not vnCache[v] then
        local t=Drawing.new("Text"); t.Outline=true; t.OutlineColor=Color3.new(0,0,0)
        t.Center=true; t.Visible=false; vnCache[v]=t
    end
    return vnCache[v]
end
local function removeVNText(v)
    if vnCache[v] then vnCache[v]:Remove(); vnCache[v]=nil end
end

local function getOrMakeBuildText(inst)
    if not buildCache[inst] then
        local t=Drawing.new("Text"); t.Outline=true; t.OutlineColor=Color3.new(0,0,0)
        t.Center=true; t.Visible=false; buildCache[inst]=t
    end
    return buildCache[inst]
end
local function removeBuildText(inst)
    if buildCache[inst] then buildCache[inst]:Remove(); buildCache[inst]=nil end
end

-- ============================================================
--  Рисование
-- ============================================================
local function drawEntry(e, inst)
    hideEntry(e)
    local modCfg = ESP.Modules[e.modType]
    if not modCfg.Enabled then return end
    if not inst or not inst.Parent or not inst:IsDescendantOf(workspace) then return end

    local cf, sz = getBoundingBox(inst)
    if not cf then return end

    local distStuds  = (Camera.CFrame.Position - cf.Position).Magnitude
    local distMeters = studsToMeters(distStuds)
    if distMeters > ESP.MaxDist then return end

    local corners = getCorners(cf, sz)
    local cp, onSc = Camera:WorldToViewportPoint(cf.Position)
    if not onSc or cp.Z <= 0 then return end

    local col = modCfg.Color
    local th  = modCfg.Thickness

    local x0,y0,x1,y1 = drawBox(
        ESP.BoxStyle, ESP.Outline, corners, col, th,
        e.box2d, e.boxOutl, e.ln3d, e.ln3dO, e.cnr2d, e.cnr2dO, e.cnr3d, e.cnr3dO
    )

    if ESP.HighlightEnabled then
        if not e.highlight then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = inst; hl.Parent = HLFolder
            e.highlight = hl
        end
        e.highlight.OutlineColor        = col
        e.highlight.FillColor           = ESP.HighlightFillColor
        e.highlight.FillTransparency    = ESP.HighlightFillTransp
        e.highlight.OutlineTransparency = ESP.HighlightOutlineTransp
        e.highlight.Enabled             = true
    else
        if e.highlight then e.highlight.Enabled=false end
    end

    e.txt.Size=ESP.TextSize; e.txt.Color=ESP.TextColor
    local label = ""
    if ESP.ShowName then label = inst.Name end
    if ESP.ShowDist then
        local dm = math.floor(distMeters)
        label = label ~= "" and (label.." ["..dm.."m]") or (dm.."m")
    end
    if label ~= "" and x0 then
        e.txt.Position = Vector2.new((x0+x1)*0.5, y0 - ESP.TextSize - 2)
        e.txt.Text = label; e.txt.Visible = true
    end
end

local function drawVehicleName(vehicle)
    local t = getOrMakeVNText(vehicle)
    t.Visible = false
    if not ESP.VehicleName.Enabled then return end
    if not vehicle or not vehicle.Parent then return end

    local ok, cf, sz = pcall(function() return vehicle:GetBoundingBox() end)
    if not ok or not sz then return end

    local distStuds  = (Camera.CFrame.Position - cf.Position).Magnitude
    local distMeters = studsToMeters(distStuds)
    if distMeters > ESP.MaxDist then return end

    local corners = getCorners(cf, sz)
    local x0,y0,x1,y1 = screenBounds(corners)
    if not x0 then return end

    local vn   = ESP.VehicleName
    t.Size     = vn.TextSize
    t.Color    = vn.Color
    t.Text     = vehicle.Name .. " [" .. math.floor(distMeters) .. "m]"
    t.Position = Vector2.new((x0+x1)*0.5, y0 - vn.TextSize - vn.Offset)
    t.Visible  = true
end

local function drawBuildText(inst)
    local t = getOrMakeBuildText(inst)
    t.Visible = false
    if not BuildESP.Enabled then return end
    if not inst or not inst.Parent or not inst:IsDescendantOf(workspace) then return end

    local cf, sz = getBoundingBox(inst)
    if not cf then return end

    local distStuds  = (Camera.CFrame.Position - cf.Position).Magnitude
    local distMeters = studsToMeters(distStuds)
    if distMeters > BuildESP.MaxDist then return end

    local corners = getCorners(cf, sz)
    local x0,y0,x1,y1 = screenBounds(corners)
    if not x0 then return end

    t.Size  = BuildESP.TextSize
    t.Color = BuildESP.Color
    local label = inst.Name
    if BuildESP.ShowDist then
        label = label .. " [" .. math.floor(distMeters) .. "m]"
    end
    t.Text     = label
    t.Position = Vector2.new((x0+x1)*0.5, y0 - BuildESP.TextSize - 3)
    t.Visible  = true
end

-- ============================================================
--  Сканирование целей
-- ============================================================
local function getTargets()
    local folder  = workspace:FindFirstChild("SpawnedVehicles")
    local modules = {}
    local vehicles= {}
    if not folder then return modules, vehicles end

    for _, vehicle in ipairs(folder:GetChildren()) do
        if not vehicle:IsA("Model") then continue end

        local team = getVehicleTeam(vehicle)
        if team ~= nil and ESP.TeamFilter[team] == false then continue end

        local dm = vehicle:FindFirstChild("DamageModules")
        if dm then
            local vehicleHasTarget = false
            for _, part in ipairs(dm:GetDescendants()) do
                if not part or not part.Parent then continue end
                if not (part:IsA("Model") or part:IsA("BasePart")) then continue end

                local mt = getModuleType(part.Name)
                if not mt then continue end

                local parentOk = part.Parent ~= nil
                    and part.Parent:IsDescendantOf(dm)
                    and part.Parent ~= dm
                if not parentOk then continue end

                if ESP.PropFilter[part.Name] == false then continue end

                modules[part] = { modType = mt, vehicle = vehicle }
                vehicleHasTarget = true
            end
            if vehicleHasTarget then vehicles[vehicle] = true end
        end

        local turret = vehicle:FindFirstChild("Turret1")
        if turret then
            local muzzle = turret:FindFirstChild("ATGMMuzzle")
            if muzzle then
                local atgmsFolder = muzzle:FindFirstChild("ATGMs")
                if atgmsFolder then
                    for _, missile in ipairs(atgmsFolder:GetChildren()) do
                        if missile and missile.Parent
                            and (missile:IsA("Model") or missile:IsA("BasePart")) then
                            modules[missile] = { modType = "ATGM", vehicle = vehicle }
                            vehicles[vehicle] = true
                        end
                    end
                end
            end
        end
    end
    return modules, vehicles
end

local function getBuildings()
    local folder = workspace:FindFirstChild("PlacedBuildings")
    local out = {}
    if not folder then return out end
    for _, inst in ipairs(folder:GetChildren()) do
        if inst and inst.Parent and (inst:IsA("Model") or inst:IsA("BasePart")) then
            out[inst] = true
        end
    end
    return out
end

-- ============================================================
--  RenderStepped loop
-- ============================================================
RunService.RenderStepped:Connect(function()
    for inst,entry in pairs(espCache) do
        if not inst or not inst.Parent or not inst:IsDescendantOf(workspace) then
            removeEntry(entry); espCache[inst]=nil
        end
    end
    for v in pairs(vnCache) do
        if not v or not v.Parent then removeVNText(v) end
    end
    for inst in pairs(buildCache) do
        if not inst or not inst.Parent then removeBuildText(inst); buildCache[inst]=nil end
    end

    local modules, vehicles = getTargets()
    local buildings = getBuildings()

    if not ESP.Enabled then
        for _,e in pairs(espCache) do hideEntry(e) end
        for _,t in pairs(vnCache)  do t.Visible=false end
    else
        for inst,e in pairs(espCache) do
            if not modules[inst] then removeEntry(e); espCache[inst]=nil end
        end
        for v in pairs(vnCache) do
            if not vehicles[v] then removeVNText(v) end
        end
        for inst,info in pairs(modules) do
            if not espCache[inst] then espCache[inst]=makeEntry(info.modType) end
            espCache[inst].modType = info.modType
            drawEntry(espCache[inst], inst)
        end
        for v in pairs(vehicles) do
            drawVehicleName(v)
        end
        for v,t in pairs(vnCache) do
            if not vehicles[v] then t.Visible=false end
        end
    end

    if not BuildESP.Enabled then
        for _,t in pairs(buildCache) do t.Visible=false end
    else
        for inst in pairs(buildCache) do
            if not buildings[inst] then removeBuildText(inst) end
        end
        for inst in pairs(buildings) do
            drawBuildText(inst)
        end
    end
end)

Notification:Notify({
    Title   = "VEHICLE ESP",
    Content = "Loaded! Enable ESP in VISUAL tab",
    Icon    = "check"
})
