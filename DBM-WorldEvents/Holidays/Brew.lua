local mod	= DBM:NewMod("Brew", "DBM-WorldEvents", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(15467)
--mod:SetModelID(15879)
--mod:SetReCombatTime(10)
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

mod:AddBoolOption("NormalizeVolume", false, "misc")

local setActive = false
local function CheckEventActive()
	local date = C_DateAndTime.GetCurrentCalendarTime()
	local month, day = date.month, date.monthDay
	if month == 9 then
		if day >= 20 then
			setActive = true
		end
	elseif month == 10 then
		if day < 7 then
			setActive = true
		end
	end
end
CheckEventActive()

--Volume normalizing or disabling for blizzard stupidly putting the area's music on DIALOG audio channel, making it blaringly loud
local function setDialog(self, set)
	if not self.Options.NormalizeVolume or not self.Options.Enabled then return end
	if set then
		local musicEnabled = GetCVarBool("Sound_EnableMusic") or true
		local musicVolume = tonumber(GetCVar("Sound_MusicVolume"))
		DBM.Options.RestoreBrewSoundVolume = tonumber(GetCVar("Sound_DialogVolume")) or 1
		if musicEnabled and musicVolume then--Normalize volume to music volume level
			DBM:Debug("Setting normalized volume to music volume of: "..musicVolume)
			SetCVar("Sound_DialogVolume", musicVolume)
		else--Just mute it
			DBM:Debug("Setting normalized volume to 0")
			SetCVar("Sound_DialogVolume", 0)
		end
	else
		if DBM.Options.RestoreBrewSoundVolume then
			DBM:Debug("Restoring Dialog volume to saved value of: "..DBM.Options.RestoreBrewSoundVolume)
			SetCVar("Sound_DialogVolume", DBM.Options.RestoreBrewSoundVolume)
			DBM.Options.RestoreBrewSoundVolume = nil
		end
	end
end

function mod:ZONE_CHANGED_NEW_AREA()
	if setActive then
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID == 27 or mapID == 1 then--Dun Morogh, Durotar
			setDialog(self, true)
		else
			setDialog(self)
		end
	else
		--Even if event isn't active. If a sound option was stored, restore it
		if DBM.Options.RestoreBrewSoundVolume then
			setDialog(self)
		end
	end
end
mod.OnInitialize = mod.ZONE_CHANGED_NEW_AREA
