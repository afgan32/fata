local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/afgan32/fata/refs/heads/main/src/source.luau?t=" .. tostring(tick())))();
Fatality:PrintUpdateVersion()
local Notification = Fatality:CreateNotifier();

Fatality:Loader({
	Name = "FATALITY",
	Duration = 4
});

Notification:Notify({
	Title = "FATALITY",
	Content = "Hello, "..game.Players.LocalPlayer.DisplayName..' Welcome back!',
	Icon = "clipboard"
})

local Window = Fatality.new({
	Name = "FATALITY",
	Expire = "never",
});

local Rage = Window:AddMenu({
	Name = "RAGE",
	Icon = "skull"
})

local Legit = Window:AddMenu({
	Name = "LEGIT",
	Icon = "target"
})

local Visual = Window:AddMenu({
	Name = "VISUAL",
	Icon = "eye"
})

local Misc = Window:AddMenu({
	Name = "MISC",
	Icon = "settings"
})

local Skins = Window:AddMenu({
	Name = "SKINS",
	Icon = "palette"
})

local Lua = Window:AddMenu({
	Name = "LUA",
	Icon = "code"
})

do
	local Weapon = Rage:AddSection({
		Position = 'left',
		Name = "WEAPON"
	});

	local Extra = Rage:AddSection({
		Position = 'center',
		Name = "EXTRA"
	});

	local General = Rage:AddSection({
		Position = 'right',
		Name = "GENERAL"
	});

	Weapon:AddSlider({
		Name = "Hit-chance",
		Default = 61
	})

	Weapon:AddSlider({
		Name = "Pointscale",
		Type = "%",
		Default = 0
	})

	Weapon:AddSlider({
		Name = "Min-damage",
		Type = "%",
		Default = 85
	})

	Weapon:AddDropdown({
		Name = "Hitboxes",
		Values = {"Head",'Neck','Arms','Legs'}
	})

	Weapon:AddDropdown({
		Name = "Multipoint",
		Values = {"Head",'Neck','Arms','Legs'}
	})

	Weapon:AddDropdown({
		Name = "Target selection",
		Values = {"Damage"},
		Default = "Damage"
	})

	local Autostop = Extra:AddToggle({
		Name = "Autostop",
		Option = true;
	});

	Autostop.Option:AddToggle({
		Name = "Something"
	})

	Autostop.Option:AddToggle({
		Name = "Something"
	})

	Autostop.Option:AddToggle({
		Name = "Something"
	})

	Autostop.Option:AddToggle({
		Name = "Something"
	})

	Extra:AddToggle({
		Name = "Autoscope",
	});

	Extra:AddToggle({
		Name = "Ignore limbs on moving",
	});

	Extra:AddToggle({
		Name = "Autorevolver",
	});

	General:AddToggle({
		Name = "Aimbot",
		Risky = true
	})

	General:AddToggle({
		Name = "Slient aim",
		Risky = false
	})

	General:AddSlider({
		Name = "Maximum fov",
		Type = " deg",
		Default = 0
	})

	General:AddToggle({
		Name = "Autofire",
		Risky = false
	})

	General:AddToggle({
		Name = "Delay shot",
		Risky = false
	})

	General:AddToggle({
		Name = "Duck peek assist",
		Risky = false
	})

	General:AddToggle({
		Name = "Force bodyaim",
		Risky = false
	})

	General:AddToggle({
		Name = "Force shoot",
		Risky = false
	})

	General:AddToggle({
		Name = "Headshot only",
		Risky = false
	})

	General:AddToggle({
		Name = "Knife bot",
		Risky = false
	})

	General:AddToggle({
		Name = "Zeus bot",
		Risky = false
	})

	local NoSpread = General:AddToggle({
		Name = "Nospread",
		Risky = false,
		Option = true
	})

	NoSpread.Option:AddToggle({
		Name = "Something"
	})

	NoSpread.Option:AddToggle({
		Name = "Something"
	})

	NoSpread.Option:AddToggle({
		Name = "Something"
	})

	NoSpread.Option:AddToggle({
		Name = "Something"
	})

	local Doubletap = General:AddToggle({
		Name = "Doubletap",
		Risky = true,
		Option = true
	})

	Doubletap.Option:AddToggle({
		Name = "Something"
	})

	Doubletap.Option:AddToggle({
		Name = "Something"
	})

	Doubletap.Option:AddToggle({
		Name = "Something"
	})

	Doubletap.Option:AddToggle({
		Name = "Something"
	})

	General:AddButton({
		Name = "Notification",
		Callback = function()
			Notification:Notify({
				Title = "Notification",
				Content = "Testing Notification",
				Duration = math.random(3,7),
				Icon = "info"
			})
		end,
	})
