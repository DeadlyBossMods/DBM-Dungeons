local mod	= DBM:NewMod("DestructorsWraith", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3028)
--mod:SetCreatureID(4275)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 462222"
--	"SPELL_CAST_SUCCESS,
--	"SPELL_AURA_APPLIED"
)

local timerShockwave	= mod:NewCastCountTimer(2, 462222)
local timerShockwaveCD	= mod:NewCDTimer(28, 462222)
local timerNova			= mod:NewCastTimer(11.3, 460401)

local specWarnNova		= mod:NewSpecialWarningDodge(460401, nil, nil, 1, 2)
local specWarnShockwave	= mod:NewSpecialWarningDodge(462222, nil, nil, nil, 1, 2)

function mod:OnCombatStart(delay)
	timerShockwaveCD:Start(16 - delay)
end

-- Destructor's Devastation happens 3 times in a row with 3 different spell ids:
-- 462222, 462160, 461761 in that order, 2 sec cast, 1 sec delay
-- "Destructor's Devastation-462222-npc:228022-000012DAD5 = pull:18.2, 35.5, 29.1",
-- "Destructor's Devastation-462222-npc:228022-000012D5C6 = pull:16.2",
-- It's then always followed by Nova
-- "Nether Nova-460401-npc:228022-000012D5C6 = pull:27.5",

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(462222) then
		specWarnShockwave:Play("shockwave")
		timerShockwave:Start(2, 1)
		timerShockwave:Start(5, 2)
		timerShockwave:Start(8, 3)
		timerNova:Start()
		timerShockwaveCD:Start()
		specWarnNova:Schedule(8.5) -- Half a second after the shock wave so no one mistakes it for a shock wave warning
	end
end
