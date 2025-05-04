local mod	= DBM:NewMod("MechagonTrash", "DBM-Party-BfA", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2097)
mod:RegisterZoneCombat(2097)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 300687 300764 300777 300650 300159 300177 300171 300087 300188 300207 299475 300414 300514 300436 300424 301681 301667 301629 284219 301088 294290 294349 293854 293986 1215409 293827 1215411 1215412 297128",--294324
	"SPELL_CAST_SUCCESS 299525 295169 301088 1217819 293683 293729 294103 294073 1215412 293854 294195 293930",--294015
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 300650 299588 293930 300414 301629 284219 303941 294195 297133",--294180
	"SPELL_AURA_APPLIED_DOSE 299438 299474 299502 293670",
	"SPELL_AURA_REMOVED 284219",
	"UNIT_DIED"
)

--https://www.wowhead.com/guides/operation-mechagon-megadungeon-strategy-guide
--TODO, target scan https://www.wowhead.com/spell=299525/scrap-grenade used by Pistonhead Blaster? Cast is a bit short so it's more iffy
--TODO, add https://www.wowhead.com/spell=301689/charged-coil ?
--TODO, verify target scans on Scrap Cannon and B.O.R.K.
--TODO, https://www.wowhead.com/spell=301712/pounce is instant cast, can we scan target and is it worth it on something that probably isn't avoidable?
--TODO, https://www.wowhead.com/spell=282945/buzz-saw is environmental and probably not detectable, but add of it is
--TODO, find possible CDs for defensive measures, right now it's still iffy
--TODO, prio nameplate setup
--[[
(ability.id = 293930) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 12345
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 144295) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 144295)
--]]
local warnSummonSquirrel			= mod:NewSpellAnnounce(293854, 4)
local warnExhaust					= mod:NewSpellAnnounce(300177, 2)--Heavy Scrapbot
local warnScrapGrenade				= mod:NewSpellAnnounce(299525, 3)--Pistonhead Blaster (upgrade to specwarn/yell if target scan possible)
local warnFlyingPeck				= mod:NewSpellAnnounce(294073, 3, nil, "Tank|Healer")
local warnSquirrel					= mod:NewSpellAnnounce(293854, 2)
local warnCharge					= mod:NewCastAnnounce(301681, 3)--Mechagon Cavalry
local warnVolatileWaste				= mod:NewCastAnnounce(294349, 4)--Living Waste
local warnPuncture					= mod:NewCastAnnounce(1215411, 3)
local warnSledgehammer				= mod:NewStackAnnounce(299438, 2, nil, "Tank|Healer")--Pistonhead Scrapper
local warnRippingSlash				= mod:NewStackAnnounce(299474, 2, nil, "Tank|Healer")--Saurolisk Bonenipper
local warnNanoslicer				= mod:NewStackAnnounce(299502, 2, nil, "Tank|Healer")--Mechagon Trooper
local warnChainblade				= mod:NewStackAnnounce(293670, 2, nil, "Tank|Healer")--Workshop Defender
local warnShrunk					= mod:NewTargetNoFilterAnnounce(284219, 1)
local FieryJaws						= mod:NewTargetNoFilterAnnounce(1217819, 2, nil, false, 2)--(S2 confirmed). Spammy so off by default
local warnCorrosiveGunk				= mod:NewSpellAnnounce(1215412, 2)--(S2 confirmed)

