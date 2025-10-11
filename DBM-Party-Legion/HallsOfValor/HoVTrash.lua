local mod	= DBM:NewMod("HoVTrash", "DBM-Party-Legion", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1477)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 199805 192563 199726 191508 199210 198892 198934 215433 210875 192158 200901 198595 192288",
	"SPELL_AURA_APPLIED 215430",
	"SPELL_AURA_REMOVED 215430",
	"UNIT_DIED",
	"GOSSIP_SHOW"
)

--TODO wicked dagger (199674)?
--TODO, HIGH chance most nameplate timers are wrong in Legion Remix, if so they'll be disabled in remix with "not self:IsRemix()" checks
local warnCrackle					= mod:NewTargetAnnounce(199805, 2)
local warnCracklingStorm			= mod:NewTargetAnnounce(198892, 2)
local warnThunderousBolt			= mod:NewCastAnnounce(198595, 3)
local warnCleansingFlame			= mod:NewCastAnnounce(192563, 4)
local warnHolyRadiance				= mod:NewCastAnnounce(215433, 3)
local warnRuneOfHealing				= mod:NewCastAnnounce(198934, 3)

local specWarnBlastofLight			= mod:NewSpecialWarningDodge(191508, nil, nil, nil, 2, 2)
local specWarnPenetratingShot		= mod:NewSpecialWarningDodge(199210, nil, nil, nil, 2, 2)
local specWarnChargePulse			= mod:NewSpecialWarningDodge(210875, nil, nil, nil, 2, 2)
local specWarnSanctify				= mod:NewSpecialWarningDodge(192158, nil, nil, nil, 2, 5)
local specWarnEyeofStorm			= mod:NewSpecialWarningMoveTo(200901, nil, nil, nil, 2, 2)
local specWarnCrackle				= mod:NewSpecialWarningYou(199805, nil, nil, nil, 1, 2)
local yellCrackle					= mod:NewShortYell(199805)
local specWarnCracklingStorm		= mod:NewSpecialWarningYou(198892, nil, nil, nil, 1, 2)
local yellCracklingStorm			= mod:NewShortYell(198892)
local specWarnThunderstrike			= mod:NewSpecialWarningMoveAway(215430, nil, nil, nil, 1, 2)
local yellThunderstrike				= mod:NewShortYell(215430)
local specWarnThunderousBolt		= mod:NewSpecialWarningInterrupt(198595, "HasInterrupt", nil, nil, 1, 2)
local specWarnHolyRadiance			= mod:NewSpecialWarningInterrupt(215433, "HasInterrupt", nil, nil, 1, 2)
local specWarnRuneOfHealing			= mod:NewSpecialWarningInterrupt(198934, false, nil, nil, 1, 2)--Mob can be moved out of it so Holy more important spell to kick
local specWarnCleansingFlame		= mod:NewSpecialWarningInterrupt(192563, "HasInterrupt", nil, nil, 1, 2)
local specWarnUnrulyYell			= mod:NewSpecialWarningInterrupt(199726, "HasInterrupt", nil, nil, 1, 2)
local specWarnSearingLight			= mod:NewSpecialWarningInterrupt(192288, "HasInterrupt", nil, nil, 1, 2)

