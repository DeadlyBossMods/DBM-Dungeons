local mod	= DBM:NewMod(608, "DBM-Party-WotLK", 15, 278)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(36494)
mod:SetEncounterID(1999)
mod:SetZone(658)
if not DBM:IsPostMidnight() then
	mod:SetUsedIcons(8)
end

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnThrowSaronite					= mod:NewCountAnnounce(1261286, 3)

	local specWarnOrebreaker				= mod:NewSpecialWarningDodgeCount(1261546, nil, nil, nil, 2, 2)--The dodge 4-5 seconds after orebreaker debuffs
	local specWarnCryostomp					= mod:NewSpecialWarningCount(1261847, nil, nil, nil, 2, 2)
	local specWarnGlacialOverload			= mod:NewSpecialWarningCount(1262029, nil, nil, nil, 2, 12)

	local timerOrebreakerCD					= mod:NewCDCountTimer(20.5, 1261546, nil, nil, nil, 5)
	local timerCryostompCD					= mod:NewCDCountTimer(20.5, 1261847, nil, nil, nil, 2)
	local timerThrowSaroniteCD				= mod:NewCDCountTimer(20.5, 1261286, nil, nil, nil, 3)
	local timerGlacialOverloadCD			= mod:NewCDCountTimer(20.5, 1262029, nil, nil, nil, 2)

	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1261286, true, 1261286, 1, 1, "debuffyou", 17)--Throw Saronite
	mod:AddPrivateAuraSoundOption(1261540, true, 1261540, 1, 1, "targetyou", 2)--Orebreaker
	mod:AddPrivateAuraSoundOption(1261799, true, 1261799, 1, 2, "watchfeet", 8)--Glacial Overload (GTFO)

	mod.vb.orebreakerCount = 0
	mod.vb.cryostompCount = 0
	mod.vb.saroniteCount = 0
	mod.vb.glacialCount = 0
	local badStateDetected = false

	---@param self DBMMod
	local function setFallback(self)
		--Blizz API fallbacks
		--specWarnOrebreaker:SetAlert(144, "targetyou", 2, 3, 0)--backup pif private aura for Orebreaker gets removed
		specWarnCryostomp:SetAlert(145, "aesoon", 2)
		specWarnGlacialOverload:SetAlert(147, "breaklos", 12)
		timerOrebreakerCD:SetTimeline(144)
		timerCryostompCD:SetTimeline(145)
		timerThrowSaroniteCD:SetTimeline(146)
		timerGlacialOverloadCD:SetTimeline(147)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.orebreakerCount = 1
		self.vb.cryostompCount = 1
		self.vb.saroniteCount = 1
		self.vb.glacialCount = 1
		if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
			)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:UnregisterShortTermEvents()
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Logic confirmed against M+ logs. Pattern: Glacial Overload(33)/Throw Saronite(7)/Orebreaker(20)/Cryostomp(42 or 0). Bars with duration 0 are placeholders always canceled.
			if timer == 0 then return end--Placeholder Cryostomp, always canceled
			if timer == 7 then--Throw Saronite
				timerThrowSaroniteCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "saronite", "saroniteCount"))
			elseif timer == 20 then--Orebreaker
				timerOrebreakerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "orebreaker", "orebreakerCount"))
			elseif timer == 33 then--Glacial Overload
				timerGlacialOverloadCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "glacial", "glacialCount"))
			elseif timer == 42 then--Cryostomp (real)
				timerCryostompCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "cryostomp", "cryostompCount"))
			else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
				if not DBM.Options.DebugMode then
					badStateDetected = true
					if DBM.Options.IgnoreBlizzAPI then
						DBM.Options.IgnoreBlizzAPI = false
						DBM:FireEvent("DBM_ResumeBlizzAPI")
					end
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
					if eventType == "cryostomp" then
						specWarnCryostomp:Show(eventCount)
						specWarnCryostomp:Play("aesoon")
					elseif eventType == "saronite" then
						warnThrowSaronite:Show(eventCount)
					elseif eventType == "glacial" then
						specWarnGlacialOverload:Show(eventCount)
						specWarnGlacialOverload:Play("breaklos")
					elseif eventType == "orebreaker" then
						specWarnOrebreaker:Schedule(4, eventCount)
						specWarnOrebreaker:ScheduleVoice(4, "watchstep")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end

