local mod	= DBM:NewMod(177, "DBM-Party-Cataclysm", 11, 76, 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(52258)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_EMOTE"
)

local warnPursuit				= mod:NewTargetNoFilterAnnounce(96306, 4)
local warnRupture				= mod:NewTargetNoFilterAnnounce(96619, 3)

local specWarnPursuit			= mod:NewSpecialWarningRun(96306, nil, nil, 2, 4, 2)
local specWarnRupture			= mod:NewSpecialWarningYou(96619, nil, nil, nil, 1, 2)
local specWarnRuptureNear		= mod:NewSpecialWarningClose(96619, nil, nil, nil, 1, 2)

local timerPursuit				= mod:NewBuffActiveTimer(15, 96306, nil, nil, nil, 5)
local timerPursuitCD			= mod:NewCDTimer(45, 96306, nil, nil, nil, 3)--Assumed, it's a very short fight.

function mod:OnCombatStart(delay)
--	timerPursuitCD:Start(-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 96619 then
		if args:IsPlayer() then
			specWarnRupture:Show()
			specWarnRupture:Play("targetyou")
		elseif self:IsClassic() and self:CheckNearby(10, args.destName) then
			specWarnRuptureNear:Show(args.destName)
			specWarnRuptureNear:Play("runaway")
		else
			warnRupture:Show(args.destName)
		end
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg, _, _, _, target)
	if msg:find(L.pursuitEmote) then
		if not target then return end
		target = DBM:GetUnitFullName(target)
		timerPursuit:Start()
		timerPursuitCD:Start()
		if target then
			if target == UnitName("player") then
				specWarnPursuit:Show()
				specWarnPursuit:Play("justrun")
			else
				warnPursuit:Show(target)
			end
		end
	end
end
