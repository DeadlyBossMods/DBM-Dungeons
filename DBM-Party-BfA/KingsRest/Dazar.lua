local mod	= DBM:NewMod(2172, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(136160)
mod:SetEncounterID(2143)
mod:SetZone(1762)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--local warnGaleSlash					= mod:NewSpellAnnounce(268403, 2)
	--local warnQuakingLeap				= mod:NewTargetAnnounce(268932, 2)

	--local specWarnQuakingLeap			= mod:NewSpecialWarningYou(268932, nil, nil, nil, 1, 2, nil, nil, "targetyou")
	--local specWarnBladeCombo			= mod:NewSpecialWarningDefensive(268586, nil, nil, nil, 1, 2, nil, nil, "defensive")
	--local specWarnImpalingSpear			= mod:NewSpecialWarningDodge(268796, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	--local specWarnHuntingLeap			= mod:NewSpecialWarningYou(269231, nil, nil, nil, 1, 2, nil, nil, "runaway")
	--local specWarnDeadlyRoar			= mod:NewSpecialWarningSpell(269369, nil, nil, nil, 2, 2, nil, nil, "fearsoon")

	--local timerGaleSlashCD				= mod:NewCDCountTimer(0, 268403, nil, nil, nil, 3)
	--local timerQuakingLeapCD			= mod:NewCDCountTimer(0, 268932, nil, nil, nil, 3)
	--local timerBladeComboCD				= mod:NewCDCountTimer(0, 268586, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	--local timerHuntingLeapCD			= mod:NewCDCountTimer(0, 269231, nil, nil, nil, 3)
	--local timerDeathlyRoarCD			= mod:NewCDCountTimer(0, 269369, nil, nil, nil, 2)

	local badStateDetected = false
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			--specWarnQuakingLeap:SetAlert(0, "targetyou", 2)
			--specWarnBladeCombo:SetAlert(0, "defensive", 2)
			--specWarnImpalingSpear:SetAlert(0, "watchstep", 2)
			--specWarnHuntingLeap:SetAlert(0, "runaway", 2)
			--specWarnDeadlyRoar:SetAlert(0, "fearsoon", 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		--timerGaleSlashCD:SetTimeline(0, onlyColor)
		--timerQuakingLeapCD:SetTimeline(0, onlyColor)
		--timerBladeComboCD:SetTimeline(0, onlyColor)
		--timerHuntingLeapCD:SetTimeline(0, onlyColor)
		--timerDeathlyRoarCD:SetTimeline(0, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		badStateDetected = false
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents("ENCOUNTER_TIMELINE_EVENT_ADDED", "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
			setFallback(self, true)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:UnregisterShortTermEvents()
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		--Timeline routing will be added after event durations are verified.
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		--Timeline completion handling will be added with the event routing.
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 268403 268932 268586 269369",
		"SPELL_CAST_SUCCESS 269231",
		"UNIT_DIED",
		"INSTANCE_ENCOUNTER_ENGAGE_UNIT",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--(ability.id = 268932 or ability.id = 268403 or ability.id = 268586) and type = "begincast"
	--TODO:  pull:12.0, 42.3, 19.7, 23.2 (wtf?)
	local warnGaleSlash					= mod:NewSpellAnnounce(268403, 2)
	local warnQuakingLeap				= mod:NewTargetAnnounce(268932, 2)

	local specWarnQuakingLeap			= mod:NewSpecialWarningYou(268932, nil, nil, nil, 1, 2, nil, nil, "targetyou")
	local yellQuakingLeap				= mod:NewYell(268932)
	local specWarnBladeCombo			= mod:NewSpecialWarningDefensive(268586, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnImpalingSpear			= mod:NewSpecialWarningDodge(268796, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	----ADDS
	local specWarnHuntingLeap			= mod:NewSpecialWarningYou(269231, nil, nil, nil, 1, 2, nil, nil, "runaway")
	local yellHuntingLeap				= mod:NewYell(269231)
	local specWarnDeadlyRoar			= mod:NewSpecialWarningSpell(269369, nil, nil, nil, 2, 2, nil, nil, "fearsoon")
	--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

	local timerGaleSlashCD				= mod:NewCDTimer(13, 268403, nil, nil, nil, 3)
	local timerQuakingLeapCD			= mod:NewCDTimer(19.3, 268932, nil, nil, nil, 3)
	local timerBladeComboCD				= mod:NewCDTimer(14.5, 268586, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	--Adds
	local timerHuntingLeapCD			= mod:NewCDTimer(12.8, 269231, nil, nil, nil, 3)
	local timerDeathlyRoarCD			= mod:NewCDTimer(13.6, 269369, nil, nil, nil, 2)


	local seenMobs = {}

	--Handles the ICD that Boss triggers on other abilities
	local function updateAllTimers(_, ICD)
		DBM:Debug("updateAllTimers running", 3)
		if timerGaleSlashCD:GetRemaining() < ICD then
			local elapsed, total = timerGaleSlashCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerGaleSlashCD extended by: "..extend, 2)
			timerGaleSlashCD:Stop()
			timerGaleSlashCD:Update(elapsed, total+extend)
		end
		if timerQuakingLeapCD:GetRemaining() < ICD then
			local elapsed, total = timerQuakingLeapCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerQuakingLeapCD extended by: "..extend, 2)
			timerQuakingLeapCD:Stop()
			timerQuakingLeapCD:Update(elapsed, total+extend)
		end
		if timerBladeComboCD:GetRemaining() < ICD then
			local elapsed, total = timerBladeComboCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerBladeComboCD extended by: "..extend, 2)
			timerBladeComboCD:Stop()
			timerBladeComboCD:Update(elapsed, total+extend)
		end
	end

	function mod:LeapTarget(targetname)
		if not targetname then return end
		if targetname == UnitName("player") then
			specWarnQuakingLeap:Show()
			specWarnQuakingLeap:Play("targetyou")
			yellQuakingLeap:Yell()
		else
			warnQuakingLeap:Show(targetname)
		end
	end

	function mod:OnCombatStart(delay)
		timerGaleSlashCD:Start(8.4-delay)
		timerQuakingLeapCD:Start(12-delay)
		timerBladeComboCD:Start(18-delay)
	end

	function mod:OnCombatEnd()
		table.wipe(seenMobs)

	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 268403 then
			warnGaleSlash:Show()
			timerGaleSlashCD:Start()
			--updateAllTimers(self, 4.5)--Not confirmed
		elseif spellId == 268932 then
			timerQuakingLeapCD:Stop()
			timerQuakingLeapCD:Start()
			self:BossTargetScanner(args.sourceGUID, "LeapTarget", 0.05, 12, true)--0.2 seconds faster than emote still
			updateAllTimers(self, 4.5)
		elseif spellId == 268586 then
			if self:IsTanking("player", "boss1", nil, true) and self:AntiSpam(3, 1) then
				specWarnBladeCombo:Show()
				specWarnBladeCombo:Play("defensive")
			end
			timerBladeComboCD:Stop()
			timerBladeComboCD:Start()
			updateAllTimers(self, 5)
		elseif spellId == 269369 then
			specWarnDeadlyRoar:Show()
			specWarnDeadlyRoar:Play("fearsoon")
			timerDeathlyRoarCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 269231 then
			if args:IsPlayer() then
				specWarnHuntingLeap:Show()
				specWarnHuntingLeap:Play("runaway")
				yellHuntingLeap:Yell()
			end
			timerHuntingLeapCD:Start()
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 136984 then--Reban
			timerHuntingLeapCD:Stop()
		elseif cid == 136976 then--T'zala
			timerDeathlyRoarCD:Stop()
		end
	end

	function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		for i = 1, 3 do
			local unitID = "boss"..i
			local GUID = UnitGUID(unitID)
			if GUID and not seenMobs[GUID] then
				seenMobs[GUID] = true
				local cid = self:GetCIDFromGUID(GUID)
				if cid == 136984 then--Reban
					timerHuntingLeapCD:Start(5)
				elseif cid == 136976 then--T'zala
					timerDeathlyRoarCD:Start(8)
				end
			end
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 269377 then--Spokey Pattern Controller
			specWarnImpalingSpear:Show()
			specWarnImpalingSpear:Play("watchstep")
		end
	end
end
