local mod	= DBM:NewMod("GrimBatolTrash", "DBM-Party-Cataclysm", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 451871 456696 451612 451939 451379 451378 76711 456711 456713 451387 451067 451224 451391",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 451613 451614 451379 451224",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 451613",
	"UNIT_DIED"
)

--TODO, additional priority interrupts
local warnRive							= mod:NewCastAnnounce(451378, 3, nil, nil, "Tank|Healer")
local warnSearMind						= mod:NewCastAnnounce(76711, 2)

local specWarnMassTremor				= mod:NewSpecialWarningSpell(451871, nil, nil, nil, 2, 2)
local specWarnUmbralWind				= mod:NewSpecialWarningSpell(451939, nil, nil, nil, 2, 2)
local specWarnAscension					= mod:NewSpecialWarningDodge(451387, nil, nil, nil, 2, 2)
local specWarnObsidianStomp				= mod:NewSpecialWarningDodge(456696, nil, nil, nil, 2, 2)
local specWarnShadowlavaBlast			= mod:NewSpecialWarningDodge(456711, nil, nil, nil, 2, 2)
local specWarnDarkEruption				= mod:NewSpecialWarningDodge(456713, nil, nil, nil, 2, 2)
local specWarnDecapitate				= mod:NewSpecialWarningDodge(451067, nil, nil, nil, 2, 2)
local specWarnMindPiercer				= mod:NewSpecialWarningDodge(451391, nil, nil, nil, 2, 2)
local specWarnTwilightFlames			= mod:NewSpecialWarningMoveAway(451612, nil, nil, nil, 2, 2)
local yellTwilightFlames				= mod:NewShortYell(451612)
local yellTwilightFlamesFades			= mod:NewShortFadesYell(451612)
local specWarnRecklessTacticDispel		= mod:NewSpecialWarningDispel(451379, "RemoveEnrage", nil, nil, 1, 2)
local specWarnEnvelopingShadowflame		= mod:NewSpecialWarningDispel(451224, "RemoveCurse", nil, nil, 1, 2)
local specWarnSearMind					= mod:NewSpecialWarningInterrupt(76711, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(451614, nil, nil, nil, 1, 8)

local timerMassTremorCD					= mod:NewCDNPTimer(23, 451871, nil, nil, nil, 2)
local timerObsidianStompCD				= mod:NewCDNPTimer(18.2, 451871, nil, nil, nil, 3)
local timerTwilightFlamesCD				= mod:NewCDNPTimer(20.6, 451612, nil, nil, nil, 3)
local timerUmbralWindCD					= mod:NewCDNPTimer(22.2, 451939, nil, nil, nil, 2)
local timerRecklessTacticCD				= mod:NewCDNPTimer(15.4, 451379, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerRiveCD						= mod:NewCDNPTimer(17, 451378, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerShadowlavaBlastCD			= mod:NewCDNPTimer(19.4, 456711, nil, nil, nil, 3)--Small Sample, could be shorter
local timerDarkEruptionCD				= mod:NewCDNPTimer(21.8, 456713, nil, nil, nil, 3)--Small Sample, could be shorter
local timerAscensionCD					= mod:NewCDNPTimer(20, 451387, nil, nil, nil, 2)
local timerDecapitateCD					= mod:NewCDNPTimer(18.1, 451067, nil, nil, nil, 3)--Small Sample, could be shorter
local timerEnvelopingShadowflameCD		= mod:NewCDNPTimer(18.1, 451224, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)--Small Sample, could be shorter
local timerMindPiercerCD				= mod:NewCDNPTimer(18.1, 451391, nil, nil, nil, 3)
--local timerSearMindCD					= mod:NewCDNPTimer(19.1, 76711, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Not useful right now since stuns can interrupt (without putting on cooldown)

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
		timerMassTremorCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnMassTremor:Show()
			specWarnMassTremor:Play("aesoon")
		end
	elseif spellId == 456696 then--Spammed by non combat enemies entire instance, if IsValidWarning above isn't enough, additional filter messages needed
		timerObsidianStompCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnObsidianStomp:Show()
			specWarnObsidianStomp:Play("watchstep")
		end
	elseif spellId == 451612 then
		timerTwilightFlamesCD:Start(nil, args.sourceGUID)
	elseif spellId == 451939 then
		timerUmbralWindCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnUmbralWind:Show()
			specWarnUmbralWind:Play("carefly")
		end
	elseif spellId == 451379 then
		timerRecklessTacticCD:Start(nil, args.sourceGUID)
	elseif spellId == 451378 then
		timerRiveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnRive:Show()
		end
	elseif spellId == 76711 then
		--timerSearMindCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn76711interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSearMind:Show(args.sourceName)
			specWarnSearMind:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSearMind:Show()
		end
	elseif spellId == 456711 then
		timerShadowlavaBlastCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnShadowlavaBlast:Show()
			specWarnShadowlavaBlast:Play("shockwave")
		end
	elseif spellId == 456713 then
		timerDarkEruptionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDarkEruption:Show()
			specWarnDarkEruption:Play("watchstep")
		end
	elseif spellId == 451387 then
		timerAscensionCD:Start()
		if self:AntiSpam(3, 4) then
			specWarnAscension:Show()
			specWarnAscension:Play("aesoon")
		end
	elseif spellId == 451067 then
		timerDecapitateCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDecapitate:Show()
			specWarnDecapitate:Play("watchstep")
		end
	elseif spellId == 451224 then
		timerEnvelopingShadowflameCD:Start(nil, args.sourceGUID)
	elseif spellId == 451391 then
		timerMindPiercerCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnMindPiercer:Show()
			specWarnMindPiercer:Play("watchstep")
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 384476 then

	end
end
--]]

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
		timerAscensionCD:Stop(args.destGUID)
	elseif cid == 224240 then--Twilight Decapitator
		timerDecapitateCD:Stop(args.destGUID)
	elseif cid == 224271 then--Twilight Warlock
		timerEnvelopingShadowflameCD:Stop(args.destGUID)
	elseif cid == 39392 then--Faceless Corruptor
		timerMindPiercerCD:Stop(args.destGUID)
	end
end
