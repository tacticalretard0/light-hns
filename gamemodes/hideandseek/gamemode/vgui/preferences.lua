local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 400)
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:DockPadding(0, 24, 0, 0)
	-- New close button
	self.CB = self:Add("DButton")
	self.CB:SetSize(24, 24)
	self.CB:SetPos(476, 0)
	self.CB:SetText("")
	self.CB.DoClick = function()
		self:Close()
	end
	self.CB.Paint = function(this, w, h)
		GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(0, 0, 0, 125))
		draw.SimpleText("r", "Marlett", w / 2 + 1, h / 2 + 1, Color(0, 0, 0, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("r", "Marlett", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	-- "Tabs" bar
	self.TabsP = self:Add("DPanel")
	self.TabsP:Dock(TOP)
	self.TabsP.Paint = function() end

	self.Buttons = {}

	-- Buttons to toggle panels
	local texts = { "INTERFACE", "PLAYER MODEL", "CROSSHAIR", "PLACEHOLDER" }
	local tabs = { "HNS.PreferencesHUD", "DPanel", "DPanel", "DPanel" }
	-- Create panel
	for i, text in ipairs(texts) do
		local button = self.TabsP:Add("DButton")
		button:Dock(LEFT)
		button:SetWide(125)
		button:SetText("")
		-- Panel that the button will show
		button.Panel = self:Add(tabs[i])
		button.Panel:Dock(FILL)
		button.Panel:Hide()
		-- Funcs
		button.Paint = function(this, w, h)
			surface.SetDrawColor(self:GetTheme(2))
			surface.DrawRect(0, 0, w, h)
			GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, self:GetTint(), 6, function(s) return s.Active end)

			draw.SimpleText(text, "HNS.RobotoSmall", w / 2 + 1, h / 2 + 1, Color(0, 0, 0, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(text, "HNS.RobotoSmall", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		button.DoClick = function(this)
			-- Hide other panels
			for _, v in ipairs(self.Buttons) do
				if v == this then
					v.Active = true
					v.Panel:Show()
				else
					v.Active = false
					v.Panel:Hide()
				end
			end
		end

		button.GetTheme = self.GetTheme
		button.GetTint = self.GetTint
		button.Panel.GetTheme = self.GetTheme
		button.Panel.GetTint = self.GetTint

		table.insert(self.Buttons, button)

		-- Show first panel
		if i == 1 then
			button:DoClick()
		end
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetTheme(1))
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self:GetTint())
	surface.DrawRect(0, 0, w, 24)
	draw.SimpleText("LHNS - PLAYER PREFERENCES", "HNS.RobotoSmall", 9, 13, Color(0, 0, 0, 175), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("LHNS - PLAYER PREFERENCES", "HNS.RobotoSmall", 8, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Should return HiderColor, SeekerColor or Specator color
function PANEL:GetTint()
	if LocalPlayer():Team() == TEAM_HIDE then
		return GAMEMODE:GetTeamShade(TEAM_HIDE, GAMEMODE.CVars.HiderColor:GetString())
	elseif LocalPlayer():Team() == TEAM_SEEK then
		return GAMEMODE:GetTeamShade(TEAM_SEEK, GAMEMODE.CVars.SeekerColor:GetString())
	else
		return team.GetColor(LocalPlayer():Team())
	end
end

-- Differences between themes
local light = {
	Color(255, 255, 255), -- BG
	Color(125, 125, 125), -- Header
	Color(0, 0, 0), -- Text
}

local dark = {
	Color(25, 25, 25), -- BG
	Color(50, 50, 50), -- Header
	Color(255, 255, 255), -- Text
}

function PANEL:GetTheme(i)
	if GAMEMODE.CVars.DarkTheme:GetBool() then
		return dark[i] || Color(0, 0, 0)
	else
		return light[i] || Color(255, 255, 255)
	end
end

vgui.Register("HNS.Preferences", PANEL, "DFrame")
timer.Simple(0.1, function()
	vgui.Create("HNS.Preferences", PANEL, "DFrame")
end)

-- HUD settings panel
PANEL = {}

function PANEL:Init()
	self:DockPadding(0, 10, 0, 6)
	-- Container
	self.SP = self:Add("DScrollPanel")
	self.SP:Dock(FILL)
	-- HUD selection
	self.HUD = self:AddSlider(124, 124)
	self.HUD.Paint = function(this, w, h)
		-- Text
		draw.SimpleText("HUD SELECTION", "HNS.RobotoSmall", 65, 1, Color(0, 0, 0, 125), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("HUD SELECTION", "HNS.RobotoSmall", 64, 0, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		-- Selected name
		local hud = GAMEMODE.HUDs[GAMEMODE.CVars.HUD:GetInt()]
		if hud then
			draw.SimpleText(hud.Name:upper(), "HNS.RobotoSmall", w - 116, 1, Color(0, 0, 0, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(hud.Name:upper(), "HNS.RobotoSmall", w - 116, 0, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
	-- Values
	self.HUD.Slider:SetMinMax(1, #GAMEMODE.HUDs)
	self.HUD.Slider:SetValue(GAMEMODE.CVars.HUD:GetInt())
	self.HUD.Slider:SetDecimals(0)
	self.HUD.Slider.OnValueChanged = function(this, value)
		value = math.Round(value)
		this:SetValue(value)
		-- Update HUD and text
		GAMEMODE.CVars.HUD:SetInt(value)
	end

	-- HUD Scaling
	self.Scale = self:AddSlider(124, 124)
	self.Scale.Paint = function(this, w, h)
		-- Text
		draw.SimpleText("HUD SCALING", "HNS.RobotoSmall", 65, 1, Color(0, 0, 0, 125), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("HUD SCALING", "HNS.RobotoSmall", 64, 0, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		-- Selected name
		draw.SimpleText(GAMEMODE.CVars.HUDScale:GetInt(), "HNS.RobotoSmall", w - 116, 1, Color(0, 0, 0, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(GAMEMODE.CVars.HUDScale:GetInt(), "HNS.RobotoSmall", w - 116, 0, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	-- Values
	self.Scale.Slider:SetMinMax(1, 6)
	self.Scale.Slider:SetValue(GAMEMODE.CVars.HUDScale:GetInt())
	self.Scale.Slider:SetDecimals(0)
	self.Scale.Slider.OnValueChanged = function(this, value)
		value = math.Round(value)
		this:SetValue(value)
		-- Update HUD and text
		GAMEMODE.CVars.HUDScale:SetInt(value)
	end

	-- Checkboxs
	self:AddCheckbox("ENABLE DARK THEME", "has_darktheme", 124)
	self:AddCheckbox("SHOW OTHER PLAYERS' STEAM ID", "has_showid", 124)
	self:AddCheckbox("PUT YOURSELF AT THE TOP OF THE SCOREBOARD (TODO)", "has_scob_ontop", 124)
	-- Speed and its wangs
	self.Speed = self:AddCheckbox("SHOW MOVEMENT SPEED (X Y):", "has_showspeed", 124)
	-- Panel that prevents button click
	self.Speed.Panel = self.Speed:Add("DPanel")
	self.Speed.Panel:Dock(FILL)
	self.Speed.Panel:DockMargin(290, 0, 0, 0)
	self.Speed.Panel.Paint = function() end
	-- Wangs
	self.Speed.SpeedX = self.Speed.Panel:Add("DNumberWang")
	self.Speed.SpeedX:SetPos(0, 1)
	self.Speed.SpeedX:SetSize(50, 22)
	self.Speed.SpeedX:SetMinMax(45, ScrW() - 45)
	self.Speed.SpeedX:SetValue(GAMEMODE.CVars.SpeedX:GetInt())
	self.Speed.SpeedX:SetConVar("has_speedx")

	self.Speed.SpeedY = self.Speed.Panel:Add("DNumberWang")
	self.Speed.SpeedY:SetPos(54, 1)
	self.Speed.SpeedY:SetSize(50, 22)
	self.Speed.SpeedY:SetMinMax(30, ScrH() - 30)
	self.Speed.SpeedY:SetValue(GAMEMODE.CVars.SpeedY:GetInt())
	self.Speed.SpeedY:SetConVar("has_speedy")

	-- Center button
	self.Speed.SpeedC = self.Speed.Panel:Add("DButton")
	self.Speed.SpeedC:SetPos(108, 1)
	self.Speed.SpeedC:SetSize(50, 22)
	self.Speed.SpeedC:SetText("Center")
	self.Speed.SpeedC.DoClick = function()
		self.Speed.SpeedX:SetValue(ScrW() / 2)
		self.Speed.SpeedY:SetValue(ScrH() / 2)
	end
	-- Enable/Disable
	self.Speed.SpeedX:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Speed.SpeedY:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Speed.SpeedC:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Speed.OnChangeAdditional = function(this, value)
		self.Speed.SpeedX:SetEnabled(value)
		self.Speed.SpeedY:SetEnabled(value)
		self.Speed.SpeedC:SetEnabled(value)
	end
end

function PANEL:AddSlider(offsetx, offsety)
	local panel = self.SP:Add("DPanel")
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 0, 6)
	-- Slider
	panel.Slider = panel:Add("DNumSlider")
	panel.Slider:Dock(FILL)
	panel.Slider:DockMargin(offsetx, 0, offsety, 0)
	-- Disable all elements besides the slider
	panel.Slider.Label:Hide()
	panel.Slider.TextArea:Hide()
	-- Make slider fancier
	panel.Slider.Paint = function(this, w, h)
		surface.SetDrawColor(self:GetTint())
		surface.DrawLine(7, h / 2, w - 7, h / 2)

		local space = (w - 16) / (panel.Slider:GetMax() - 1)
		-- Lines
		for i = 0, panel.Slider:GetMax() do
			surface.DrawRect(8 + space * i, h / 2 + 2, 1, 4)
		end
	end

	return panel
end

function PANEL:AddCheckbox(text, cvar, offsetx)
	local panel = self.SP:Add("DButton")
	panel:Dock(TOP)
	panel:SetTall(24)
	panel:SetText("")
	panel:DockMargin(0, 0, 0, 6)
	-- Cache cvar
	panel.CVar = GetConVar(cvar)
	-- Funcs
	panel.Paint = function(this, w, h)
		draw.SimpleText(text, "HNS.RobotoSmall", 65, h / 2 + 2, Color(0, 0, 0, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "HNS.RobotoSmall", 64, h / 2 + 1, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		GAMEMODE.DUtils.Outline(24, 0, 24, 24, 2, self:GetTint())
		GAMEMODE.DUtils.FadeHover(this, 1, 28, 4, 16, h - 8, self:GetTint(), 6, function(s) return s.CVar:GetBool() end)
	end
	panel.DoClick = function(this)
		this.CVar:SetBool(!this.CVar:GetBool())
		this.OnChangeAdditional(this, this.CVar:GetBool())
	end

	return panel
end

function PANEL:Paint() end

vgui.Register("HNS.PreferencesHUD", PANEL, "DPanel")