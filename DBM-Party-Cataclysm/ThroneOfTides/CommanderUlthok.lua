local mod	= DBM:NewMod(102, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

if (wowToc >= 100200) then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
	mod.sendMainBossGUID = true
else--TODO, refine for cata classic since no timewalker there
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40765)
mod:SetEncounterID(1044)

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 427672 427456 427668 427670",
		"SPELL_AURA_APPLIED 427559"
	)

	--[[
(ability.id = 427672 or ability.id = 427456 or ability.id = 427668 or ability.id = 427670) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	--TODO, more timer data needed (longer pulls)
	local warnAwakenOoze								= mod:NewCountAnnounce(427456, 3)

	local specWarnBubblingFissure						= mod:NewSpecialWarningDodge(427672, nil, nil, nil, 2, 2)
	local specWarnFesteringShockwave					= mod:NewSpecialWarningCount(427668, nil, nil, nil, 2, 2)
	local specWarnCrushingClaw							= mod:NewSpecialWarningDefensive(427670, nil, nil, nil, 1, 2)
	local specWarnGTFO									= mod:NewSpecialWarningGTFO(427559, nil, nil, nil, 1, 8)

	local timerBubblingFissureCD						= mod:NewCDTimer(32.3, 427672, nil, nil, nil, 3)--32-34
	local timerAwakenOozeCD								= mod:NewCDCountTimer(48.5, 427456, nil, nil, nil, 1)
	local timerFesteringShockwaveCD						= mod:NewCDCountTimer(32.7, 427668, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
	local timerCrushingClawCD							= mod:NewCDCountTimer(26.7, 427670, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod.vb.oozeCount = 0
	mod.vb.festeringCount = 0
	mod.vb.clawCount = 0
	--Delays usually caused by a 6 second lockout from Festering shockwave on just the tank ability
	--likely a protection to keep healer from having to heal shockwave and tank at same time
	--With more data, i'll be able to scrap table and just dynamically apply timer updates automatically, but I want to confirm theory first
	local clawTimers = {8.2, 26.7, 27.9, 32.7}

	function mod:OnCombatStart(delay)
		self.vb.oozeCount = 0
		self.vb.festeringCount = 0
		self.vb.clawCount = 0
		timerCrushingClawCD:Start(8.2-delay, 1)
		timerBubblingFissureCD:Start(15.5-delay)
		timerFesteringShockwaveCD:Start(25.2-delay, 1)
		timerAwakenOozeCD:Start(30.1-delay, 1)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 427672 then
			specWarnBubblingFissure:Show()
			specWarnBubblingFissure:Play("watchstep")
			timerBubblingFissureCD:Start()
		elseif spellId == 427456 then
			self.vb.oozeCount = self.vb.oozeCount + 1
			warnAwakenOoze:Show(self.vb.oozeCount)
			timerAwakenOozeCD:Start(nil, self.vb.oozeCount+1)
		elseif spellId == 427668 then
			self.vb.festeringCount = self.vb.festeringCount + 1
			specWarnFesteringShockwave:Show(self.vb.festeringCount)
			specWarnFesteringShockwave:Play("carefly")
			timerFesteringShockwaveCD:Start(nil, self.vb.festeringCount+1)
		elseif spellId == 427670 then
			self.vb.clawCount = self.vb.clawCount + 1
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnCrushingClaw:Show()
				specWarnCrushingClaw:Play("defensive")
			end
			local timer = clawTimers[self.vb.clawCount+1] or 26.7
			timerCrushingClawCD:Start(timer, self.vb.clawCount+1)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 427559 and args:IsPlayer() and self:AntiSpam(3, 1) then
			specWarnGTFO:Show(args.spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
else
	--10.1.7 on retail, and Cataclysm classic if it happens (if it doesn't happen old version of mod will be retired)
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 76094 76100 76026",
		"SPELL_CAST_START 76047 76100"
	)

	--TODO, GTFO for void zones
	local warnDarkFissure		= mod:NewSpellAnnounce(76047, 4)
	local warnSqueeze			= mod:NewTargetNoFilterAnnounce(76026, 3)
	local warnEnrage			= mod:NewSpellAnnounce(76100, 2, nil, "Tank")

	local specWarnCurse			= mod:NewSpecialWarningDispel(76094, "RemoveCurse", nil, 2, 1, 2)
	local specWarnFissure		= mod:NewSpecialWarningDodge(76047, "Tank", nil, nil, 1, 2)

	local timerDarkFissureCD	= mod:NewCDTimer(18.4, 76047, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerSqueeze			= mod:NewTargetTimer(6, 76026, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerSqueezeCD		= mod:NewCDTimer(29, 76026, nil, nil, nil, 3)
	local timerEnrage			= mod:NewBuffActiveTimer(10, 76100, nil, "Tank|Healer", 2, 5)

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 76094 and self:CheckDispelFilter("curse") then
			specWarnCurse:Show(args.destName)
			specWarnCurse:Play("helpdispel")
		elseif args.spellId == 76100 then
			timerEnrage:Start()
		elseif args.spellId == 76026 then
			warnSqueeze:Show(args.destName)
			timerSqueeze:Start(args.destName)
			timerSqueezeCD:Start()
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 76047 then
			if self.Options.SpecWarn76047dodge then
				specWarnFissure:Show()
				specWarnFissure:Play("shockwave")
			else
				warnDarkFissure:Show()
			end
			timerDarkFissureCD:Start()
		elseif args.spellId == 76100 then
			warnEnrage:Show()
		end
	end
end
