local mod	= DBM:NewMod(2173, "DBM-Party-BfA", 5, 1023)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129208)
mod:SetEncounterID(2109)
mod:SetHotfixNoticeRev(20240807000000)
--mod:SetMinSyncRevision(20211203000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 269029 268230 268260 463182",
	"SPELL_CAST_SUCCESS 268963 268752 181089 268230",
	"SPELL_AURA_APPLIED 272421",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_START boss1 boss2 boss3 boss4 boss5",--boss and Adds
--	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5"--boss and Adds
)

--TODO, cannons remaining, who's carrying ordinance, etc
--[[
 (ability.id = 269029 or ability.id = 268230 or ability.id = 268260 or ability.id = 273470 or ability.id = 463182) and type = "begincast"
 or (ability.id = 268963 or ability.id = 181089 or ability.id = 268752) and type = "cast"
 or ability.id = 272421 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnWithdraw					= mod:NewCountAnnounce(268752, 2)
local warnCrimsonSwipe				= mod:NewSpellAnnounce(268230, 2, nil, false, 2)--Can't be avoided by tanks, so opt in, not opt out
local warnUnstableOrdnance			= mod:NewSpellAnnounce(268995, 1)
local warnFieryRicochet				= mod:NewCountAnnounce(463182, 3)

local specWarnMassBombardment		= mod:NewSpecialWarningDodgeCount(463185, nil, nil, nil, 2, 2)
local specWarnCleartheDeck			= mod:NewSpecialWarningDodgeCount(269029, "Tank", nil, nil, 3, 15)
local specWarnBroadside				= mod:NewSpecialWarningDodgeCount(268260, "Tank", nil, nil, 1, 2)

local timerMassBombardmentCD		= mod:NewCDCountTimer(25, 463185, nil, nil, nil, 3)
local timerRicochetCD				= mod:NewCDCountTimer(18.2, 463182, nil, nil, nil, 3)
--local timerWithdrawCD				= mod:NewCDCountTimer(40, 268752, nil, nil, nil, 6)--Health based now
local timerCleartheDeckCD			= mod:NewCDCountTimer(17.7, 269029, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCrimsonSwipeCD			= mod:NewCDNPTimer(10.6, 268230, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--11.8-12.2 now
local timerBroadsideCD				= mod:NewCDCountTimer(12.1, 268260, nil, nil, nil, 3)--12.1-14.2

mod.vb.massBombCount = 0
mod.vb.ricochetCount = 0
mod.vb.withdrawCount = 0
mod.vb.clearDeckCount = 0
mod.vb.broadCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
--	self.vb.bossGone = false
	self.vb.massBombCount = 0
	self.vb.ricochetCount = 0
	self.vb.withdrawCount = 0
	self.vb.clearDeckCount = 0
	self.vb.broadCount = 0
	timerCleartheDeckCD:Start(3.5-delay, 1)
	timerRicochetCD:Start(9.3-delay, 1)--Could be shorter, but most people trigger gutshot on pull
	if self:IsMythic() then
		timerMassBombardmentCD:Start(10.1-delay, 1)
	end
--	timerWithdrawCD:Start(13.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 269029 then
		self.vb.clearDeckCount = self.vb.clearDeckCount + 1
		specWarnCleartheDeck:Show(self.vb.clearDeckCount)
		specWarnCleartheDeck:Play("frontal")
		timerCleartheDeckCD:Start(nil, self.vb.clearDeckCount+1)
	elseif spellId == 268230 then
		if self:AntiSpam(3, 1) then
			warnCrimsonSwipe:Show()
		end
	elseif spellId == 268260 and args:GetSrcCreatureID() == 136549 then--Broadside
		self.vb.broadCount = self.vb.broadCount + 1
		specWarnBroadside:Show(self.vb.broadCount)
		specWarnBroadside:Play("watchstep")
		timerBroadsideCD:Start(11.1, self.vb.broadCount+1)--11.1-14.6 in TWW (formerly 10.9)
	elseif spellId == 463182 then
		self.vb.ricochetCount = self.vb.ricochetCount + 1
		warnFieryRicochet:Show(self.vb.ricochetCount)
		timerRicochetCD:Start(18.2, self.vb.ricochetCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 268963 then--Unstable Ordnance
		warnUnstableOrdnance:Show()
		timerBroadsideCD:Stop()
	elseif spellId == 268230 then
		timerCrimsonSwipeCD:Start(nil, args.sourceGUID)
	elseif spellId == 268752 then--Withdraw (boss Leaving)
		self:SetStage(2)
		self.vb.withdrawCount = self.vb.withdrawCount + 1
		warnWithdraw:Show(self.vb.withdrawCount)
		timerCleartheDeckCD:Stop()
		timerRicochetCD:Stop()
		timerMassBombardmentCD:Stop()
		timerBroadsideCD:Start(10.9, self.vb.broadCount+1)--10.9-15 in TWW
	elseif spellId == 181089 then--Encounter Event (boss returning)
		self:SetStage(1)
		timerBroadsideCD:Stop()
		timerCleartheDeckCD:Start(3.3, self.vb.clearDeckCount+1)
		timerRicochetCD:Start(8.4, self.vb.ricochetCount+1)
		if self:IsMythic() then
			timerMassBombardmentCD:Start(25, self.vb.massBombCount+1)
		end
--		timerWithdrawCD:Start(36, self.vb.withdrawCount+1)--Health based in TWW
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 272421 and self:AntiSpam(5, 2) then
		self.vb.massBombCount = self.vb.massBombCount + 1
		specWarnMassBombardment:Show(self.vb.massBombCount)
		specWarnMassBombardment:Play("watchstep")
		timerMassBombardmentCD:Start(25, self.vb.massBombCount+1)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 141532 then--Ashvane Deckhand
		timerCrimsonSwipeCD:Stop(args.destGUID)
	end
end

--[[
--Legacy code, in case they do bfa classic for some odd reason
function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 268752 then--Withdraw (boss Leaving)
		self:SetStage(2)
--		self.vb.bossGone = true
		self.vb.withdrawCount = self.vb.withdrawCount + 1
		warnWithdraw:Show(self.vb.withdrawCount)
		timerCleartheDeckCD:Stop()
		timerBroadsideCD:Start(11.3, self.vb.broadCount+1)
	elseif spellId == 268745 and self.vb.bossGone then--Energy Tracker (boss returning)
		self:SetStage(1)
--		self.vb.bossGone = false
		timerBroadsideCD:Stop()
		timerCleartheDeckCD:Start(4.3, self.vb.clearDeckCount+1)--Confirmed in TWW
		timerMassBombardmentCD:Start(nil, self.vb.massBombCount+1)
		timerWithdrawCD:Start(36, self.vb.withdrawCount+1)--NOT yet confirmed in TWW
	end
end
--]]
