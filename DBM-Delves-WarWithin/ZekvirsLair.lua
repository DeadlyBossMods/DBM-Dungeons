local mod	= DBM:NewMod("z2682", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"--Best way to really call it
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(225204)--Non hard one placeholder on load. Real one set in OnCombatStart
mod:SetEncounterID(2987, 2985)
mod:SetHotfixNoticeRev(20240914000000)
mod:SetMinSyncRevision(20240914000000)
mod:SetZone(2682)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 450519 450568 450451 450505 450492 450597 453937 451003 450449 450914 451782 450872 472159 472128",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 450505 472128",
	"SPELL_AURA_REMOVED 451003",
--	"SPELL_PERIODIC_DAMAGE",
	"UNIT_DIED"
)

local warnEnfeeblingSpittle					= mod:NewCountAnnounce(450505, 2)
local warnHatchingEgg						= mod:NewCastAnnounce(453937, 3)
local warnWebBlast							= mod:NewCastAnnounce(450597, 4)
local warnBlackBlood						= mod:NewSpellAnnounce(451003, 2)
local warnBlackBloodEnd						= mod:NewEndAnnounce(451003, 2)

local specWarnCallWebTerror					= mod:NewSpecialWarningSwitchCount(450568, nil, nil, nil, 1, 2)
local specWarnAnglersWeb					= mod:NewSpecialWarningDodgeCount(450519, nil, nil, nil, 2, 15)
local specWarnClawSmash						= mod:NewSpecialWarningDodgeCount(450451, nil, nil, nil, 3, 15)
local specWarnUnendingSpines				= mod:NewSpecialWarningDodgeCount(450872, nil, nil, nil, 2, 2)
local specWarnEnfeeblingSpittleInterrupt	= mod:NewSpecialWarningInterruptCount(450505, false, nil, nil, 1, 2)
local specWarnRegeneratingCarapace			= mod:NewSpecialWarningInterruptCount(450449, nil, nil, nil, 1, 2, 4)--Stage 1
local specWarnBloodInfusedCarapace			= mod:NewSpecialWarningInterruptCount(450914, nil, nil, nil, 1, 2, 4)--Stage 2
local specWarnEnfeeblingSpittleDispel		= mod:NewSpecialWarningDispel(450505, "RemoveMagic", nil, nil, 1, 2)
local specWarnHorrendousRoar				= mod:NewSpecialWarningRunCount(450492, nil, nil, nil, 4, 2)
local specWarnInfiniteHorror				= mod:NewSpecialWarningRunCount(451782, nil, nil, nil, 4, 2, 4)--Stage 2 version of Roar on mythic

