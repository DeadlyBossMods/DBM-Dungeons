local mod	= DBM:NewMod("NeltharusTrash", "DBM-Party-Dragonflight", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
--mod:SetZone(1234)--FIXME RIGHT ID
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 382708 376186 372566 372311 372201 381663 378282 384597 378847 372615 372561 395427 379406 384161 372262 372971 372223 373084 378827 384623",
	"SPELL_CAST_SUCCESS 376169 372296 374451 384597",
	"SPELL_AURA_APPLIED 384161 373089 371875 373540 372461 382791 383651",
--	"SPELL_AURA_APPLIED_DOSE 339528",
	"SPELL_AURA_REMOVED 382791 383651",
	"UNIT_DIED",
	"GOSSIP_SHOW"
)

--NOTE: Many alerts are drycodes from https://www.wowhead.com/guide/dungeons/neltharus-strategy and could have invalid IDs/events
--TODO, throw lava dodge at start or success? depends on when ground visual appears/locks on.
--TODO, add https://www.wowhead.com/spell=372538/melt ? mob packs have higher prio spells so that's why this one iffy interrupt
--TODO, off interrupt, CC alert for https://www.wowhead.com/spell=372225/dragonbone-axe ?
--TODO, auto gossip the cooking buff? (https://www.wowhead.com/spell=383376/qalashi-goulash)
--[[
(ability.id = 384623 or ability.id = 378827 or ability.id = 382708 or ability.id = 376186 or ability.id = 372566 or ability.id = 372311 or ability.id = 372201 or ability.id = 381663 or ability.id = 378282 or ability.id = 384597 or ability.id = 378847 or ability.id = 372615 or ability.id = 372561 or ability.id = 395427 or ability.id = 379406 or ability.id = 384161 or ability.id = 372262 or ability.id = 372971 or ability.id = 372223 or ability.id = 373084) and type = "begincast"
 or (ability.id = 376169 or ability.id = 372296) and type = "cast"
 or ability.id = 383654
--]]
local warnBlazingSlash						= mod:NewCastAnnounce(384597, 3, nil, nil, "Tank|Healer")
local warnBrutalStrike						= mod:NewCastAnnounce(378847, 3, nil, nil, "Tank|Healer")
local warnReverberatingSlam					= mod:NewCastAnnounce(372971, 3, nil, nil, "Tank|Healer")
local warnMoltencore						= mod:NewCastAnnounce(378282, 4)
local warnBurningRoar						= mod:NewCastAnnounce(395427, 4)
local warnMoteofCombustion					= mod:NewCastAnnounce(384161, 4)
local warnMendingClay						= mod:NewCastAnnounce(372223, 3)
local warnForgestomp						= mod:NewCastAnnounce(384623, 3)
local warnBoldAmbush						= mod:NewTargetNoFilterAnnounce(372566, 3)
local warnBindingSpear						= mod:NewTargetNoFilterAnnounce(372561, 3)
local warnMoltenBarrier						= mod:NewTargetNoFilterAnnounce(382791, 4)
local warnBurningChain						= mod:NewTargetNoFilterAnnounce(374451, 1)

local specWarnTempest						= mod:NewSpecialWarningSpell(381663, nil, nil, nil, 2, 13)--pushbackincoming
local specWarnVolcanicGuard					= mod:NewSpecialWarningDodge(382708, nil, nil, nil, 1, 2)
local specWarnEruptiveCrush					= mod:NewSpecialWarningDodge(376186, nil, nil, nil, 2, 2)
local specWarnMagmaFist						= mod:NewSpecialWarningDodge(372311, nil, nil, nil, 2, 2)
local specWarnExplosiveConcoction			= mod:NewSpecialWarningDodge(378827, nil, nil, nil, 2, 2)
local specWarnScorchingBreath				= mod:NewSpecialWarningDodge(372201, nil, nil, nil, 2, 2)
local specWarnThrowLava						= mod:NewSpecialWarningDodge(379406, nil, nil, nil, 2, 2)
local specWarnPierceMarrow					= mod:NewSpecialWarningDodge(372262, nil, nil, nil, 2, 2)
local specWarnBindingSpear					= mod:NewSpecialWarningDodge(372561, nil, nil, nil, 2, 2)
local specWarnConflagrantBattery			= mod:NewSpecialWarningDodge(372296, nil, nil, nil, 2, 2)
local yellBindingSpear						= mod:NewYell(372561)
local specWarnScorchingFusillade			= mod:NewSpecialWarningMoveAway(372543, nil, nil, nil, 1, 2)
local yellScorchingFusillade				= mod:NewYell(372543)
local specWarnMoteofCombustionYou			= mod:NewSpecialWarningYou(384161, nil, nil, nil, 1, 2)
local yellMoteofCombustion					= mod:NewYell(384161)
local specWarnBoldAmbush					= mod:NewSpecialWarningYou(372566, nil, nil, nil, 1, 2)
local yellBoldAmbush						= mod:NewYell(372566)
local specWarnImbuedMagma					= mod:NewSpecialWarningDispel(372461, "RemoveMagic", nil, nil, 1, 2)
local specWarnFiredUp						= mod:NewSpecialWarningDispel(371875, "RemoveEnrage", nil, nil, 2, 2)
local specWarnMoltenCore					= mod:NewSpecialWarningInterrupt(378282, "HasInterrupt", nil, nil, 1, 2)
local specWarnEmberReach					= mod:NewSpecialWarningInterrupt(372615, "HasInterrupt", nil, nil, 1, 2)
local specWarnBurningRoar					= mod:NewSpecialWarningInterrupt(395427, "HasInterrupt", nil, nil, 1, 2)
local specWarnMoteofCombustion				= mod:NewSpecialWarningInterrupt(384161, "HasInterrupt", nil, nil, 1, 2)
local specWarnMendingClay					= mod:NewSpecialWarningInterrupt(372223, "HasInterrupt", nil, nil, 1, 2)
local specWarnMoltenArmy					= mod:NewSpecialWarningInterrupt(383651, "HasInterrupt", nil, nil, 1, 2)

local timerMagmaFistCD						= mod:NewCDNPTimer(25.4, 372311, nil, nil, nil, 3)
local timerBrutalStrikeCD					= mod:NewCDNPTimer(15.1, 378847, nil, "Tank|Healer", nil, 5)
local timerBlazingSlashCD					= mod:NewCDNPTimer(12.4, 384597, nil, "Tank|Healer", nil, 5)--Doesn't go on cooldown if stunned
local timerVolcanicGuardCD					= mod:NewCDNPTimer(25.1, 382708, nil, nil, nil, 3)
local timerExplosiveConcoctionCD			= mod:NewCDNPTimer(18.2, 378827, nil, nil, nil, 3)
local timerBindingSpearCD					= mod:NewCDNPTimer(25.4, 372561, nil, nil, nil, 3)
local timerMendingClayCD					= mod:NewCDNPTimer(25.4, 372223, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBurningRoarCD					= mod:NewCDNPTimer(20.5, 395427, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerMoltenCoreCD						= mod:NewCDNPTimer(8.1, 378282, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerEruptiveCrushCD					= mod:NewCDNPTimer(15.7, 376186, nil, nil, nil, 3)
local timerScorchingBreathCD				= mod:NewCDNPTimer(16.1, 372201, nil, nil, nil, 3)
local timerMoteofCombustionCD				= mod:NewCDNPTimer(18.2, 384161, nil, nil, nil, 3)
local timerThrowLavaCD						= mod:NewCDNPTimer(12.1, 379406, nil, nil, nil, 3)
local timerPierceMarrowCD					= mod:NewCDNPTimer(10.9, 372262, nil, nil, nil, 3)
local timerScorchingFusilladeCD				= mod:NewCDNPTimer(23, 372543, nil, nil, nil, 3)
local timerConflagrantBatteryCD				= mod:NewCDNPTimer(22.6, 372296, nil, nil, nil, 3)
--local timerReverbSlamCD					= mod:NewCDNPTimer(17, 372971, nil, nil, nil, 3)--8-17? needs further review
local timerCandescentTempestCD				= mod:NewCDNPTimer(27.5, 381663, nil, nil, nil, 2)
local timerForgestompCD						= mod:NewCDNPTimer(17.3, 384623, nil, nil, nil, 2)

mod:AddBoolOption("AGBuffs", true)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

local magmaMod = DBM:GetModByName("2494")

local cachedGUIDS = {}

function mod:AmbushTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnBoldAmbush:Show()
			specWarnBoldAmbush:Play("targetyou")
		end
		yellBoldAmbush:Yell()
	else
		warnBoldAmbush:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 382708 then
		timerVolcanicGuardCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnVolcanicGuard:Show()
			specWarnVolcanicGuard:Play("shockwave")
		end
	elseif spellId == 376186 then
		timerEruptiveCrushCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnEruptiveCrush:Show()
			specWarnEruptiveCrush:Play("watchstep")
		end
	elseif spellId == 372561 then
		timerBindingSpearCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(2, 2) then
			specWarnBindingSpear:Show()
			specWarnBindingSpear:Play("watchstep")
		end
	elseif spellId == 379406 then
		timerThrowLavaCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnThrowLava:Show()
			specWarnThrowLava:Play("watchstep")
		end
	elseif spellId == 372311 then
		timerMagmaFistCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnMagmaFist:Show()
			specWarnMagmaFist:Play("shockwave")
		end
	elseif spellId == 372262 then
		timerPierceMarrowCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnPierceMarrow:Show()
			specWarnPierceMarrow:Play("chargemove")
		end
	elseif spellId == 372201 then
		timerScorchingBreathCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnScorchingBreath:Show()
			specWarnScorchingBreath:Play("shockwave")
		end
	elseif spellId == 381663 then
		timerCandescentTempestCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			specWarnTempest:Show()
			specWarnTempest:Play("pushbackincoming")
		end
	elseif spellId == 372566 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "AmbushTarget", 0.1, 8)
	elseif spellId == 372615 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnEmberReach:Show(args.sourceName)
		specWarnEmberReach:Play("kickcast")
	elseif spellId == 372223 then
		timerMendingClayCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn372223interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMendingClay:Show(args.sourceName)
			specWarnMendingClay:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMendingClay:Show()
		end
	elseif spellId == 378282 then
		timerMoltenCoreCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn378282interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMoltenCore:Show(args.sourceName)
			specWarnMoltenCore:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMoltencore:Show()
		end
	elseif spellId == 395427 then
		timerBurningRoarCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn395427interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBurningRoar:Show(args.sourceName)
			specWarnBurningRoar:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBurningRoar:Show()
		end
	elseif spellId == 384161 then
		timerMoteofCombustionCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn384161interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMoteofCombustion:Show(args.sourceName)
			specWarnMoteofCombustion:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMoteofCombustion:Show()
		end
	elseif spellId == 384597 then
		if self:AntiSpam(3, 5) then
			warnBlazingSlash:Show()
		end
	elseif spellId == 378847 then
		timerBrutalStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnBrutalStrike:Show()
		end
	elseif spellId == 372971 then
--		timerReverbSlamCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnReverberatingSlam:Show()
		end
	elseif spellId == 373084 then--Scorching Fusillade cast (preferred for timer over debuff)
		timerScorchingFusilladeCD:Start(nil, args.sourceGUID)
	elseif spellId == 378827 then
		timerExplosiveConcoctionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnExplosiveConcoction:Show()
			specWarnExplosiveConcoction:Play("watchstep")
		end
	elseif spellId == 384623 then
		timerForgestompCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnForgestomp:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 376169 and self:AntiSpam(5, 8) then--Throw Experimental Concoction
		---@diagnostic disable-next-line: dbm-sync-checker
		magmaMod:SendSync("TuskRP")
	elseif spellId == 372296 then
		timerConflagrantBatteryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnConflagrantBattery:Show()
			specWarnConflagrantBattery:Play("watchstep")
		end
	elseif spellId == 374451 then
		warnBurningChain:Show(args.destName)
	elseif spellId == 384597 then
		timerBlazingSlashCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 384161 then
		if args:IsPlayer() then
			specWarnMoteofCombustionYou:Show()
			specWarnMoteofCombustionYou:Play("targetyou")
			yellMoteofCombustion:Yell()
		end
	elseif spellId == 373089 then
		if args:IsPlayer() then
			specWarnScorchingFusillade:Show()
			specWarnScorchingFusillade:Play("scatter")
			yellScorchingFusillade:Yell()
		end
	elseif spellId == 371875 and self:AntiSpam(3, 3) then
		specWarnFiredUp:Show(args.destName)
		specWarnFiredUp:Play("enrage")
	elseif spellId == 373540 then
		warnBindingSpear:CombinedShow(0.3, args.destName)--Can it hit more than one?
		if args:IsPlayer() then
			yellBindingSpear:Yell()
		end
	elseif spellId == 372461 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
		specWarnImbuedMagma:Show(args.destName)
		specWarnImbuedMagma:Play("helpdispel")
	elseif spellId == 382791 then
		warnMoltenBarrier:Show(args.destName)
	elseif spellId == 383651 then--Army Buff
		cachedGUIDS[args.destGUID] = true
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 382791 then--Molten Barrier
		if cachedGUIDS[args.destGUID] then--still casting
			specWarnMoltenArmy:Show(args.destName)
			specWarnMoltenArmy:Play("kickcast")
		end
	elseif spellId == 383651 then--Army Buff
		cachedGUIDS[args.destGUID] = nil
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 189266 then--Qalashi Trainee
		timerMagmaFistCD:Stop(args.destGUID)
	elseif cid == 192787 then--Qalashi Spinecrusher
		timerBrutalStrikeCD:Stop(args.destGUID)
	elseif cid == 193293 then--Qalashi Warden
		timerVolcanicGuardCD:Stop(args.destGUID)
		timerBlazingSlashCD:Stop(args.destGUID)
	elseif cid == 192786 then--Qalashi Plunderer
		timerExplosiveConcoctionCD:Stop(args.destGUID)
	elseif cid == 189227 then--Qalashi Hunter
		timerBindingSpearCD:Stop(args.destGUID)
	elseif cid == 189265 then--Qalashi Bonetender
		timerMendingClayCD:Stop(args.destGUID)
	elseif cid == 189235 then--Overseer Lahar
		timerBurningRoarCD:Stop(args.destGUID)
		timerEruptiveCrushCD:Stop(args.destGUID)
	elseif cid == 189464 then--Qalashi Irontorch
		timerScorchingBreathCD:Stop(args.destGUID)
		timerMoteofCombustionCD:Stop(args.destGUID)
	elseif cid == 193944 then--Qalashi Lavabearer
		timerThrowLavaCD:Stop(args.destGUID)
	elseif cid == 189467 then--Qalashi Bonesplitter
		timerPierceMarrowCD:Stop(args.destGUID)
	elseif cid == 189466 then--Irontorch Commander
		timerScorchingFusilladeCD:Stop(args.destGUID)
		timerConflagrantBatteryCD:Stop(args.destGUID)
	elseif cid == 189471 then--Qalashi Blacksmith
--		timerReverbSlamCD:Start(args.destGUID)
		timerForgestompCD:Stop(args.destGUID)
	elseif cid == 193291 then--Apex Blazewing
		timerCandescentTempestCD:Stop(args.destGUID)
	elseif cid == 192788 then--Qalashi Thaumaturge
		timerMoltenCoreCD:Stop(args.destGUID)
	end
end

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		if self.Options.AGBuffs and (gossipOptionID == 107310) then -- Blacksmith Buff
			self:SelectGossip(gossipOptionID)
		end
	end
end
