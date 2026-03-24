local mod	= DBM:NewMod("Gnoll", "DBM-WorldEvents", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(974)

if DBM:IsPostMidnight() then
	mod:RegisterSafeEvents(
		"UNIT_SPELLCAST_SUCCEEDED player",
		"UNIT_AURA player",
		"UNIT_POWER_UPDATE player"
	)
else
	mod:RegisterEvents(
		"SPELL_AURA_APPLIED 101612",
		"SPELL_AURA_REMOVED 101612",
		"UNIT_SPELLCAST_SUCCEEDED player",
		"UNIT_POWER_UPDATE player"
	)
end
mod.noStatistics = true

local warnGameOverQuest			= mod:NewAnnounce("warnGameOverQuest", 2, 101612, nil, false)
local warnGameOverNoQuest		= mod:NewAnnounce("warnGameOverNoQuest", 2, 101612, nil, false)
mod:AddBoolOption("warnGameOver", true, "announce")
local warnGnoll					= mod:NewAnnounce("warnGnoll", 2, nil, false)

local specWarnHogger			= mod:NewSpecialWarning("specWarnHogger")

local timerGame					= mod:NewBuffActiveTimer(60, 101612, nil, nil, nil, 5, nil, nil, nil, 1, 5)

local gameEarnedPoints = 0
local gameMaxPoints = 0

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 101612 and args:IsPlayer() then
		gameEarnedPoints = 0
		gameMaxPoints = 0
		timerGame:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 101612 and args:IsPlayer() then
		timerGame:Cancel()
		if self.Options.warnGameOver then
			if gameEarnedPoints > 0 then
				warnGameOverQuest:Show(gameEarnedPoints, gameMaxPoints)
			else
				warnGameOverNoQuest:Show(gameMaxPoints)
			end
		end
	end
end

do
	local gameActive = false
	function mod:UNIT_AURA()
		local hasBuff = DBM:UnitBuff("player", 101612)
		if self:issecretvalue(hasBuff) then return end
		if hasBuff and not gameActive then
			gameEarnedPoints = 0
			gameMaxPoints = 0
			timerGame:Start()
			gameActive = true
		elseif not hasBuff and gameActive then
			timerGame:Cancel()
			gameActive = false
			if self.Options.warnGameOver then
				if gameEarnedPoints > 0 then
					warnGameOverQuest:Show(gameEarnedPoints, gameMaxPoints)
				else
					warnGameOverNoQuest:Show(gameMaxPoints)
				end
			end
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if self:issecretvalue(spellId) then return end
	if spellId == 102044 then--Hogger
		gameMaxPoints = gameMaxPoints + 3
		if self:AntiSpam(2, 1) then
			specWarnHogger:Show()
		end
	elseif spellId == 102036 then--Gnoll
		gameMaxPoints = gameMaxPoints + 1
		warnGnoll:Show()
	end
end

function mod:UNIT_POWER_UPDATE(_, powerType)
	if powerType == "ALTERNATE" then
		local playerPower = UnitPower("player", 10)
		if self:issecretvalue(playerPower) then return end
		if playerPower > gameEarnedPoints then
			gameEarnedPoints = playerPower
		end
	end
end
