local mod	= DBM:NewMod(1207, "DBM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

if (wowToc >= 100200) then
	mod.upgradedMPlus = true
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(83894, 83892, 83893)--Dulhu 83894, Gola 83892, Telu 83893
mod:SetEncounterID(1757)
mod:SetHotfixNoticeRev(20231021000000)
mod:SetMinSyncRevision(20231021000000)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 168082 427498 427459 427509",
		"SPELL_CAST_SUCCESS 427510",
		"SPELL_AURA_APPLIED 168082 427510",
	--	"SPELL_AURA_APPLIED_DOSE",
	--	"SPELL_AURA_REMOVED",
	--	"SPELL_AURA_REMOVED_DOSE",
	--	"SPELL_PERIODIC_DAMAGE",
	--	"SPELL_PERIODIC_MISSED",
		"UNIT_DIED"
	--	"UNIT_SPELLCAST_SUCCEEDED boss1"
	)
	--[[
	(ability.id = 168082 or ability.id = 427498 or ability.id = 427459 or ability.id = 427509) and type = "begincast"
	 or ability.id = 427510 and type = "cast"
	 or (target.id = 83894 or target.id = 83892 or target.id = 83893) and type = "death"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	--General
	--local specWarnGTFO								= mod:NewSpecialWarningGTFO(409058, nil, nil, nil, 1, 8)
	--Life Warden Gola
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(10409))
	local warnTorrentialFury							= mod:NewCountAnnounce(427498, 4)

	local specWarnRevitalize							= mod:NewSpecialWarningInterruptCount(168082, "HasInterrupt", nil, nil, 1, 2)
	local specWarnRevitalizeDispel						= mod:NewSpecialWarningDispel(168082, "MagicDispeller", nil, nil, 1, 2)

	local timerRevitalizeCD								= mod:NewCDCountTimer(17, 168082, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	local timerTorrentialFuryCD							= mod:NewCDCountTimer(50.9, 427498, nil, nil, nil, 2)
	--Earthshaper Telu
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(10413))
	local warnTerrestrialFury							= mod:NewCountAnnounce(427509, 4)

	local specWarnToxicBloom							= mod:NewSpecialWarningInterruptCount(427459, "HasInterrupt", nil, nil, 1, 2)

	local timerToxicBloomCD								= mod:NewCDCountTimer(17, 427459, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	local timerTerrestrialFuryCD						= mod:NewCDCountTimer(50.9, 427509, nil, nil, nil, 2)
	--Dulhu
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(10417))
	local warnNoxiousCharge								= mod:NewTargetNofilterAnnounce(427510, 3)

	local specWarnNoxiousCharge							= mod:NewSpecialWarningYou(427510, nil, nil, nil, 3, 2)
	local yellNoxiousCharge								= mod:NewShortYell(427510)

	local timerNoxiousChargeCD							= mod:NewCDCountTimer(17, 427510, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod.vb.revitalizeCount = 0
	mod.vb.torrentialCount = 0
	mod.vb.bloomCount = 0
	mod.vb.terrestrialCount = 0
	mod.vb.chargeCount = 0
	mod.vb.golaDead = false
	mod.vb.teluDead = false
	mod.vb.golaGUID = nil
	mod.vb.teluGUID = nil

	--Delay used to get boss GUIDs before initial timers so timers can be assigned to correct nameplates on engage
	local function scanBosses(self, delay)
		for i = 1, 3 do
			local unitID = "boss"..i
			if UnitExists(unitID) then
				local cid = self:GetUnitCreatureId(unitID)
				local bossGUID = UnitGUID(unitID)
				--All timers obviously -1
				if cid == 83894 then--Dulhu
					timerNoxiousChargeCD:Start(11.1, 1, bossGUID)
				elseif cid == 83892 then--Gola
					self.vb.golaGUID = bossGUID
					--timerRevitalizeCD:Start(30.5, 1, bossGUID)--Not started here, because Torrential triggers it's 30.3 reset when it's cast
					--timerTorrentialFuryCD:Start(1, bossGUID)--Cast on engage pretty much
				else--Telu
					self.vb.teluGUID = bossGUID
					timerToxicBloomCD:Start(6.2, 1, bossGUID)
					timerTerrestrialFuryCD:Start(29.3, 1, bossGUID)
				end
			end
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.revitalizeCount = 0
		self.vb.torrentialCount = 0
		self.vb.bloomCount = 0
		self.vb.terrestrialCount = 0
		self.vb.chargeCount = 0
		self.vb.golaDead = false
		self.vb.teluDead = false
		self.vb.golaGUID = nil
		self.vb.teluGUID = nil
		self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
	end

	--function mod:OnCombatEnd()
	--	if self.Options.RangeFrame then
	--		DBM.RangeCheck:Hide()
	--	end
	--end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 168082 then
			self.vb.revitalizeCount = self.vb.revitalizeCount + 1
			local count = self.vb.revitalizeCount
			specWarnRevitalize:Show(args.sourceName, count)
			timerRevitalizeCD:Start(nil, self.vb.revitalizeCount+1, args.sourceGUID)
			if count == 1 then
				specWarnRevitalize:Play("kick1r")
			elseif count == 2 then
				specWarnRevitalize:Play("kick2r")
			elseif count == 3 then
				specWarnRevitalize:Play("kick3r")
			elseif count == 4 then
				specWarnRevitalize:Play("kick4r")
			elseif count == 5 then
				specWarnRevitalize:Play("kick5r")
			else
				specWarnRevitalize:Play("kickcast")
			end
		elseif spellId == 427459 then
			if not self.vb.teluGUID then--In cases of late IEEU and failure to cache guid on engage
				self.vb.teluGUID = args.sourceGUID
			end
			self.vb.bloomCount = self.vb.bloomCount + 1
			local count = self.vb.bloomCount
			specWarnToxicBloom:Show(args.sourceName, count)
			timerToxicBloomCD:Start(nil, self.vb.bloomCount+1, args.sourceGUID)
			if count == 1 then
				specWarnToxicBloom:Play("kick1r")
			elseif count == 2 then
				specWarnToxicBloom:Play("kick2r")
			elseif count == 3 then
				specWarnToxicBloom:Play("kick3r")
			elseif count == 4 then
				specWarnToxicBloom:Play("kick4r")
			elseif count == 5 then
				specWarnToxicBloom:Play("kick5r")
			else
				specWarnToxicBloom:Play("kickcast")
			end
		elseif spellId == 427498 then
			if not self.vb.golaGUID then--In cases of late IEEU and failure to cache guid on engage
				self.vb.golaGUID = args.sourceGUID
			end
			self.vb.torrentialCount = self.vb.torrentialCount + 1
			warnTorrentialFury:Show(self.vb.torrentialCount)
			if not self.vb.teluDead then--Won't be cast again if Telu dead
				timerTorrentialFuryCD:Start(nil, self.vb.torrentialCount+1, args.sourceGUID)
			end
			--Sets Revitalize interrupt timer to 30.3, cleaner than doing it by count and more accurate too
			timerRevitalizeCD:HardStop(args.sourceGUID)
			timerRevitalizeCD:Start(30.3, self.vb.revitalizeCount+1, args.sourceGUID)
		elseif spellId == 427509 then
			self.vb.terrestrialCount = self.vb.terrestrialCount + 1
			warnTerrestrialFury:Show(self.vb.terrestrialCount)
			if not self.vb.golaDead then--Won't be cast again if gola is dead
				timerTerrestrialFuryCD:Start(nil, self.vb.terrestrialCount+1, args.sourceGUID)
			end
			--Sets bloom interrupt timer to 30.3, cleaner than doing it by count and more accurate too
			timerToxicBloomCD:HardStop(args.sourceGUID)
			timerToxicBloomCD:Start(30.3, self.vb.bloomCount+1, args.sourceGUID)
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 427510 then
			self.vb.chargeCount = self.vb.chargeCount + 1
			timerNoxiousChargeCD:Start(nil, args.sourceGUID)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 168082 then
			specWarnRevitalizeDispel:Show(args.destName)
			specWarnRevitalizeDispel:Play("dispelboss")
		elseif spellId == 427510 then
			if args:IsPlayer() then
				specWarnNoxiousCharge:Show()
				specWarnNoxiousCharge:Play("targetyou")
				yellNoxiousCharge:Yell()
			else
				warnNoxiousCharge:Show(args.destName)
			end
		end
	end

	--[[
	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 409058 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
	--]]

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 83892 then--Gola
			self.vb.golaDead = true
			timerRevitalizeCD:HardStop(args.destGUID)
			timerTorrentialFuryCD:HardStop(args.destGUID)
			--Also stops Terrestrial Fury CD timer
			timerTerrestrialFuryCD:HardStop(self.vb.teluGUID)
		elseif cid == 83893 then--Telu
			self.vb.teluDead = true
			timerToxicBloomCD:HardStop(args.destGUID)
			--Does a unique reset on Revitalize
			--https://www.warcraftlogs.com/reports/kZAbmPhKT3vjdtw6#fight=last&pins=2%24Off%24%23244F4B%24expression%24%09(ability.id%20%3D%20168082%20or%20ability.id%20%3D%20427498%20or%20ability.id%20%3D%20427459%20or%20ability.id%20%3D%20427509)%20and%20type%20%3D%20%22begincast%22%20%09%20or%20ability.id%20%3D%20427510%20and%20type%20%3D%20%22cast%22%20%09%20or%20(target.id%20%3D%2083894%20or%20target.id%20%3D%2083892%20or%20target.id%20%3D%2083893)%20and%20type%20%3D%20%22death%22%20%09%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
			--https://www.warcraftlogs.com/reports/k41D2nZAtFbwTj6Q#fight=18&pins=2%24Off%24%23244F4B%24expression%24%09(ability.id%20%3D%20168082%20or%20ability.id%20%3D%20427498%20or%20ability.id%20%3D%20427459%20or%20ability.id%20%3D%20427509)%20and%20type%20%3D%20%22begincast%22%20%09%20or%20ability.id%20%3D%20427510%20and%20type%20%3D%20%22cast%22%20%09%20or%20(target.id%20%3D%2083894%20or%20target.id%20%3D%2083892%20or%20target.id%20%3D%2083893)%20and%20type%20%3D%20%22death%22%20%09%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
			--https://www.warcraftlogs.com/reports/6tyz9wfYHb3jFD8m#fight=7&pins=2%24Off%24%23244F4B%24expression%24%09(ability.id%20%3D%20168082%20or%20ability.id%20%3D%20427498%20or%20ability.id%20%3D%20427459%20or%20ability.id%20%3D%20427509)%20and%20type%20%3D%20%22begincast%22%20%09%20or%20ability.id%20%3D%20427510%20and%20type%20%3D%20%22cast%22%20%09%20or%20(target.id%20%3D%2083894%20or%20target.id%20%3D%2083892%20or%20target.id%20%3D%2083893)%20and%20type%20%3D%20%22death%22%20%09%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
			--[[
				--Below extrapolation is only scenario that works for all 3 pulls but seems pretty extreme even for blizzard
				--Here is the work
				8.8 remaining CD on death for revitalize (As determined by last Torentail cast and 30.3 rule)
				Next revitalized was cast 41.6 after telu death
				Time Added 32.8 (doesn't match other pulls, not the answer)
				29.549 remaining on Torential (also not the answer)
				29.549+8.8 = 38.349 (falls short of target goal by bigger margin than I'd accept)
				+2.8 for remaining CD on terrential = 41.1. 41.1 lands within margin of error for 41.6 (~0.5)

				4 remaining on revitalize cd on death (As determined by last Torentail cast and 30.3 rule)
				Next Revitalize was cast 29.6 after telu death
				Time Added 25.6 (doesn't match other pulls, not the answer)
				24.7 Remaining on Torrential (also not the answer)
				24.7+4 = 28.7, (28.7 not to short, but why does it work here and not other 2 pulls)
				+Because 0 remaining CD on Terrential CD. So it was 24.7+4+0. still 28.7 but it's within margin of error for 29.6 (~0.9)

				11.3 emaining on revitalize cd on death (As determined by last Torentail cast and 30.3 rule)
				Next Revitalize was cast 51.4 after telu death
				Time Added 40.1 (doesn't match other pulls, not the answer)
				32.037 remaining on torrential (also not the answer)
				32+11.3 (43.3 way too short of target margin)
				+6.569 for remaining CD on terrential=49.869 which is within margin of error for 51.4 (~1.5)

				TL/DR: Revitalize Restarted and set to (time remaining on revitalize) + (time remaining on Terrestrial) + (time remaining on Torrential)
			--]]
			--Leave it to blizzard for some convoluted scripting, but this actually works. It's the ONLY solution that works in all 3 of them
			--TODO, move away from hard pulling frim timers (that user might have disabled) and time stamping last cast of each of these
			local torrRemaining = timerTorrentialFuryCD:GetRemaining(self.vb.torrentialCount+1, self.vb.golaGUID)
			local terrRemaining = timerTerrestrialFuryCD:GetRemaining(self.vb.terrestrialCount+1, args.destGUID)
			local revRemaining = timerRevitalizeCD:GetRemaining(self.vb.revitalizeCount+1, self.vb.golaGUID)
			timerRevitalizeCD:HardStop(self.vb.golaGUID)
			if torrRemaining and terrRemaining and revRemaining then
				timerRevitalizeCD:Start(torrRemaining+terrRemaining+revRemaining, self.vb.revitalizeCount+1, self.vb.golaGUID)
			end
			--These timers stopped after I pull data from them for above
			timerTerrestrialFuryCD:HardStop(args.destGUID)
			--Also stops Torrential Fury CD timer
			timerTorrentialFuryCD:HardStop(self.vb.golaGUID)
		elseif cid == 83894 then--Dulhu
			timerNoxiousChargeCD:HardStop(args.destGUID)
		end
	end
else
	--10.1.7 on retail, and classic if it happens (if it doesn't happen old version of mod will be retired)
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 168082 168041 168105 168383 175997",
		"SPELL_CAST_SUCCESS 168375",
		"SPELL_AURA_APPLIED 168105 168041 168520",
		"SPELL_AURA_REMOVED 168520",
		"SPELL_PERIODIC_DAMAGE 167977",
		"SPELL_ABSORBED 167977",
		"UNIT_DIED"
	)

	--Timers are too difficult to do, rapidTides messes up any chance of ever having decent timers.
	--TODO, check if timers more stable in DF version, probably not
	--General
	local warnShapersFortitude			= mod:NewTargetNoFilterAnnounce(168520, 3)

	local timerShapersFortitude			= mod:NewTargetTimer(8, 168520, nil, false, 2, 5)

	mod:AddNamePlateOption("NPAuraOnFort", 168520)
	--Life Warden Gola
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(10409))
	local specWarnRevitalizingWaters	= mod:NewSpecialWarningInterrupt(168082, "HasInterrupt", nil, 2, 1, 2)
	local specWarnRapidTidesDispel		= mod:NewSpecialWarningDispel(168105, "MagicDispeller", nil, nil, 3, 2)
	--Earthshaper Telu
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(10413))
	local specWarnBramble				= mod:NewSpecialWarningGTFO(167977, nil, nil, nil, 1, 8)
	local specWarnBriarskin				= mod:NewSpecialWarningInterrupt(168041, false, nil, nil, 1, 2)--if you have more than one interruptor, great. but off by default because we can't assume you can interrupt every bosses abilities. and heal takes priority
	local specWarnBriarskinDispel		= mod:NewSpecialWarningDispel(168041, false, nil, nil, 1, 2)--Not as important as rapid Tides and to assume you have at least two dispellers is big assumption
	--Dulhu
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(10417))
	local warnGraspingVine				= mod:NewTargetNoFilterAnnounce(168375, 2)

	local specWarnNoxious				= mod:NewSpecialWarningRun(175997, nil, nil, 2, 4, 2)
	local specWarnSlash					= mod:NewSpecialWarningDodge(168383, nil, nil, nil, 2, 2)
	local yellSlash						= mod:NewYell(168383)

	local timerNoxiousCD				= mod:NewCDTimer(16, 175997, nil, "Melee", nil, 2)
	local timerGraspingVineCD			= mod:NewNextTimer(30.4, 168375, nil, nil, nil, 3)

	mod.vb.lastGrasping = nil

	function mod:OnCombatStart(delay)
		self.vb.lastGrasping = nil
		if self.Options.NPAuraOnFort then
			DBM:FireEvent("BossMod_EnableHostileNameplates")
		end
	end

	function mod:OnCombatEnd()
		if self.Options.NPAuraOnFort then
			DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
		end
	end

	function mod:GraspingVineTarget(targetname, uId)
		if not targetname then
			self.vb.lastGrasping = nil
			return
		end
		warnGraspingVine:Show(targetname)
		self.vb.lastGrasping = targetname
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 168082 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRevitalizingWaters:Show(args.sourceName)
			specWarnRevitalizingWaters:Play("kickcast")
		elseif spellId == 168041 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBriarskin:Show(args.sourceName)
			specWarnBriarskin:Play("kickcast")
		elseif spellId == 168383 then
			if self.vb.lastGrasping and self.vb.lastGrasping == UnitName("player") then
				yellSlash:Yell()
			else
				specWarnSlash:Show()
				specWarnSlash:Play("watchstep")
			end
		elseif spellId == 175997 then
			specWarnNoxious:Show()
			timerNoxiousCD:Start(nil, args.sourceGUID)
			specWarnNoxious:Play("justrun")
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 168375 then
			self:BossTargetScanner(83894, "GraspingVineTarget", 0.05, 10)
			timerGraspingVineCD:Start(nil, args.sourceGUID)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 168105 then
			specWarnRapidTidesDispel:Show(args.destName)
			specWarnRapidTidesDispel:Play("dispelboss")
		elseif spellId == 168041 then
			specWarnBriarskinDispel:Show(args.destName)
			specWarnBriarskinDispel:Play("dispelboss")
		elseif spellId == 168520 then
			warnShapersFortitude:Show(args.destName)
			timerShapersFortitude:Start(args.destName)
			if self.Options.NPAuraOnFort then
				DBM.Nameplate:Show(true, args.destGUID, spellId, nil, 8)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 168520 then
			timerShapersFortitude:Cancel(args.destName)
			if self.Options.NPAuraOnFort then
				DBM.Nameplate:Hide(true, args.destGUID, spellId)
			end
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 167977 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
			specWarnBramble:Show(spellName)
			specWarnBramble:Play("watchfeet")
		end
	end
	mod.SPELL_ABSORBED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 83894 then
			timerNoxiousCD:Cancel()
		end
	end
end
