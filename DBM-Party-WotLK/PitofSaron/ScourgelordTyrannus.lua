local mod	= DBM:NewMod(610, "DBM-Party-WotLK", 15, 278)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(36658, 36661)
mod:SetEncounterID(2000)
mod:SetZone(658)
if not DBM:IsPostMidnight() then
	mod:DisableESCombatDetection()
	mod:SetUsedIcons(8)
end
mod:SetHotfixNoticeRev(20220119000000)
mod:SetMinSyncRevision(20220119000000)

mod:RegisterCombat("combat")

--TODO, some actual custom sounds and timer disables when apis added
if DBM:IsPostMidnight() then
	local warnRimeBlast					= mod:NewCountAnnounce(1262772, 3)
	local warnBoneInfusion				= mod:NewCountAnnounce(1276648, 3)

	local specWarnScourgelordsBrand		= mod:NewSpecialWarningCount(1262582, nil, nil, nil, 1, 2)
	local specWarnArmyOfTheDead			= mod:NewSpecialWarningCount(1263406, nil, nil, nil, 1, 2)
	local specWarnDeathsGrasp			= mod:NewSpecialWarningDodgeCount(1263756, nil, nil, nil, 2, 2)
	local specWarnIcyBarrage			= mod:NewSpecialWarningDodgeCount(1276948, nil, nil, nil, 2, 2)

	local timerScourgelordsBrandCD		= mod:NewCDCountTimer(20.5, 1262582, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerArmyOfTheDeadCD			= mod:NewCDCountTimer(20.5, 1263406, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerRimeBlastCD				= mod:NewCDCountTimer(20.5, 1262772, nil, nil, nil, 3)
	local timerBoneInfusionCD			= mod:NewCDCountTimer(20.5, 1276648, nil, nil, nil, 3)
	local timerDeathsGraspCD			= mod:NewCDCountTimer(20.5, 1263756, nil, nil, nil, 3)
	local timerIcyBarrageCD				= mod:NewCDCountTimer(20.5, 1276948, nil, nil, nil, 3)

	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1262772, true, 1262772, 1, 1, "debuffyou", 17)--Rime Blast

	mod.vb.brandCount = 0
	mod.vb.armyCount = 0
	mod.vb.rimeCount = 0
	mod.vb.boneCount = 0
	mod.vb.graspCount = 0
	mod.vb.barrageCount = 0
	local badStateDetected = false
	local nextTwentyEightType = nil

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		--Blizz API fallbacks
		if not dontSetAlerts then
			if self:IsTank() then
				specWarnScourgelordsBrand:SetAlert(164, "carefly", 2)
			end
			specWarnArmyOfTheDead:SetAlert(165, "mobsoon", 2)
			specWarnDeathsGrasp:SetAlert(168, "watchstep", 2)
			specWarnIcyBarrage:SetAlert(375, "watchstep", 2)
		end
		timerScourgelordsBrandCD:SetTimeline(164)
		timerArmyOfTheDeadCD:SetTimeline(165)
		timerRimeBlastCD:SetTimeline(166)
		timerBoneInfusionCD:SetTimeline(167)
		timerDeathsGraspCD:SetTimeline(168)
		timerIcyBarrageCD:SetTimeline(375)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.brandCount = 1
		self.vb.armyCount = 1
		self.vb.rimeCount = 1
		self.vb.boneCount = 1
		self.vb.graspCount = 1
		self.vb.barrageCount = 1
		nextTwentyEightType = nil
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
			)
			--SetTimeline events since user has disabled DBM Bars (so they can still get countdowns in blizzard timeline API instead)
			if DBM.Options.HideDBMBars then
				setFallback(self, true)
			end
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		nextTwentyEightType = nil
		self:UnregisterShortTermEvents()
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Logic confirmed against M+ logs. Unique durations: Brand(14), Army(52), Grasp(24), Icy Barrage(12), Rime opener(7).
			--28-second bars are context-dependent: after 7 => Rime, after that => Brand, after 12 => Bone Infusion.
			if timer == 14 then--Scourgelord's Brand opener
				timerScourgelordsBrandCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "brand", "brandCount"))
			elseif timer == 52 then--Army of the Dead
				timerArmyOfTheDeadCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "army", "armyCount"))
			elseif timer == 24 then--Death's Grasp
				timerDeathsGraspCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "grasp", "graspCount"))
			elseif timer == 12 then--Icy Barrage
				nextTwentyEightType = "bone"
				timerIcyBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "barrage", "barrageCount"))
			elseif timer == 7 then--Rime Blast opener for a Rime/Brand pair
				nextTwentyEightType = "rime"
				timerRimeBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "rime", "rimeCount"))
			elseif timer == 28 then
				if nextTwentyEightType == "rime" then
					nextTwentyEightType = "brand"
					timerRimeBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "rime", "rimeCount"))
				elseif nextTwentyEightType == "brand" then
					nextTwentyEightType = nil
					timerScourgelordsBrandCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "brand", "brandCount"))
				elseif nextTwentyEightType == "bone" then
					nextTwentyEightType = nil
					timerBoneInfusionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bone", "boneCount"))
				else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
					if not DBM.Options.DebugMode then
						badStateDetected = true
						self:ResumeBlizzardAPI()
						self:UnregisterShortTermEvents()
						setFallback(self)
						DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
					else
						DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers|r", nil, nil, nil, true)
					end
				end
			else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
				if not DBM.Options.DebugMode then
					badStateDetected = true
					self:ResumeBlizzardAPI()
					self:UnregisterShortTermEvents()
					setFallback(self)
					DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
				else
					DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers|r", nil, nil, nil, true)
				end
			end
		end

		--Note, bar state changing and canceling is handled by core
		function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
			if eventInfo.source ~= 0 then return end
			local eventID = eventInfo.id
			local timerExact = eventInfo.duration
			local timer = math.floor(timerExact + 0.5)
			if not badStateDetected then
				timersAll(self, timer, timerExact, eventID)
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			if not eventID or not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType and eventCount then
					if eventType == "brand" then
						if self:IsTank() then
							specWarnScourgelordsBrand:Show(eventCount)
							specWarnScourgelordsBrand:Play("carefly")
						end
					elseif eventType == "army" then
						specWarnArmyOfTheDead:Show(eventCount)
						specWarnArmyOfTheDead:Play("mobsoon")
					elseif eventType == "grasp" then
						specWarnDeathsGrasp:Show(eventCount)
						specWarnDeathsGrasp:Play("watchstep")
					elseif eventType == "barrage" then
						specWarnIcyBarrage:Show(eventCount)
						specWarnIcyBarrage:Play("watchstep")
					elseif eventType == "rime" then
						warnRimeBlast:Show(eventCount)
					elseif eventType == "bone" then
						warnBoneInfusion:Show(eventCount)
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEvents(
		"CHAT_MSG_MONSTER_YELL"
	)

	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 69167",
		"SPELL_CAST_SUCCESS 69155",
		"SPELL_AURA_APPLIED 69172",
		"SPELL_AURA_REMOVED 69172",
		"SPELL_PERIODIC_DAMAGE 69238",
		"SPELL_PERIODIC_MISSED 69238",
		"CHAT_MSG_RAID_BOSS_EMOTE",
		"UNIT_DIED"
	)

	local warnForcefulSmash			= mod:NewSpellAnnounce(69155, 2, nil, "Tank")
	local warnOverlordsBrand		= mod:NewTargetAnnounce(69172, 4)
	local warnHoarfrost				= mod:NewTargetAnnounce(69246, 2)

	local specWarnHoarfrost			= mod:NewSpecialWarningMoveAway(69246, nil, nil, nil, 1, 2)
	local yellHoarfrost				= mod:NewYell(69246)
	local specWarnIcyBlast			= mod:NewSpecialWarningMove(69238, nil, nil, nil, 1, 2)
	local specWarnOverlordsBrand	= mod:NewSpecialWarningReflect(69172, nil, nil, nil, 3, 2)
	local specWarnUnholyPower		= mod:NewSpecialWarningSpell(69167, nil, nil, nil, 1, 2)--Spell for now. may change to run away if damage is too high for defensive

	local timerCombatStart			= mod:NewCombatTimer(31)
	local timerOverlordsBrandCD		= mod:NewCDTimer(12, 69172, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
	local timerOverlordsBrand		= mod:NewTargetTimer(8, 69172, nil, nil, nil, 5)
	local timerUnholyPower			= mod:NewBuffActiveTimer(10, 69167, nil, "Tank|Healer", 2, 5)
	local timerHoarfrostCD			= mod:NewCDTimer(25.5, 69246, nil, nil, nil, 3)
	local timerForcefulSmash		= mod:NewCDTimer(40, 69155, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)--Highly Variable. 40-50

	mod:AddSetIconOption("SetIconOnHoarfrostTarget", 69246, true, 0, {8})

	function mod:OnCombatStart(delay)
		timerForcefulSmash:Start(9-delay)--Sems like a WTF
		timerOverlordsBrandCD:Start(-delay)
		timerHoarfrostCD:Start(31.5-delay)--Verify
	end

	function mod:OnCombatEnd()
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 69167 then					-- Unholy Power
			if self:IsTanking("player", nil, nil, true, args.sourceGUID) then--GUID used because #nochanges clasic won't enable boss unit IDs in dungeons
				specWarnUnholyPower:Show()
				specWarnUnholyPower:Play("justrun")
			end
			timerUnholyPower:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 69155 then					-- Forceful Smash
	        warnForcefulSmash:Show()
	        timerForcefulSmash:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 69172 then							-- Overlord's Brand
			timerOverlordsBrandCD:Start()
			timerOverlordsBrand:Start(args.destName)
			if args:IsPlayer() then
				specWarnOverlordsBrand:Show(args.sourceName)
				specWarnOverlordsBrand:Play("stopattack")
			else
				warnOverlordsBrand:Show(args.destName)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellId == 69172 then							-- Overlord's Brand
			timerOverlordsBrand:Stop(args.destName)
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
		if spellId == 69238 and destGUID == UnitGUID("player") and self:AntiSpam() then		-- Icy Blast, MOVE!
			specWarnIcyBlast:Show()
			specWarnIcyBlast:Play("runaway")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_DIED(args)
		if self:GetCIDFromGUID(args.destGUID) == 36658 then
			DBM:EndCombat(self)
		end
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
		if msg == L.HoarfrostTarget or msg:find(L.HoarfrostTarget) then--Probably don't need this, verify
			if not target then return end
			timerHoarfrostCD:Start()
			target = DBM:GetUnitFullName(target) or target
			if target == UnitName("player") then
				specWarnHoarfrost:Show()
				specWarnHoarfrost:Play("targetyou")
				yellHoarfrost:Yell()
			else
				warnHoarfrost:Show(target)
			end
			if target and self.Options.SetIconOnHoarfrostTarget then
				self:SetIcon(target, 8, 5)
			end
		end
	end

	function mod:CHAT_MSG_MONSTER_YELL(msg)
		if (msg == L.CombatStart or msg == L.CombatStart) then
			timerCombatStart:Start()
		end
	end
end
