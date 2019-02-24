local mod	= DBM:NewMod("EoATrash", "DBM-Party-Legion", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
--mod:SetModelID(47785)
mod:SetZone()

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 196870 195046 195284",
	"SPELL_AURA_APPLIED 196127 192706"
)

--TODO, still missing some GTFOs for this. Possibly other important spells.
local warnArcaneBomb			= mod:NewTargetAnnounce(192706, 4)

local specWarnStorm				= mod:NewSpecialWarningInterrupt(196870, "HasInterrupt", nil, nil, 1, 2)
local specWarnRejuvWaters		= mod:NewSpecialWarningInterrupt(195046, "HasInterrupt", nil, nil, 1, 2)
local specWarnUndertow			= mod:NewSpecialWarningInterrupt(195284, "HasInterrupt", nil, nil, 1, 2)--Might only be interruptable by stuns, if so change option default?
local specWarnSpraySand			= mod:NewSpecialWarningDodge(196127, "Tank", nil, nil, 1, 2)
local specWarnArcaneBomb		= mod:NewSpecialWarningMoveAway(192706, nil, nil, nil, 3, 2)
local yellArcaneBomb			= mod:NewYell(192706)

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 196870 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnStorm:Show(args.sourceName)
		specWarnStorm:Play("kickcast")
	elseif spellId == 195046 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRejuvWaters:Show(args.sourceName)
		specWarnRejuvWaters:Play("kickcast")
	elseif spellId == 195284 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnUndertow:Show(args.sourceName)
		specWarnUndertow:Play("kickcast")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 196127 then
		specWarnSpraySand:Show()
		specWarnSpraySand:Play("shockwave")
	elseif spellId == 192706 then
		if args:IsPlayer() then
			specWarnArcaneBomb:Show()
			specWarnArcaneBomb:Play("runout")
			yellArcaneBomb:Yell()
		else
			warnArcaneBomb:Show(args.destName)
		end
	end
end
