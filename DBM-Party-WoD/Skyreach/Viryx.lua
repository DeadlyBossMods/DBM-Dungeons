local mod	= DBM:NewMod(968, "DBM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(76266)
mod:SetEncounterID(1701)
mod:SetUsedIcons(1)

mod:RegisterCombat("combat")

--NOTE: Solar Blast alternates between 12 and 27 second cd
if DBM:IsPostMidnight() then
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(1253998, true, 1)--Cast Down
	mod:AddCustomAlertSoundOption(154396, "HasInterrupt", 1)--Solar Blast
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(1253538, true, 3, 0)
	mod:AddCustomTimerOptions(1253998, true, 1, 0)
	mod:AddCustomTimerOptions(154396, true, 4, 0)
	mod:AddCustomTimerOptions(1253531, true, 3, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1253541, true, 1253541, 1)--Scorching Ray
	mod:AddPrivateAuraSoundOption(153954, true, 1253998, 1)--Cast Down
	mod:AddPrivateAuraSoundOption(1253531, true, 1253531, 1)--Lens Flare

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()
		self:EnableAlertOptions(1253998, 310, "targetchange", 2)
		self:EnableAlertOptions(154396, 311, "kickcast", 2)

		self:EnableTimelineOptions(1253538, 309)
		self:EnableTimelineOptions(1253998, 310)
		self:EnableTimelineOptions(154396, 311)
		self:EnableTimelineOptions(1253531, 312)

		self:EnablePrivateAuraSound(1253541, "debuffyou", 17)
		self:EnablePrivateAuraSound(153954, "targetyou", 2)
		self:EnablePrivateAuraSound(1253531, "laserrun", 2)
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 154055",
		"SPELL_CAST_START 154055",
		"SPELL_PERIODIC_DAMAGE 154043",
		"SPELL_ABSORBED 154043",
		"UNIT_DIED",
		"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5"--On a bad pull you can very much have 3-4 adds.
	)

	--TODO, had bugged transcriptor so no IEEU events. See if IEEU is better for adds joining fight.
	local warnCastDown			= mod:NewTargetNoFilterAnnounce(153954, 4)
	local warnShielding			= mod:NewTargetNoFilterAnnounce(154055, 2)

	local specWarnCastDownSoon	= mod:NewSpecialWarningSoon(153954, nil, nil, nil, 1, 2)--Everyone, becaus it can grab healer too, which affects healer/tank
	local specWarnCastDown		= mod:NewSpecialWarningSwitch(153954, "Dps", nil, nil, 3, 2)--Only dps, because it's their job to stop it.
	local specWarnLensFlareCast	= mod:NewSpecialWarningSpell(154043, nil, nil, nil, 2, 2)--If there is any way to find actual target, like maybe target scanning, this will be changed.
	local specWarnLensFlare		= mod:NewSpecialWarningGTFO(154043, nil, nil, nil, 1, 8)
	local specWarnAdd			= mod:NewSpecialWarning("specWarnAdd", "Dps", nil, nil, 1, 2)
	local specWarnShielding		= mod:NewSpecialWarningInterrupt(154055, "HasInterrupt", nil, 2, 1, 2)

	local timerLenseFlareCD		= mod:NewCDTimer(38, 154043, nil, nil, nil, 3)
	local timerCastDownCD		= mod:NewCDTimer(28, 153954, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)

	mod:AddSetIconOption("SetIconOnCastDown", 153954, true, 0, {1})

	mod.vb.lastGrab = nil
	local skyTrashMod = DBM:GetModByName("SkyreachTrash")

	function mod:CastDownTarget(targetname, uId)
		if not targetname then return end
		self.vb.lastGrab = targetname
		warnCastDown:Show(self.vb.lastGrab)
		if self.Options.SetIconOnCastDown then
			self:SetIcon(self.vb.lastGrab, 1)
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.lastGrab = nil
		timerCastDownCD:Start(15-delay)
		timerLenseFlareCD:Start(27.3-delay)
		if skyTrashMod and skyTrashMod.Options.RangeFrame and skyTrashMod.vb.debuffCount ~= 0 then--In case of bug where range frame gets stuck open from trash pulls before this boss.
			skyTrashMod.vb.debuffCount = 0--Fix variable
			DBM.RangeCheck:Hide()--Close range frame.
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 154055 then
			warnShielding:Show(args.destName)
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 154055 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShielding:Show(args.sourceName)
			specWarnShielding:Play("kickcast")
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 154043 and destGUID == UnitGUID("player") and self:AntiSpam(2) then
			specWarnLensFlare:Show(spellName)
			specWarnLensFlare:Play("watchfeet")
		end
	end
	mod.SPELL_ABSORBED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 76267 then--Solar Zealot
			if self.Options.SetIconOnCastDown and self.vb.lastGrab then
				self:SetIcon(self.vb.lastGrab, 0)
				self.vb.lastGrab = nil
			end
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 153954 then--Cast Down (4-5 sec before pre warning)
			specWarnCastDownSoon:Show()
			self:BossTargetScanner(76266, "CastDownTarget", 0.05, 15)
			specWarnCastDownSoon:Play("mobsoon")
		elseif spellId == 165834 then--Force Demon Creator to Ride Me
			--TODO, see if victom detectable here instead
			timerCastDownCD:Start()
			if self.vb.lastGrab and self.vb.lastGrab ~= UnitName("player") then
				specWarnCastDown:Show()
				specWarnCastDown:Play("helpme")
				specWarnCastDown:ScheduleVoice(2, "helpme2")
			end
		elseif spellId == 154049 then-- Call Adds
			specWarnAdd:Show()
			specWarnAdd:Play("killmob")
		elseif spellId == 154032 then--Actual Lens Flare cast. 154043 is not cast, despite SUCCESS event. It only fires if beam makes contact with a player. Then SPELL_CAST_SUCCESS and SPELL_AURA_APPLIED fire
			specWarnLensFlareCast:Show()
			specWarnLensFlareCast:Play("watchstep")
			timerLenseFlareCD:Start()
		end
	end
end
