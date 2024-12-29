if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("DestructorsWraith", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3028)
mod:SetCreatureID(228022)
mod:SetZone(2784)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 462222 460401"
)

local specWarnNova		= mod:NewSpecialWarningDodge(460401, nil, nil, nil, 2, 2)
local specWarnShockwave	= mod:NewSpecialWarningDodge(462222, nil, nil, nil, 2, 2)

local timerShockwave	= mod:NewCastCountTimer(2, 462222, nil, nil, nil, 5)
local timerShockwaveCD	= mod:NewCDTimer(28, 462222, nil, nil, nil, 3)
local timerNova			= mod:NewCastTimer(4, 460401, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerShockwaveCD:Start(16 - delay)
end

-- Destructor's Devastation happens 3 times in a row with 3 different spell ids:
-- 462222, 462160, 461761 in that order, 2.5 sec cast, 0.5 sec delay
-- "Destructor's Devastation-461761-npc:228022-0000142E02 = pull:23.8, 25.9, 35.6",
-- "Destructor's Devastation-462160-npc:228022-0000142E02 = pull:20.8, 25.9, 35.6",
-- "Destructor's Devastation-462222-npc:228022-0000142E02 = pull:17.8, 25.9, 35.7",
-- Wowhead claims that this is always followed by Nova, but that isn't true, Nova can happen independently:
-- "Nether Nova-460401-npc:228022-0000142E02 = pull:32.4, 42.1",

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(462222) then
		specWarnShockwave:Play("shockwave")
		timerShockwave:Start(2.5, 1)
		timerShockwave:Start(5.5, 2)
		timerShockwave:Start(8.5, 3)
		timerShockwaveCD:Start()
	elseif args:IsSpellID(460401) then
		timerNova:Start()
		specWarnNova:Show()
		specWarnNova:Play("justrun")
	end
end