local specWarnMegaDrill				= mod:NewSpecialWarningSpell(1215409, nil, nil, nil, 2, 2)--Waste Processing Unit (294324 old version) (S2 confirmed)
local specWarnProcessWaste			= mod:NewSpecialWarningSpell(294290, nil, nil, nil, 1, 15)--Waste Processing Unit
local specWarnShockCoil				= mod:NewSpecialWarningSpell(300207, nil, nil, nil, 2, 2)--Weaponized Crawler
local specWarnShortOut				= mod:NewSpecialWarningSpell(297128, nil, nil, nil, 2, 2)--(S2 confirmed)
local specWarnSlimewave				= mod:NewSpecialWarningDodge(300777, nil, nil, nil, 2, 2)--Slime Elemental
local specWarnScrapCannon			= mod:NewSpecialWarningDodge(300188, nil, nil, nil, 2, 15)--Weaponized Crawler
local yellScrapCannon				= mod:NewYell(300188)--Weaponized Crawler
local specWarnBORK					= mod:NewSpecialWarningDodge(299475, nil, nil, nil, 2, 15)--Scraphound
local yellBORK						= mod:NewYell(299475)--Scraphound
local specWarnShockwave				= mod:NewSpecialWarningDodge(300424, nil, nil, nil, 2, 15)--Scrapbone Bully
local specWarnRapidFire				= mod:NewSpecialWarningDodge(301667, nil, nil, nil, 2, 15)--Mechagon Cavalry
local specWarnRocketBarrage			= mod:NewSpecialWarningDodge(294103, nil, nil, nil, 2, 2)--Rocket Tonk
local specWarnSonicPulse			= mod:NewSpecialWarningDodge(293986, nil, nil, nil, 2, 2)--Blastatron X-80/Spider Tank (S2 confirmed)
--local specWarnLaunchHERockets		= mod:NewSpecialWarningDodge(294015, nil, nil, nil, 2, 2)--Blastatron X-80/Spider Tank (S2 confirmed, but not logged, passive 4 second repeater)
local specWarnCapacitorDischarge	= mod:NewSpecialWarningDodge(295169, nil, nil, nil, 3, 2)--Blastatron X-80 (S2 confirmed)
--local specwarnCorrosiveGunk		= mod:NewSpecialWarningMoveTo(1215412, nil, nil, nil, 12, 2)
local specWarnConsume				= mod:NewSpecialWarningRun(300687, nil, nil, nil, 4, 2)--Toxic Monstrosity
local specWarnGyroScrap				= mod:NewSpecialWarningRun(300159, "Melee", nil, nil, 4, 2)--Heavy Scrapbot
local specWarnShrinkYou				= mod:NewSpecialWarningYou(284219, nil, nil, nil, 1, 2)
local yellShrunk					= mod:NewShortYell(284219)--Shrunk will just say with white letters
local yellShrunkRepeater			= mod:NewPlayerRepeatYell(284219)
local specWarnShieldGenerator		= mod:NewSpecialWarningMove(293683, nil, nil, nil, 1, 2)
local specWarnSlimeBolt				= mod:NewSpecialWarningInterrupt(300764, "HasInterrupt", nil, nil, 1, 2)--Slime Elemental
local specWarnSuffocatingSmog		= mod:NewSpecialWarningInterrupt(300650, "HasInterrupt", nil, nil, 1, 2)--Toxic Lurker
local specWarnRepairProtocol		= mod:NewSpecialWarningInterrupt(300171, "HasInterrupt", nil, nil, 1, 2)--Heavy Scrapbot
local specWarnRepair				= mod:NewSpecialWarningInterrupt(300087, "HasInterrupt", nil, nil, 1, 2)--Pistonhead Mechanic
local specWarnEnrage				= mod:NewSpecialWarningInterrupt(300414, "HasInterrupt", nil, nil, 1, 2)--Scrapbone Grinder/Scrapbone Bully
local specWarnStoneskin				= mod:NewSpecialWarningInterrupt(300514, "HasInterrupt", nil, nil, 1, 2)--Scrapbone Shaman
local specWarnGraspingHex			= mod:NewSpecialWarningInterrupt(300436, "HasInterrupt", nil, nil, 1, 2)--Scrapbone Shaman
local specWarnEnlarge				= mod:NewSpecialWarningInterrupt(301629, "HasInterrupt", nil, nil, 1, 2)--Mechagon Renormalizer
local specWarnShrink				= mod:NewSpecialWarningInterrupt(284219, "HasInterrupt", nil, nil, 1, 2)--Mechagon Renormalizer
local specWarnDetonate				= mod:NewSpecialWarningInterrupt(301088, "HasInterrupt", nil, nil, 1, 2)--Bomb Tonk (High Prio) (S2 confirmed)
local specWarnTuneUp				= mod:NewSpecialWarningInterrupt(293729, "HasInterrupt", nil, nil, 1, 2)
local specwarnGigaWallop			= mod:NewSpecialWarningInterrupt(293827, "HasInterrupt", nil, nil, 1, 2)--No cooldown, so no nampelate timer (S2 confirmed)
local specWarnSuffocatingSmogDispel	= mod:NewSpecialWarningDispel(300650, "RemoveDisease", nil, nil, 1, 2)--Toxic Lurker
local specWarnOverclockDispel		= mod:NewSpecialWarningDispel(293930, "MagicDispeller", nil, nil, 1, 2)--Pistonhead Mechanic/Mechagon Mechanic
local specWarnEnlargeDispel			= mod:NewSpecialWarningDispel(301629, "MagicDispeller", nil, nil, 1, 2)--Mechagon Renormalizer
local specWarnDefensiveCounter		= mod:NewSpecialWarningDispel(297133, "MagicDispeller", nil, nil, 1, 2)--Anodized Coilbearer/Defense Bot Mk III
--local specWarnShrinkDispel		= mod:NewSpecialWarningDispel(284219, "RemoveMagic", nil, nil, 1, 2)--Mechagon Renormalizer
--local specWarnFlamingRefuseDispel	= mod:NewSpecialWarningDispel(294180, "RemoveMagic", nil, nil, 1, 2)--Junkyard D.0.G. (Likely Deprecated)
local specWarnArcingZap				= mod:NewSpecialWarningDispel(294195, "RemoveMagic", nil, nil, 1, 2)--Defense Bot Mk I/Defense Bot Mk III (S2 confirmed)
local specWarnEnrageDispel			= mod:NewSpecialWarningDispel(300414, "RemoveEnrage", nil, nil, 1, 2)--Scrapbone Grinder/Scrapbone Bully
--local specWarnRiotShield			= mod:NewSpecialWarningReflect(258317, "CasterDps", nil, nil, 1, 2)

