local mod	= DBM:NewMod("SoTTrash", "DBM-Party-Legion", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
--mod:SetModelID(47785)
mod:SetZone()

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 248304 245585 245727 248133 248184 248227",
	"SPELL_AURA_APPLIED 249077 249081"
)

local warnCorruptingVoid			= mod:NewTargetAnnounce(245510, 3)
local warnSupField					= mod:NewTargetAnnounce(249081, 3)
local warnWildSummon				= mod:NewCastAnnounce(248304, 3)

local specWarnCorruptingVoid		= mod:NewSpecialWarningMoveAway(245510, nil, nil, nil, 1, 2)
local specWarnDarkMatter			= mod:NewSpecialWarningSwitch(248227, nil, nil, nil, 1, 2)
local yellCorruptingVoid			= mod:NewYell(245510)
local specWarnSupField				= mod:NewSpecialWarningYou(249081, nil, nil, nil, 1, 2)
local yellSupField					= mod:NewYell(249081)
local specWarnVoidDiffusion			= mod:NewSpecialWarningInterrupt(245585, "HasInterrupt", nil, nil, 1, 2)
local specWarnConsumeEssence		= mod:NewSpecialWarningInterrupt(245727, "HasInterrupt", nil, nil, 1, 2)
local specWarnStygianBlast			= mod:NewSpecialWarningInterrupt(248133, "HasInterrupt", nil, nil, 1, 2)
local specWarnDarkFlay				= mod:NewSpecialWarningInterrupt(248184, "HasInterrupt", nil, nil, 1, 2)

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 248304 then
		warnWildSummon:Show()
	elseif spellId == 245585 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnVoidDiffusion:Show(args.sourceName)
		specWarnVoidDiffusion:Play("kickcast")
	elseif spellId == 245727 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnConsumeEssence:Show(args.sourceName)
		specWarnConsumeEssence:Play("kickcast")
	elseif spellId == 248133 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnStygianBlast:Show(args.sourceName)
		specWarnStygianBlast:Play("kickcast")
	elseif spellId == 248184 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDarkFlay:Show(args.sourceName)
		specWarnDarkFlay:Play("kickcast")
	elseif spellId == 248227 then
		specWarnDarkMatter:Show()
		specWarnDarkMatter:Play("killmob")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 249077 and self:AntiSpam(3, args.destName) then
		if args:IsPlayer() then
			specWarnCorruptingVoid:Show()
			specWarnCorruptingVoid:Play("runout")
			yellCorruptingVoid:Yell()
		else
			warnCorruptingVoid:Show(args.destName)
		end
	elseif spellId == 249081 and self:AntiSpam(3, args.destName) then
		if args:IsPlayer() then
			specWarnSupField:Show()
			specWarnSupField:Play("stopmove")
			yellSupField:Yell()
		else
			warnSupField:Show(args.destName)
		end
	end
end
