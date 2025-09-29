local mod	= DBM:NewMod(1719, "DBM-Party-Legion", 7, 800)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(104217)
mod:SetEncounterID(1869)
mod:SetHotfixNoticeRev(20221127000000)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Out of combat register, to support the secondary bosses off to sides
mod:RegisterEvents(
	"SPELL_CAST_START 208165 207881 207906"
)

--[[
(ability.id = 208165 or ability.id = 207881 or ability.id = 207906) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--NOTE: Sub boss abilities are in trash module since they are often pulled out and not done with boss
local warnWitheringSoul				= mod:NewSpellAnnounce(208165, 2)
local warnBurningIntensity			= mod:NewSpellAnnounce(207906, 3)

local specWarnInfernalEruption		= mod:NewSpecialWarningDodge(207881, nil, nil, nil, 2, 2)

local timerWitheringSoulCD			= mod:NewCDTimer(14.5, 208165, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerInfernalEruptionCD		= mod:NewCDTimer(20.1, 207881, nil, nil, nil, 2)
local timerBurningIntensityCD		= mod:NewCDTimer(22.6, 207906, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

function mod:OnCombatStart(delay)
	timerBurningIntensityCD:Start(6-delay)
	timerWitheringSoulCD:Start(12-delay)
	timerInfernalEruptionCD:Start(self:IsMythicPlus() and 19.5 or 14.9-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 208165 then
		warnWitheringSoul:Show()
		timerWitheringSoulCD:Start(self:IsMythicPlus() and 14.5 or 13.3)
	elseif spellId == 207881 then
		specWarnInfernalEruption:Show()
		specWarnInfernalEruption:Play("watchstep")
		timerInfernalEruptionCD:Start()
	elseif spellId == 207906 then
		warnBurningIntensity:Show()
		timerBurningIntensityCD:Start()
	end
end
