local mod	= DBM:NewMod("UnderrotTrash", "DBM-Party-BfA", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true


mod:RegisterEvents(
	"SPELL_CAST_START 272609 266106 265019 265089 265091 265433 265540 272183 278961 278755 265487 272592 265081 272180 266209 413044",
	"SPELL_CAST_SUCCESS 265523 265016 266201 266265 265668",
	"SPELL_AURA_APPLIED 265568 266107 266209 265091 278789 278961 266201",
	"UNIT_DIED"
)

--TODO, verify dark omen can actually be stunned/CCed
--TODO, maybe alert if multiple https://www.wowhead.com/spell=265376/barbed-spear target you at once
--TODO, gift of ghuun and reconstruction timers. they are pretty long and rarely see double cast from a single mob
--[[
(ability.id = 413044 or ability.id = 272609 or ability.id = 266106 or ability.id = 265019 or ability.id = 265089 or ability.id = 265091 or ability.id = 265433 or ability.id = 265540 or ability.id = 272183 or ability.id = 278961 or ability.id = 265523 or ability.id = 278755 or ability.id = 265568 or ability.id = 265487 or ability.id = 272592 or ability.id = 265081 or ability.id = 272180 or ability.id = 266209 or ability.id = 265016) and type = "begincast"
 or (ability.id = 265668 or ability.id = 266107 or ability.id = 266201 or ability.id = 266265) and type = "cast"
--]]
local warnBloodHarvest				= mod:NewTargetNoFilterAnnounce(265016, 3)
local warnGiftOfGhuun				= mod:NewCastAnnounce(265091, 3)
local warnDarkReconstitution		= mod:NewCastAnnounce(265089, 3)
local warnSonicSreech				= mod:NewCastAnnounce(266106, 3)
local warnRaiseDead					= mod:NewCastAnnounce(272183, 3)--No longer exists in M+ but maybe still exists in timewalking/leveling version?
local warnShadowBoltVolley			= mod:NewCastAnnounce(265487, 3)
local warnWitheringCurse			= mod:NewCastAnnounce(265433, 3)
local warnWarcry					= mod:NewCastAnnounce(265081, 4)
local warnHarrowingDespair			= mod:NewCastAnnounce(278755, 3)
local warnWickedFrenzy				= mod:NewCastAnnounce(266209, 3)
local warnVoidSpit					= mod:NewCastAnnounce(272180, 2, nil, nil, false)--AKA Dark Bolt prior to 10.1
local warnDarkEchoes				= mod:NewCastAnnounce(413044, 4)

local specWarnMaddeningGaze			= mod:NewSpecialWarningDodge(272609, nil, nil, 2, 3, 2)
local yellBloodHarvest				= mod:NewShortYell(265016)--Pre Savage Cleave target awareness
local specWarnSavageCleave			= mod:NewSpecialWarningDodge(265019, nil, nil, nil, 2, 2)
local specWarnRottenBile			= mod:NewSpecialWarningDodge(265540, nil, nil, nil, 2, 2)
local specWarnAbyssalReach			= mod:NewSpecialWarningDodge(272592, nil, nil, nil, 2, 2)
local specWarnDarkOmen				= mod:NewSpecialWarningMoveAway(265568, nil, nil, nil, 1, 2)
local yellDarkOmen					= mod:NewShortYell(265568)
local specWarnThirstforBlood		= mod:NewSpecialWarningRun(266107, nil, nil, nil, 4, 2)
local specWarnSonicScreech			= mod:NewSpecialWarningInterrupt(266106, "HasInterrupt", nil, nil, 1, 2)
local specWarnDarkReconstituion		= mod:NewSpecialWarningInterrupt(265089, "HasInterrupt", nil, nil, 1, 2)
local specWarnGiftofGhuun			= mod:NewSpecialWarningInterrupt(265091, "HasInterrupt", nil, nil, 1, 2)
local specWarnShadowBoltVolley		= mod:NewSpecialWarningInterrupt(265487, "HasInterrupt", nil, nil, 1, 2)
local specWarnWitheringCurse		= mod:NewSpecialWarningInterrupt(265433, "HasInterrupt", nil, nil, 1, 2)
local specWarnRaiseDead				= mod:NewSpecialWarningInterrupt(272183, "HasInterrupt", nil, nil, 1, 2)
local specWarnDecayingMind			= mod:NewSpecialWarningInterrupt(278961, "HasInterrupt", nil, nil, 1, 2)
local specWarnHarrowingDespair		= mod:NewSpecialWarningInterrupt(278755, "HasInterrupt", nil, nil, 1, 2)
local specWarnVoidSpit				= mod:NewSpecialWarningInterrupt(272180, "HasInterrupt", nil, nil, 1, 2)
local specWarnDarkEchoes			= mod:NewSpecialWarningInterrupt(413044, "HasInterrupt", nil, nil, 1, 2)
local specWarnWickedFrenzy			= mod:NewSpecialWarningInterrupt(266209, "HasInterrupt", nil, nil, 1, 2)
local specWarnWickedFrenzyDispel	= mod:NewSpecialWarningDispel(266209, "RemoveEnrage", nil, nil, 1, 2)
local specWarnDecayingMindDispel	= mod:NewSpecialWarningDispel(278961, "RemoveDisease", nil, nil, 1, 2)
local specWarnGiftofGhuunDispel		= mod:NewSpecialWarningDispel(265091, "MagicDispeller", nil, nil, 1, 2)
local specWarnBoneShieldDispel		= mod:NewSpecialWarningDispel(266201, "MagicDispeller", nil, nil, 1, 2)--Unlike BFA version, 10.1 version now instant cast, no interrupt just dispel
local specWarnSpiritDrainTotemOut	= mod:NewSpecialWarningDodge(265523, nil, nil, nil, 2, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(278789, nil, nil, nil, 1, 8)

local timerBloodHarvestCD			= mod:NewCDNPTimer(12.1, 265016, nil, nil, nil, 3)
local timerRottenBileCD				= mod:NewCDNPTimer(10.7, 265540, nil, nil, nil, 3)
local timerWaveofDecayCD			= mod:NewCDNPTimer(10.7, 265668, nil, false, nil, 3)--Off by default to reduce clutter, but optional for those that want it
local timerWarcryCD					= mod:NewCDNPTimer(25.2, 265081, nil, nil, nil, 2)
local timerDecayingMindCD			= mod:NewCDNPTimer(27.7, 278961, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSonicScreechCD			= mod:NewCDNPTimer(25.4, 266106, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerVoidSpitCD				= mod:NewCDNPTimer(9.7, 272180, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDarkEchoesCD				= mod:NewCDNPTimer(18.2, 413044, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBoneShieldCD				= mod:NewCDNPTimer(25.4, 266201, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerWickedEmbraceCD			= mod:NewCDNPTimer(8.5, 266265, nil, "RemoveMagic", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerWickedFrenzyCD			= mod:NewCDNPTimer(25.4, 266209, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerWitheringCurseCD			= mod:NewCDNPTimer(25.4, 272180, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerShadowBoltVolleyCD		= mod:NewCDNPTimer(25.4, 265487, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--25.4-27.7
local timerAbyssalReachCD			= mod:NewCDNPTimer(16.1, 272592, nil, nil, nil, 3)
local timerMaddeningGazeCD			= mod:NewCDNPTimer(15.7, 272609, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON, nil, mod:IsTank() and 2 or nil, 3)--15.7-17

function mod:OnInitialize()
    if self.Options.Timer272609cdCVoice == true then
        self.Options.Timer272609cdCVoice = self:IsTank() and 2
    end
end

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 272609 then
		timerMaddeningGazeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnMaddeningGaze:Show()
			specWarnMaddeningGaze:Play("shockwave")
		end
	elseif spellId == 265019 and self:AntiSpam(3, 2) then
		specWarnSavageCleave:Show()
		specWarnSavageCleave:Play("shockwave")
	elseif spellId == 265540 then
		timerRottenBileCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRottenBile:Show()
			specWarnRottenBile:Play("shockwave")
		end
	elseif spellId == 266106 then
		timerSonicScreechCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn266106interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSonicScreech:Show(args.sourceName)
			specWarnSonicScreech:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnSonicSreech:Show()
		end
	elseif spellId == 265089 then
		if self.Options.SpecWarn265089interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDarkReconstituion:Show(args.sourceName)
			specWarnDarkReconstituion:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnDarkReconstitution:Show()
		end
	elseif spellId == 265091 then
		if self.Options.SpecWarn265091interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGiftofGhuun:Show(args.sourceName)
			specWarnGiftofGhuun:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnGiftOfGhuun:Show()
		end
	elseif spellId == 265433 then
		timerWitheringCurseCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn265433interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWitheringCurse:Show(args.sourceName)
			specWarnWitheringCurse:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnWitheringCurse:Show()
		end
	elseif spellId == 272183 then
		if self.Options.SpecWarn272183interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRaiseDead:Show(args.sourceName)
			specWarnRaiseDead:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnRaiseDead:Show()
		end
	elseif spellId == 278961 then
		timerDecayingMindCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDecayingMind:Show(args.sourceName)
			specWarnDecayingMind:Play("kickcast")
		end
	elseif spellId == 278755 then
		if self.Options.SpecWarn278755interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHarrowingDespair:Show(args.sourceName)
			specWarnHarrowingDespair:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnHarrowingDespair:Show()
		end
	elseif spellId == 272180 then
--		timerVoidSpitCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn272180interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnVoidSpit:Show(args.sourceName)
			specWarnVoidSpit:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnVoidSpit:Show()
		end
	elseif spellId == 265487 then
		timerShadowBoltVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn265487interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShadowBoltVolley:Show(args.sourceName)
			specWarnShadowBoltVolley:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnShadowBoltVolley:Show()
		end
	elseif spellId == 272592 then
		timerAbyssalReachCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnAbyssalReach:Show()
			specWarnAbyssalReach:Play("watchstep")
		end
	elseif spellId == 265081 then
		timerWarcryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnWarcry:Show()
		end
	elseif spellId == 266209 then
		timerWickedFrenzyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn266209interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWickedFrenzy:Show(args.sourceName)
			specWarnWickedFrenzy:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnWickedFrenzy:Show()
		end
	elseif spellId == 413044 then
		timerDarkEchoesCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn413044interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDarkEchoes:Show(args.sourceName)
			specWarnDarkEchoes:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnDarkEchoes:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 265523 and self:AntiSpam(3, 2) then
		specWarnSpiritDrainTotemOut:Show()
		specWarnSpiritDrainTotemOut:Play("watchstep")
	elseif spellId == 265016 then
		timerBloodHarvestCD:Start(nil, args.sourceGUID)
		if args:IsPlayer() then
			yellBloodHarvest:Yell()
		else
			warnBloodHarvest:Show(args.destName)
		end
	elseif spellId == 266201 then
		timerBoneShieldCD:Start(nil, args.sourceGUID)
	elseif spellId == 266265 then
		timerWickedEmbraceCD:Start(nil, args.sourceGUID)
	elseif spellId == 265668 then
		timerWaveofDecayCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 265568 and args:IsPlayer() and not DBM:UnitDebuff("player", spellId) then
		specWarnDarkOmen:Show()
		specWarnDarkOmen:Play("range5")
		yellDarkOmen:Yell()
	elseif spellId == 266107 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnThirstforBlood:Show()
		specWarnThirstforBlood:Play("justrun")
	elseif spellId == 266209 and self:AntiSpam(3, 5) then
		specWarnWickedFrenzyDispel:Show(args.destName)
		specWarnWickedFrenzyDispel:Play("enrage")
	elseif spellId == 265091 and not args:IsDestTypePlayer() and self:AntiSpam(4, 3) then
		specWarnGiftofGhuunDispel:Show(args.destName)
		specWarnGiftofGhuunDispel:Play("helpdispel")
	elseif spellId == 266201 and not args:IsDestTypePlayer() and self:AntiSpam(4, 3) then
		specWarnBoneShieldDispel:Show(args.destName)
		specWarnBoneShieldDispel:Play("helpdispel")
	elseif spellId == 278789 and args:IsPlayer() and self:AntiSpam(3, 8) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 278961 and args:IsDestTypePlayer() and self:CheckDispelFilter("disease") and self:AntiSpam(3, 3) then
		specWarnDecayingMindDispel:Show(args.destName)
		specWarnDecayingMindDispel:Play("helpdispel")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 131436 then--Chosen Blood Matron
		timerBloodHarvestCD:Stop(args.destGUID)
		timerWarcryCD:Stop(args.destGUID)
	elseif cid == 130909 then--Fetid Maggot
		timerRottenBileCD:Stop(args.destGUID)
	elseif cid == 133870 then--Diseased Lasher
		timerDecayingMindCD:Stop(args.destGUID)
	elseif cid == 133835 then--Feral Bloodswarmer
		timerSonicScreechCD:Stop(args.destGUID)
	elseif cid == 138187 then--Grotesque Horror
--		timerVoidSpitCD:Stop(args.destGUID)
		timerDarkEchoesCD:Stop(args.destGUID)
	elseif cid == 134284 then--Fallen Deathspeaker
		timerWickedFrenzyCD:Stop(args.destGUID)
		timerWickedEmbraceCD:Stop(args.destGUID)
	elseif cid == 133912 then--Broodsworn Defiler
		timerWitheringCurseCD:Stop(args.destGUID)
		timerShadowBoltVolleyCD:Stop(args.destGUID)
	elseif cid == 138281 then--Faceless Corruptor
		timerAbyssalReachCD:Stop(args.destGUID)
		timerMaddeningGazeCD:Stop(args.destGUID)
	elseif cid == 133836 then--Reanimated Guardian
		timerBoneShieldCD:Stop(args.destGUID)
	elseif cid == 133852 then--Living Rot
		timerWaveofDecayCD:Start(args.destGUID)
	end
end