end

do
	local Aim = Legit:AddSection({
		Position = 'left',
		Name = "AIM"
	});

	local Rcs = Legit:AddSection({
		Position = 'left',
		Name = "RCS"
	});

	local Trigger = Legit:AddSection({
		Position = 'center',
		Name = "TRIGGER"
	});

	local Backtrack = Legit:AddSection({
		Position = 'center',
		Name = "BACKTRACK"
	});

	local General = Legit:AddSection({
		Position = 'right',
		Name = "GENERAL"
	});

	Aim:AddToggle({
		Name = "Aim assist"
	})

	Aim:AddDropdown({
		Name = "Mode",
		Default = "Adaptive",
		Values = {"Adaptive","value 1",'Value 2'}
	})

	Aim:AddDropdown({
		Name = "Hitboxes",
		Multi = true,
		Default = {
			["Head"] = true
		},
		Values = {
			"Head",
			'Neck',
			'Arms',
			'Legs'
		}
	})

	Aim:AddSlider({
		Name = "Multipoint"
	})

	Aim:AddSlider({
		Name = "Aim fov",
		Round = 1,
		Default = 0.1,
		Type = " deg"
	})

	Aim:AddSlider({
		Name = "Aim speed",
		Default = 1,
		Type = "%"
	})

	Aim:AddSlider({
		Name = "Min-damage",
		Default = 61,
	})


	Aim:AddToggle({
		Name = "Only in scpoe"
	})


	Aim:AddToggle({
		Name = "Autostop"
	})

	Rcs:AddToggle({
		Name = "Recoil control"
	})

	Rcs:AddSlider({
		Name = "Speed",
		Default = 1,
		Type = "%"
	})


	Rcs:AddToggle({
		Name = "Re-center"
	})


	Rcs:AddSlider({
		Name = "Start bullet",
		Default = 1,
	})

	Trigger:AddToggle({
		Name = "Triggerbot"
	})

	Trigger:AddSlider({
		Name = "Hit-chance",
		Default = 100,
		Type = "%"
	})

	Trigger:AddToggle({
		Name = "Use seed when available"
	})

	Trigger:AddSlider({
		Name = "Min-damage",
		Default = 0,
		Type = "%"
	})

	Trigger:AddSlider({
		Name = "Reaction time",
		Default = 0,
		Type = "ms"
	})

	Trigger:AddToggle({
		Name = "Wait for aim assist hitgroup"
	})

	Trigger:AddToggle({
		Name = "Only in Scope"
	})

	Backtrack:AddSlider({
		Name = "Backtrack",
		Default = 0,
		Type = "%"
	})

	General:AddToggle({
		Name = "Enabled"
	})

	General:AddDropdown({
		Name = "Disablers",
		Values = {"d1",'d2'}
	})

	General:AddToggle({
		Name = "Visualize fov",
		Option = true
	}).Option:AddColorPicker({
		Name = "Color",
		Default = Color3.fromRGB(255, 34, 75)
	})

	General:AddToggle({
		Name = "Autorevolver"
	})
end

