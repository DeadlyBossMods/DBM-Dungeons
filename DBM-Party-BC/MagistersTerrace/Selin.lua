local mod = DBM:NewMod(530, "DBM-Party-BC", 16, 249)
local L = mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(24723)
mod:SetEncounterID(1897)

--if not mod:IsRetail() then
--	mod:SetModelID(22731)--Unknown, two bosses have same ID
--end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 44320"
)

local specWarnChannel		= mod:NewSpecialWarning("warningFelCrystal", "-Healer", nil, nil, 1, 2)--(-5081)

local timerChannelCD		= mod:NewTimer(47, "timerFelCrystal", 44320, nil, nil, 1)--(-5081)

function mod:OnCombatStart(delay)
	timerChannelCD:Start(12.8-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 44320 then--Mana Rage, triggers right before CHAT_MSG_RAID_BOSS_EMOTE
		specWarnChannel:Show()
		specWarnChannel:Play("targetchange")
		timerChannelCD:Start()
	end
end
