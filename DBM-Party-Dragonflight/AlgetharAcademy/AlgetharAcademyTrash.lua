if DBM:IsPostMidnight() then return end
local mod	= DBM:NewMod("AlgetharAcademyTrash", "DBM-Party-Dragonflight", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2526)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 387910 377383 378003 388976 388863 377912 387843 388392 377389 396812 389054 388911",
	"SPELL_CAST_SUCCESS 390915 388984",
	"SPELL_AURA_APPLIED 388984 387843",
	"SPELL_AURA_REMOVED 387843",
	"UNIT_DIED",
	"GOSSIP_SHOW"
)

--[[
(ability.id = 388392 or ability.id = 387843 or ability.id = 388911 or ability.id = 387910 or ability.id = 378003 or ability.id = 377912 or ability.id = 377389 or ability.id = 396812) and type = "begincast"
 or ability.id = 388984 and type = "cast"
--]]
--TODO: add https://www.wowhead.com/spell=386026/surge ?
local warnManavoid								= mod:NewCastAnnounce(388863, 3)
local warnMonotonousLecture						= mod:NewCastAnnounce(388392, 2)
local warnViciousAmbush							= mod:NewTargetAnnounce(388984, 3)
local warnCalloftheFlock						= mod:NewCastAnnounce(377389, 3)
local warnMysticBlast							= mod:NewCastAnnounce(396812, 3)
local warnAstralWhirlwind						= mod:NewCastAnnounce(387910, 3)
local warnAstralBomb							= mod:NewCastAnnounce(387843, 3)
local warnAstralBombTargets						= mod:NewTargetAnnounce(387843, 3)

local specWarnExpelIntruders					= mod:NewSpecialWarningRun(377912, nil, nil, nil, 4, 2)
local specWarnDetonateSeeds						= mod:NewSpecialWarningDodge(390915, nil, nil, nil, 2, 2)
local specWarnDeadlyWinds						= mod:NewSpecialWarningDodge(378003, nil, nil, nil, 2, 2)
local specWarnRiftbreath						= mod:NewSpecialWarningDodge(388976, nil, nil, nil, 2, 2)
local specWarnGust								= mod:NewSpecialWarningDodge(377383, nil, nil, nil, 2, 2)
local yellGust									= mod:NewYell(377383)
local specWarnViciousAmbush						= mod:NewSpecialWarningYou(388984, nil, nil, nil, 1, 2)--You warning not move away, because some strategies involve actually baiting charge into melee instead of out
local yellnViciousAmbush						= mod:NewYell(388984)
local specWarnAstralBomb						= mod:NewSpecialWarningMoveTo(387843, nil, nil, nil, 2, 2)
local yellAstralBomb							= mod:NewYell(387843)
local yellAstralBombFades						= mod:NewShortFadesYell(387843)
local specWarnMonotonousLecture					= mod:NewSpecialWarningInterrupt(388392, "HasInterrupt", nil, nil, 1, 2)
local specWarnMysticBlast						= mod:NewSpecialWarningInterrupt(396812, "HasInterrupt", nil, nil, 1, 2)
local specWarnCalloftheFlock					= mod:NewSpecialWarningInterrupt(377389, "HasInterrupt", nil, nil, 1, 2)

