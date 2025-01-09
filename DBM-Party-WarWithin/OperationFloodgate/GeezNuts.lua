if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod(2651, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(236950)
mod:SetEncounterID(3054)
--mod:SetHotfixNoticeRev(20240817000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 465463 468841 468813 468815 466190",
	"SPELL_CAST_SUCCESS 468276",
	"SPELL_AURA_APPLIED 468741 468616 468815",
--	"SPELL_AURA_REMOVED"
	"SPELL_AURA_REMOVED 465463 468616",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, improve timer handling around boss energy and Turbo Charge
--NOTE, Leaping Sparks script does NOT have block for target scanning, so if they private debuff, we can still see target anyways
--NOTE: target scanning possible on Gigazap private aura but will likely get fixed later
--NOTE, https://www.wowhead.com/ptr-2/spell=468844/leaping-spark summons the spark
--TODO, record new audio if "move to pool" causes lack of clarity to specifically say "move spark to pool"
local warnTurboChargeOver					= mod:NewEndAnnounce(465463, 1)
local warnDam								= mod:NewCountAnnounce(468276, 2)
local warnShockWaterStun					= mod:NewTargetNoFilterAnnounce(468741, 2)
local warnLeapingSpark						= mod:NewTargetNoFilterAnnounce(468841, 2)
local warnGigaZapLater						= mod:NewTargetNoFilterAnnounce(468815, 3, nil, "Healer")--Pre target is private aura, but dot is not, we can still warn the healer who has dots

local specWarnTurboCharge					= mod:NewSpecialWarningDodgeCount(465463, nil, nil, nil, 2, 2)
local specWarnLeapingSpark					= mod:NewSpecialWarningRun(468841, nil, nil, nil, 4, 18)
local yellLeapingSpark						= mod:NewShortYell(468841)
local specWarnThunderPunch					= mod:NewSpecialWarningDefensive(466190, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerTurboChargeCD					= mod:NewAITimer(33.9, 465463, nil, nil, nil, 6)
local timerDamCD							= mod:NewAITimer(33.9, 468276, nil, nil, nil, 3)
local timerLeapingSparksCD					= mod:NewAITimer(33.9, 468841, nil, nil, nil, 3)
local timerGigazapCD						= mod:NewAITimer(33.9, 468813, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerThunderPunchCD					= mod:NewAITimer(33.9, 466190, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

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
	timerTurboChargeCD:Start(1-delay)--1.6, 60.0
	timerDamCD:Start(1-delay)--16.0
	timerLeapingSparksCD:Start(1-delay)--38.1
	timerGigazapCD:Start(1-delay)--28.0, 26.0
	timerThunderPunchCD:Start(1-delay)--24.0, 26.0
	self:EnablePrivateAuraSound(468811, "defensive", 2)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 465463 then
		self.vb.turboChargeCount = self.vb.turboChargeCount + 1
		specWarnTurboCharge:Show(self.vb.turboChargeCount)
		specWarnTurboCharge:Play("farfromline")
		timerTurboChargeCD:Start()
	elseif spellId == 468841 then
		self.vb.sparksCount = self.vb.sparksCount + 1
		timerLeapingSparksCD:Start()
	elseif spellId == 468813 then
		self.vb.gigaZapCount = self.vb.gigaZapCount + 1
		timerGigazapCD:Start()
		--"<35.71 21:43:09> [CLEU] SPELL_CAST_START#Creature-0-5769-2773-2529-226404-00007DDBE7#Geezle Gigazap(54.3%-90.0%)##nil#468813#Gigazap#nil#nil#nil#nil#nil#nil",
		--"<35.84 21:43:10> [UNIT_TARGET] boss1#Geezle Gigazap#Target: Crenna Earth-Daughter#TargetOfTarget: Omegal",
		--"<38.74 21:43:12> [CLEU] SPELL_AURA_APPLIED#Creature-0-5769-2773-2529-226404-00007DDBE7#Geezle Gigazap#Vehicle-0-5769-2773-2529-209072-00007DDBF6#Crenna Earth-Daughter#468815#Gigazap#DEBUFF#nil#nil#nil#nil#nil",
	elseif spellId == 466190 then
		self.vb.punchCount = self.vb.punchCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnThunderPunch:Show()
			specWarnThunderPunch:Play("defensive")
		end
		timerThunderPunchCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 468276 and self:AntiSpam(8, 1) then
		self.vb.damCount = self.vb.damCount + 1
		warnDam:Show(self.vb.damCount)
		timerDamCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 468741 and args:IsPlayer() or self:IsHealer() then
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
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 465463 then
		warnTurboChargeOver:Show()
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--TODO, timers for shockwater?
--"Shock Water-468723-npc:226404-00007DDBE7 = pull:25.6, 15.5",
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 468276 then
		self.vb.damCount = self.vb.damCount + 1
		warnDam:Show(self.vb.damCount)
		timerDamCD:Start()
	end
end
