local mod	= DBM:NewMod("NLTrash", "DBM-Party-Legion", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 183088 226296 202108 193505 226287 183548 193585 226406",
	"SPELL_CAST_SUCCESS 183433",
	"SPELL_AURA_APPLIED 200154 183407 186576 193803 201983"
)
local warnSubmerge				= mod:NewSpellAnnounce(183433, 3)
local warnBurningHatred			= mod:NewTargetAnnounce(200154, 3)
local warnCallWorm				= mod:NewCastAnnounce(183548, 3)
local warnMetamorphosis			= mod:NewTargetNoFilterAnnounce(193803, 3, nil, false)
local warnCrush					= mod:NewCastAnnounce(226287, 3)
local warnPiercingShards		= mod:NewCastAnnounce(226296, 4, nil, nil, "Tank|Healer")
local warnFracture				= mod:NewCastAnnounce(193505, 3, nil, nil, "Tank|Healer")
local warnEmberSwipe			= mod:NewCastAnnounce(226406, 3, nil, nil, "Tank|Healer")
local warnPetrifyingTotem		= mod:NewCastAnnounce(202108, 3)
local warnBound					= mod:NewCastAnnounce(193585, 3)

local specWarnBurningHatred		= mod:NewSpecialWarningRun(200154, nil, nil, nil, 4, 2)
local specWarnAcidSplatter		= mod:NewSpecialWarningMove(183407, nil, nil, nil, 1, 2)
local specWarnAvalanche			= mod:NewSpecialWarningDodge(183088, "Melee", nil, 2, 1, 2)
local specWarnFrenzy			= mod:NewSpecialWarningDispel(201983, "RemoveEnrage", nil, nil, 1, 2)
local specWarnGTFO				= mod:NewSpecialWarningGTFO(186576, nil, nil, nil, 1, 8)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 183088 and self:AntiSpam(3, 2) then
		specWarnAvalanche:Show()
		specWarnAvalanche:Play("watchstep")
	elseif spellId == 226296 and self:AntiSpam(3, 5) then
		warnPiercingShards:Show()
	elseif spellId == 202108 and self:AntiSpam(3, 6) then
		warnPetrifyingTotem:Show()
	elseif spellId == 193505 and self:AntiSpam(3, 5) then
		warnFracture:Show()
	elseif spellId == 226287 and self:AntiSpam(3, 4) then
		warnCrush:Show()
	elseif spellId == 183548 and self:AntiSpam(3, 5) then
		warnCallWorm:Show()
	elseif spellId == 193585 and self:AntiSpam(3, 6) then
		warnBound:Show()
	elseif spellId == 226406 and self:AntiSpam(3, 5) then
		warnEmberSwipe:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 183433 and self:AntiSpam(3, 5) then
		warnSubmerge:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 200154 then
		if args:IsPlayer() then
			specWarnBurningHatred:Show()
			specWarnBurningHatred:Play("justrun")
		else
			warnBurningHatred:Show(args.destName)
		end
	elseif spellId == 183407 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnAcidSplatter:Show()
		specWarnAcidSplatter:Play("runaway")
	elseif spellId == 186576 and args:IsPlayer() and self:AntiSpam(3, 7) then
		specWarnGTFO:Show(args.spellname)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 193803 and self:AntiSpam(3, 6) then
		warnMetamorphosis:Show(args.destName)
	elseif spellId == 201983 and self:AntiSpam(3, 5) then
		specWarnFrenzy:Show(args.destName)
		specWarnFrenzy:Play("enrage")
	end
end
