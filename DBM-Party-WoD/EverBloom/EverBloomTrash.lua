if (DBM:GetTOC() < 100200) then return end--DO NOT DELETE DO NOT DELETE DO NOT DELETE. We don't want this module loading in wod classic (if that happens heh)
local mod	= DBM:NewMod("EverBloomTrash", "DBM-Party-WoD", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1279)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 164965 165213 169657 169445 164887 169494 169839 426845 169840 426974",
	"SPELL_CAST_SUCCESS 165213 172578 165123 426500 427223",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 164965 169658 165123 169495 426500",
--	"SPELL_AURA_APPLIED_DOSE 164886",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--[[
(ability.id = 164965 or ability.id = 165213 or ability.id = 169657 or ability.id = 169445 or ability.id = 164887 or ability.id = 169494 or ability.id = 169839 or ability.id = 426845 or ability.id = 169840 or ability.id = 426974) and type = "begincast"
 or (ability.id = 165213 or ability.id = 172578 or ability.id = 165123 or ability.id = 426500 or ability.id = 427223) and type = "cast"
--]]
local warnPoisonousClaws						= mod:NewSpellAnnounce(169657, 3, nil, "Tank")
local warnEnragedGrowth							= mod:NewCastAnnounce(165213, 4)
local warnChokingVines							= mod:NewCastAnnounce(164965, 3)
local warnNoxiousEruption						= mod:NewCastAnnounce(169445, 3)
local warnHealingWaters							= mod:NewCastAnnounce(164887, 3)
local warnVenomBurst							= mod:NewTargetNoFilterAnnounce(165123, 4)
local warnGnarledroots							= mod:NewTargetNoFilterAnnounce(426500, 3)

