local mod	= DBM:NewMod("ArtifactImpossibleFoe", "DBM-Challenges", 3)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(115638)
mod:SetEncounterID(3612)
mod.soloChallenge = true

mod:RegisterCombat("combat")
mod:SetReCombatTime(20, 5)--Basically killing of recombat restriction. mage tower lets you spam retry, we want the mod to let you

if DBM:IsPostMidnight() then
	--local specWarnImpServants = mod:NewSpecialWarningSwitch(235140, nil, nil, nil, 1, 2, nil, nil, "bigmob")
	--local specWarnDarkFury = mod:NewSpecialWarningSwitch(243111, nil, nil, nil, 1, 7, nil, nil, "attackshield")
	--local specWarnDarkFuryKick = mod:NewSpecialWarningInterrupt(243111, nil, nil, nil, 1, 2, nil, nil, "kickcast")

	--local timerImpServantsCD = mod:NewCDCountTimer(0, 235140, nil, nil, nil, 1)
	--local timerDarkFuryCD = mod:NewCDCountTimer(0, 243111, nil, nil, nil, 5)
	local badStateDetected = false
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			--specWarnImpServants:SetAlert(0, "bigmob", 2)
			--specWarnDarkFury:SetAlert(0, "attackshield", 2)
			--specWarnDarkFuryKick:SetAlert(0, "kickcast", 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		--timerImpServantsCD:SetTimeline(0, onlyColor)
		--timerDarkFuryCD:SetTimeline(0, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		badStateDetected = true
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
		"SPELL_AURA_APPLIED 243113",
		"SPELL_AURA_REMOVED 243113",
		"UNIT_DIED",
		"UNIT_SPELLCAST_SUCCEEDED boss1",
		"CHAT_MSG_RAID_BOSS_EMOTE"
	)
	--Notes:
	--NEW VOICE: attackshield
	--TODO, fix shield absorb, auto calculation doesn't work do to scaling tech. UnitAura detects invalid absorb amount
	local specWarnImpServants		= mod:NewSpecialWarningSwitch(235140, nil, nil, nil, 1, 2, nil, nil, "bigmob")--Agatha's Vengeance spellId used for now
	local specWarnDarkFury			= mod:NewSpecialWarningSwitch(243111, nil, nil, nil, 1, 7, nil, nil, "attackshield")
	local specWarnDarkFuryKick		= mod:NewSpecialWarningInterrupt(243111, nil, nil, nil, 1, 2, nil, nil, "kickcast")

	local timerImpServantsCD		= mod:NewCDTimer(45, 235140, nil, nil, nil, 1)
	local timerDarkFuryCD			= mod:NewCDTimer(51.1, 243111, nil, nil, nil, 5, nil, nil, nil, 1, 4)

	mod:AddInfoFrameOption(243111, true)

	mod.vb.phase = 1

	function mod:OnCombatStart(delay)
		self.vb.phase = 1
		timerImpServantsCD:Start(11-delay)--14 in one log, 11 in another
		timerDarkFuryCD:Start(50-delay)
	end

	function mod:OnCombatEnd()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 243113 then
			specWarnDarkFury:Show()
			specWarnDarkFury:Play("attackshield")
			if self.vb.phase == 2 then
				timerDarkFuryCD:Start(68)
			else
				timerDarkFuryCD:Start()
			end
			if self.Options.InfoFrame then
				DBM.InfoFrame:SetHeader(args.spellName)
				DBM.InfoFrame:Show(2, "enemyabsorb", args.spellName)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 243113 then
			specWarnDarkFuryKick:Show(args.sourceName)
			specWarnDarkFuryKick:Play("kickcast")
			if self.Options.InfoFrame then
				DBM.InfoFrame:Hide()
			end
		end
	end

	function mod:UNIT_DIED(args)
		if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
			DBM:EndCombat(self, true)
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 242987 then--Translocate
			if self.vb.phase == 1 then
				self.vb.phase = 2
			end
		end
	end

	--"<53.75 21:03:46> [CHAT_MSG_MONSTER_EMOTE] |TInterface\\Icons\\spell_shaman_earthquake:20|t%s readies itself to charge!#Jormog the Behemoth###Kylistà##0#0##0#12#nil#0#false#false#false#false", -- [133]
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find(L.impServants) or msg == L.impServants then
			specWarnImpServants:Show()
			specWarnImpServants:Play("bigmob")
			timerImpServantsCD:Start()
		end
	end
end
