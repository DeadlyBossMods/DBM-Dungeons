local mod	= DBM:NewMod(2651, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(236950)
mod:SetEncounterID(3054)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(468811, true, 468813, 1)--Gigazap
mod:AddPrivateAuraSoundOption(468723, true, 468723, 1)
mod:AddPrivateAuraSoundOption(468616, true, 468616, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(468811, "defensive", 2)
	self:EnablePrivateAuraSound(468723, "watchfeet", 8)
	self:EnablePrivateAuraSound(468616, "sparktowater", 18)
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 465463 468841 468813 468815 466190",
	"SPELL_CAST_SUCCESS 468276",
	"SPELL_AURA_APPLIED 468741 468616 468815",
	"SPELL_AURA_REMOVED 465463 468616",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)
--]]

--NOTE, Leaping Sparks script does NOT have block for target scanning, so if they private debuff, we can still see target anyways
--NOTE: target scanning possible on Gigazap private aura but will likely get fixed later
--NOTE, https://www.wowhead.com/ptr-2/spell=468844/leaping-spark summons the spark
--[[
(ability.id = 465463 or ability.id = 468841 or ability.id = 468813 or ability.id = 468815 or ability.id = 466190) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
local warnTurboChargeOver					= mod:NewEndAnnounce(465463, 1)
local warnDam								= mod:NewCountAnnounce(468276, 2)
local warnShockWaterStun					= mod:NewTargetNoFilterAnnounce(468741, 2)
local warnLeapingSpark						= mod:NewTargetNoFilterAnnounce(468841, 2, nil, false, 2)--off by default since it's spammmy in bad groups
local warnGigaZapLater						= mod:NewTargetNoFilterAnnounce(468815, 3, nil, "Healer")--Pre target is private aura, but dot is not, we can still warn the healer who has dots

local specWarnTurboCharge					= mod:NewSpecialWarningDodgeCount(465463, nil, nil, nil, 2, 2)
local specWarnLeapingSpark					= mod:NewSpecialWarningRun(468841, nil, nil, nil, 4, 18)
local yellLeapingSpark						= mod:NewShortYell(468841)
local specWarnThunderPunch					= mod:NewSpecialWarningDefensive(466190, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerTurboChargeCD					= mod:NewNextCountTimer(60, 465463, nil, nil, nil, 6)
local timerDamCD							= mod:NewNextCountTimer(60, 468276, nil, nil, nil, 3)--60 is assumed. cannot be confirmed without longer transcriptor log
local timerLeapingSparksCD					= mod:NewNextCountTimer(60, 468841, nil, nil, nil, 3)
local timerGigazapCD						= mod:NewNextCountTimer(33.9, 468813, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerThunderPunchCD					= mod:NewNextCountTimer(33.9, 466190, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddPrivateAuraSoundOption(468811, true, 468813, 1)--Gigazap

mod.vb.turboChargeCount = 0
mod.vb.damCount = 0
mod.vb.sparksCount = 0
mod.vb.gigaZapCount = 0
mod.vb.punchCount = 0

function mod:OnCombatStart(delay)
	self.vb.turboChargeCount = 0
	self.vb.damCount = 0
	self.vb.sparksCount = 0
	self.vb.gigaZapCount = 0
	self.vb.punchCount = 0
	timerTurboChargeCD:Start(1.6-delay, 1)
	timerDamCD:Start(16-delay, 1)--16.0
	timerThunderPunchCD:Start(24-delay, 1)
	timerGigazapCD:Start(28-delay, 1)
	timerLeapingSparksCD:Start(38-delay, 1)
	self:EnablePrivateAuraSound(468811, "defensive", 2)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 465463 then
		self.vb.turboChargeCount = self.vb.turboChargeCount + 1
		specWarnTurboCharge:Show(self.vb.turboChargeCount)
		specWarnTurboCharge:Play("aesoon")
		specWarnTurboCharge:ScheduleVoice(2, "farfromline")
		timerTurboChargeCD:Start(nil, self.vb.turboChargeCount+1)
	elseif spellId == 468841 then
		self.vb.sparksCount = self.vb.sparksCount + 1
		timerLeapingSparksCD:Start(nil, self.vb.sparksCount+1)
	elseif spellId == 468813 then
		self.vb.gigaZapCount = self.vb.gigaZapCount + 1
		local timer = (self.vb.gigaZapCount % 2 == 0) and 36 or 28
		timerGigazapCD:Start(timer, self.vb.gigaZapCount+1)
		--"Gigazap-468813-npc:226404-00004BAEAB = pull:28.0, 28.0, 36.0, 28.0, 36.0",
		--"<35.71 21:43:09> [CLEU] SPELL_CAST_START#Creature-0-5769-2773-2529-226404-00007DDBE7#Geezle Gigazap(54.3%-90.0%)##nil#468813#Gigazap#nil#nil#nil#nil#nil#nil",
		--"<35.84 21:43:10> [UNIT_TARGET] boss1#Geezle Gigazap#Target: Crenna Earth-Daughter#TargetOfTarget: Omegal",
		--"<38.74 21:43:12> [CLEU] SPELL_AURA_APPLIED#Creature-0-5769-2773-2529-226404-00007DDBE7#Geezle Gigazap#Vehicle-0-5769-2773-2529-209072-00007DDBF6#Crenna Earth-Daughter#468815#Gigazap#DEBUFF#nil#nil#nil#nil#nil",
	elseif spellId == 466190 then
		self.vb.punchCount = self.vb.punchCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnThunderPunch:Show()
			specWarnThunderPunch:Play("defensive")
		end
		local timer = (self.vb.punchCount % 2 == 0) and 36 or 24
		--"Thunder Punch-466190-npc:226404-00004BAEAB = pull:24.0, 28.0, 36.0, 28.0, 36.0",
		timerThunderPunchCD:Start(timer, self.vb.punchCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 468276 and self:AntiSpam(8, 1) then
		self.vb.damCount = self.vb.damCount + 1
		warnDam:Show(self.vb.damCount)
		timerDamCD:Start(nil, self.vb.damCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 468741 and args:IsPlayer() or (self:IsHealer() and args:IsDestTypePlayer()) then
		warnShockWaterStun:CombinedShow(0.3, args.destName)
	elseif spellId == 468616 and args:IsDestTypePlayer() then
		if args:IsPlayer() then
			specWarnLeapingSpark:Show()
			specWarnLeapingSpark:Play("sparktowater")
			yellLeapingSpark:Yell()
		else
			warnLeapingSpark:Show(args.destName)
		end
	elseif spellId == 468815 then
		warnGigaZapLater:PreciseShow(2, args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 465463 then
		warnTurboChargeOver:Show()
	end
end

--"Shock Water-468723-npc:226404-00007DDBE7 = pull:25.6, 15.5",
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 468276 then
		self.vb.damCount = self.vb.damCount + 1
		warnDam:Show(self.vb.damCount)
		timerDamCD:Start(nil, self.vb.damCount+1)
	end
end
--]]
