local mod	= DBM:NewMod("Cannon", "DBM-WorldEvents", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(974)

mod:RegisterSafeEvents(
	"UNIT_AURA player"
)
mod.noStatistics = true

local timerMagicWings				= mod:NewBuffFadesTimer(8, 102116, nil, false, 2, 5)

do
	local gameActive = false
	function mod:UNIT_AURA()
		local hasBuff = DBM:UnitBuff("player", 102116)
		if self:issecretvalue(hasBuff) then return end
		if hasBuff and not gameActive then
			timerMagicWings:Start()
			gameActive = true
		elseif not hasBuff and gameActive then
			timerMagicWings:Cancel()
			gameActive = false
		end
	end
end
