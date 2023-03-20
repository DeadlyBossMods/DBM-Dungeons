local mod	= DBM:NewMod("BrackenhideHollowTrash", "DBM-Party-Dragonflight", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 382555 367500 388060 388046 382474 382787 374544 385029 383062 367503",
	"SPELL_CAST_SUCCESS 368287 383385 382435 384930",
	"SPELL_AURA_APPLIED 382555 383087 383399 385058 385827 384974 367484",
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525",
	"SPELL_PERIODIC_DAMAGE 383399",
	"SPELL_PERIODIC_MISSED 383399"
)

--TODO: can https://www.wowhead.com/ptr/spell=383385/rotting-surge can be stunned (but not interrupted)
--TODO, can burst of decay be interrupted/stunned or target scanned?
--TODO, Add https://www.wowhead.com/spell=382593/crushing-smash?
--TODO, add https://www.wowhead.com/spell=382410/witherbolt interrupt warning?
local warnBurstofDecay						= mod:NewCastAnnounce(374544, 4)--Change to target scan?
local warnHidiousCackle						= mod:NewCastAnnounce(367500, 4)
local warnScreech							= mod:NewCastAnnounce(385029, 4)
local warnDecayClaws						= mod:NewCastAnnounce(382787, 4, nil, nil, "Tank|Healer")
local warnSummonLashers						= mod:NewCastAnnounce(383062, 2, nil, nil, "Tank")
local warnWitheringContagion				= mod:NewTargetAnnounce(383087, 3)
local warnWitheringBurst					= mod:NewTargetAnnounce(367503, 3)
local warnStealth							= mod:NewSpellAnnounce(384930, 3)

local specWarnViolentWhirlwind				= mod:NewSpecialWarningRun(388046, "Melee", nil, nil, 4, 2)
local specWarnScentedMeat					= mod:NewSpecialWarningRun(384974, nil, nil, nil, 4, 2)
local specWarnViciousClawmangle				= mod:NewSpecialWarningRun(367484, nil, nil, nil, 4, 2)
local specWarnRagestorm						= mod:NewSpecialWarningRun(382555, "Melee", nil, nil, 4, 2)
local specWarnRagestormDispel				= mod:NewSpecialWarningDispel(382555, "RemoveEnrage", nil, nil, 1, 2)
local specWarnBloodyRage					= mod:NewSpecialWarningDispel(385827, "RemoveEnrage", nil, nil, 1, 2)
local specWarnWitheringPoison				= mod:NewSpecialWarningDispel(385058, "RemovePoison", nil, nil, 1, 2)
local specWarnWitheringContagion			= mod:NewSpecialWarningMoveAway(383087, nil, nil, nil, 1, 2)
local specWarnStinkBreath					= mod:NewSpecialWarningDodge(388060, nil, nil, nil, 2, 2)
local specWarnToxicTrap						= mod:NewSpecialWarningDodge(368287, nil, nil, nil, 2, 2)
local specWarnRottingSurge					= mod:NewSpecialWarningDodge(383385, nil, nil, nil, 2, 2)
local specWarnRotchantingTotem				= mod:NewSpecialWarningSwitch(382435, "Dps", nil, nil, 1, 2)
local yellWitheringContagion				= mod:NewYell(383087)
local specWarnWitheringBurst				= mod:NewSpecialWarningYou(367503, nil, nil, nil, 1, 2)
local yellWitheringBurst					= mod:NewYell(367503)
local specWarnHidiousCackle					= mod:NewSpecialWarningInterrupt(367500, "HasInterrupt", nil, nil, 1, 2)
local specWarnDecaySurge					= mod:NewSpecialWarningInterrupt(382474, "HasInterrupt", nil, nil, 1, 2)
local specWarnScreech						= mod:NewSpecialWarningInterrupt(385029, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(383399, nil, nil, nil, 1, 8)

--local timerDecayClawsCD						= mod:NewCDTimer(9.7, 382787, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 gtfo

function mod:BurstTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnWitheringBurst:Show()
			specWarnWitheringBurst:Play("targetyou")
		end
		yellWitheringBurst:Yell()
	else
		warnWitheringBurst:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 382555 and self:AntiSpam(3, 1) then
		specWarnRagestorm:Show()
		specWarnRagestorm:Play("justrun")
	elseif spellId == 367500 then
		if self.Options.SpecWarn367500interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHidiousCackle:Show(args.sourceName)
			specWarnHidiousCackle:Play("kickcast")
		elseif self:AntiSpam(3, 5) then
			warnHidiousCackle:Show()
		end
	elseif spellId == 382474 then
		if self.Options.SpecWarn382474interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
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
		if self.Options.SpecWarn385029interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnScreech:Show(args.sourceName)
			specWarnScreech:Play("kickcast")
		elseif self:AntiSpam(3, 5) then
			warnScreech:Show()
		end
	elseif spellId == 383062 and self:AntiSpam(3, 5) then
		warnSummonLashers:Show()
	elseif spellId == 367503 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "BurstTarget", 0.1, 8)

	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 368287 and self:AntiSpam(3, 2) then
		specWarnToxicTrap:Show()
		specWarnToxicTrap:Play("watchstep")
	elseif spellId == 383385 and self:AntiSpam(3, 2) then
		specWarnRottingSurge:Show()
		specWarnRottingSurge:Play("watchstep")
	elseif spellId == 382435 and self:AntiSpam(3, 5) then
		specWarnRotchantingTotem:Show()
		specWarnRotchantingTotem:Play("attacktotem")
	elseif spellId == 384930 and self:AntiSpam(3, 5) then
		warnStealth:Show()
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 382555 and self:AntiSpam(3, 3) then
		specWarnRagestormDispel:Show(args.destName)
		specWarnRagestormDispel:Play("enrage")
	elseif spellId == 385827 and self:AntiSpam(3, 3) then
		specWarnBloodyRage:Show(args.destName)
		specWarnBloodyRage:Play("enrage")
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
	elseif spellId == 385058 and args:IsDestTypePlayer() and self:CheckDispelFilter("poison") and self:AntiSpam(3, 3) then
		specWarnWitheringPoison:Show(args.destName)
		specWarnWitheringPoison:Play("helpdispel")
	elseif spellId == 384974 and args:IsPlayer() and self:AntiSpam(4, 1) then
		specWarnScentedMeat:Show()
		specWarnScentedMeat:Play("justrun")
	elseif spellId == 367484 and args:IsPlayer() and self:AntiSpam(4, 1) then
		specWarnViciousClawmangle:Show()
		specWarnViciousClawmangle:Play("justrun")
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

