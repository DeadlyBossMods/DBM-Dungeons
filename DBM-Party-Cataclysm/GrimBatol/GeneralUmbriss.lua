local mod	= DBM:NewMod(131, "DBM-Party-Cataclysm", 3, 71)
local L		= mod:GetLocalizedStrings()

if not mod:IsCata() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else
	mod.statTypes = "normal,heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(39625)
mod:SetEncounterID(1051)
mod:SetHotfixNoticeRev(20240614000000)
--mod:SetMinSyncRevision(20230929000000)

mod:RegisterCombat("combat")

if not mod:IsCata() then
	--Retail version of mod
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 448847 448877 447261"
	)

	local specWarnCommandingRoar	= mod:NewSpecialWarningDodgeCount(448847, nil, nil, nil, 2, 2)
	local specWarnRockSpike			= mod:NewSpecialWarningDodgeCount(448877, nil, nil, nil, 2, 2)
	local specWarnSkullsplitter		= mod:NewSpecialWarningDefensive(447261, nil, nil, nil, 1, 2)

	local timerCommandingRoarCD		= mod:NewNextCountTimer(25, 448847, nil, nil, nil, 3)
	local timerRockSpikeCD			= mod:NewNextCountTimer(25, 448877, nil, nil, nil, 3)
	local timerSkullsplitterCD		= mod:NewNextCountTimer(25, 447261, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod.vb.roarCount = 0
	mod.vb.spikeCount = 0
	mod.vb.skullCount = 0

	function mod:OnCombatStart(delay)
		self.vb.roarCount = 0
		self.vb.spikeCount = 0
		self.vb.skullCount = 0
		timerCommandingRoarCD:Start(6, 1)
		timerRockSpikeCD:Start(10, 1)
		timerSkullsplitterCD:Start(24, 1)
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 448847 then
			self.vb.roarCount = self.vb.roarCount + 1
			specWarnCommandingRoar:Show(self.vb.roarCount)
			specWarnCommandingRoar:Play("breathsoon")
			timerCommandingRoarCD:Start(nil, self.vb.roarCount+1)
		elseif args.spellId == 448877 then
			specWarnRockSpike:Show(self.vb.spikeCount)
			specWarnRockSpike:Play("watchstep")
			timerRockSpikeCD:Start(nil, self.vb.spikeCount+1)
		elseif args.spellId == 447261 then
			self.vb.skullCount = self.vb.skullCount + 1
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnSkullsplitter:Show()
				specWarnSkullsplitter:Play("defensive")
			end
			timerSkullsplitterCD:Start(nil, self.vb.skullCount+1)
		end
	end
else
	--Classic version of mod
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 74846 74853 74837 90170",
		"SPELL_CAST_START 74634",
		"CHAT_MSG_RAID_BOSS_EMOTE",
		"UNIT_HEALTH boss1",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, ground siege? 21-31 variation, too much to add timer at this time
	--TODO, review start timer placement for wound
	local warnBleedingWound		= mod:NewTargetNoFilterAnnounce(74846, 4, nil, "Tank|Healer")
	local warnMalady			= mod:NewTargetAnnounce(74837, 2)
	local warnFrenzySoon		= mod:NewSoonAnnounce(74853, 2, nil, "Tank|Healer")
	local warnFrenzy			= mod:NewSpellAnnounce(74853, 3, nil, "Tank|Healer")
	local warnBlitz				= mod:NewTargetNoFilterAnnounce(74670, 3)

	local specWarnMalice		= mod:NewSpecialWarningDefensive(90170, nil, nil, nil, 1, 2)
	local specWarnGroundSiege	= mod:NewSpecialWarningDodge(74634, "Melee", nil, nil, 2, 2)
	local specWarnBlitz			= mod:NewSpecialWarningYou(74670, nil, nil, nil, 1, 2)
	local yellBlitz				= mod:NewYell(74670)

	local specWarnSummonSkardyn	= mod:NewSpecialWarningAdds(74859, "Dps", nil, nil, 1, 2)--Seems health based, pull,and 50%?

	local timerBleedingWoundCD	= mod:NewCDCountTimer(20.5, 74846, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerBlitz			= mod:NewCDCountTimer(21.8, 74670, nil, nil, nil, 3)
	local timerMalice			= mod:NewBuffActiveTimer(20, 90170, nil, "Tank|Healer", 2, 5)

	mod.vb.warnedFrenzy = false
	mod.vb.blitzCount = 0
	mod.vb.woundCount = 0

	function mod:OnCombatStart(delay)
		self.vb.warnedFrenzy = false
		self.vb.blitzCount = 0
		self.vb.woundCount = 0
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 74846 then
			self.vb.woundCount = self.vb.woundCount + 1
			warnBleedingWound:Show(args.destName)
			timerBleedingWoundCD:Start(nil, self.vb.woundCount+1)--Is this really best place to start this CD? what if a DK can AMS it or something
		elseif spellId == 74853 then
			warnFrenzy:Show()
		elseif spellId == 74837 then
			warnMalady:CombinedShow(0.3, args.destName)
		elseif spellId == 90170 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnMalice:Show()
				specWarnMalice:Play("defensive")
			end
			timerMalice:Start()
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 74634 then
			specWarnGroundSiege:Show()
			specWarnGroundSiege:Play("watchstep")
		end
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
		if msg:find("spell:74670") then
			self.vb.blitzCount = self.vb.blitzCount + 1
			timerBlitz:Start(nil, self.vb.blitzCount+1)
			if not target then return end
			target = DBM:GetUnitFullName(target) or target
			if target == UnitName("player") then
				specWarnBlitz:Show()
				specWarnBlitz:Play("targetyou")
				yellBlitz:Yell()
			else
				warnBlitz:Show(target)
			end
		end
	end

	function mod:UNIT_HEALTH(uId)
		local h = UnitHealth(uId) / UnitHealthMax(uId) * 100
		if h > 33 and h < 38 and not self.vb.warnedFrenzy then
			warnFrenzySoon:Show()
			self.vb.warnedFrenzy = true
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 74859 then
			specWarnSummonSkardyn:Show()
			specWarnSummonSkardyn:Play("killmob")
		end
	end
end