local timerThunderousBoltCD			= mod:NewCDNPTimer(4.8, 198595, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--6-7
local timerRuneOfHealingCD			= mod:NewCDNPTimer(17, 198934, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--17-18.2
local timerHolyRadianceCD			= mod:NewCDNPTimer(18.1, 215433, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--17-18.2
local timerCleansingFlameCD			= mod:NewCDNPTimer(6.1, 192563, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--6-9
local timerBlastofLightCD			= mod:NewCDNPTimer(18, 191508, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--May be lower
local timerEyeofStormCD				= mod:NewCDNPTimer(25, 200901, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerSanctifyCD				= mod:NewCDNPTimer(25, 192158, nil, nil, nil, 3)--25-30 based on searing light casts since searing light has 6sec ICD lockout

mod:AddGossipOption(true, "Encounter")
--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 generalized, 7 GTFO

local eyeShortName = DBM:GetSpellName(91320)--Inner Eye

function mod:CrackleTarget(targetname, uId)
	if not targetname then
		warnCrackle:Show(DBM_COMMON_L.UNKNOWN)
		return
	end
	if targetname == UnitName("player") then
		specWarnCrackle:Show()
		specWarnCrackle:Play("targetyou")
		yellCrackle:Yell()
	else
		warnCrackle:Show(targetname)
	end
end

function mod:CracklingStormTarget(targetname, uId)
	if not targetname then
		warnCracklingStorm:Show(DBM_COMMON_L.UNKNOWN)
		return
	end
	if targetname == UnitName("player") then
		specWarnCracklingStorm:Show()
		specWarnCracklingStorm:Play("targetyou")
		yellCracklingStorm:Yell()
	else
		warnCracklingStorm:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 199805 then
		self:BossTargetScanner(args.sourceGUID, "CrackleTarget", 0.1, 9)
	elseif spellId == 198892 then
		self:BossTargetScanner(args.sourceGUID, "CracklingStormTarget", 0.1, 9)
	elseif spellId == 192563 then
		timerCleansingFlameCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn192563interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCleansingFlame:Show(args.sourceName)
			specWarnCleansingFlame:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnCleansingFlame:Show()
		end
	elseif spellId == 215433 then
		timerHolyRadianceCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn215433interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHolyRadiance:Show(args.sourceName)
			specWarnHolyRadiance:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnHolyRadiance:Show()
		end
	elseif spellId == 198934 then
		timerRuneOfHealingCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn198934interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRuneOfHealing:Show(args.sourceName)
			specWarnRuneOfHealing:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnRuneOfHealing:Show()
		end
	elseif spellId == 199726 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnUnrulyYell:Show(args.sourceName)
		specWarnUnrulyYell:Play("kickcast")
	elseif spellId == 191508 then
		if self:AntiSpam(3, 2) then
			specWarnBlastofLight:Show()
			specWarnBlastofLight:Play("shockwave")
		end
		timerBlastofLightCD:Start(nil, args.sourceGUID)
	elseif spellId == 198595 then
		timerThunderousBoltCD:Start(self:IsRemix() and 3.6 or 4.8, args.sourceGUID)
		if self.Options.SpecWarn198595interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnThunderousBolt:Show(args.sourceName)
			specWarnThunderousBolt:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnThunderousBolt:Show()
		end
	elseif spellId == 199210 and self:AntiSpam(3, 2) then
		specWarnPenetratingShot:Show()
		specWarnPenetratingShot:Play("shockwave")
	elseif spellId == 210875 and self:AntiSpam(3, 2) then
		specWarnChargePulse:Show()
		specWarnChargePulse:Play("watchstep")
	elseif spellId == 192158 then--P1 2 adds
		specWarnSanctify:Show()
		specWarnSanctify:Play("watchorb")
		timerSanctifyCD:Start(nil, args.sourceGUID)
	--2/22 01:53:53.948  SPELL_CAST_START,Creature-0-3019-1477-12381-97219-000075B856,"Solsten",0x10a48,0x0,0000000000000000,nil,0x80000000,0x80000000,200901,"Eye of the Storm",0x8
	elseif spellId == 200901 and args:GetSrcCreatureID() == 97219 then
		specWarnEyeofStorm:Show(eyeShortName)
		specWarnEyeofStorm:Play("findshelter")
		timerEyeofStormCD:Start(nil, args.sourceGUID)
	elseif spellId == 192288 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSearingLight:Show(args.sourceName)
			specWarnSearingLight:Play("kickcast")
		end
		--On fly correct santify which is delayed by the forced ICD of Searing Light casts
		if (timerSanctifyCD:GetRemaining() > 0) and (timerSanctifyCD:GetRemaining() < 6) then
			local elapsed, total = timerSanctifyCD:GetTime()
			local extend = 6 - (total-elapsed)
			DBM:Debug("timerSanctifyCD extended by: "..extend, 2)
			timerSanctifyCD:Update(elapsed, total+extend)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	if args.spellId == 215430 then
		if args:IsPlayer() then
			specWarnThunderstrike:Show()
			specWarnThunderstrike:Play("scatter")
			yellThunderstrike:Yell()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(6)
			end
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	if args.spellId == 215430 and args:IsPlayer() then
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 101637 then--Valarjar Aspirant
		timerBlastofLightCD:Stop(args.destGUID)
	elseif cid == 95834 then--Valajar Mystic
		timerRuneOfHealingCD:Stop(args.destGUID)
		timerHolyRadianceCD:Stop(args.destGUID)
	elseif cid == 97197 then--Valajar Purifier
		timerCleansingFlameCD:Stop(args.destGUID)
	elseif cid ==  95842 then--Valjar Thundercaller
		timerThunderousBoltCD:Stop(args.destGUID)
	elseif cid == 97219 then--Solsten
		timerEyeofStormCD:Stop(args.destGUID)
	elseif cid == 97202 then--Olmyr
		timerSanctifyCD:Stop(args.destGUID)
	end
end

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		if self.Options.AutoGossipEncounter and (gossipOptionID == 44755 or gossipOptionID == 44801 or gossipOptionID == 44802 or gossipOptionID == 44754) then -- Skovald Trash
			self:SelectGossip(gossipOptionID)
		elseif self.Options.AutoGossipEncounter and gossipOptionID == 44910 then -- Odyn
			self:SelectGossip(gossipOptionID, true)
		end
	end
end
