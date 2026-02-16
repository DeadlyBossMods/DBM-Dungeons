local mod	= DBM:NewMod("Shot", "DBM-WorldEvents", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(974)

mod:RegisterCombat("combat")

mod:RegisterSafeEvents(
	"UNIT_AURA player"
)
mod.noStatistics = true

local timerGame		= mod:NewBuffActiveTimer(60, 101871, nil, nil, nil, 5, nil, nil, nil, 1, 5)

mod:AddBoolOption("SetBubbles", true)--Because the NPC is an annoying and keeps doing chat says while you're shooting which cover up the targets if bubbles are on.

local CVAR = false

do
	local gameActive = false
	function mod:UNIT_AURA()
		local hasBuff = DBM:UnitBuff("player", 101871)
		if self:issecretvalue(hasBuff) then return end
		if hasBuff and not gameActive then
			timerGame:Start()
			if self.Options.SetBubbles and GetCVarBool("chatBubbles") then
				CVAR = true
				SetCVar("chatBubbles", 0)
			end
			gameActive = true
		elseif not hasBuff and gameActive then
			timerGame:Cancel()
			if self.Options.SetBubbles and not GetCVarBool("chatBubbles") and CVAR then--Only turn them back on if they are off now, but were on when we minigame
				SetCVar("chatBubbles", 1)
				CVAR = false
			end
			gameActive = false
		end
	end
end
