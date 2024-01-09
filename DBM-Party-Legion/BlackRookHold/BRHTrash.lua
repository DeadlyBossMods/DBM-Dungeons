local mod	= DBM:NewMod("BRHTrash", "DBM-Party-Legion", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1501)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 200261 221634 221688 225573 214003 199663 200105 196916 225732 196883 194966 200248 200256 200291 200784 200913 201139 201176 182118 214001 227913",--199663
	"SPELL_CAST_SUCCESS 200343 225962 203163 204896 200784",--8599
	"SPELL_AURA_APPLIED 194966 200105 200248 8599 203163",
	"SPELL_AURA_APPLIED_DOSE 200084 225909 200248",
	"SPELL_AURA_REMOVED 200248",
	"UNIT_DIED"
)

--[[
(ability.id = 200261 or ability.id = 221634 or ability.id = 221688 or ability.id = 225573 or ability.id = 214003 or ability.id = 199663 or ability.id = 200105 or ability.id = 196916 or ability.id = 225732 or ability.id = 196883 or ability.id = 194966 or ability.id = 200248 or ability.id = 200256 or ability.id = 200291 or ability.id = 200784 or ability.id = 200913 or ability.id = 201139 or ability.id = 201176 or ability.id = 182118 or ability.id = 203163 or ability.id = 214001 or ability.id = 199663) and type = "begincast"
 or (ability.id = 200343 or ability.id = 225962 or ability.id = 203163 or ability.id = 204896 or ability.id = 8599 or ability.id = 200784) and type = "cast"
--]]
--TODO, add Etch? http://www.wowhead.com/spell=198959/etch
--TODO, can't find spellId for Priceless artifact puddles. when found, add GTFO
--TODO, despite what two guides say, fel frenzy doesn't exist in any M+ logs at all
--NOTE, trash uses 194966 just like boss, the expression will pick up both
local warnSoulEchoes				= mod:NewTargetAnnounce(194966, 2)
local warnSacrificeSoul				= mod:NewTargetNoFilterAnnounce(200105, 2)
local warnSicBats					= mod:NewTargetNoFilterAnnounce(203163, 2)
local warnArrowBarrage				= mod:NewSpellAnnounce(200343, 4, nil, nil, nil, nil, nil, 3)
local warnKnifeDance				= mod:NewSpellAnnounce(200291, 4, nil, nil, nil, nil, nil, 3)
local warnDrinkPotion				= mod:NewSpellAnnounce(200784, 4, nil, nil, nil, nil, nil, 3)
local warnBloodthirstyLeap			= mod:NewSpellAnnounce(225962, 2, nil, false)--Instant cast, announcing it already happened doesn't affect much agency to player
local warnGlaiveToss				= mod:NewCastAnnounce(196916, 3)
local warnPhasedExplosion			= mod:NewCastAnnounce(200256, 3, nil, nil, false)--They basically spam cast it, so off by default
local warnFelFrenzy					= mod:NewCastAnnounce(227913, 4)--High prio off internet
local warnSoulVenom					= mod:NewStackAnnounce(225909, 2)