local timerConsumeCD				= mod:NewCDNPTimer(20, 300687, nil, nil, nil, 2)--Toxic Monstrosity. 20 second based on guide, not actual log. might need fixing
local timerDetonateCD				= mod:NewCDPNPTimer(22.5, 301088, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Small sample
local timerMegaDrillCD				= mod:NewCDNPTimer(23.6, 1215409, nil, nil, nil, 2)
local timerFieryJawsCD				= mod:NewCDNPTimer(18.4, 1217819, nil, nil, nil, 3)--18.4-21.9
local timerSonicPulseCD				= mod:NewCDNPTimer(13.3, 293986, nil, nil, nil, 3)--6.0 for Blastatron X-80, 13.3 for Spider Tank
local timerCapacitorDischargeCD		= mod:NewCDNPTimer(27.9, 295169, nil, nil, nil, 3)
local timerShieldGeneratorCD		= mod:NewCDNPTimer(21.9, 293683, nil, nil, nil, 5)
local timerTuneUpCD					= mod:NewCDNPTimer(20.6, 293729, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRocketBarrageCD			= mod:NewCDNPTimer(16.6, 294103, nil, nil, nil, 3)
local timerFlyingPeckCD				= mod:NewCDNPTimer(15.8, 294073, nil, nil, nil, 5)
local timerPunctureCD				= mod:NewCDNPTimer(19.3, 1215411, nil, nil, nil, 5)
local timerCorrosiveGunkCD			= mod:NewCDNPTimer(20.1, 1215412, nil, nil, nil, 2)
local timerSquirrelCD				= mod:NewCDNPTimer(14.6, 293854, nil, nil, nil, 1)
local timerArcingZapCD				= mod:NewCDNPTimer(20.9, 294195, nil, nil, nil, 5)
local timerShortOutCD				= mod:NewCDNPTimer(27.5, 297128, nil, nil, nil, 2)
local timerOverclockCD				= mod:NewCDNPTimer(15, 293930, nil, nil, nil, 5)--15-20.6

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

local function shrunkYellRepeater(self)
	yellShrunkRepeater:Yell()
	self:Schedule(2, shrunkYellRepeater, self)
end

function mod:Scraptarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(4, 6, targetname) then
		yellScrapCannon:Yell()
	end
end

function mod:BORKtarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(4, 6, targetname) then
		yellBORK:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 300687 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 1) then
			specWarnConsume:Show()
			specWarnConsume:Play("justrun")
		end
		timerConsumeCD:Start(20, args.sourceGUID)
	elseif spellId == 300159 and self:IsValidWarning(args.sourceGUID) and self:AntiSpam(3, 1) then
		specWarnGyroScrap:Show()
		specWarnGyroScrap:Play("justrun")
	elseif spellId == 300777 and self:IsValidWarning(args.sourceGUID) and self:AntiSpam(3, 2) then
		specWarnSlimewave:Show()
		specWarnSlimewave:Play("chargemove")
	elseif spellId == 300764 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSlimeBolt:Show(args.sourceName)
		specWarnSlimeBolt:Play("kickcast")
	elseif spellId == 300650 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSuffocatingSmog:Show(args.sourceName)
		specWarnSuffocatingSmog:Play("kickcast")
	elseif spellId == 300171 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRepairProtocol:Show(args.sourceName)
		specWarnRepairProtocol:Play("kickcast")
	elseif spellId == 300087 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRepair:Show(args.sourceName)
		specWarnRepair:Play("kickcast")
	elseif spellId == 300414 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnEnrage:Show(args.sourceName)
		specWarnEnrage:Play("kickcast")
	elseif spellId == 300514 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnStoneskin:Show(args.sourceName)
		specWarnStoneskin:Play("kickcast")
	elseif spellId == 300436 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnGraspingHex:Show(args.sourceName)
		specWarnGraspingHex:Play("kickcast")
	elseif spellId == 301629 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnEnlarge:Show(args.sourceName)
		specWarnEnlarge:Play("kickcast")
	elseif spellId == 293827 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specwarnGigaWallop:Show(args.sourceName)
		specwarnGigaWallop:Play("kickcast")
	elseif spellId == 284219 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnShrink:Show(args.sourceName)
		specWarnShrink:Play("kickcast")
	elseif spellId == 301088 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDetonate:Show(args.sourceName)
			specWarnDetonate:Play("kickcast")
		end
	elseif spellId == 300177 and self:IsValidWarning(args.sourceGUID) and self:AntiSpam(3, 6) then
		warnExhaust:Show()
	elseif spellId == 300188 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 2) then
			specWarnScrapCannon:Show()
			specWarnScrapCannon:Play("frontal")
		end
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "Scraptarget", 0.1, 8)
	elseif spellId == 299475 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 2) then
			specWarnBORK:Show()
			specWarnBORK:Play("frontal")
		end
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "BORKtarget", 0.1, 8)
	elseif spellId == 300424 and self:IsValidWarning(args.sourceGUID) and self:AntiSpam(3, 2) then
		specWarnShockwave:Show()
		specWarnShockwave:Play("frontal")
	elseif spellId == 300207 and self:IsValidWarning(args.sourceGUID) and self:AntiSpam(3, 4) then
		specWarnShockCoil:Show()
		specWarnShockCoil:Play("aesoon")
	elseif spellId == 301681 and self:AntiSpam(3, 6) then
		warnCharge:Show()
	elseif spellId == 301667 and self:AntiSpam(3, 2) then
		specWarnRapidFire:Show()
		specWarnRapidFire:Play("frontal")--Or watchstep?
	elseif spellId == 1215409 then
		timerMegaDrillCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnMegaDrill:Show()
			specWarnMegaDrill:Play("aesoon")
		end
	elseif spellId == 294290 and self:AntiSpam(3, 5) then
		specWarnProcessWaste:Show()
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnProcessWaste:Play("defensive")
		else
			specWarnProcessWaste:Play("frontal")
		end
	elseif spellId == 294349 and self:AntiSpam(5, 4) then
		warnVolatileWaste:Show()
	elseif spellId == 293854 and self:AntiSpam(3, 6) then
		warnSummonSquirrel:Show()
	elseif spellId == 293986 then
		local cid = self:GetCIDFromGUID(args.sourceGUID)
		local timer = (cid == 144296) and 13.3 or 6.0
		timerSonicPulseCD:Start(timer, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnSonicPulse:Show()
			specWarnSonicPulse:Play("farfromline")
		end
	elseif spellId == 1215411 then
		timerPunctureCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnPuncture:Show()
		end
	elseif spellId == 1215412 then
		if self:AntiSpam(3, 6) then
			--specwarnCorrosiveGunk:Show(DBM_COMMON_L.BREAK_LOS)
			--specwarnCorrosiveGunk:Play("breaklos")
			warnCorrosiveGunk:Show()
		end
	elseif spellId == 297128 then
		timerShortOutCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnShortOut:Show()
			specWarnShortOut:Play("aesoon")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 299525 and self:AntiSpam(3, 2) then
		warnScrapGrenade:Show()--SUCCESS, because this needs to be dodged when it hits ground, not when it's traveling toward a target that's moving
	--elseif spellId == 294015 and self:AntiSpam(3, 2) then
	--	specWarnLaunchHERockets:Show()
	--	specWarnLaunchHERockets:Play("watchstep")
	elseif spellId == 295169 then
		timerCapacitorDischargeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnCapacitorDischarge:Show()
			specWarnCapacitorDischarge:Play("watchstep")
		end
	elseif spellId == 301088 then
		timerDetonateCD:Start(22.5, args.sourceGUID)
	elseif spellId == 1217819 then
		timerFieryJawsCD:Start(nil, args.sourceGUID)
		FieryJaws:Show(args.destName)
	elseif spellId == 293683 then
		timerShieldGeneratorCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnShieldGenerator:Show()
			specWarnShieldGenerator:Play("moveboss")
		end
	elseif spellId == 293729 then
		timerTuneUpCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTuneUp:Show(args.sourceName)
			specWarnTuneUp:Play("kickcast")
		end
	elseif spellId == 294103 then
		timerRocketBarrageCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRocketBarrage:Show()
			specWarnRocketBarrage:Play("watchstep")
		end
	elseif spellId == 294073 then--Other spellids are just duplicate events, not needed
		timerFlyingPeckCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnFlyingPeck:Show()
		end
	elseif spellId == 1215412 then
		timerCorrosiveGunkCD:Start(nil, args.sourceGUID)
	elseif spellId == 293854 then
		timerSquirrelCD:Start(nil, args.sourceGUID)
		warnSquirrel:Show()--no antispam FOR NOW
	elseif spellId == 294195 then
		timerArcingZapCD:Start(nil, args.sourceGUID)
	elseif spellId == 293930 and self:AntiSpam(3, args.sourceGUID) then--Mob fires 2 success events per cast
		timerOverclockCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 301088 then
		timerDetonateCD:Start(22.5, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 300650 and args:IsDestTypePlayer() and self:CheckDispelFilter("disease") and self:AntiSpam(5, 3) then
		specWarnSuffocatingSmogDispel:Show(args.destName)
		specWarnSuffocatingSmogDispel:Play("helpdispel")
	elseif (spellId == 299588 or spellId == 293930) and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnOverclockDispel:Show(args.destName)
		specWarnOverclockDispel:Play("helpdispel")
	elseif spellId == 301629 and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnEnlargeDispel:Show(args.destName)
		specWarnEnlargeDispel:Play("helpdispel")
	elseif (spellId == 303941 or spellId == 297133) and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnDefensiveCounter:Show(args.destName)
		specWarnDefensiveCounter:Play("helpdispel")
	elseif spellId == 300414 and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnEnrageDispel:Show(args.destName)
		specWarnEnrageDispel:Play("enrage")
	elseif spellId == 284219 then
		if args:IsPlayer() then
			specWarnShrinkYou:Show()
			specWarnShrinkYou:Play("targetyou")
			yellShrunk:Yell()
			if self:IsMythic() then--Only repeat yell on mythic and mythic+
				self:Unschedule(shrunkYellRepeater)
				self:Schedule(2, shrunkYellRepeater, self)
			end
--		elseif self.Options.SpecWarn284219dispel and self:CheckDispelFilter() then
--			specWarnShrinkDispel:Show(args.destName)
--			specWarnShrinkDispel:Play("helpdispel")
		else
			warnShrunk:Show(args.destName)
		end
	--elseif spellId == 294180 and self:CheckDispelFilter("magic") then
	--	specWarnFlamingRefuseDispel:Show(args.destName)
	--	specWarnFlamingRefuseDispel:Play("helpdispel")
	elseif spellId == 294195 and self:CheckDispelFilter("magic") then
		specWarnArcingZap:CombinedShow(1, args.destName)
		specWarnArcingZap:ScheduleVoice(1, "helpdispel")
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 299438 and args:IsDestTypePlayer() then
		local amount = args.amount or 1
		if (amount >= 3) and self:AntiSpam(3, 5) then
			warnSledgehammer:Show(args.destName, amount)
		end
	elseif spellId == 299474 then
		local amount = args.amount or 1
		if (amount >= 3) and self:AntiSpam(3, 5) then
			warnRippingSlash:Show(args.destName, amount)
		end
	elseif spellId == 299502 then
		local amount = args.amount or 1
		if (amount >= 3) and self:AntiSpam(3, 5) then
			warnNanoslicer:Show(args.destName, amount)
		end
	elseif spellId == 293670 then
		local amount = args.amount or 1
		if (amount >= 3) and self:AntiSpam(3, 5) then
			warnChainblade:Show(args.destName, amount)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 284219 then
		if args:IsPlayer() then
			self:Unschedule(shrunkYellRepeater)
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 154744 or cid == 154758 or cid == 150168 then--Toxic Monstrosity
		timerConsumeCD:Stop(args.destGUID)
	elseif cid == 151657 then--Bomb Tonk
		timerDetonateCD:Stop(args.destGUID)
	elseif cid == 144293 then--Waste Processing Unit
		timerMegaDrillCD:Stop(args.destGUID)
		timerPunctureCD:Stop(args.destGUID)
	elseif cid == 151773 then--Junkyard D.0.G.
		timerFieryJawsCD:Stop(args.destGUID)
	elseif cid == 144296 then--Spider Tank
		timerSonicPulseCD:Stop(args.destGUID)
	elseif cid == 151476 then--Blastatron X-80
		timerSonicPulseCD:Stop(args.destGUID)
		timerCapacitorDischargeCD:Stop(args.destGUID)
	elseif cid == 144299 then--Workshop Defender
		timerShieldGeneratorCD:Stop(args.destGUID)
	elseif cid == 144295 then--Mechagon Mechanic
		timerTuneUpCD:Stop(args.destGUID)
		timerOverclockCD:Stop(args.destGUID)
	elseif cid == 151659 then--Rocket Tonk
		timerRocketBarrageCD:Stop(args.destGUID)
	elseif cid == 151658 then--Strider Tonk
		timerFlyingPeckCD:Stop(args.destGUID)
	elseif cid == 236033 then--Metal Gunk
		timerCorrosiveGunkCD:Stop(args.destGUID)
	elseif cid == 144294 then--Mechagon Tinkerer
		timerSquirrelCD:Stop(args.destGUID)
	elseif cid == 144298 or cid == 151649 then--Defense Bot Mk3 and Mk1
		timerArcingZapCD:Stop(args.destGUID)
		if cid == 144298 then--Mk3 only
			timerShortOutCD:Stop(args.destGUID)
		end
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 154744 then--Toxic Monstrosity
--		timerConsumeCD:Start(20-delay, guid)
	elseif cid == 151657 then--Bomb Tonk
		timerDetonateCD:Start(9.8-delay, guid)
	elseif cid == 144293 then--Waste Processing Unit
		timerPunctureCD:Start(7.1-delay, guid)
		timerMegaDrillCD:Start(13.1-delay, guid)
	elseif cid == 151773 then--Junkyard D.0.G.
		timerFieryJawsCD:Start(8.9-delay, guid)
	elseif cid == 144296 then--Spider Tank
		timerSonicPulseCD:Start(6-delay, guid)
	elseif cid == 151476 then--Blastatron X-80
		--timerSonicPulseCD:Start(1.2-delay, guid)--Not worth showing a 1.2 timer
		timerCapacitorDischargeCD:Start(17.8-delay, guid)
--	elseif cid == 144299 then--Workshop Defender
--		timerShieldGeneratorCD:Start(13.2-delay, guid)--Used instantly on engage now
	elseif cid == 151659 then--Rocket Tonk
		timerRocketBarrageCD:Start(5-delay, guid)
	elseif cid == 144295 then--Mechagon Mechanic
	--	timerTuneUpCD:Start(10-delay, guid)--IFFY, heals usually don't get cast until healthholds THEN go on cooldown
		timerOverclockCD:Start(15-delay, guid)
	elseif cid == 151658 then--Strider Tonk
		timerFlyingPeckCD:Start(8.5-delay, guid)
	elseif cid == 236033 then--Metal Gunk
		timerCorrosiveGunkCD:Start(11-delay, guid)
	elseif cid == 144294 then--Mechagon Tinkerer
		timerSquirrelCD:Start(4.7-delay, guid)
	elseif cid == 144298 or cid == 151649 then--Defense Bot Mk1 and Mk3
		--timerArcingZapCD:Start(9.5-delay, guid)--Used on engage now
		if cid == 144298 then--Mk3 only
			timerShortOutCD:Start(11.1-delay, guid)
		end
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
