GM.HiderColors = {
	["Default"] = Color(0, 50, 175),
	["Full Blue"] = Color(0, 0, 255),
	["Dark Blue"] = Color(0, 0, 175),
	["Light Blue"] = Color(20, 130, 200),
	["Shark"] = Color(75, 150, 225),
	["Super Light Blue"] = Color(0, 255, 255),
}

GM.SeekerColors = {
	["Default"] = Color(175, 75, 50),
	["Full Red"] = Color(255, 0, 0),
	["Dark Red"] = Color(175, 0, 0),
	["Crimson"] = Color(220, 20, 60),
	["Pink"] = Color(255, 105, 180),
	["Rose"] = Color(255, 0, 130),
}

-- Get a valid color shade for a team
function GM:GetTeamColor(t, k) -- team, key
	if t == TEAM_HIDE then
		-- If the key is an invalid color, just return the default one
		return self.HiderColors[k] || self.HiderColors.Default
	elseif t == TEAM_SEEK then
		return self.SeekerColors[k] || self.SeekerColors.Default
	else
		-- Throw error to identify issues
		error("Invalid team! (Got: " .. t .. ")")
	end
end

-- Wrapper for GM:GetTeamColor
function GM:GetPlayerTeamColor(ply)
	if ply:Team() == TEAM_HIDE then
		if SERVER then
			return self:GetTeamColor(TEAM_HIDE, ply:GetInfo("has_hidercolor", "Default"))
		else
			return self:GetTeamColor(TEAM_HIDE, GetConVar("has_hidercolor"):GetString())
		end
	elseif ply:Team() == TEAM_SEEK then
		if SERVER then
			return self:GetTeamColor(TEAM_SEEK, ply:GetInfo("has_seekercolor", "Default"))
		else
			return self:GetTeamColor(TEAM_SEEK, GetConVar("has_seekercolor"):GetString())
		end
	end
end