local specWarnSicBats				= mod:NewSpecialWarningYou(203163, nil, nil, nil, 1, 2)
local specWarnStrikeDown			= mod:NewSpecialWarningDefensive(225732, nil, nil, nil, 1, 2)
local specWarnCoupdeGrace			= mod:NewSpecialWarningDefensive(214003, nil, nil, nil, 1, 2)
local specWarnBrutalAssault			= mod:NewSpecialWarningDefensive(201139, nil, nil, nil, 1, 2)
local specWarnBonebreakingStrike	= mod:NewSpecialWarningDodge(200261, nil, nil, nil, 2, 2)--Even tank can side step it, but tank can also aim it away from others
local specWarnWhirlOfFlame			= mod:NewSpecialWarningDodge(221634, nil, nil, nil, 2, 2)
local specWarnIndigestion			= mod:NewSpecialWarningDodge(200913, nil, nil, nil, 2, 2)
local specWarnThrowArtifact			= mod:NewSpecialWarningDodge(201176, nil, nil, nil, 2, 2)
local specWarnRavensDive			= mod:NewSpecialWarningDodge(214001, nil, nil, nil, 2, 2)
local specWarnOverDetonation		= mod:NewSpecialWarningRun(221688, nil, nil, nil, 4, 2)
local specWarnSoulEchos				= mod:NewSpecialWarningMoveAway(194966, nil, nil, nil, 1, 2)
local yellArrowBarrage				= mod:NewYell(200343)
local specWarnSpiritBlast			= mod:NewSpecialWarningInterrupt(196883, "HasInterrupt", nil, nil, 1, 2)
local specWarnDarkMending			= mod:NewSpecialWarningInterrupt(225573, "HasInterrupt", nil, nil, 1, 2)
local specWarnSoulBlast				= mod:NewSpecialWarningInterrupt(199663, "HasInterrupt", nil, nil, 1, 2)
local specWarnArcaneBlitz			= mod:NewSpecialWarningInterrupt(200248, "HasInterrupt", nil, nil, 1, 2)
local specWarnFelFrenzy				= mod:NewSpecialWarningInterrupt(227913, "HasInterrupt", nil, nil, 1, 2)--High Priority
local specWarnSoulBlade				= mod:NewSpecialWarningDispel(200084, "RemoveMagic", nil, nil, 1, 2)
local specWarnDrainLife				= mod:NewSpecialWarningDispel(204896, "RemoveMagic", nil, nil, 1, 2)
local specWarnEnrage				= mod:NewSpecialWarningDispel(8599, "RemoveEnrage", nil, 2, 1, 2)

