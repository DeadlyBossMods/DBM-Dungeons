local mod	= DBM:NewMod("z2682", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"--Best way to really call it

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(225204)--Non hard one placeholder on load. Real one set in OnCombatStart
mod:SetEncounterID(2987, 2985)
mod:SetHotfixNoticeRev(20240914000000)
mod:SetMinSyncRevision(20240914000000)
mod:SetZone(2682)

--mod:RegisterCombat("scenario", 2682)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 450519 450568 450451 450505 450492 450597 453937",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 450505",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
	"UNIT_DIED"
)

local warnEnfeeblingSpittle					= mod:NewCountAnnounce(450505, 2)
local warnHatchingEgg						= mod:NewCastAnnounce(453937, 3)
local warnWebBlast							= mod:NewCastAnnounce(450597, 4)

local specWarnAnglersWeb					= mod:NewSpecialWarningDodgeCount(450519, nil, nil, nil, 2, 2)
local specWarnCallWebTerror					= mod:NewSpecialWarningSwitchCount(450568, nil, nil, nil, 1, 2)
local specWarnClawSmash						= mod:NewSpecialWarningDodgeCount(450451, nil, nil, nil, 2, 2)
local specWarnEnfeeblingSpittleInterrupt	= mod:NewSpecialWarningInterruptCount(450505, false, nil, nil, 1, 2)
local specWarnEnfeeblingSpittleDispel		= mod:NewSpecialWarningDispel(450505, "RemoveMagic", nil, nil, 1, 2)
local specWarnHorrendousRoar				= mod:NewSpecialWarningRunCount(450492, nil, nil, nil, 4, 2)

local timerAnglersWebCD						= mod:NewCDCountTimer(52.6, 450519, nil, nil, nil, 5)--Not a good sample, boss died too fast
local timerCallWebTerrorCD					= mod:NewCDCountTimer(40, 450568, nil, nil, nil, 1)
local timerClawSmashCD						= mod:NewCDCountTimer(19.4, 450451, nil, nil, nil, 3)--19.4-23
local timerEnfeeblingSpittleCD				= mod:NewCDCountTimer(17, 450505, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON .. DBM_COMMON_L.MAGIC_ICON)
local timerHorrendousRoarCD					= mod:NewCDCountTimer(20.6, 450492, nil, nil, nil, 3)--20.6-25
local timerHatchingEggCD					= mod:NewCastNPTimer(15, 453937, nil, nil, nil, 1)
local timerWebBlastCD						= mod:NewCDNPTimer(12.1, 450597, nil, nil, nil, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--mod.vb.bossStarted = false--Work around blizzard bug where ENCOUNTER_START fires more than once
mod.vb.AnglersCount = 0
mod.vb.AddCount = 0
mod.vb.smashCount = 0
mod.vb.enfeeblingSpittleCount = 0
mod.vb.roarCount = 0

function mod:OnCombatStart(delay)
	self.vb.AnglersCount = 0
	self.vb.AddCount = 0
	self.vb.smashCount = 0
	self.vb.enfeeblingSpittleCount = 0
	self.vb.roarCount = 0
	if self:IsMythic() then
		self:SetCreatureID(221427)
		DBM:AddMsg("This version isn't supported yet")
		--timerClawSmashCD:Start(4.6, 1)
		--timerEnfeeblingSpittleCD:Start(8.2, 1)
		--timerCallWebTerrorCD:Start(18.1, 1)
		--timerHorrendousRoarCD:Start(11.9, 1)
		--timerAnglersWebCD:Start(20, 1)
	else
		self:SetCreatureID(225204)
		timerClawSmashCD:Start(4.6, 1)
		timerEnfeeblingSpittleCD:Start(8.2, 1)
		timerCallWebTerrorCD:Start(18.1, 1)
		timerHorrendousRoarCD:Start(11.9, 1)
		timerAnglersWebCD:Start(20, 1)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 450519 then
		self.vb.AnglersCount = self.vb.AnglersCount + 1
		specWarnAnglersWeb:Show(self.vb.AnglersCount)
		specWarnAnglersWeb:Play("shockwave")
		timerAnglersWebCD:Start(nil, self.vb.AnglersCount+1)
	elseif args.spellId == 450568 then
		self.vb.AddCount = self.vb.AddCount + 1
		specWarnCallWebTerror:Show(self.vb.AddCount)
		specWarnCallWebTerror:Play("killmob")
		timerCallWebTerrorCD:Start(nil, self.vb.AddCount+1)
	elseif args.spellId == 450451 then
		self.vb.smashCount = self.vb.smashCount + 1
		specWarnClawSmash:Show(self.vb.smashCount)
		specWarnClawSmash:Play("shockwave")
		timerClawSmashCD:Start(nil, self.vb.smashCount+1)
	elseif args.spellId == 450505 then
		self.vb.enfeeblingSpittleCount = self.vb.enfeeblingSpittleCount + 1
		if self.Options.SpecWarn450505interrupt and self:CheckInterruptFilter(args.sourceGUID, nil, true) then
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
	elseif args.spellId == 450597 then
		warnWebBlast:Show()
		timerWebBlastCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 453937 then
		warnHatchingEgg:Show()
		timerHatchingEggCD:Start(nil, args.sourceGUID)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 138680 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 450505 then
		if self:CheckDispelFilter("magic") then
			specWarnEnfeeblingSpittleDispel:Show(args.destName)
			specWarnEnfeeblingSpittleDispel:Play("helpdispel")
		end
	end
end

--[[
function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 1098 then

	end
end
--]]

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
		timerHatchingEggCD:Stop(args.destGUID)
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
