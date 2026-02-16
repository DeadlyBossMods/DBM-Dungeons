local mod	= DBM:NewMod(609, "DBM-Party-WotLK", 15, 278)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(36476)
mod:SetEncounterID(2001)
mod:SetZone(658)
if not DBM:IsPostMidnight() then
	mod:SetUsedIcons(8)
end

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Note. https://www.wowhead.com/spell=1282138/shade-bomb is ignored on purpose to avoid spam
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(1264027, true, 1)--Shade Shift
	mod:AddCustomAlertSoundOption(1264336, true, 2)--Plague Expulsion
	mod:AddCustomAlertSoundOption(1264287, true, 1)--Blight Smawsh
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(1264363, nil, 3, 0)--Get 'Em, Ick! (parent of Lumbering Fixation)
	mod:AddCustomTimerOptions(1264027, nil, 1, 0)
	mod:AddCustomTimerOptions(1264336, nil, 3, 0)
	mod:AddCustomTimerOptions(1264287, nil, 5, 0)
	mod:AddCustomTimerOptions(1264453, nil, 3, 0)--Lumbering Fixation (child of Get 'Em, Ick!)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1264453, true, 1264363, 1)--Lumbering Fixation
	mod:AddPrivateAuraSoundOption(1264299, true, 1264299, 2)--Blight (GTFO)
	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()
		self:EnableAlertOptions(1264027, 204, "killmob", 2)
		self:EnableAlertOptions(1264336, 205, "watchstep", 2)--Might need changing or clarification later
		if self:IsTank() then
			self:EnableAlertOptions(1264287, 206, "defensive", 1)
		end

		self:EnableTimelineOptions(1264363, 203)
		self:EnableTimelineOptions(1264027, 204)
		self:EnableTimelineOptions(1264336, 205)
		self:EnableTimelineOptions(1264287, 206)
		self:EnableTimelineOptions(1264453, 561)

		self:EnablePrivateAuraSound(1264453, "justrun", 2)--1280616 also fires but it's redundant
		self:EnablePrivateAuraSound(1264299, "watchfeet", 8)
	end
else

	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 68987 68989 69012",
		"SPELL_AURA_APPLIED 69029",
		"SPELL_AURA_REMOVED 69029",
		"SPELL_PERIODIC_DAMAGE 69024",
		"SPELL_PERIODIC_MISSED 69024",
		"UNIT_AURA_UNFILTERED"
	)

	local warnPursuitCast			= mod:NewCastAnnounce(68987, 3)
	local warnPursuit				= mod:NewTargetNoFilterAnnounce(68987, 4)

	local specWarnToxic				= mod:NewSpecialWarningMove(69024, nil, nil, nil, 1, 2)
	local specWarnMines				= mod:NewSpecialWarningSpell(69015, nil, nil, nil, 2, 2)
	local specWarnPursuit			= mod:NewSpecialWarningRun(68987, nil, nil, 2, 4, 2)
	local specWarnPoisonNova		= mod:NewSpecialWarningRun(68989, "Melee", nil, 2, 4, 2)

	local timerSpecialCD			= mod:NewCDSpecialTimer(20)--Every 20-22 seconds. In rare cases he skips a special though and goes 40 seconds. unsure of cause
	local timerPursuitCast			= mod:NewCastTimer(5, 68987, nil, nil, nil, 3)
	local timerPursuitConfusion		= mod:NewBuffActiveTimer(12, 69029, nil, nil, nil, 5)
	local timerPoisonNova			= mod:NewCastTimer(5, 68989, nil, "Melee", 2, 2)

	mod:AddSetIconOption("SetIconOnPursuitTarget", 68987, true, 0, {8})
	--mod:GroupSpells(68987, 69029)

	local pursuit = DBM:GetSpellName(68987)
	local pursuitTable = {}

	function mod:OnCombatStart(delay)
		table.wipe(pursuitTable)
		timerSpecialCD:Start()
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 68987 then					-- Pursuit
			warnPursuitCast:Show()
			timerPursuitCast:Start()
			timerSpecialCD:Start()
		elseif spellId == 68989 then				-- Poison Nova
			timerPoisonNova:Start()
			specWarnPoisonNova:Show()
			specWarnPoisonNova:Play("runout")
			timerSpecialCD:Start()
		elseif spellId == 69012 then				--Explosive Barrage
			specWarnMines:Show()
			specWarnMines:Play("watchstep")
			timerSpecialCD:Start(22)--Will be 2 seconds longer because of how long barrage lasts
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 69029 then					-- Pursuit Confusion
			timerPursuitConfusion:Start()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellId == 69029 then					-- Pursuit Confusion
			timerPursuitConfusion:Cancel()
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
		if spellId == 69024 and destGUID == UnitGUID("player") and self:AntiSpam() then
			specWarnToxic:Show()
			specWarnToxic:Play("runaway")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_AURA_UNFILTERED(uId)
		local isPursuitDebuff = DBM:UnitDebuff(uId, pursuit)
		local name = DBM:GetUnitFullName(uId) or "UNKNOWN"
		if not isPursuitDebuff and pursuitTable[name] then
			pursuitTable[name] = nil
			if self.Options.SetIconOnPursuitTarget then
				self:SetIcon(name, 0)
			end
		elseif isPursuitDebuff and not pursuitTable[name] then
			pursuitTable[name] = true
			if UnitIsUnit(uId, "player") then
				specWarnPursuit:Show()
				specWarnPursuit:Play("justrun")
			else
				warnPursuit:Show(name)
			end
			if self.Options.SetIconOnPursuitTarget then
				self:SetIcon(name, 8)
			end
		end
	end
end
