local mod	= DBM:NewMod("z2710", "DBM-WorldEvents", 2)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"

mod:SetRevision("@file-date-integer@")
mod:SetZone(2710)

mod:RegisterCombat("scenario", 2710)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 463052 463081 462892 462802 462936 462856",
	"SPELL_CAST_SUCCESS 462983",
	"SPELL_AURA_APPLIED 462983",
	"UNIT_DIED",
	"UPDATE_UI_WIDGET",
	"UNIT_SPELLCAST_SUCCEEDED_UNFILTERED"
)

--TODO, actually detect wave number and change specWarnAdds to count warning
--TODO, on wave 20 disable the looping adds timer
local warnBeam						= mod:NewSpellAnnounce(462892, 3)
local warnPurifyingFlames			= mod:NewSpellAnnounce(462802, 3)
local warnSelfDestruct				= mod:NewSpellAnnounce(63801, 4)--Bomb spawns

local specWarnAdds					= mod:NewSpecialWarningAdds(433320, nil, nil, nil, 1, 2)
local specWarnBellowingSlam			= mod:NewSpecialWarningDodge(463052, nil, nil, nil, 2, 2)
local specWarnEarthshakingCharge	= mod:NewSpecialWarningDodge(463081, nil, nil, nil, 2, 2)
local specWarnVolatileMagma			= mod:NewSpecialWarningMove(462983, nil, nil, nil, 1, 2)

--local timerAdds					= mod:NewAddsTimer(9.8, 433320)--Initial wave only
local timerBellowingSlamCD			= mod:NewCDNPTimer(20.6, 463052, nil, nil, nil, 3)
local timerMaintenanceCD			= mod:NewCDNPTimer(19.3, 462936, nil, nil, nil, 5)
local timerVolatileMagmaCD			= mod:NewCDNPTimer(17.3, 462983, nil, nil, nil, 3)

function mod:SPELL_CAST_START(args)
	if args.spellId == 463052 then
		specWarnBellowingSlam:Show()
		specWarnBellowingSlam:Play("watchstep")
		timerBellowingSlamCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 463081 then
		specWarnEarthshakingCharge:Show()
		specWarnEarthshakingCharge:Play("shockwave")
	elseif args.spellId == 462892 then
		warnBeam:Show()
	elseif args.spellId == 462802 and self:AntiSpam(4, 1) then
		warnPurifyingFlames:Show()
	elseif args.spellId == 462936 then
		timerMaintenanceCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 462983 then
		timerVolatileMagmaCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 462983 and args:IsPlayer() then
		specWarnVolatileMagma:Show()
		specWarnVolatileMagma:Play("turnaway")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 229782 then--Golem at end
		timerBellowingSlamCD:Stop(args.destGUID)
		DBM:EndCombat(self)--Win
	elseif cid == 229769 then
		timerMaintenanceCD:Stop(args.destGUID)
	elseif cid == 229778 then
		timerVolatileMagmaCD:Stop(args.destGUID)
	end
end

--"<52.66 12:44:32> [UPDATE_UI_WIDGET] widgetID:6187, widgetType:2, widgetSetID:1356, scriptedAnimationEffectID:0, barMin:0, widgetScale:0, glowAnimType:0, tooltipLoc:0, shownState:1, widgetSizeSetting:0, fillMinOpacity:0, text:Awakened Cache Reward, textEnabledState:3, barTextSizeType:0, layoutDirection:0, barValue:1, hasTimer:false, overrideBarText:, partitionValues:table, colorTint:6, barTextFontType:1, barMax:4, textFontType:1, barTextEnabledState:3, fillMaxOpacity:0, modelSceneLayer:0, textSizeType:0, outAnimType:0, orderIndex:1, widgetTag:, inAnimType:0, showGlowState:0, fillMotionType:0, overrideBarTextShownType:0, barValueTextType:0, tooltip:Current progress in Awakening The Machine. Every 5th wave completed provides a reward upgrade.",
--"<71.64 12:44:51> [UPDATE_UI_WIDGET] widgetID:5573, text:Wave 6  ",
--NOTE, in midnight and beyond since unit died is no longer usable, fix this to use widget api to detect win instead if this content every returns to relevance
function mod:UPDATE_UI_WIDGET(table)
	local id = table.widgetID
	if id == 5573 then
		specWarnAdds:Show()
		specWarnAdds:Play("killmob")
--	elseif id == 6187 then
		--timerAdds:Stop()
	end
end

--NOTE: This scenario has no boss unit Ids. These alerts will only work with focus, target, and friendly nameplates
function mod:UNIT_SPELLCAST_SUCCEEDED_UNFILTERED(uId, _, spellId)
	if spellId == 462819 and self:AntiSpam(4, 3) then--Player Detection
		--Bombs fire this spell on activation cause it's script that enables their detection of being near player (or npc) to explode
		warnSelfDestruct:Show()
--	elseif spellId == 433923 and self:AntiSpam(4, 2) then-- -[DNT] Kuldas Machine Speaker Ritual - Cosmetic Channel-
		--Timer for initial wave after resuming/starting
		--All other adds spawn on defeat of last set
--		timerAdds:Start()
--	elseif spellId == 433320 and self:AntiSpam(4, 4) then
		--This actually is a looping 10 second timer that will skip adds if some are still alive
		--But if none are alive they will spawn exactly on the repeating tick
--		timerAdds:Start()
	end
end
