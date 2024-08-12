if DBM:IsCata() then return end
local mod	= DBM:NewMod("GrimBatolTrash", "DBM-Party-Cataclysm", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 451871 456696 451939 451378 76711 456711 456713 451387 451067 451391 451965 462216 451971",
	"SPELL_CAST_SUCCESS 451613 451224 456696 451871 451612 451939 451378 451379 451965 76711 451971 456711 456713 451391",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 451613 451614 451379 451224 451394",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 451613",
	"UNIT_DIED"
)

--[[
(ability.id = 451871 or ability.id = 451612 or ability.id = 451939 or ability.id = 451379 or ability.id = 451378 or ability.id = 76711 or ability.id = 456711 or ability.id = 456713 or ability.id = 451387 or ability.id = 451067 or ability.id = 451391 or ability.id = 451965 or ability.id = 462216 or ability.id = 451971) and (type = "begincast" or type = "cast")
 or (ability.id = 451613 or ability.id = 451224) and type = "cast"
 or stoppedAbility.id = 451871 or stoppedAbility.id = 76711
 or ability.id = 456696 and (type = "begincast" or type = "cast")
--]]
local warnRive							= mod:NewCastAnnounce(451378, 3, nil, nil, "Tank|Healer")
local warnMassTremor					= mod:NewCastAnnounce(451871, 2)--High Prio off interrupt backup
local warnSearMind						= mod:NewCastAnnounce(76711, 2)--High Prio off interrupt backup
local warnMoltenWake					= mod:NewSpellAnnounce(451965, 2)
local warnMindPiercer					= mod:NewTargetNoFilterAnnounce(451394, 4)

