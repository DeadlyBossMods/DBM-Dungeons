local mod	= DBM:NewMod(114, "DBM-Party-Cataclysm", 8, 68)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43878)
mod:SetEncounterID(1043)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 86340",
	"RAID_BOSS_EMOTE"
)

local warnSummonTempest		= mod:NewSpellAnnounce(86340, 2)

local timerSummonTempest	= mod:NewCDTimer(16.8, 86340, nil, nil, nil, 1)--16.8 old
local timerShield			= mod:NewNextTimer(30.5, 86292, nil, nil, nil, 6)

function mod:OnCombatStart(delay)
	timerSummonTempest:Start(self:IsMythicPlus() and 7.2 or 16.8-delay)
	timerShield:Start(23.3-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 86340 then
		warnSummonTempest:Show()
		timerSummonTempest:Start(self:IsMythicPlus() and 18.2 or 16.8)
	end
end

function mod:RAID_BOSS_EMOTE(msg)
	if msg == L.Retract or msg:find(L.Retract) then
		timerShield:Start()
	end
end
