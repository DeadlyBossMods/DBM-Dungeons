local mod	= DBM:NewMod(1662, "DBM-Party-Legion", 5, 767)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(91003)
mod:SetEncounterID(1790)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 188169 188114",
	"SPELL_PERIODIC_DAMAGE 192800",
	"SPELL_PERIODIC_MISSED 192800"
)

--TODO, is razorshards 29 seconds now?
local warnShatter					= mod:NewCountAnnounce(188114, 2)

local specWarnRazorShards			= mod:NewSpecialWarningSpell(188169, "Tank", nil, nil, 1, 2)
local specWarnGas					= mod:NewSpecialWarningGTFO(192800, nil, nil, nil, 1, 8)

local timerShatterCD				= mod:NewCDTimer(24.2, 188114, nil, nil, nil, 2)
local timerRazorShardsCD			= mod:NewCDTimer(29, 188169, nil, "Tank", nil, 5)

mod.vb.shatterCount = 0

function mod:OnCombatStart(delay)
	self.vb.shatterCount = 0
	timerShatterCD:Start(20-delay, 1)
	timerRazorShardsCD:Start(25-delay)--27?
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 188169 then
		specWarnRazorShards:Show()
		specWarnRazorShards:Play("shockwave")
		timerRazorShardsCD:Start()
	elseif spellId == 188114 then
		self.vb.shatterCount = self.vb.shatterCount + 1
		warnShatter:Show(self.vb.shatterCount)
		timerShatterCD:Start(nil, self.vb.shatterCount+1)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 192800 and destGUID == UnitGUID("player") and self:AntiSpam(2.5, 1) then
		specWarnGas:Show(spellName)
		specWarnGas:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