do
	local SubTabs = Visual:AddSubTabs({"Local", "Enemy", "Team", "World"})

	-- Local sub-tab
	local LocalMisc = SubTabs["Local"]:AddSection({
		Name = "MISC",
		Position = 'left'
	})

	local LocalModel = SubTabs["Local"]:AddSection({
		Name = "MODEL",
		Position = 'center'
	})

	local LocalExtra = SubTabs["Local"]:AddSection({
		Name = "EXTRA",
		Position = 'right'
	})

	LocalExtra:AddToggle({ Name = "Test Toggle 1" })
	LocalExtra:AddToggle({ Name = "Test Toggle 2" })
	LocalExtra:AddSlider({ Name = "Test Slider" })

	LocalMisc:AddToggle({
		Name = "Thirdperson",
		Option = true
	}).Option:AddSlider({
		Name = "Distance"
	});

	LocalMisc:AddToggle({
		Name = "Overhead override",
		Option = true
	}).Option:AddDropdown({
		Name = "Override"
	});

	LocalMisc:AddToggle({
		Name = "Fov override",
		Option = true
	}).Option:AddToggle({
		Name = "Something"
	})

	LocalMisc:AddToggle({
		Name = "Viewmodel override",
		Option = true
	}).Option:AddToggle({
		Name = "Something"
	})

	LocalMisc:AddDropdown({
		Name = "Remove scope"
	})

	local pc = LocalMisc:AddToggle({
		Name = "Penetration crosshair",
		Option = true
	}).Option;

	pc:AddColorPicker({
		Name = "Walls",
		Default = Color3.fromRGB(111, 255, 0)
	})

	pc:AddColorPicker({
		Name = "Can't walls",
		Default = Color3.fromRGB(255, 0, 4)
	})

	LocalMisc:AddToggle({
		Name = "Force crosshair",
		Option = true
	}).Option:AddToggle({
		Name = "Something"
	})

	LocalMisc:AddDropdown({
		Name = "Spread"
	})

	LocalMisc:AddToggle({
		Name = "Bullet tracer",
		Option = true
	}).Option:AddColorPicker({
		Name = "Color",
		Default = Color3.fromRGB(255, 41, 116)
	})

	LocalModel:AddDropdown({
		Name = "Visible",
		Default = "Disabled",
		Values = {"Disabled",'Something'}
	})

	LocalModel:AddDropdown({
		Name = "Invisible",
		Default = "Disabled",
		Values = {"Disabled",'Something'}
	})

	LocalModel:AddDropdown({
		Name = "Arms",
		Default = "Disabled",
		Values = {"Disabled",'Something'}
	})

	LocalModel:AddDropdown({
		Name = "Viewmodel",
		Default = "Disabled",
		Values = {"Disabled",'Something'}
	})

	LocalModel:AddDropdown({
		Name = "Attachments",
		Default = "Disabled",
		Values = {"Disabled",'Something'}
	})

	LocalModel:AddToggle({
		Name = 'Glow',
		Option = true
	}).Option:AddColorPicker({
		Name = "Color"
	})

	LocalModel:AddKeybind({
		Name = "Toggle"
	})

	-- Enemy sub-tab
	local EnemyGeneral = SubTabs["Enemy"]:AddSection({
		Name = "GENERAL",
		Position = 'left'
	})

	local EnemyESP = SubTabs["Enemy"]:AddSection({
		Name = "ESP",
		Position = 'center'
	})

	EnemyGeneral:AddToggle({ Name = "Enabled" })

	EnemyESP:AddToggle({ Name = "Name" })
	EnemyESP:AddToggle({ Name = "Box", Option = true }).Option:AddColorPicker({
		Name = "Color",
		Default = Color3.fromRGB(255, 75, 75)
	})
	EnemyESP:AddToggle({ Name = "Health" })
	EnemyESP:AddToggle({ Name = "Skeleton" })

	-- Team sub-tab
	local TeamGeneral = SubTabs["Team"]:AddSection({
		Name = "GENERAL",
		Position = 'left'
	})
	TeamGeneral:AddToggle({ Name = "Enabled" })
	TeamGeneral:AddToggle({ Name = "Name" })

	-- World sub-tab
	local WorldGeneral = SubTabs["World"]:AddSection({
		Name = "GENERAL",
		Position = 'left'
	})
	WorldGeneral:AddToggle({ Name = "Enabled" })
	WorldGeneral:AddToggle({ Name = "Item name" })
	WorldGeneral:AddToggle({ Name = "Item icon" })
