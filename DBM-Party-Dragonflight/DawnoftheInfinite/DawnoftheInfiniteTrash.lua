local mod	= DBM:NewMod("DawnoftheInfiniteTrash", "DBM-Party-Dragonflight", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2579)

mod.isTrashMod = true

mod:RegisterEvents(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED",
--	"GOSSIP_SHOW"
)

--[[

--]]

--local warnManavoid								= mod:NewCastAnnounce(388863, 3)
--
--local specWarnExpelIntruders					= mod:NewSpecialWarningRun(377912, nil, nil, nil, 4, 2)
--local yellAstralBomb							= mod:NewShortYell(387843)
--local yellAstralBombFades						= mod:NewShortFadesYell(387843)
--local specWarnMonotonousLecture					= mod:NewSpecialWarningInterrupt(388392, "HasInterrupt", nil, nil, 1, 2)
--
--local timerCalloftheFlockCD						= mod:NewCDTimer(36, 377389, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerDeadlyWindsCD						= mod:NewCDTimer(10.9, 378003, nil, nil, nil, 3)

--mod:AddBoolOption("AGBuffs", true)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 387910 then

	--elseif spellId == 388392 then
	--	timerMonotonousLectureCD:Start(nil, args.sourceGUID)
	--	if self.Options.SpecWarn388392interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--		specWarnMonotonousLecture:Show(args.sourceName)
	--		specWarnMonotonousLecture:Play("kickcast")
	--	elseif self:AntiSpam(2, 5) then
	--		warnMonotonousLecture:Show()
	--	end
--	elseif spellId == 310839 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
--		specWarnDirgefromBelow:Show(args.sourceName)
--		specWarnDirgefromBelow:Play("kickcast")
	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 390915 and self:AntiSpam(3, 2) then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 388984 then

	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 387843 and args:IsPlayer() then

	end
end
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 196044 then
		timerMonotonousLectureCD:Stop(args.destGUID)
	end
end
--]]

--[[
function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		--Black, Bronze, Blue, Red, Green
		if self.Options.AGBuffs and (gossipOptionID == 107065 or gossipOptionID == 107081 or gossipOptionID == 107082 or gossipOptionID == 107088 or gossipOptionID == 107083) then -- Buffs
			self:SelectGossip(gossipOptionID)
		end
	end
end
--]]
