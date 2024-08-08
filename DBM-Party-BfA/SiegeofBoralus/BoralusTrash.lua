local mod	= DBM:NewMod("BoralusTrash", "DBM-Party-BfA", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 275826 256627 256957 256709 257170 272546 257169 272713 274569 272571 272888 272711 268260 257288 454440 272662",
	"SPELL_CAST_SUCCESS 256627 256640 257170 256709 257288 272422 454437 275826 275835 272888 272546 454440 272711 257169 272571",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 256957 257168 272421 272571 272888 454437",
	"UNIT_DIED"
)

--TODO, heavy slash tank only?
--TODO, target scan Ricochet (272542)? (does it even still exist?)
--TODO, https://www.wowhead.com/beta/spell=275836/stinging-venom stack announcer for tank/healer?
--TODO, nameplate timer for Watertight shell. it has a really long CD (or is health based) and I haven't been able to find a shitter enough group to see two casts on a single mob yet
--[[
(ability.id = 275826 or ability.id = 256627 or ability.id = 256957 or ability.id = 256709 or ability.id = 257170 or ability.id = 272546 or ability.id = 257169 or ability.id = 272713 or ability.id = 274569 or ability.id = 272571 or ability.id = 272888 or ability.id = 257288 or ability.id = 268260 or ability.id = 272711 or ability.id = 275835 or ability.id = 454440 or ability.id = 272874) and type = "begincast"
 or (ability.id = 256640 or ability.id = 272422 or ability.id = 454437) and type = "cast"
 or (stoppedAbility.id = 256957 or stoppedAbility.id = 274569 or stoppedAbility.id = 272571 or stoppedAbility.id = 454440 or stoppedability.id = 275826)
 or (ability.id = 275826 or ability.id = 256627 or ability.id = 256957 or ability.id = 256709 or ability.id = 257170 or ability.id = 272546 or ability.id = 257169 or ability.id = 272713 or ability.id = 274569 or ability.id = 272571 or ability.id = 272888 or ability.id = 257288 or ability.id = 268260 or ability.id = 272711 or ability.id = 275835 or ability.id = 454440 or ability.id = 272874) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnBananaRampage				= mod:NewSpellAnnounce(272546, 2)
local warnBolsteringShout			= mod:NewCastAnnounce(275826, 4)--High Prio Interrupt
local warnWatertightShell			= mod:NewCastAnnounce(256957, 4)--High Prio Interrupt
local warnChoakingWaters			= mod:NewCastAnnounce(272571, 4)--High Prio Interrupt
local warnStinkyVomit				= mod:NewCastAnnounce(454440, 4)--High Prio Interrupt
local warnFerocity					= mod:NewCastAnnounce(272888, 3)
local warnAzeriteCharge				= mod:NewTargetAnnounce(454437, 2)
local warnBurningTar				= mod:NewSpellAnnounce(256640, 2)
local warnIronHook					= mod:NewSpellAnnounce(272662, 4, nil, nil, nil, nil, nil, 12)

local specWarnSlobberKnocker		= mod:NewSpecialWarningDodge(256627, "Tank", nil, nil, 1, 2)
local specWarnSingingSteel			= mod:NewSpecialWarningDodge(256709, "Tank", nil, nil, 1, 2)
local specWarnHeavySlash			= mod:NewSpecialWarningDodge(257288, "Tank", nil, nil, 1, 2)
local specWarnCrushingSlam			= mod:NewSpecialWarningDodge(272711, "Tank", nil, nil, 1, 2)
--local specWarnTrample				= mod:NewSpecialWarningDodge(272874, nil, nil, nil, 2, 2)
local specWarnBroadside				= mod:NewSpecialWarningDodge(268260, nil, nil, nil, 2, 2)
local specWarnSavageTempest			= mod:NewSpecialWarningRun(257170, nil, nil, nil, 4, 2)--can tank run out too? or does it follow tank
local specWarnSightedArt			= mod:NewSpecialWarningYou(272421, nil, nil, nil, 1, 2)
local yellSightedArt				= mod:NewYell(272421)
local specWarnAzeriteCharge			= mod:NewSpecialWarningMoveAway(454437, nil, nil, nil, 1, 2)
local yellAzeriteCharge				= mod:NewYell(454437)
local specWarnBolsteringShout		= mod:NewSpecialWarningInterrupt(275826, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnWatertightShell		= mod:NewSpecialWarningInterrupt(256957, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnRevitalizingMist		= mod:NewSpecialWarningInterrupt(274569, "HasInterrupt", nil, nil, 1, 2)--Same mob as choking waters, but also important
local specWarnChokingWaters			= mod:NewSpecialWarningInterrupt(272571, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnStinkyVomit			= mod:NewSpecialWarningInterrupt(454440, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnWatertightShellDispel	= mod:NewSpecialWarningDispel(256957, "MagicDispeller", nil, nil, 1, 2)
local specWarnCursedSlash			= mod:NewSpecialWarningDispel(257168, "RemoveCurse", nil, nil, 1, 2)
local specWarnFerocity				= mod:NewSpecialWarningDispel(272888, "RemoveEnrage", nil, 2, 1, 2)
local specWarnChokingWatersDispel	= mod:NewSpecialWarningDispel(272571, "RemoveMagic", nil, 2, 1, 2)
local specWarnFear					= mod:NewSpecialWarningSpell(257169, nil, nil, nil, 2, 2)

--copilot, there are no NewCDTimer objects in this mod, only NewCDNPTimer objects
--copilot, there is no DBM_CORE_L in this mod, only DBM_COMMON_L
local timerSlobberknockerCD			= mod:NewCDNPTimer(18.8, 256627, nil, nil, nil, 5)--18.8-20
local timerBurningTarCD				= mod:NewCDNPTimer(22.6, 256640, nil, nil, nil, 3)
local timerSavageTempestCD			= mod:NewCDNPTimer(19.1, 257170, nil, nil, nil, 3)
local timerSingSteelCD				= mod:NewCDNPTimer(17, 256709, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerHeavySlashCD				= mod:NewCDNPTimer(20.6, 257288, nil, nil, nil, 5)
local timerSightedArtCD				= mod:NewCDNPTimer(12.1, 272421, nil, nil, nil, 3)
local timerAzeriteChargeCD			= mod:NewCDNPTimer(15.7, 454437, nil, nil, nil, 3)
local timerBolsteringShoutCD		= mod:NewCDNPTimer(18.1, 275826, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerStingingVenomCoatingCD	= mod:NewCDNPTimer(16.9, 275835, nil, nil, nil, 5)--Lasts 10 seconds, recast time is 17 so has a high uptime
local timerFerocityCD				= mod:NewCDNPTimer(38.9, 272888, nil, nil, nil, 5)--Small sample, but it seems like a very long cooldown
local timerBananaRampageCD			= mod:NewCDNPTimer(16.9, 272546, nil, nil, nil, 3)
local timerStinkyVomitCD			= mod:NewCDNPTimer(16.1, 454440, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--16.1-19.4
local timerCrushingSlamCD			= mod:NewCDNPTimer(20.6, 272711, nil, nil, nil, 3)
local timerTerrifyingRoarCD			= mod:NewCDNPTimer(31.6, 257169, nil, nil, nil, 2)
local timerChoakingWatersCD			= mod:NewCDNPTimer(29.1, 272571, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--29.1-31.6
local timerIronHookCD				= mod:NewCDNPTimer(19.4, 272662, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 275826 then
		if self.Options.SpecWarn275826interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBolsteringShout:Show(args.sourceName)
			specWarnBolsteringShout:Play("kickcast")
		elseif self:AntiSpam(4, 7) then
			warnBolsteringShout:Show()
		end
	elseif spellId == 256627 and self:AntiSpam(3, 2) then
		specWarnSlobberKnocker:Show()
		specWarnSlobberKnocker:Play("shockwave")
	elseif spellId == 256709 and self:AntiSpam(3, 2) then
		specWarnSingingSteel:Show()
		specWarnSingingSteel:Play("shockwave")
	elseif spellId == 257170 and self:AntiSpam(4, 1) then
		specWarnSavageTempest:Show()
		specWarnSavageTempest:Play("whirlwind")
	elseif spellId == 272546 and self:AntiSpam(4, 6) then
		warnBananaRampage:Show()
	elseif spellId == 257169 and self:AntiSpam(4, 5) then
		specWarnFear:Show()
		specWarnFear:Play("fearsoon")
	elseif spellId == 256957 then
		if self.Options.SpecWarn256957interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWatertightShell:Show(args.sourceName)
			specWarnWatertightShell:Play("kickcast")
		elseif self:AntiSpam(4, 7) then
			warnWatertightShell:Show()
		end
	elseif spellId == 274569 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRevitalizingMist:Show(args.sourceName)
		specWarnRevitalizingMist:Play("kickcast")
	elseif spellId == 272571 then
		if self.Options.SpecWarn272571interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChokingWaters:Show(args.sourceName)
			specWarnChokingWaters:Play("kickcast")
		elseif self:AntiSpam(4, 7) then
			warnChoakingWaters:Show()
		end
	elseif spellId == 272888 and self:AntiSpam(4, 6) then
		warnFerocity:Show()
	elseif spellId == 272711 and self:AntiSpam(3, 2) then
		specWarnCrushingSlam:Show()
		specWarnCrushingSlam:Play("shockwave")
	elseif spellId == 268260 and args:GetSrcCreatureID() == 138465 then--Trash version
		if self:AntiSpam(3, 2) then
			specWarnBroadside:Show()
			specWarnBroadside:Play("watchstep")
		end
	elseif spellId == 257288 and args:GetSrcCreatureID() == 129879 and self:AntiSpam(3, 2) then--Trash version
		specWarnHeavySlash:Show()
		specWarnHeavySlash:Play("shockwave")
	elseif spellId == 454440 then
		if self.Options.SpecWarn454440interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnStinkyVomit:Show(args.sourceName)
			specWarnStinkyVomit:Play("kickcast")
		elseif self:AntiSpam(4, 7) then
			warnStinkyVomit:Show()
		end
	elseif spellId == 272662 then
		warnIronHook:Show()
		warnIronHook:Play("pullin")
		timerIronHookCD:Start(19.4, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 256627 then
		timerSlobberknockerCD:Start(16.8, args.sourceGUID)--18.8 - 2
	elseif spellId == 256640 then
		warnBurningTar:Show()
		timerBurningTarCD:Start(22.6, args.sourceGUID)
	elseif spellId == 257170 then
		timerSavageTempestCD:Start(16.1, args.sourceGUID)--19.1 - 3
	elseif spellId == 256709 then
		timerSingSteelCD:Start(15, args.sourceGUID)--17 - 2
	elseif spellId == 257288 and args:GetSrcCreatureID() == 129879 then
		timerHeavySlashCD:Start(17.8, args.sourceGUID)--20.6 - 2.8
	elseif spellId == 272422 then--No filter needed, boss version doesn't fire this spellID
		timerSightedArtCD:Start(12.1, args.sourceGUID)
	elseif spellId == 454437 then
		timerAzeriteChargeCD:Start(15.7, args.sourceGUID)
	elseif spellId == 275826 then
		timerBolsteringShoutCD:Start(15.6, args.sourceGUID)--18.1 - 2.5
	elseif spellId == 275835 then
		timerStingingVenomCoatingCD:Start(15.4, args.sourceGUID)--16.9 - 1.5
	elseif spellId == 272888 then
		timerFerocityCD:Start(35.9, args.sourceGUID)--38.9 - 3
	elseif spellId == 272546 then
		timerBananaRampageCD:Start(15.4, args.sourceGUID)
	elseif spellId == 454440 then
		timerStinkyVomitCD:Start(18.1, args.sourceGUID)--16.1 - 2
	elseif spellId == 272711 then
		timerCrushingSlamCD:Start(17.1, args.sourceGUID)--20.6 - 3.5
	elseif spellId == 257169 then
		timerTerrifyingRoarCD:Start(28.6, args.sourceGUID)--31.6 - 3
	elseif spellId == 272571 then
		timerChoakingWatersCD:Start(26.6, args.sourceGUID)--29.1 - 2.5
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 275826 then
		timerBolsteringShoutCD:Start(15.6, args.sourceGUID)--18.1 - 2.5
	elseif args.extraSpellId == 454440 then
		timerStinkyVomitCD:Start(18.1, args.sourceGUID)--16.1 - 2
	elseif args.extraSpellId == 272571 then
		timerChoakingWatersCD:Start(26.6, args.sourceGUID)--29.1 - 2.5
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 256957 and self:IsValidWarning(args.sourceGUID) and not args:IsDestTypePlayer() then
		specWarnWatertightShellDispel:CombinedShow(1, args.destName)
		specWarnWatertightShellDispel:ScheduleVoice(1, "helpdispel")
	elseif spellId == 257168 and self:IsValidWarning(args.sourceGUID) and self:CheckDispelFilter("curse") then
		specWarnCursedSlash:Show(args.destName)
		specWarnCursedSlash:Play("helpdispel")
	elseif spellId == 272421 and args:IsPlayer() and args:GetSrcCreatureID() ~= 129208 then--Want to filter it from firing on boss fight
		specWarnSightedArt:Show()
		specWarnSightedArt:Play("targetyou")
		yellSightedArt:Yell()
	elseif spellId == 272571 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
		specWarnChokingWatersDispel:Show(args.destName)
		specWarnChokingWatersDispel:Play("helpdispel")
	elseif spellId == 272888 and self:IsValidWarning(args.sourceGUID) then
		specWarnFerocity:Show(args.destName)
		specWarnFerocity:Play("helpdispel")
	elseif spellId == 454437 and args:IsDestTypePlayer() then
		if args:IsPlayer() then
			specWarnAzeriteCharge:Show()
			specWarnAzeriteCharge:Play("runout")
			yellAzeriteCharge:Yell()
		else
			warnAzeriteCharge:Show(args.destName)
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 129374 then--Scrimshaw Enforcer
		timerSlobberknockerCD:Stop(args.destGUID)
	elseif cid == 129372 then--Blacktar Bomber
		timerBurningTarCD:Stop(args.destGUID)
	elseif cid == 129369 then--Irontide Raider
		timerSavageTempestCD:Stop(args.destGUID)
	elseif cid == 129371 then--Riptide Shredder
		timerSingSteelCD:Stop(args.destGUID)
	elseif cid == 129879 then--Irontide Cleaver (Trash version)
		timerHeavySlashCD:Stop(args.destGUID)
	elseif cid == 141939 or cid == 138255 or cid == 135263 then--Ashvane Spotter
		timerSightedArtCD:Stop(args.destGUID)
	elseif cid == 128969 then--Ashvane Commander
		timerAzeriteChargeCD:Stop(args.destGUID)
		timerBolsteringShoutCD:Stop(args.destGUID)
	elseif cid == 137516 then--Ashvane Invader
		timerStingingVenomCoatingCD:Stop(args.destGUID)
	elseif cid == 137517 then--Ashvane Destroyer
		timerFerocityCD:Stop(args.destGUID)
	elseif cid == 129366 then--Bilge Rat Buccaneer
		timerBananaRampageCD:Stop(args.destGUID)
	elseif cid == 135241 then--Bilge Rat Pillager
		timerStinkyVomitCD:Stop(args.destGUID)
	elseif cid == 135245 then--Billage Rat Demolisher
		timerCrushingSlamCD:Stop(args.destGUID)
		timerTerrifyingRoarCD:Stop(args.destGUID)
	elseif cid == 129367 then--Bilge Rat Tempest
		timerChoakingWatersCD:Stop(args.destGUID)
	elseif cid == 129369 then--Iron Raider
		timerIronHookCD:Stop(args.destGUID)
	end
end

--Spells not in combat log what so ever, so this relies on unit event off a users target or nameplate unit IDs, then syncing to group
--In combat log in TWW+, but keeping code around in case we get a classic BfA for some insane reason
--[[
function mod:UNIT_SPELLCAST_START(uId, _, spellId)
	if spellId == 272874 then
		local guid = UnitGUID(uId)
		if guid and self:IsValidWarning(guid, uId) then
			self:SendSync("Trample")
		end
	elseif spellId == 272711 then
		local guid = UnitGUID(uId)
		if guid and self:IsValidWarning(guid, uId) then
			self:SendSync("CrushingSlam")
		end
	elseif spellId == 268260 then
		local guid = UnitGUID(uId)
		if guid and self:IsValidWarning(guid, uId) then
			self:SendSync("Broadside")
		end
	end
end

function mod:OnSync(msg)
	if msg == "Trample" and self:AntiSpam(4, 10) then
		specWarnTrample:Show()
		specWarnTrample:Play("chargemove")
	elseif msg == "CrushingSlam" and self:AntiSpam(2.5, 2) then
		specWarnCrushingSlam:Show()
		specWarnCrushingSlam:Play("shockwave")
	elseif msg == "Broadside" then
		specWarnBroadside:Show()
		specWarnBroadside:Play("watchstep")
	end
end
--]]
