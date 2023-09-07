local mod	= DBM:NewMod(104, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"
mod.upgradedMPlus = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40792)
mod:SetEncounterID(1047)
mod:SetMainBossID(42172)--42172 is Ozumat, but we need Neptulon for engage trigger.

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 83463 76133",
	"SPELL_CAST_SUCCESS 83985 83986",
	"UNIT_SPELLCAST_SUCCEEDED"
)

local warnPhase			= mod:NewPhaseChangeAnnounce(2, nil, nil, nil, nil, nil, nil, 2)
local warnBlightSpray	= mod:NewSpellAnnounce(83985, 2)

local timerPhase		= mod:NewTimer(95, "TimerPhase", nil, nil, nil, 6)
local timerBlightSpray	= mod:NewBuffActiveTimer(4, 83985, nil, nil, nil, 3)

mod.vb.warnedPhase2 = false
mod.vb.warnedPhase3 = false

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.warnedPhase2 = false
	self.vb.warnedPhase3 = false
	timerPhase:Start()--Can be done right later once consistency is confirmed.
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 83463 and not self.vb.warnedPhase2 then
		self:SetStage(2)
		warnPhase:Show(DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.stage:format(2))
		warnPhase:Play("ptwo")
		self.vb.warnedPhase2 = true
	elseif args.spellId == 76133 and not self.vb.warnedPhase3 then
		self:SetStage(3)
		warnPhase:Show(DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.stage:format(3))
		warnPhase:Play("pthree")
		self.vb.warnedPhase3 = true
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(83985, 83986) then
		warnBlightSpray:Show()
		timerBlightSpray:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 83909 then --Clear Tidal Surge
		self:SendSync("bossdown")
	end
end

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "bossdown" then
		DBM:EndCombat(self)
	end
end