local specWarnUmbralWind				= mod:NewSpecialWarningSpell(451939, nil, nil, nil, 2, 2)
local specWarnAscension					= mod:NewSpecialWarningDodge(451387, nil, nil, nil, 2, 2)
local specWarnObsidianStomp				= mod:NewSpecialWarningDodge(456696, nil, nil, nil, 2, 2)
local specWarnShadowlavaBlast			= mod:NewSpecialWarningDodge(456711, nil, nil, nil, 2, 2)
local specWarnDarkEruption				= mod:NewSpecialWarningDodge(456713, nil, nil, nil, 2, 2)
local specWarnDecapitate				= mod:NewSpecialWarningDodge(451067, nil, nil, nil, 2, 2)
local specWarnMindPiercer				= mod:NewSpecialWarningDodge(451391, nil, nil, nil, 2, 2)
local specWarnBlazingShadowflame		= mod:NewSpecialWarningDodge(462216, nil, nil, nil, 2, 2)
local specWarnTwilightFlames			= mod:NewSpecialWarningMoveAway(451612, nil, nil, nil, 2, 2)
local specWarnLavaFist					= mod:NewSpecialWarningDefensive(451971, nil, nil, nil, 2, 2)--12.8
local yellTwilightFlames				= mod:NewShortYell(451612)
local yellTwilightFlamesFades			= mod:NewShortFadesYell(451612)
local specWarnRecklessTacticDispel		= mod:NewSpecialWarningDispel(451379, "RemoveEnrage", nil, nil, 1, 2)
local specWarnEnvelopingShadowflame		= mod:NewSpecialWarningDispel(451224, "RemoveCurse", nil, nil, 1, 2)
local specWarnMassTremor				= mod:NewSpecialWarningInterrupt(451871, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnSearMind					= mod:NewSpecialWarningInterrupt(76711, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnGTFO						= mod:NewSpecialWarningGTFO(451614, nil, nil, nil, 1, 8)

local timerMassTremorCD					= mod:NewCDNPTimer(23, 451871, nil, nil, nil, 2)--Valid August 11
local timerObsidianStompCD				= mod:NewCDNPTimer(17, 456696, nil, nil, nil, 3)--Valid August 11
local timerTwilightFlamesCD				= mod:NewCDNPTimer(20.6, 451612, nil, nil, nil, 3)--Valid August 11
local timerUmbralWindCD					= mod:NewCDNPTimer(23, 451939, nil, nil, nil, 2)--Valid August 11
local timerRecklessTacticCD				= mod:NewCDNPTimer(15.7, 451379, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)--Valid August 11
local timerRiveCD						= mod:NewCDNPTimer(18.1, 451378, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Valid August 11
local timerShadowlavaBlastCD			= mod:NewCDNPTimer(18.1, 456711, nil, nil, nil, 3)--Valid August 11
local timerDarkEruptionCD				= mod:NewCDNPTimer(20.6, 456713, nil, nil, nil, 3)--Valid August 11
--local timerAscensionCD				= mod:NewCDNPTimer(20, 451387, nil, nil, nil, 2)--Not able to find a double cast on August 11
--local timerDecapitateCD				= mod:NewCDNPTimer(18.1, 451067, nil, nil, nil, 3)--Not able to find a single cast on August 11
local timerEnvelopingShadowflameCD		= mod:NewCDNPTimer(20.6, 451224, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)--Valid August 11. Small Sample, could be shorter
local timerMindPiercerCD				= mod:NewCDNPTimer(18.1, 451391, nil, nil, nil, 3)--Valid August 11
local timerSearMindCD					= mod:NewCDNPTimer(20.4, 76711, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Valid August 11
local timerMoltenWakeCD					= mod:NewCDNPTimer(18.1, 451965, nil, nil, nil, 2)--Valid August 11
local timerLavaFistCD					= mod:NewCDNPTimer(15.7, 451971, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Valid August 11

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

--[[
function mod:CLTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnChainLightning:Show()
			specWarnChainLightning:Play("runout")
		end
		yellChainLightning:Yell()
	end
end
--]]


function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 451871 then
		if self.Options.SpecWarn451871interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMassTremor:Show(args.sourceName)
			specWarnMassTremor:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMassTremor:Show()
		end
	elseif spellId == 456696 then--Spammed by non combat enemies entire instance, if IsValidWarning above isn't enough, additional filter messages needed
		if self:AntiSpam(3, 2) then
			specWarnObsidianStomp:Show()
			specWarnObsidianStomp:Play("watchstep")
		end
	elseif spellId == 451939 then
		if self:AntiSpam(3, 5) then
			specWarnUmbralWind:Show()
			specWarnUmbralWind:Play("carefly")
		end
	elseif spellId == 451378 then
		if self:AntiSpam(3, 5) then
			warnRive:Show()
		end
	elseif spellId == 76711 then
		if self.Options.SpecWarn76711interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSearMind:Show(args.sourceName)
			specWarnSearMind:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSearMind:Show()
		end
	elseif spellId == 456711 then
		if self:AntiSpam(3, 2) then
			specWarnShadowlavaBlast:Show()
			specWarnShadowlavaBlast:Play("shockwave")
		end
	elseif spellId == 456713 then
		if self:AntiSpam(3, 2) then
			specWarnDarkEruption:Show()
			specWarnDarkEruption:Play("watchstep")
		end
	elseif spellId == 451387 then
		--timerAscensionCD:Start()
		if self:AntiSpam(3, 4) then
			specWarnAscension:Show()
			specWarnAscension:Play("aesoon")
		end
	elseif spellId == 451067 then
		if self:AntiSpam(3, 2) then
			specWarnDecapitate:Show()
			specWarnDecapitate:Play("watchstep")
		end
	elseif spellId == 451391 then
		if self:AntiSpam(3, 2) then
			specWarnMindPiercer:Show()
			specWarnMindPiercer:Play("watchstep")
		end
	elseif spellId == 451965 then
		if self:AntiSpam(3, 4) then
			warnMoltenWake:Show()
		end
	elseif spellId == 451971 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnLavaFist:Show()
			specWarnLavaFist:Play("defensive")
		end
	elseif spellId == 462216 then
		if self:AntiSpam(3, 2) then
			specWarnBlazingShadowflame:Show()
			specWarnBlazingShadowflame:Play("shockwave")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 451224 then
		timerEnvelopingShadowflameCD:Start(19.1, args.sourceGUID)--20.6-1.5
	elseif spellId == 456696 then--Spammed by non combat enemies entire instance, if IsValidWarning above isn't enough, additional filter messages needed
		timerObsidianStompCD:Start(16, args.sourceGUID)
	elseif spellId == 451871 then
		timerMassTremorCD:Start(20, args.sourceGUID)
	elseif spellId == 451612 then
		timerTwilightFlamesCD:Start(19.1, args.sourceGUID)--20.6-1.5
	elseif spellId == 451939 then
		timerUmbralWindCD:Start(19, args.sourceGUID)--23-4
	elseif spellId == 451378 then
		timerRiveCD:Start(17.1, args.sourceGUID)--18.1-1
	elseif spellId == 451379 then
		timerRecklessTacticCD:Start(15.2, args.sourceGUID)
	elseif spellId == 451965 then
		timerMoltenWakeCD:Start(16.1)--18.1-2
	elseif spellId == 76711 then
		timerSearMindCD:Start(18.9, args.sourceGUID)
	elseif spellId == 451971 then
		timerLavaFistCD:Start(12.7, args.sourceGUID)--15.7-3
	elseif spellId == 456711 then
		timerShadowlavaBlastCD:Start(15.6, args.sourceGUID)--18.1-2.5
	elseif spellId == 456713 then
		timerDarkEruptionCD:Start(17.6, args.sourceGUID)--20.6-3
	elseif spellId == 451391 then
		timerMindPiercerCD:Start(15.1, args.sourceGUID)--18.1-3
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 451871 then
		timerMassTremorCD:Start(20, args.destGUID)
	elseif args.extraSpellId == 76711 then
		timerSearMindCD:Start(18.9, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 451613 then
		if args:IsPlayer() then
			specWarnTwilightFlames:Show()
			specWarnTwilightFlames:Play("runout")
			yellTwilightFlames:Yell()
			yellTwilightFlamesFades:Countdown(spellId)
		end
	elseif spellId == 451614 and args:IsPlayer() and self:AntiSpam(3, 8) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 451379 and self:AntiSpam(3, 3) then
		specWarnRecklessTacticDispel:Show(args.destName)
		specWarnRecklessTacticDispel:Play("enrage")
	elseif spellId == 451224 and args:IsDestTypePlayer() then
		if self:CheckDispelFilter("curse") then
			specWarnEnvelopingShadowflame:Show(args.destName)
			specWarnEnvelopingShadowflame:Play("helpdispel")
		end
	elseif spellId == 451394 then
		warnMindPiercer:CombinedShow(0.3, args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 451613 then
		if args:IsPlayer() then
			yellTwilightFlamesFades:Cancel()
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 224219 then--Twilight Earthcaller
		timerMassTremorCD:Stop(args.destGUID)
	elseif cid == 224152 then--Twilight Brute
		timerObsidianStompCD:Stop(args.destGUID)
	elseif cid == 224609 then--Twilight Destroyer
		timerTwilightFlamesCD:Stop(args.destGUID)
		timerUmbralWindCD:Stop(args.destGUID)
	elseif cid == 224221 then--Twilight Overseer
		timerRecklessTacticCD:Stop(args.destGUID)
		timerRiveCD:Stop(args.destGUID)
	elseif cid == 224249 then--Twilight LavaBender
		timerShadowlavaBlastCD:Stop(args.destGUID)
		timerDarkEruptionCD:Stop(args.destGUID)
		--timerAscensionCD:Stop(args.destGUID)
	--elseif cid == 224240 then--Twilight Decapitator
	--	timerDecapitateCD:Stop(args.destGUID)
	elseif cid == 224271 then--Twilight Warlock
		timerEnvelopingShadowflameCD:Stop(args.destGUID)
	elseif cid == 39392 then--Faceless Corruptor
		timerMindPiercerCD:Stop(args.destGUID)
	elseif cid == 40166 then--Molten Giant
		timerMoltenWakeCD:Stop(args.destGUID)
		timerLavaFistCD:Stop(args.destGUID)
	elseif cid == 40167 then--Twilight Beguiler
		timerSearMindCD:Stop(args.destGUID)
	end
end
