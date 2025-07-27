if DBM:IsMop() then return end
local mod	= DBM:NewMod("JadeTempleTrash", "DBM-Party-MoP", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 398300 395859 397899 397881 397889 396001 395872 396073 396018 397931 114646 397914 397878",
	"SPELL_AURA_APPLIED 396020 396018",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED_UNFILTERED"
)
--[[
(ability.id = 395872 or ability.id = 395859 or ability.id = 397914 or ability.id = 397889 or ability.id = 398300) and type = "begincast"
--]]
--TODO, add https://www.wowhead.com/spell=110125/shattered-resolve when i better understand if ground stuff is on applied or removed
local warnSurgingDeluge						= mod:NewSpellAnnounce(397881, 2)
local warnTidalburst						= mod:NewCastAnnounce(397889, 3)
local warnHauntingScream					= mod:NewCastAnnounce(395859, 4)
local warnSleepySililoquy					= mod:NewCastAnnounce(395872, 3)
local warnCatNap							= mod:NewCastAnnounce(396073, 3)
local warnFitofRage							= mod:NewCastAnnounce(396018, 3)
local warnDefilingMists						= mod:NewCastAnnounce(397914, 3)
local warnHauntingGaze						= mod:NewCastAnnounce(114646, 3, nil, nil, "Tank|Healer")
local warnDarkClaw							= mod:NewCastAnnounce(397931, 4, nil, nil, "Tank|Healer")
local warnGoldenBarrier						= mod:NewTargetNoFilterAnnounce(396020, 2)

local specWarnTaintedRipple					= mod:NewSpecialWarningMoveTo(397878, nil, nil, nil, 2, 13)
local specWarnFlamesofDoubt					= mod:NewSpecialWarningDodge(398300, nil, nil, nil, 2, 2)
local specWarnLegSweep						= mod:NewSpecialWarningDodge(397899, nil, nil, nil, 2, 2)
local specWarnTerritorialDisplay			= mod:NewSpecialWarningDodge(396001, nil, nil, nil, 2, 2)
local specWarnShatterResolve				= mod:NewSpecialWarningDodge(110125, nil, nil, nil, 2, 2)
--local yellConcentrateAnima					= mod:NewYell(339525)
--local yellConcentrateAnimaFades				= mod:NewShortFadesYell(339525)
local specWarnFitOfRage						= mod:NewSpecialWarningDispel(396018, "RemoveEnrage", nil, nil, 1, 2)
local specWarnHauntingScream				= mod:NewSpecialWarningInterrupt(395859, "HasInterrupt", nil, nil, 1, 2)
local specWarnSleepySililoquy				= mod:NewSpecialWarningInterrupt(395872, "HasInterrupt", nil, nil, 1, 2)
local specWarnDefilingMists					= mod:NewSpecialWarningInterrupt(397914, "HasInterrupt", nil, nil, 1, 2)
local specWarnTidalburst					= mod:NewSpecialWarningInterrupt(397889, "HasInterrupt", nil, nil, 1, 2)

local timerTaintedRippleCD					= mod:NewCDNPTimer(14.5, 397878, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerTidalburstCD						= mod:NewCDNPTimer(16.6, 397889, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDarkClawCD						= mod:NewCDNPTimer(9.7, 397931, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--9.7-14.5
local timerHauntingScreamCD					= mod:NewCDNPTimer(18.2, 395859, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSleepySililoquyCD				= mod:NewCDNPTimer(10.9, 395872, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--10.9-12
local timerFlamesofDoubtCD					= mod:NewCDNPTimer(15.3, 398300, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerDefilingMistsCD					= mod:NewCDNPTimer(10.9, 397914, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 398300 then
		timerFlamesofDoubtCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnFlamesofDoubt:Show()
			specWarnFlamesofDoubt:Play("shockwave")
		end
	elseif spellId == 397899 and self:AntiSpam(3, 2) then
		specWarnLegSweep:Show()
		specWarnLegSweep:Play("watchstep")
	elseif spellId == 396001 and self:AntiSpam(3, 2) then
		specWarnTerritorialDisplay:Show()
		specWarnTerritorialDisplay:Play("watchstep")
	elseif spellId == 395859 then
		timerHauntingScreamCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn395859interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHauntingScream:Show(args.sourceName)
			specWarnHauntingScream:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHauntingScream:Show()
		end
	elseif spellId == 395872 then
		timerSleepySililoquyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn395872interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSleepySililoquy:Show(args.sourceName)
			specWarnSleepySililoquy:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSleepySililoquy:Show()
		end
	elseif spellId == 397881 and self:AntiSpam(3, 6) then--Basically de-emphasized dodge warnings but using diff antispam so they don't squelch emphasized dodge warnings
		warnSurgingDeluge:Show()
	elseif spellId == 397889 then
		timerTidalburstCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn397889interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTidalburst:Show(args.sourceName)
			specWarnTidalburst:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnTidalburst:Show()
		end
	elseif spellId == 397914 then
		timerDefilingMistsCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn397914interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDefilingMists:Show(args.sourceName)
			specWarnDefilingMists:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDefilingMists:Show()
		end
	elseif spellId == 396073 and self:AntiSpam(3, 5) then
		warnCatNap:Show()
	elseif spellId == 396018 and self:AntiSpam(3, 5) then
		warnFitofRage:Show()
	elseif spellId == 397931 then
		timerDarkClawCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnDarkClaw:Show()
		end
	elseif spellId == 114646 and self:AntiSpam(3, 5) then
		warnHauntingGaze:Show()
	elseif spellId == 397878 then
		timerTaintedRippleCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnTaintedRipple:Show(DBM_COMMON_L.BREAK_LOS)
			specWarnTaintedRipple:Play("breaklos")
		end
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 396020 then
		warnGoldenBarrier:Show(args.destName)
	elseif spellId == 396018 and self:AntiSpam(3, 3) then
		specWarnFitOfRage:Show(args.destName)
		specWarnFitOfRage:Play("enrage")
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

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 200126 then--Fallen Waterspeaker
		timerTidalburstCD:Stop(args.destGUID)
	elseif cid == 59555 then--Haunting Sha
		timerHauntingScreamCD:Stop(args.destGUID)
	elseif cid == 59546 then--The Talking Fish
		timerSleepySililoquyCD:Stop(args.destGUID)
	elseif cid == 200387 then--Shambling Infester
		timerFlamesofDoubtCD:Stop(args.destGUID)
	elseif cid == 200137 then--Depraved mistweaver
		timerDefilingMistsCD:Stop(args.destGUID)
	elseif cid == 57109 or cid == 65362 then--Minion of Doubt
		timerDarkClawCD:Stop(args.destGUID)
	elseif cid == 59873 then--Corrupted Living Water
		timerTaintedRippleCD:Stop(args.destGUID)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED_UNFILTERED(uId, _, spellId)
	if spellId == 397928 and self:AntiSpam(3, 2) then
		specWarnShatterResolve:Show()
		specWarnShatterResolve:Play("watchstep")
	end
end
