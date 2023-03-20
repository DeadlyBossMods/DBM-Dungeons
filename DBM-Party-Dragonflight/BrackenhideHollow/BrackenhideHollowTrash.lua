local mod	= DBM:NewMod("BrackenhideHollowTrash", "DBM-Party-Dragonflight", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 382555 367500 388060 388046 382474 382787 374544 385029",
	"SPELL_CAST_SUCCESS 368287",
	"SPELL_AURA_APPLIED 382555 383087 383399",
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525",
	"SPELL_PERIODIC_DAMAGE 383399",
	"SPELL_PERIODIC_MISSED 383399"
)

--TODO: can https://www.wowhead.com/ptr/spell=383385/rotting-surge be interrupted?
--TODO, can burst of decay be interrupted/stunned?
--TODO, can screech be interrupted or does it need stun?
local warnBurstofDecay						= mod:NewCastAnnounce(374544, 4)--Change to target scan?
local warnHidiousCackle						= mod:NewCastAnnounce(367500, 4)
local warnScreech							= mod:NewCastAnnounce(385029, 4)
local warnDecayClaws						= mod:NewCastAnnounce(382787, 4, nil, nil, "Tank|Healer")
local warnWitheringContagion				= mod:NewTargetAnnounce(383087, 3)

local specWarnViolentWhirlwind				= mod:NewSpecialWarningRun(388046, "Melee", nil, nil, 4, 2)
local specWarnRagestorm						= mod:NewSpecialWarningRun(382555, "Melee", nil, nil, 4, 2)
local specWarnRagestormDispel				= mod:NewSpecialWarningDispel(382555, "RemoveEnrage", nil, nil, 1, 2)
local specWarnWitheringContagion			= mod:NewSpecialWarningMoveAway(383087, nil, nil, nil, 1, 2)
local specWarnStinkBreath					= mod:NewSpecialWarningDodge(388060, nil, nil, nil, 2, 2)
local specWarnToxicTrap						= mod:NewSpecialWarningDodge(368287, nil, nil, nil, 2, 2)
local yellWitheringContagion				= mod:NewYell(383087)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(383399, nil, nil, nil, 1, 8)

local specWarnHidiousCackle					= mod:NewSpecialWarningInterrupt(367500, "HasInterrupt", nil, nil, 1, 2)
local specWarnDecaySurge					= mod:NewSpecialWarningInterrupt(382474, "HasInterrupt", nil, nil, 1, 2)

--local timerDecayClawsCD						= mod:NewCDTimer(9.7, 382787, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 gtfo

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 382555 and self:AntiSpam(3, 1) then
		specWarnRagestorm:Show()
		specWarnRagestorm:Play("justrun")
	elseif spellId == 367500 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHidiousCackle:Show(args.sourceName)
			specWarnHidiousCackle:Play("kickcast")
		elseif self:AntiSpam(3, 5) then
			warnHidiousCackle:Show()
		end
	elseif spellId == 382474 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDecaySurge:Show(args.sourceName)
			specWarnDecaySurge:Play("kickcast")
		--elseif self:AntiSpam(3, 5) then
		--	warnHidiousCackle:Show()
		end
	elseif spellId == 388060 and self:AntiSpam(3, 2) then
		specWarnStinkBreath:Show()
		specWarnStinkBreath:Play("shockwave")
	elseif spellId == 388046 and self:AntiSpam(3, 1) then
		specWarnViolentWhirlwind:Show()
		specWarnViolentWhirlwind:Play("justrun")
	elseif spellId == 382787 then
--		timerDecayClawsCD:Start()
		if self:AntiSpam(3, 5) then
			warnDecayClaws:Show()
		end
	elseif spellId == 374544 and self:AntiSpam(3, 5) then
		warnBurstofDecay:Show()
	elseif spellId == 385029 and self:AntiSpam(3, 5) then
		warnScreech:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 368287 and self:AntiSpam(3, 2) then
		specWarnToxicTrap:Show()
		specWarnToxicTrap:Play("watchstep")
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 382555 and self:AntiSpam(3, 5) then
		specWarnRagestormDispel:Show(args.destName)
		specWarnRagestormDispel:Play("enrage")
	elseif spellId == 383087 then
		warnWitheringContagion:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnWitheringContagion:Show()
			specWarnWitheringContagion:Play("range5")
			yellWitheringContagion:Yell()
		end
	elseif spellId == 383399 and args:IsPlayer() and self:AntiSpam(3, 7) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 339525 and args:IsPlayer() then

	end
end
--]]

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 383399 and destGUID == UnitGUID("player") and self:AntiSpam(2, 7) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