local timerMonotonousLectureCD					= mod:NewCDNPTimer(15.8, 388392, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerMysticBlastCD						= mod:NewCDNPTimer(20.6, 396812, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerCalloftheFlockCD						= mod:NewCDNPTimer(36, 377389, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDeadlyWindsCD						= mod:NewCDNPTimer(10.9, 378003, nil, nil, nil, 3)
local timerExpelIntrudersCD						= mod:NewCDNPTimer(26.6, 377912, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerViciousAmbushCD						= mod:NewCDNPTimer(14.5, 388984, nil, nil, nil, 3)
local timerAstralWhirlwindCD					= mod:NewCDNPTimer(18.2, 387910, nil, "Melee", nil, 3)--These mob packs are heavily stunned and CD can be delayed by stuns
local timerAstralBombCD							= mod:NewCDNPTimer(17, 387843, nil, nil, nil, 3)--These mob packs are heavily stunned and CD can be delayed by stuns
local timerVicousLungeCD						= mod:NewCDNPTimer(11.4, 389054, nil, nil, nil, 3)
local timerSeveringSlashCD						= mod:NewCDNPTimer(14.3, 388911, nil, nil, nil, 5)

mod:AddGossipOption(true, "Buff")

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:GustTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellGust:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 387910 then
		timerAstralWhirlwindCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnAstralWhirlwind:Show()
		end
	elseif spellId == 388863 and self:AntiSpam(4, 6) then
		warnManavoid:Show()
	elseif spellId == 387843 then
		timerAstralBombCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(4, 5) then
			warnAstralBomb:Show()
		end
	elseif spellId == 388392 then
		timerMonotonousLectureCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn388392interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMonotonousLecture:Show(args.sourceName)
			specWarnMonotonousLecture:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnMonotonousLecture:Show()
		end
	elseif spellId == 377389 then
		timerCalloftheFlockCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn377389interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCalloftheFlock:Show(args.sourceName)
			specWarnCalloftheFlock:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnCalloftheFlock:Show()
		end
	elseif spellId == 396812 then
		timerMysticBlastCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn396812interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMysticBlast:Show(args.sourceName)
			specWarnMysticBlast:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnMysticBlast:Show()
		end
	elseif spellId == 377383 then
		if self:AntiSpam(3, 2) then
			specWarnGust:Show()
			specWarnGust:Play("shockwave")
		end
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "GustTarget", 0.1, 8)
	elseif spellId == 378003 then
		timerDeadlyWindsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDeadlyWinds:Show()
			specWarnDeadlyWinds:Play("watchstep")
		end
	elseif spellId == 388976 and self:AntiSpam(3, 2) then
		specWarnRiftbreath:Show()
		specWarnRiftbreath:Play("shockwave")
	elseif spellId == 377912 then
		timerExpelIntrudersCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnExpelIntruders:Show()
			specWarnExpelIntruders:Play("justrun")
		end
	elseif spellId == 389054 then
		timerVicousLungeCD:Start(nil, args.sourceGUID)
	elseif spellId == 388911 then
		timerSeveringSlashCD:Start(nil, args.sourceGUID)
--	elseif spellId == 310839 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
--		specWarnDirgefromBelow:Show(args.sourceName)
--		specWarnDirgefromBelow:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 390915 and self:AntiSpam(3, 2) then
		specWarnDetonateSeeds:Show()
		specWarnDetonateSeeds:Play("watchstep")
	elseif spellId == 388984 then
		timerViciousAmbushCD:Start(nil, args.sourceGUID)
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 388984 then
		warnViciousAmbush:Show(args.destName)
		if args:IsPlayer() then
			specWarnViciousAmbush:Show()
			specWarnViciousAmbush:Play("targetyou")
			yellnViciousAmbush:Yell()
		end
	elseif spellId == 387843 then
		warnAstralBombTargets:CombinedShow(1, args.destName)
		if args:IsPlayer() then
			specWarnAstralBomb:Show(DBM_COMMON_L.ADDS)
			specWarnAstralBomb:Play("targetyou")
			yellAstralBomb:Yell()
			yellAstralBombFades:Countdown(spellId, 2)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 387843 and args:IsPlayer() then
		yellAstralBombFades:Cancel()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 196044 then--Unruly Textbook
		timerMonotonousLectureCD:Stop(args.destGUID)
	elseif cid == 192680 then--Guardian Sentry
		timerDeadlyWindsCD:Stop(args.destGUID)
		timerExpelIntrudersCD:Stop(args.destGUID)
	elseif cid == 196671 then--Arcane Ravager
		timerViciousAmbushCD:Stop(args.destGUID)
	elseif cid == 196200 then--Algeth'ar Echoknight
		timerAstralWhirlwindCD:Stop(args.destGUID)
	elseif cid == 196202 then--Spectral Invoker
		timerAstralBombCD:Stop(args.destGUID)
	elseif cid == 192333 then--Alpha Eagle
		timerCalloftheFlockCD:Stop(args.destGUID)
	elseif cid == 196576 then--Spellbound Scepter
		timerMysticBlastCD:Stop(args.destGUID)
	elseif cid == 196694 then--Arcane Forager
		timerVicousLungeCD:Stop(args.destGUID)
	elseif cid == 196577 then--Spellbound battleaxe
		timerSeveringSlashCD:Stop(args.destGUID)
	end
end

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		--Black, Bronze, Blue, Red, Green
		if self.Options.AutoGossipBuff and (gossipOptionID == 107065 or gossipOptionID == 107081 or gossipOptionID == 107082 or gossipOptionID == 107088 or gossipOptionID == 107083) then -- Buffs
			self:SelectGossip(gossipOptionID)
		end
	end
end