local timerRP						= mod:NewRPTimer(68)
local timerSacrificeSoulCD			= mod:NewCDNPTimer(21.8, 200105, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerGlaiveTossCD				= mod:NewCDNPTimer(14.5, 196916, nil, nil, nil, 3)
local timerStrikeDownCD				= mod:NewCDNPTimer(9.7, 225732, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBonebreakingStrikeCD		= mod:NewCDNPTimer(21.8, 200261, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerKnifeDanceCD				= mod:NewCDNPTimer(18.1, 200291, nil, nil, nil, 2)
local timerArrowBarrageCD			= mod:NewCDNPTimer(20.6, 200343, nil, nil, nil, 3)--20.7-23
local timerBloodthirstyLeapCD		= mod:NewCDNPTimer(14.5, 225962, nil, nil, nil, 3)
local timerDrainLifeCD				= mod:NewCDNPTimer(16.8, 204896, nil, nil, nil, 3)--16.8-19
local timerBrutalAssaultCD			= mod:NewCDNPTimer(20.6, 201139, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerDrinkPotionCD			= mod:NewCDNPTimer(21.8, 200784, nil, nil, nil, 5)
local timerSicBatsCD				= mod:NewCDNPTimer(21.8, 203163, nil, nil, nil, 5)
local timerCoupdeGraceCD			= mod:NewCDNPTimer(8.4, 214003, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerRavensDiveCD				= mod:NewCDNPTimer(16.9, 214001, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

local blitzStacks = {}

--"<2.04 23:10:40> [BOSS_KILL] 1832#Amalgam of Souls", -- [27]
--"<2.07 23:10:40> [CLEU] UNIT_DIED##nil#Creature-0-4225-1501-17971-98542-00007A7FD4#Amalgam of Souls#-1#false#nil#nil", -- [28]
--"<10.62 23:10:49> [CHAT_MSG_MONSTER_SAY] The darkness... it is gone.#Lady Velandras Ravencrest###Omegal##0#0##0#2108#nil#0#false#false#false#false", -- [37]
--"<15.93 23:10:54> [CHAT_MSG_MONSTER_YELL] You... aren't the ones who did this?#Lord Etheldrin Ravencrest###Omegal##0#0##0#2109#nil#0#false#false#false#false", -- [38]
--"<29.29 23:11:07> [CHAT_MSG_MONSTER_SAY] I... understand now. You... you must find Kur'talos. You must put a stop to this.#Lord Etheldrin Ravencrest###Darksøl##0#0##0#2110#nil#0#false#false#false#false", -- [39]
--"<39.20 23:11:17> [ZONE_CHANGED_INDOORS] Black Rook Hold#Black Rook Hold#Hidden Passageway", -- [41]
function mod:StartFirstRP()
	timerRP:Start(36)--Approx, no definitive timestamp but zone ZONE_CHANGED_INDOORS fired running into door til it opened and we subtrack 1 second on top of that
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 200261 then
		timerBonebreakingStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBonebreakingStrike:Show()
			specWarnBonebreakingStrike:Play("shockwave")
		end
	elseif spellId == 200913 and self:AntiSpam(3, 2) then
		specWarnIndigestion:Show()
		specWarnIndigestion:Play("shockwave")
	elseif spellId == 201176 and self:AntiSpam(3, 2) then
		specWarnThrowArtifact:Show()
		specWarnThrowArtifact:Play("watchstep")
	elseif spellId == 221634 then
		if self:AntiSpam(3, 2) then
			specWarnWhirlOfFlame:Show()
			specWarnWhirlOfFlame:Play("watchstep")
		end
	elseif spellId == 214001 then
		timerRavensDiveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRavensDive:Show()
			specWarnRavensDive:Play("watchstep")
		end
	elseif spellId == 221688 then
		if self:AntiSpam(3, 1) then
			specWarnOverDetonation:Show()
			specWarnOverDetonation:Play("justrun")
		end
	elseif spellId == 225573 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDarkMending:Show(args.sourceName)
			specWarnDarkMending:Play("kickcast")
		end
	elseif spellId == 182118 or spellId == 227913 then
		if self.Options.SpecWarn227913interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFelFrenzy:Show(args.sourceName)
			specWarnFelFrenzy:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnFelFrenzy:Show()
		end
	elseif spellId == 199663 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSoulBlast:Show(args.sourceName)
			specWarnSoulBlast:Play("kickcast")
		end
	elseif spellId == 196883 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSpiritBlast:Show(args.sourceName)
			specWarnSpiritBlast:Play("kickcast")
		end
	elseif spellId == 200248 then
		--Excessively throttle it cause ability is literally spammed so we check stacks, we check interrupt CD, and we even 3 second throttle it
		if blitzStacks[args.destGUID] and blitzStacks[args.destGUID] >= 5 and self:CheckInterruptFilter(args.sourceGUID, false, true) and self:AntiSpam(3, 5) then
			specWarnArcaneBlitz:Show(args.sourceName)
			specWarnArcaneBlitz:Play("kickcast")
		end
	elseif spellId == 214003 then
		timerCoupdeGraceCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnCoupdeGrace:Show()
			specWarnCoupdeGrace:Play("defensive")
		end
	elseif spellId == 225732 then
		timerStrikeDownCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnStrikeDown:Show()
			specWarnStrikeDown:Play("defensive")
		end
	elseif spellId == 200105 then
		timerSacrificeSoulCD:Start(nil, args.sourceGUID)
	elseif spellId == 196916 then
		timerGlaiveTossCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnGlaiveToss:Show()
		end
	elseif spellId == 194966 then
		--Soul Echoes Timer
	elseif spellId == 200256 then
		warnPhasedExplosion:Show()
	elseif spellId == 200291 then
		timerKnifeDanceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3.5, 6) then
			warnKnifeDance:Show()
			warnKnifeDance:Play("crowdcontrol")
		end
	elseif spellId == 200784 then
		--Starts 4.8 second recast timer on cast start
		--ie it'll recast after 4.8 seconds if this cast is stopped
		--But if it finishes casting, goes on ?? second CD
		timerDrinkPotionCD:Start(4.8, args.sourceGUID)
		if self:AntiSpam(3.5, 6) then
			warnDrinkPotion:Show()
			warnDrinkPotion:Play("crowdcontrol")
		end
	elseif spellId == 201139 then
		timerBrutalAssaultCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnBrutalAssault:Show()
			specWarnBrutalAssault:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 200343 then
		timerArrowBarrageCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3.5, 6) then
			warnArrowBarrage:Show()
			warnArrowBarrage:Play("crowdcontrol")
		end
		if args:IsPlayer() and self:AntiSpam(3, 6) then
			yellArrowBarrage:Yell()
		end
	elseif spellId == 225962 then--225962 first leap, 225963 second leap (which we don't care about for announce/timer purposes)
		timerBloodthirstyLeapCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnBloodthirstyLeap:Show()
		end
	elseif spellId == 203163 then
		--Does not go on CD until it's cast. if it's stunned, it's recast within a 3-5 sec cast window
		timerSicBatsCD:Start(16, args.sourceGUID)
	elseif spellId == 204896 then
		timerDrainLifeCD:Start(nil, args.sourceGUID)
		if self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnDrainLife:Show(args.destName)
			specWarnDrainLife:Play("helpdispel")
		end
	elseif spellId == 200784 then
		--Starts 4.8 second recast timer on cast start
		--ie it'll recast after 4.8 seconds if this cast is stopped
		--But if it finishes casting, goes on ?? second CD
		timerDrinkPotionCD:Stop(args.sourceGUID)
		--TODO, when it's recast is it actually goes on cooldown
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 194966 then
		if args:IsPlayer() then
			specWarnSoulEchos:Show()
			specWarnSoulEchos:Play("runout")
			specWarnSoulEchos:ScheduleVoice(1, "keepmove")
		else
			warnSoulEchoes:Show(args.destName)
		end
	elseif spellId == 200084 and args:IsDestTypePlayer() then
		local amount = args.amount or 1
		if amount % 2 == 0 and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnSoulBlade:Show(args.destName)
			specWarnSoulBlade:Play("helpdispel")
		end
	elseif spellId == 225909 and args:IsDestTypePlayer() then
		local amount = args.amount or 1
		if (amount % 10 == 0) and (self:CheckDispelFilter("magic") or args:IsPlayer()) and self:AntiSpam(3, 3) then
			warnSoulVenom:Show(args.destName, amount)
		end
	elseif spellId == 200105 then
		warnSacrificeSoul:Show(args.sourceName)--Source name used, we want to kill the actor not the target (sometimes one in same though)
	elseif spellId == 200248 then
		blitzStacks[args.destGUID] = args.amount or 1
	elseif spellId == 8599 and self:AntiSpam(4, 3) then
		specWarnEnrage:Show(args.destName)
		specWarnEnrage:Play("enrage")
	elseif spellId == 203163 then
		if args:IsPlayer() then
			specWarnSicBats:Show()
			specWarnSicBats:Play("targetyou")
		else
			warnSicBats:Show(args.destName)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 98368 then--ghostly-protector
		timerSacrificeSoulCD:Stop(args.destGUID)
--	elseif cid == 98370 then--ghostly-councilor
		--Soul Blast
	elseif cid == 98538 then--lady-velandras-ravencrest#drops;mode:normal
		timerGlaiveTossCD:Stop(args.destGUID)
		timerStrikeDownCD:Stop(args.destGUID)
--	elseif cid == 98521 then--lord-etheldrin-ravencrest
		--Spirit Blast
		--Soul Echoes
	elseif cid == 98275 then--risen-archer
		timerArrowBarrageCD:Stop(args.destGUID)
	elseif cid == 98280 then--risen-arcanist
		blitzStacks[args.destGUID] = nil
	elseif cid == 98691 then--risen-scout
		timerKnifeDanceCD:Stop(args.destGUID)
	elseif cid == 98243 or cid == 98706 then--soul-torn-champion / commander-shemdahsohn
		timerBonebreakingStrikeCD:Stop(args.destGUID)
	elseif cid == 101839 then--risen-companion
		timerBloodthirstyLeapCD:Stop(args.destGUID)
	elseif cid == 98810 then--wrathguard-bladelord
		timerBrutalAssaultCD:Stop(args.destGUID)
	elseif cid == 98792 then--wyrmtongue-scavenger
		timerDrinkPotionCD:Stop()
	elseif cid == 102788 then--felspite-dominator
		--Fel Frenzy
		timerSicBatsCD:Stop(args.destGUID)
	elseif cid == 102094 then--risen-swordsman
		timerCoupdeGraceCD:Stop(args.destGUID)
	elseif cid == 102095 then--risen-lancer
		timerRavensDiveCD:Stop(args.destGUID)
	elseif cid == 98813 then--Bloodscent Felhouhd
		timerDrainLifeCD:Stop(args.destGUID)
	end
end