local specWarnBoundingWhirl						= mod:NewSpecialWarningSpell(172578, "Melee", nil, nil, 4, 2)
local specWarnCinderboltSalvo					= mod:NewSpecialWarningSpell(427223, nil, nil, nil, 2, 2)
local specWarnSpatialDisruption					= mod:NewSpecialWarningSpell(426974, nil, nil, nil, 2, 13)
local specWarnColdFusion						= mod:NewSpecialWarningDodge(426845, nil, nil, nil, 2, 2)
local specWarnVenomBurst						= mod:NewSpecialWarningMoveAway(165123, nil, nil, nil, 1, 2)
local yellnVenomBurst							= mod:NewYell(165123)
local specWarnEnragedGrowth						= mod:NewSpecialWarningInterrupt(165213, "HasInterrupt", nil, nil, 1, 2)
local specWarnChokingVines						= mod:NewSpecialWarningInterrupt(164965, "HasInterrupt", nil, nil, 1, 2)
local specWarnHealingWaters						= mod:NewSpecialWarningInterrupt(164887, "HasInterrupt", nil, nil, 1, 2)
local specWarnPyroblast							= mod:NewSpecialWarningInterrupt(169839, "HasInterrupt", nil, nil, 1, 2)
local specWarnFrostbolt							= mod:NewSpecialWarningInterrupt(169840, false, nil, nil, 1, 2)
local specWarnChokingVinesDispel				= mod:NewSpecialWarningDispel(164965, "RemoveMagic", nil, nil, 1, 2)
local specWarnVenomBurstDispel					= mod:NewSpecialWarningDispel(165123, "RemovePoison", nil, nil, 1, 2)
--local specWarnDreadpetalToxinDispel				= mod:NewSpecialWarningDispel(164886, "RemovePoison", nil, nil, 1, 2)
local specWarnPoisonClawsDispel					= mod:NewSpecialWarningDispel(169658, "RemovePoison", nil, nil, 1, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(169495, nil, nil, nil, 1, 8)

local timerEnragedGrowthCD						= mod:NewCDNPTimer(12.8, 165213, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--CD from success or interrupt
local timerChokingVinesCD						= mod:NewCDNPTimer(20.6, 164965, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBoundingWhirlCD						= mod:NewCDNPTimer(16.5, 172578, nil, nil, nil, 3)
local timerPoisonousClawsCD						= mod:NewCDNPTimer(16.5, 169657, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerVenomBurstCD							= mod:NewCDNPTimer(10.6, 165123, nil, nil, nil, 3)
local timerHealingWatersCD						= mod:NewCDNPTimer(19.4, 164887, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerLivingLeavesCD						= mod:NewCDNPTimer(18.1, 169494, nil, nil, nil, 3)
local timerGnarledRootsCD						= mod:NewCDNPTimer(18.1, 426500, nil, nil, nil, 3)
local timerPyroblastCD							= mod:NewCDNPTimer(8, 164965, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--8-13 window, quite large
local timerCinderboltSalvoCD					= mod:NewCDNPTimer(18.2, 427223, nil, nil, nil, 2)
local timerFrostboltCD							= mod:NewCDNPTimer(6, 169840, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerColdfusionCD							= mod:NewCDNPTimer(21.8, 426845, nil, nil, nil, 3)--21.8-25, maybe shorter
local timerSpatialDisruptionCD					= mod:NewCDNPTimer(21.8, 426974, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 164965 then
		timerChokingVinesCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn164965interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChokingVines:Show(args.sourceName)
			specWarnChokingVines:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnChokingVines:Show()
		end
	elseif spellId == 165213 then
		--Timer not started here, we only start CD if successfully kicked or successfully cast because otherwise it doesn't go on cooldown
		if self.Options.SpecWarn165213interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEnragedGrowth:Show(args.sourceName)
			specWarnEnragedGrowth:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnEnragedGrowth:Show()
		end
	elseif spellId == 164887 then
		timerHealingWatersCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn164887interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHealingWaters:Show(args.sourceName)
			specWarnHealingWaters:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHealingWaters:Show()
		end
	elseif spellId == 169657 then
		timerPoisonousClawsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnPoisonousClaws:Show()
		end
	elseif spellId == 169445 then
		if self:AntiSpam(3, 6) then
			warnNoxiousEruption:Show()
		end
	elseif spellId == 169494 then
		timerLivingLeavesCD:Start(nil, args.sourceGUID)
	elseif spellId == 169839 then
		timerPyroblastCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPyroblast:Show(args.sourceName)
			specWarnPyroblast:Play("kickcast")
		end
	elseif spellId == 426845 then
		timerColdfusionCD:Start(nil, args.sourceGUID)
		specWarnColdFusion:Show()
		specWarnColdFusion:Play("watchorb")
	elseif spellId == 169840 then
		timerFrostboltCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFrostbolt:Show(args.sourceName)
			specWarnFrostbolt:Play("kickcast")
		end
	elseif spellId == 426974 then
		timerSpatialDisruptionCD:Start(nil, args.sourceGUID)
		--Not antispammed on purpose, it's too unique of a mechanic to bundle with any other mechanic
		specWarnSpatialDisruption:Show()
		specWarnSpatialDisruption:Play("pullin")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 165213 then
		timerEnragedGrowthCD:Start(nil, args.sourceGUID)
	elseif spellId == 172578 then
		timerBoundingWhirlCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBoundingWhirl:Show()
			specWarnBoundingWhirl:Play("justrun")
		end
	elseif spellId == 165123 then
		timerVenomBurstCD:Start(nil, args.sourceGUID)
	elseif spellId == 426500 then
		timerGnarledRootsCD:Start(nil, args.sourceGUID)
	elseif spellId == 427223 then
		timerCinderboltSalvoCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnCinderboltSalvo:Show()
			specWarnCinderboltSalvo:Play("aesoon")
		end
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and args.extraSpellId == 165213 then
		timerEnragedGrowthCD:Start(nil, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 164965 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
		specWarnChokingVinesDispel:Show(args.destName)
		specWarnChokingVinesDispel:Play("helpdispel")
--	elseif spellId == 164886 and args:IsDestTypePlayer() then
--		local amount = args.amount or 1
--		if amount >= 6 and self:CheckDispelFilter("poison") and self:AntiSpam(3, 3) then
--			specWarnDreadpetalToxinDispel:Show(args.destName)
--			specWarnDreadpetalToxinDispel:Play("helpdispel")
--		end
	elseif spellId == 169658 and args:IsDestTypePlayer() and self:CheckDispelFilter("poison") and self:AntiSpam(3, 3) then
		specWarnPoisonClawsDispel:Show(args.destName)
		specWarnPoisonClawsDispel:Play("helpdispel")
	elseif spellId == 165123 and args:IsDestTypePlayer() and self:CheckDispelFilter("poison") and self:AntiSpam(3, 3) then
		specWarnVenomBurstDispel:Show(args.destName)
		specWarnVenomBurstDispel:Play("helpdispel")
	elseif spellId == 165123 then
		if args:IsPlayer() then
			specWarnVenomBurst:Show()
			specWarnVenomBurst:Play("range5")
			yellnVenomBurst:Yell()
		else
			warnVenomBurst:Show(args.destName)
		end
	elseif spellId == 169495 and args:IsPlayer() and self:AntiSpam(3, 8) then--Living Leaves
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 426500 then
		warnGnarledroots:CombinedShow(0.5, args.destName)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 87726 then

	end
end
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 81819 then--Everbloom Naturalist
		timerChokingVinesCD:Stop(args.destGUID)
	elseif cid == 81985 then--Everbloom Tender/Everbloom Cultivator
		timerEnragedGrowthCD:Stop(args.destGUID)
	elseif cid == 86372 then--Melded Berserker
		timerBoundingWhirlCD:Stop(args.destGUID)
	elseif cid == 84767 then--Twisted Abomination
		timerPoisonousClawsCD:Stop(args.destGUID)
	elseif cid == 82039 then--Rockspine Stinger
		timerVenomBurstCD:Stop(args.destGUID)
	elseif cid == 81820 then--Everbloom Mender
		timerHealingWatersCD:Stop(args.destGUID)
	elseif cid == 81984 then--Gnarlroot
		timerLivingLeavesCD:Stop(args.destGUID)
		timerGnarledRootsCD:Stop(args.destGUID)
	elseif cid == 84957 then--Putrid Pyromancer
		timerPyroblastCD:Stop(args.destGUID)
		timerCinderboltSalvoCD:Stop(args.destGUID)
	elseif cid == 84989 then--Infested Icecaller
		timerFrostboltCD:Stop(args.destGUID)
		timerColdfusionCD:Stop(args.destGUID)
	elseif cid == 84990 then--Addled Acanomancer
		timerSpatialDisruptionCD:Stop(args.destGUID)
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 8) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
