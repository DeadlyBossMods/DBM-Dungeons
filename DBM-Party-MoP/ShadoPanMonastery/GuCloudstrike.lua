local mod	= DBM:NewMod(673, "DBM-Party-MoP", 3, 312)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56747)--56747 (Gu Cloudstrike), 56754 (Azure Serpent)
mod:SetEncounterID(1303)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 110945 110852",
	"SPELL_AURA_REMOVED 110945",
	"SPELL_CAST_START 106923 106984 102573 107140",
	"UNIT_DIED"
)


local warnInvokeLightning		= mod:NewSpellAnnounce(106984, 2, nil, false)
local warnStaticField			= mod:NewAnnounce("warnStaticField", 3, 106923, nil, nil, nil, 106923)--Target scanning verified working
local warnChargingSoul			= mod:NewSpellAnnounce(110945, 3)--Phase 2
local warnLightningBreath		= mod:NewSpellAnnounce(102573, 3)
local warnOverchargedSoul		= mod:NewSpellAnnounce(110852, 3)--Phase 3

local specWarnStaticField		= mod:NewSpecialWarningMoveAway(106923, nil, nil, nil, 1, 2)
local specWarnStaticFieldNear	= mod:NewSpecialWarningClose(106923, nil, nil, nil, 1, 2)
local yellStaticField			= mod:NewYell(106923)
local specWarnMagneticShroud	= mod:NewSpecialWarningSpell(107140, nil, nil, nil, 2, 2)

local timerInvokeLightningCD	= mod:NewNextTimer(6, 106984)--Phase 1 ability
local timerStaticFieldCD		= mod:NewNextTimer(8, 106923, nil, nil, nil, 3)--^^
local timerLightningBreathCD	= mod:NewCDTimer(6.8, 102573, nil, nil, nil, 5)--6.8-10 ish Phase 2 ability
local timerMagneticShroudCD		= mod:NewCDTimer(12.5, 107140)--^^

local staticFieldText = DBM:GetSpellName(106923)
-- very poor code. not clean. (to replace %%s -> %s)
local targetFormatText
do
	local originalText = DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.target
	local startIndex = string.find(originalText, "%%%%")
	local tmp1 = string.sub(originalText, 1, startIndex)
	local tmp2 = string.sub(originalText, startIndex+2)
	targetFormatText = tmp1..tmp2
end

function mod:StaticFieldTarget(targetname, uId)
	if not targetname then--No one is targeting/focusing the cloud serpent, so just use generic warning
		staticFieldText = DBM:GetSpellName(106923)
		warnStaticField:Show(staticFieldText)
	else--We have a valid target, so use target warnings.
		staticFieldText = targetFormatText:format(DBM:GetSpellName(106923), targetname)
		warnStaticField:Show(staticFieldText)
		if targetname == UnitName("player") then
			specWarnStaticField:Show()
			specWarnStaticField:Play("runout")
			yellStaticField:Yell()
		else
			if uId then
				local inRange = DBM.RangeCheck:GetDistance("player", uId)
				if inRange and inRange < 6 then
					specWarnStaticFieldNear:Show(targetname)
					specWarnStaticFieldNear:Play("runaway")
				end
			end
		end
	end
end

function mod:OnCombatStart(delay)
	timerInvokeLightningCD:Start(-delay)
	timerStaticFieldCD:Start(18-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 110945 then
		warnChargingSoul:Show()
		warnInvokeLightning:Cancel()
		timerStaticFieldCD:Cancel()
		timerLightningBreathCD:Start(1.6)--1.6 now, cause remix likes to fuck with boss timers, used to be 6.8
		timerMagneticShroudCD:Start(17)--Used to be 20
	elseif args.spellId == 110852 then
		warnOverchargedSoul:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 110945 then
		warnInvokeLightning:Cancel()
		timerStaticFieldCD:Cancel()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 106923 then
		self:BossTargetScanner(56754, "StaticFieldTarget", 0.05, 20)
		timerStaticFieldCD:Start()
	elseif args.spellId == 106984 then
		warnInvokeLightning:Show()
		timerInvokeLightningCD:Start()
	elseif args.spellId == 102573 then
		warnLightningBreath:Show()
		timerLightningBreathCD:Start()
	elseif args.spellId == 107140 then
		specWarnMagneticShroud:Show()
		specWarnMagneticShroud:Play("healall")
		timerMagneticShroudCD:Start()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 56754 then
		timerMagneticShroudCD:Cancel()
		timerStaticFieldCD:Cancel()
		timerLightningBreathCD:Cancel()
	end
end