end

do
	local Settings = Misc:AddSection({
		Name = "SETTINGS",
		Position = 'left'
	})

	Settings:AddSlider({
		Name = "DPI Scale",
		Default = 1.1,
		Min = 0.5,
		Max = 1.5,
		Round = 1,
		ApplyOnRelease = true,
		Callback = function(v)
			if typeof(Fatality.SetGlobalDPIScale) == "function" then
				Fatality:SetGlobalDPIScale(v)
			end
		end
	})

	Settings:AddSlider({
		Name = "Menu Width",
		Default = 780,
		Min = 500,
		Max = 1100,
		Round = 0,
		Callback = function(v)
			Window:SetSize(v, nil)
		end
	})

	Settings:AddSlider({
		Name = "Menu Height",
		Default = 540,
		Min = 350,
		Max = 750,
		Round = 0,
		Callback = function(v)
			Window:SetSize(nil, v)
		end
	})

	Settings:AddSlider({
		Name = "Menu Position X",
		Default = 50,
		Min = 0,
		Max = 100,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Window:SetPosition(v / 100, nil)
		end
	})

	Settings:AddSlider({
		Name = "Menu Position Y",
		Default = 20,
		Min = 0,
		Max = 90,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Window:SetPosition(nil, v / 100)
		end
	})

	Settings:AddSlider({
		Name = "Header Height",
		Default = 48,
		Min = 28,
		Max = 70,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Window:SetHeaderHeight(v)
		end
	})

	Settings:AddSlider({
		Name = "Section Column Width",
		Default = 31,
		Min = 20,
		Max = 45,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Window:SetSectionColumnWidth(v / 100)
		end
	})

	Settings:AddSlider({
		Name = "Sub-Tab Column Width",
		Default = 27,
		Min = 20,
		Max = 45,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetSubTabColumnWidth(v / 100)
		end
	})

	Settings:AddSlider({
		Name = "Section Y Spacing",
		Default = 14,
		Min = 0,
		Max = 40,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetSectionPadding(v)
		end
	})

	Settings:AddSlider({
		Name = "Slider Width",
		Default = 88,
		Min = 50,
		Max = 150,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetGlobalSliderWidth(v)
		end
	})

	Settings:AddSlider({
		Name = "Slider Height",
		Default = 14,
		Min = 6,
		Max = 20,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetGlobalSliderHeight(v)
		end
	})

	Settings:AddSlider({
		Name = "Combobox Width",
		Default = 88,
		Min = 40,
		Max = 130,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetGlobalDropdownWidth(v)
		end
	})

	Settings:AddSlider({
		Name = "Combobox Height",
		Default = 20,
		Min = 12,
		Max = 36,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetGlobalDropdownHeight(v)
		end
	})

	Settings:AddSlider({
		Name = "Section Name Y Offset",
		Default = -8,
		Min = -30,
		Max = 10,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetSectionNameYOffset(v)
		end
	})

	Settings:AddSlider({
		Name = "Section Name X Offset",
		Default = 10,
		Min = -20,
		Max = 50,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetSectionNameXOffset(v)
		end
	})

	Settings:AddSlider({
		Name = "Section Name Size",
		Default = 12,
		Min = 8,
		Max = 20,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetSectionNameTextSize(v)
		end
	})

	Settings:AddSlider({
		Name = "Checkbox Scale",
		Default = 90,
		Min = 40,
		Max = 100,
		Round = 0,
		Suffix = "%",
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetCheckboxScale(v / 100)
		end
	})

	Settings:AddSlider({
		Name = "Settings Icon Scale",
		Default = 92,
		Min = 40,
		Max = 100,
		Round = 0,
		Suffix = "%",
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetOptionIconScale(v / 100)
		end
	})

	Settings:AddSlider({
		Name = "Dropdown Popup X Offset",
		Default = 0,
		Min = -50,
		Max = 50,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetDropdownPopupXOffset(v)
		end
	})

	Settings:AddSlider({
		Name = "Keybind Slider X Offset",
		Default = 36,
		Min = -20,
		Max = 150,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality.KeybindSliderXOffset = v
		end
	})

	Settings:AddSlider({
		Name = "Keybind Slider Y Offset",
		Default = 0,
		Min = -40,
		Max = 40,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality.KeybindSliderYOffset = v
		end
	})

	Settings:AddSlider({
		Name = "Keybind Checkbox X Offset",
		Default = 78,
		Min = -20,
		Max = 150,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality.KeybindCheckboxXOffset = v
		end
	})

	Settings:AddSlider({
		Name = "Keybind Checkbox Y Offset",
		Default = 0,
		Min = -40,
		Max = 40,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality.KeybindCheckboxYOffset = v
		end
	})

	Settings:AddSlider({
		Name = "Sub-Tab Area Width",
		Default = 105,
		Min = 40,
		Max = 150,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetSubTabWidth(v)
		end
	})

	local TabNames = Misc:AddSection({
		Name = "TAB NAMES",
		Position = 'center'
	})

	TabNames:AddSlider({
		Name = "Name Size",
		Default = 11,
		Min = 5,
		Max = 25,
		Round = 0,
		ApplyOnRelease = true,
		Callback = function(v)
			Fatality:SetMenuLabelTextSize(v)
		end
	})

	local menusCenter = {"RAGE", "LEGIT", "VISUAL"}
	for _, menuName in ipairs(menusCenter) do
		local sec = Misc:AddSection({
			Name = menuName .. " ICON",
			Position = 'center'
		})
		sec:AddSlider({
			Name = "Size X",
			Default = 20,
			Min = 5,
			Max = 50,
			Round = 0,
			ApplyOnRelease = true,
			Callback = function(v)
				local y = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.Y.Offset or 20
				if y == 0 then y = 20 end
				Fatality:SetMenuIconSize(menuName, v, y)
			end
		})
		sec:AddSlider({
			Name = "Size Y",
			Default = 20,
			Min = 5,
			Max = 50,
			Round = 0,
			ApplyOnRelease = true,
			Callback = function(v)
				local x = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.X.Offset or 20
				if x == 0 then x = 20 end
				Fatality:SetMenuIconSize(menuName, x, v)
			end
		})
		sec:AddSlider({
			Name = "Position X",
			Default = 5,
			Min = 0,
			Max = 30,
			Round = 0,
			ApplyOnRelease = true,
			Callback = function(v)
				Fatality:SetMenuIconPositionX(menuName, v)
			end
		})
	end

	local menusRight = {"MISC", "SKINS", "LUA"}
	for _, menuName in ipairs(menusRight) do
		local sec = Misc:AddSection({
			Name = menuName .. " ICON",
			Position = 'right'
		})
		sec:AddSlider({
			Name = "Size X",
			Default = 20,
			Min = 5,
			Max = 50,
			Round = 0,
			ApplyOnRelease = true,
			Callback = function(v)
				local y = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.Y.Offset or 20
				if y == 0 then y = 20 end
				Fatality:SetMenuIconSize(menuName, v, y)
			end
		})
		sec:AddSlider({
			Name = "Size Y",
			Default = 20,
			Min = 5,
			Max = 50,
			Round = 0,
			ApplyOnRelease = true,
			Callback = function(v)
				local x = Fatality.MenuIcons[menuName] and Fatality.MenuIcons[menuName].Size.X.Offset or 20
				if x == 0 then x = 20 end
				Fatality:SetMenuIconSize(menuName, x, v)
			end
		})
		sec:AddSlider({
			Name = "Position X",
			Default = 5,
			Min = 0,
			Max = 30,
			Round = 0,
			ApplyOnRelease = true,
			Callback = function(v)
				Fatality:SetMenuIconPositionX(menuName, v)
			end
		})
	end
end
