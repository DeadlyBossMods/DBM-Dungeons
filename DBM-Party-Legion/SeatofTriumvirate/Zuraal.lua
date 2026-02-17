local mod	= DBM:NewMod(1979, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124871)
mod:SetEncounterID(2065)
mod:SetUsedIcons(1)

mod:RegisterCombat("combat")


if DBM:IsPostMidnight() then
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(1268916, true, 2)
	mod:AddCustomAlertSoundOption(1263399, true, 2)--oozing slam
	mod:AddCustomAlertSoundOption(1263440, true, 1)--Void Slash
	mod:AddCustomAlertSoundOption(1263304, true, 2)--Crashign Void
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(1268916, true, 3, 0)
	mod:AddCustomTimerOptions(1263282, true, 3, 0)--Decimate. Has no cast warning since we can't detect target
	mod:AddCustomTimerOptions(1263399, true, 1, 0)
	mod:AddCustomTimerOptions(1263440, true, 5, 0)
	mod:AddCustomTimerOptions(1263304, true, 2, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(244588, true, 244588, 2)--Void Sludge (GTFO)

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()
		self:EnableAlertOptions(1268916, 223, "frontal", 15)
		self:EnableAlertOptions(1263399, 225, "mobsoon", 2)
		self:EnableAlertOptions(1263440, 226, "defensive", 2)
		self:EnableAlertOptions(1263304, 238, "pullin", 12)

		self:EnableTimelineOptions(1268916, 223)
		self:EnableTimelineOptions(1263282, 224)
		self:EnableTimelineOptions(1263399, 225)
		self:EnableTimelineOptions(1263440, 226)
		self:EnableTimelineOptions(1263304, 238)

		self:EnablePrivateAuraSound(244588, "watchfeet", 8)
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 246134 244579",
		"SPELL_CAST_SUCCESS 244602",
		"SPELL_AURA_APPLIED 244657 244621",
		"SPELL_AURA_REMOVED 244657 244621",
		"SPELL_DAMAGE 244433",
	--	"CHAT_MSG_RAID_BOSS_EMOTE",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, more timer updates, warning tweaks, countdowns
	--TODO, personal alternate power and warn when extra action is ready to leave Umbra Shift
	--Void Brute
	--local warnNullPalm						= mod:NewSpellAnnounce(246134, 2, nil, "Tank")
	local warnUmbraShift					= mod:NewTargetAnnounce(244433, 3)
	local warnFixate						= mod:NewTargetAnnounce(244657, 3)
	local warnVoidTear						= mod:NewTargetAnnounce(244621, 1)

	local specWarnNullPalm					= mod:NewSpecialWarningDodge(246134, nil, nil, 2, 2, 2)
	local specWarnCoalescedVoid				= mod:NewSpecialWarningSwitch(244602, "Dps", nil, nil, 1, 2)
	local specWarnUmbraShift				= mod:NewSpecialWarningYou(244433, nil, nil, nil, 1, 5)
	local specWarnFixate					= mod:NewSpecialWarningRun(244657, nil, nil, nil, 4, 2)

	local timerNullPalmCD					= mod:NewCDTimer(10.9, 246134, nil, nil, nil, 3)
	local timerDeciminateCD					= mod:NewCDTimer(12.1, 244579, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerCoalescedVoidCD				= mod:NewCDTimer(12.1, 244602, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerUmbraShiftCD					= mod:NewCDTimer(12, 244433, nil, nil, nil, 6)
	local timerVoidTear						= mod:NewBuffActiveTimer(20, 244621, nil, nil, nil, 6)

	mod:AddSetIconOption("SetIconOnFixate", 244657, true, 0, {1})

	function mod:OnCombatStart(delay)
		timerNullPalmCD:Start(10-delay)
		timerDeciminateCD:Start(17.5-delay)
		timerCoalescedVoidCD:Start(19.5-delay)
		timerUmbraShiftCD:Start(40.5-delay)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 246134 then
			specWarnNullPalm:Show()
			specWarnNullPalm:Play("shockwave")
			timerNullPalmCD:Start()
		elseif spellId == 244579 then
			timerDeciminateCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 244602 then
			specWarnCoalescedVoid:Show()
			specWarnCoalescedVoid:Play("killmob")
			--timerCoalescedVoidCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 244657 then
			if args:IsPlayer() then
				specWarnFixate:Show()
				specWarnFixate:Play("justrun")
				specWarnFixate:ScheduleVoice(1, "keepmove")
			else
				warnFixate:Show(args.destName)
			end
			if self.Options.SetIconOnFixate then
				self:SetIcon(args.destName, 1)
			end
		elseif spellId == 244621 then--Void Tear
			warnVoidTear:Show(args.destName)
			timerVoidTear:Start()
			--Cancel Timers
			timerNullPalmCD:Stop()
			timerDeciminateCD:Stop()
			timerCoalescedVoidCD:Stop()
			timerUmbraShiftCD:Stop()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 244657 then
			if self.Options.SetIconOnFixate then
				self:SetIcon(args.destName, 0)
			end
		elseif spellId == 244621 then--Void Tear
			--Resume timers (TODO, need log, for heroic the boss died with this buff)
			--timerNullPalmCD:Start(10)
			--timerDeciminateCD:Start(17.5)
			--timerCoalescedVoidCD:Start(19.5)
			--timerUmbraShiftCD:Start(40.5)
		end
	end

	function mod:SPELL_DAMAGE(_, _, _, destName, destGUID, _, _, _, spellId)
		if spellId == 244433 then
			if destGUID == UnitGUID("player") then
				specWarnUmbraShift:Show()
				specWarnUmbraShift:Play("teleyou")
			else
				warnUmbraShift:Show(destName)
			end
		end
	end

	--[[
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find("inv_misc_monsterhorn_03") then

		end
	end
	--]]

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 247576 then--Umbra Shift
			--timerUmbraShiftCD:Start()
		end
	end
end
