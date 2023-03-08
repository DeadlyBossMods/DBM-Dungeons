local mod	= DBM:NewMod("BlackrockCavernsTrash", "DBM-Party-Cataclysm", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(645)

mod.isTrashMod = true

mod:RegisterEvents(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 76686"
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

--[[

--]]

local warnShadowPrison							= mod:NewTargetNoFilterAnnounce(76686, 3, nil, "Healer")

local specWarnShadowPrison						= mod:NewSpecialWarningStopMove(76686, nil, nil, nil, 1, 2)--You warning not move away, because some strategies involve actually baiting charge into melee instead of out
--local yellnViciousAmbush						= mod:NewYell(388984)
--local specWarnMonotonousLecture					= mod:NewSpecialWarningInterrupt(388392, "HasInterrupt", nil, nil, 1, 2)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 387910 then

	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 390915 and self:AntiSpam(3, 2) then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 76686 then
		if args:IsPlayer() then
			specWarnShadowPrison:Show()
			specWarnShadowPrison:Play("stopmove")
		else
			warnShadowPrison:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 387843 and args:IsPlayer() then

	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 196044 then

	end
end
--]]
