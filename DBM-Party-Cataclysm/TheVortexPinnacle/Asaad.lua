local isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)
local mod	= DBM:NewMod(116, "DBM-Party-Cataclysm", 8, 68)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"
mod.upgradedMPlus = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43875)
mod:SetEncounterID(1042)
mod:SetHotfixNoticeRev(20230526000000)
--mod:SetMinSyncRevision(20230226000000)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 87618 87622",
--	"SPELL_CAST_SUCCESS 413263",
	"SPELL_AURA_APPLIED 86911",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--If cataclysm classic is pre nerf, static cling has shorter cast and needs faster alert
--TODO, verify changes on non mythic+ in 10.1
--TODO, diff logs can have very different results for chain lighting, seems due to boss sometimes skiping entire casts or delaying them
--[[
(ability.id = 87622 or ability.id = 87618) and type = "begincast"
 or (ability.id = 86930 or ability.id = 413263) and type = "cast"
 or ability.id = 86911 and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
  or (source.type = "NPC" and source.firstSeen = timestamp) and (source.id = 52019) or (target.type = "NPC" and target.firstSeen = timestamp) and (target.id = 52019)
--]]
local warnStaticCling			= mod:NewCastAnnounce(87618, 4)
local warnChainLightning		= mod:NewTargetAnnounce(87622, 3)

local specWarnStaticCling		= mod:NewSpecialWarningJump(87618, nil, nil, nil, 1, 2)
local specWarnNova				= mod:NewSpecialWarningSwitchCount(isRetail and 413263 or 96260, "-Healer", nil, nil, 1, 2)
local specWarnGroundingField	= mod:NewSpecialWarningMoveTo(86911, nil, DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.run:format(86911), nil, nil, 3)
local specWarnChainLit			= mod:NewSpecialWarningMoveAway(87622, nil, nil, nil, 1, 2)
local yellChainLit				= mod:NewYell(87622)

local timerChainLightningCD		= mod:NewCDTimer(13.4, 87622, nil, nil, nil, 3)
local timerStaticClingCD		= mod:NewCDTimer(15.8, 87618, nil, nil, nil, 2)
local timerStaticCling			= mod:NewCastTimer(10, 87618, nil, nil, nil, 5)
local timerStorm				= mod:NewCastTimer(10, 86930, nil, nil, nil, 2)
local timerGroundingFieldCD		= mod:NewCDCountTimer(45.7, 86911, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerNovaCD				= mod:NewCDTimer(12.1, isRetail and 413263 or 96260, nil, nil, nil, 1)

mod.vb.groundingCount = 0
mod.vb.novaCount = 0

function mod:LitTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnChainLit:Show()
		specWarnChainLit:Play("runout")
		yellChainLit:Yell()
	else
		warnChainLightning:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	self.vb.groundingCount = 0
	self.vb.novaCount = 0
	if self:IsMythicPlus() then
		timerChainLightningCD:Start(12.1-delay)
		timerNovaCD:Start(19.7)
		timerStaticClingCD:Start(25.3-delay)
		timerGroundingFieldCD:Start(30.3-delay, 1)
	else--TODO, check non M+ on 10.1
		timerNovaCD:Start(10.7)
		timerStaticClingCD:Start(10.7-delay)
		timerChainLightningCD:Start(13.1-delay)
		timerGroundingFieldCD:Start(16.9-delay, 1)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 87618 then
		--1.25 post nerf in classic, 1 sec pre nerf
		--3 lol giga nerf in M+
		warnStaticCling:Show()
		specWarnStaticCling:Schedule(2.3)--delay message since jumping at start of cast is no longer correct in 4.0.6+
		specWarnStaticCling:ScheduleVoice(2.3, "jumpnow")
		timerStaticCling:Start(3)
		local expectedTimer = self:IsMythicPlus() and 29.1 or 15.8
		if timerGroundingFieldCD:GetRemaining() < expectedTimer then
			timerStaticClingCD:Start(expectedTimer)
		end
	elseif args.spellId == 87622 then
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "LitTarget", 0.1, 8, true)
		local expectedTimer = self:IsMythicPlus() and 18.2 or 13.4
		if timerGroundingFieldCD:GetRemaining() < expectedTimer then
			timerChainLightningCD:Start(expectedTimer)
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 413263 and self:AntiSpam(5, 2) then
		if self:IsMythicPlus() then
			if timerGroundingFieldCD:GetRemaining() < 25.4 then
				timerNovaCD:Start(25.4)
			end
		else
			if timerGroundingFieldCD:GetRemaining() < 12.1 then
				timerNovaCD:Start()
			end
		end
	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 86911 and self:AntiSpam(5, 1) then
		self.vb.groundingCount = self.vb.groundingCount + 1
		specWarnGroundingField:Show(args.spellName)
		specWarnGroundingField:Play("findshelter")
		timerStorm:Start()
		if self:IsMythicPlus() then
			timerChainLightningCD:Restart(18.1)--First cast can be delayed or skipped entirely
			timerNovaCD:Restart(26.5)
			timerStaticClingCD:Restart(33.7)
			timerGroundingFieldCD:Start(65.5, self.vb.groundingCount+1)
		else
			timerStaticClingCD:Restart(12)
			--timerChainLightningCD:Start(19.3)
			timerNovaCD:Restart(22.9)
			timerGroundingFieldCD:Start(45.7, self.vb.groundingCount+1)--45.7
		end
	end
end

--Pre 10.1 "Summon Skyfall Star-96260-npc:43875-000008E8D0 = pull:10.7, 29.1, 14.6, 31.6, 13.4, 31.6, 12.1", -- [7]
function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 96260 then
		self.vb.novaCount = self.vb.novaCount + 1
		specWarnNova:Show(self.vb.novaCount)
		specWarnNova:Play("killmob")
		local expectedTime = self:IsMythicPlus() and 25.1 or 12.1
		if timerGroundingFieldCD:GetRemaining() < expectedTime then
			timerNovaCD:Start(expectedTime)
		end
	end
end