else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 68788",
		"SPELL_AURA_APPLIED 70381 68785",
		"SPELL_AURA_APPLIED_DOSE 68786",
	--	"CHAT_MSG_RAID_BOSS_EMOTE",
		"RAID_BOSS_WHISPER",
		"CHAT_MSG_ADDON"
	)

	local warnForgeWeapon			= mod:NewSpellAnnounce(68785, 2)
	local warnDeepFreeze			= mod:NewTargetNoFilterAnnounce(70381, 2)
	local warnSaroniteRock			= mod:NewTargetAnnounce(68789, 3)

	local specWarnSaroniteRock		= mod:NewSpecialWarningYou(68789, nil, nil, nil, 1, 2)
	local yellRock					= mod:NewYell(68789)
	local specWarnPermafrost		= mod:NewSpecialWarningStack(68786, nil, 9, nil, nil, 1, 2)

	local timerSaroniteRockCD		= mod:NewCDTimer(15.5, 68789, nil, nil, nil, 3)--15.5-20
	local timerDeepFreezeCD			= mod:NewCDTimer(19, 70381, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON)
	local timerDeepFreeze			= mod:NewTargetTimer(14, 70381, nil, false, 3, 5)

	mod:AddSetIconOption("SetIconOnSaroniteRockTarget", 68789, true, 0, {8})

	function mod:SPELL_CAST_START(args)
		if args.spellId == 68788 then
			timerSaroniteRockCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 70381 then		-- Deep Freeze
			--Can be warned 2 seconds earlier using emote
			--For now I willn ot change it though
			warnDeepFreeze:Show(args.destName)
			timerDeepFreeze:Start(args.destName)
			timerDeepFreezeCD:Start()
		elseif spellId == 68785 then	-- Forge Frostborn Mace
			warnForgeWeapon:Show()
		end
	end

	function mod:SPELL_AURA_APPLIED_DOSE(args)
		if args.spellId == 68786 then
			local amount = args.amount or 1
			if amount >= 9 and args:IsPlayer() and self:AntiSpam(5) then --11 stacks is what's needed for achievement, 9 to give you time to clear/dispel
				specWarnPermafrost:Show(amount)
				specWarnPermafrost:Play("stackhigh")
			end
		end
	end

	--"<125.43 21:07:21> [CHAT_MSG_RAID_BOSS_EMOTE] %s casts |cFF00AACCDeep Freeze|r at Moonianna.#Forgemaster Garfrost###Moonianna##0#0##0#870#nil#0#false#false#false#false", -- [1]
	--function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, npc, _, _, targetname)
	--	warnDeepFreeze:Show(targetname)
	--end

	function mod:RAID_BOSS_WHISPER(msg)
		--Commented out string check for now, since it should be the only thing on fight sending RAID_BOSS_WHISPER
	--	if msg == L.SaroniteRockThrow or msg:match(L.SaroniteRockThrow) then
			specWarnSaroniteRock:Show()
			specWarnSaroniteRock:Play("watchstep")
			yellRock:Yell()
	--	end
	end

	--per usual, use transcriptor message to get messages from both bigwigs and DBM, all without adding comms to this mod at all
	function mod:CHAT_MSG_ADDON(prefix, msg, channel, targetName)
		if prefix ~= "Transcriptor" then return end
		--Could maybe drop localized text, but it risks breaking if someone happens to be in party (in a different place and is also sending RBW syncs)
		if msg == L.SaroniteRockThrow or msg:find(L.SaroniteRockThrow) then
			targetName = Ambiguate(targetName, "none")
			if self:AntiSpam(5, targetName) then--Antispam sync by target name, since this doesn't use dbms built in onsync handler.
				local uId = DBM:GetRaidUnitId(targetName)
				if uId and not UnitIsUnit(uId, "player") then
					warnSaroniteRock:Show(targetName)
				end
				if self.Options.SetIconOnSaroniteRockTarget then
					self:SetIcon(targetName, 8, 5)
				end
			end
		end
	end
end