local timerAnglersWebCD						= mod:NewCDCountTimer(21.8, 450519, nil, nil, nil, 5)
local timerCallWebTerrorCD					= mod:NewCDCountTimer(38.9, 450568, nil, nil, nil, 1)
local timerClawSmashCD						= mod:NewCDCountTimer(15.8, 450451, nil, nil, nil, 3)--18.9-23
local timerEnfeeblingSpittleCD				= mod:NewAITimer(17, 450505, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON .. DBM_COMMON_L.MAGIC_ICON)--Now using AI timer since CD differs by class
local timerHorrendousRoarCD					= mod:NewCDCountTimer(18.2, 450492, nil, nil, nil, 3)--20.6-25
local timerInfiniteHorrorCD					= mod:NewCDCountTimer(18.2, 451782, nil, nil, nil, 3)
local timerUnendingSpinesCD					= mod:NewCDCountTimer(21.8, 450872, nil, nil, nil, 3)
local timerRegeneratingCarapaceCD			= mod:NewAITimer(20, 450449, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Now using AI timer since CD differs by class
local timerBloodInfusedCarapaceCD			= mod:NewAITimer(20, 450914, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Now using AI timer since CD differs by class
local timerHatchingEgg						= mod:NewCastNPTimer(20, 453937, nil, nil, nil, 1)
local timerWebBlastCD						= mod:NewCDNPTimer(12.1, 450597, nil, nil, nil, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--mod.vb.bossStarted = false--Work around blizzard bug where ENCOUNTER_START fires more than once
mod.vb.AnglersCount = 0
mod.vb.AddCount = 0
mod.vb.smashCount = 0
mod.vb.enfeeblingSpittleCount = 0
mod.vb.roarCount = 0
mod.vb.regenCount = 0
mod.vb.spinesCount = 0

function mod:OnCombatStart(delay)
	self.vb.AnglersCount = 0
	self.vb.AddCount = 0
	self.vb.smashCount = 0
	self.vb.enfeeblingSpittleCount = 0
	self.vb.roarCount = 0
	self.vb.regenCount = 0
	self.vb.spinesCount = 0
	if self:IsMythic() then
		self:SetStage(1)
		self:SetCreatureID(221427)
		timerClawSmashCD:Start(4, 1)
		timerHorrendousRoarCD:Start(9.5, 1)
		timerCallWebTerrorCD:Start(18.1, 1)
		timerAnglersWebCD:Start(20, 1)
		timerEnfeeblingSpittleCD:Start(1)--AI timer only now
		timerRegeneratingCarapaceCD:Start(1)
	else
		self:SetCreatureID(225204)
		timerClawSmashCD:Start(4, 1)
		timerCallWebTerrorCD:Start(18.1, 1)
		timerHorrendousRoarCD:Start(9.5, 1)
		timerAnglersWebCD:Start(20, 1)
		timerEnfeeblingSpittleCD:Start(1)--AI timer only now
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 450519 then
		self.vb.AnglersCount = self.vb.AnglersCount + 1
		specWarnAnglersWeb:Show(self.vb.AnglersCount)
		specWarnAnglersWeb:Play("frontal")
		timerAnglersWebCD:Start(nil, self.vb.AnglersCount+1)
	elseif args.spellId == 450568 or args.spellId == 472159 then
		self.vb.AddCount = self.vb.AddCount + 1
		specWarnCallWebTerror:Show(self.vb.AddCount)
		specWarnCallWebTerror:Play("killmob")
		timerCallWebTerrorCD:Start(nil, self.vb.AddCount+1)
	elseif args.spellId == 450451 then
		self.vb.smashCount = self.vb.smashCount + 1
		specWarnClawSmash:Show(self.vb.smashCount)
		specWarnClawSmash:Play("frontal")
		timerClawSmashCD:Start(nil, self.vb.smashCount+1)
	elseif args.spellId == 450505 or args.spellId == 472128 then
		self.vb.enfeeblingSpittleCount = self.vb.enfeeblingSpittleCount + 1
		if self.Options.SpecWarn450505interruptcount and self:CheckInterruptFilter(args.sourceGUID, nil, true) then
			specWarnEnfeeblingSpittleInterrupt:Show(args.sourceName, self.vb.enfeeblingSpittleCount)
			specWarnEnfeeblingSpittleInterrupt:Play("kickcast")
		else
			warnEnfeeblingSpittle:Show(self.vb.enfeeblingSpittleCount)
		end
		timerEnfeeblingSpittleCD:Start(nil, self.vb.enfeeblingSpittleCount+1)
	elseif args.spellId == 450492 then
		self.vb.roarCount = self.vb.roarCount + 1
		specWarnHorrendousRoar:Show(self.vb.roarCount)
		specWarnHorrendousRoar:Play("fearsoon")
		timerHorrendousRoarCD:Start(nil, self.vb.roarCount+1)
	elseif args.spellId == 451782 then
		self.vb.roarCount = self.vb.roarCount + 1
		specWarnInfiniteHorror:Show(self.vb.roarCount)
		specWarnInfiniteHorror:Play("fearsoon")
		timerInfiniteHorrorCD:Start(nil, self.vb.roarCount+1)
	elseif args.spellId == 450597 then
		warnWebBlast:Show()
		timerWebBlastCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 453937 then
		warnHatchingEgg:Show()
		timerHatchingEgg:Start(nil, args.sourceGUID)
	elseif args.spellId == 450449 then
		self.vb.regenCount = self.vb.regenCount + 1
		specWarnRegeneratingCarapace:Show(args.sourceName, self.vb.regenCount)
		specWarnRegeneratingCarapace:Play("kickcast")
		timerRegeneratingCarapaceCD:Start(nil, self.vb.regenCount+1)
	elseif args.spellId == 450914 then
		self.vb.regenCount = self.vb.regenCount + 1
		specWarnBloodInfusedCarapace:Show(args.sourceName, self.vb.regenCount)
		specWarnBloodInfusedCarapace:Play("kickcast")
		timerBloodInfusedCarapaceCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 450872 then
		self.vb.spinesCount = self.vb.spinesCount + 1
		specWarnUnendingSpines:Show(self.vb.spinesCount)
		specWarnUnendingSpines:Play("watchstep")
		timerUnendingSpinesCD:Start(nil, self.vb.spinesCount+1)
	elseif args.spellId == 451003 then
		self:SetStage(2)
		warnBlackBlood:Show()
		timerClawSmashCD:Stop()
		timerEnfeeblingSpittleCD:Stop()
		timerCallWebTerrorCD:Stop()
		timerHorrendousRoarCD:Stop()
		timerAnglersWebCD:Stop()
		timerRegeneratingCarapaceCD:Stop()
		timerUnendingSpinesCD:Stop()
		--Reset Timers (When known)
		timerClawSmashCD:Start(14.5, self.vb.smashCount+1)
		timerUnendingSpinesCD:Start(18.1, 1)
		timerCallWebTerrorCD:Start(27.95, self.vb.AddCount+1)
		timerAnglersWebCD:Start(30.3, self.vb.AnglersCount+1)
		timerInfiniteHorrorCD:Start(35.1, self.vb.roarCount+1)
		timerEnfeeblingSpittleCD:Start(2)--AI used since it's variable cd based on spec.
		timerBloodInfusedCarapaceCD:Start(2)--AI used since it's variable cd based on spec.
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 138680 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 450505 or args.spellId == 472128 then
		if self:CheckDispelFilter("magic") then
			specWarnEnfeeblingSpittleDispel:Show(args.destName)
			specWarnEnfeeblingSpittleDispel:Play("helpdispel")
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 451003 then
		warnBlackBloodEnd:Show()
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 138561 and destGUID == UnitGUID("player") and self:AntiSpam() then

	end
end
--]]

function mod:UNIT_DIED(args)
	--if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe

	--end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 224077 then--Egg Cocoon
		timerWebBlastCD:Stop(args.destGUID)
		timerHatchingEgg:Stop(args.destGUID)
	end
end

--[[
function mod:ENCOUNTER_START(eID)
	if (eID == 2985 or eID == 2987) and not self.vb.bossStarted then--Zekvir (only 2987 seen)
		self.vb.bossStarted = true
		self.vb.AnglersCount = 0
		self.vb.AddCount = 0
		self.vb.smashCount = 0
		self.vb.enfeeblingSpittleCount = 0
		self.vb.roarCount = 0
		timerClawSmashCD:Start(4.6, 1)
		timerEnfeeblingSpittleCD:Start(8.2, 1)
		timerCallWebTerrorCD:Start(18.1, 1)
		timerHorrendousRoarCD:Start(11.9, 1)
		timerAnglersWebCD:Start(20, 1)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2985 or eID == 2987 then--Zekvir (only 2987 seen)
		self.vb.bossStarted = false
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerClawSmashCD:Stop()
			timerEnfeeblingSpittleCD:Stop()
			timerCallWebTerrorCD:Stop()
			timerHorrendousRoarCD:Stop()
			timerAnglersWebCD:Stop()
		end
	end
end

--]]
