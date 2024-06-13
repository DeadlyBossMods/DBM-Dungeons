local mod	= DBM:NewMod(2173, "DBM-Party-BfA", 5, 1023)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129208)
mod:SetEncounterID(2109)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 269029 268230",
	"UNIT_DIED",
	"UNIT_SPELLCAST_START boss1 boss2 boss3 boss4 boss5",--boss and Adds
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5"--boss and Adds
)

--TODO, cannons remaining, who's carrying ordinance, etc
local warnWithdraw					= mod:NewCountAnnounce(268752, 2)
local warnCrimsonSwipe				= mod:NewSpellAnnounce(268230, 2, nil, false, 2)--Can't be avoided by tanks, so opt in, not opt out
local warnUnstableOrdnance			= mod:NewSpellAnnounce(268995, 1)

local specWarnCleartheDeck			= mod:NewSpecialWarningDodgeCount(269029, "Tank", nil, nil, 3, 2)
local specWarnHeavySlash			= mod:NewSpecialWarningDodge(257288, "Tank", nil, nil, 1, 2)
local specWarnBroadside				= mod:NewSpecialWarningDodgeCount(268260, "Tank", nil, nil, 1, 2)

local timerWithdrawCD				= mod:NewCDCountTimer(40, 268752, nil, nil, nil, 6)
local timerCleartheDeckCD			= mod:NewCDCountTimer(18.2, 269029, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCrimsonSwipeCD			= mod:NewCDNPTimer(9, 268230, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--12.2 now?
local timerBroadsideCD				= mod:NewCDCountTimer(9, 268260, nil, nil, nil, 3)--Need more data

mod.vb.bossGone = false
mod.vb.withdrawCount = 0
mod.vb.clearDeckCount = 0
mod.vb.broadCount = 0

function mod:OnCombatStart(delay)
	self.vb.bossGone = false
	self.vb.withdrawCount = 0
	self.vb.clearDeckCount = 0
	self.vb.broadCount = 0
	timerCleartheDeckCD:Start(3.6-delay, 1)
	timerWithdrawCD:Start(13.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 269029 then
		self.vb.clearDeckCount = self.vb.clearDeckCount + 1
		specWarnCleartheDeck:Show(self.vb.clearDeckCount)
		specWarnCleartheDeck:Play("shockwave")
		timerCleartheDeckCD:Start(nil, self.vb.clearDeckCount+1)
	elseif spellId == 268230 then
		if self:AntiSpam(3, 1) then
			warnCrimsonSwipe:Show()
		end
		timerCrimsonSwipeCD:Start(nil, args.sourceGUID)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 141532 then--Ashvane Deckhand
		timerCrimsonSwipeCD:Stop(args.destGUID)
	end
end

--Not in combat log what so ever
function mod:UNIT_SPELLCAST_START(_, _, spellId)
	if spellId == 257288 and self:AntiSpam(3, 1) then
		specWarnHeavySlash:Show()
		specWarnHeavySlash:Play("shockwave")
	elseif spellId == 268260 then--Broadside
		self.vb.broadCount = self.vb.broadCount + 1
		specWarnBroadside:Show(self.vb.broadCount)
		specWarnBroadside:Play("watchstep")
		timerBroadsideCD:Start(10.9, self.vb.broadCount+1)--14.6 in TWW, from a single pull, but maybe variable based on boss time to ship, needs more data
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 268752 then--Withdraw (boss Leaving)
		self.vb.bossGone = true
		self.vb.withdrawCount = self.vb.withdrawCount + 1
		warnWithdraw:Show(self.vb.withdrawCount)
		timerCleartheDeckCD:Stop()
		timerBroadsideCD:Start(11.3, self.vb.broadCount+1)
	elseif spellId == 268745 and self.vb.bossGone then--Energy Tracker (boss returning)
		self.vb.bossGone = false
		timerBroadsideCD:Stop()
		timerCleartheDeckCD:Start(4.3, self.vb.clearDeckCount+1)--Confirmed in TWW
		timerWithdrawCD:Start(36, self.vb.withdrawCount+1)--NOT yet confirmed in TWW
	elseif spellId == 268963 then--Unstable Ordnance
		warnUnstableOrdnance:Show()
		timerBroadsideCD:Stop()
	end
end
