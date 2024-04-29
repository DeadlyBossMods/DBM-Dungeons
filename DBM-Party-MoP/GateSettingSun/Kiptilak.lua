local mod	= DBM:NewMod(655, "DBM-Party-MoP", 4, 303)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56906)
mod:SetEncounterID(1397)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 107268",
	"SPELL_AURA_REMOVED 107268"
)


local warnSabotage				= mod:NewTargetAnnounce(107268, 4)
--local warnThrowExplosive		= mod:NewSpellAnnounce(102569, 3)--Doesn't show in chat/combat log, need transcriptor log
--local warnWorldinFlame		= mod:NewSpellAnnounce(101591, 4)--^, triggered at 66% and 33% boss health.

local specWarnSabotage			= mod:NewSpecialWarningYou(107268, nil, nil, nil, 1, 2)
local specWarnSabotageNear		= mod:NewSpecialWarningClose(107268, nil, nil, nil, 1, 2)

local timerSabotage				= mod:NewTargetTimer(5, 107268, nil, nil, nil, 5)
local timerSabotageCD			= mod:NewNextTimer(12, 107268, nil, nil, nil, 3)
--local timerThrowExplosiveCD	= mod:NewNextTimer(22, 102569)

mod:AddSetIconOption("IconOnSabotage", 107268, true, 0, {8})

function mod:OnCombatStart(delay)
--	timerSabotageCD:Start(-delay)--Unknown, tank pulled before log got started, will need a fresh log.
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 107268 then
		timerSabotage:Start(args.destName)
		timerSabotageCD:Start()
		if self.Options.IconOnSabotage then
			self:SetIcon(args.destName, 8)
		end
		if args:IsPlayer() then
			specWarnSabotage:Show()
			specWarnSabotage:Play("targetyou")
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = DBM.RangeCheck:GetDistance("player", uId)
				if inRange and inRange < 10 then
					specWarnSabotageNear:Show(args.destName)
					specWarnSabotageNear:Play("runaway")
				else
					warnSabotage:Show(args.destName)
				end
			end
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 107268 then
		timerSabotage:Cancel(args.destName)
		if self.Options.IconOnSabotage then
			self:SetIcon(args.destName, 0)
		end
	end
end
