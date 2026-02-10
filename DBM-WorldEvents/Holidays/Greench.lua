local mod	= DBM:NewMod("Greench", "DBM-WorldEvents", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
local isRetail = DBM:IsRetail()
if isRetail then
	mod:SetCreatureID(228745)
else
	mod:SetCreatureID(54499)
end
mod:SetModelID(39021)
mod:SetReCombatTime(10, 5)
mod:SetZone(0)--Eastern Kingdoms

mod:RegisterCombat("combat")
mod:SetWipeTime(20)

if isRetail then
	--Do nothing
	--mod:RegisterEventsInCombat(
	--	"SPELL_CAST_START 451185 451046 451251",
	--	"SPELL_CAST_SUCCESS 426643",
	--	"SPELL_AURA_APPLIED 426643"
	--)
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 101907",
		"SPELL_CAST_SUCCESS 101873",
		"SPELL_AURA_APPLIED 101860",
		"SPELL_AURA_APPLIED_DOSE 101860",
		"UNIT_SPELLCAST_SUCCEEDED target focus"
	)
end

--local warn39TonSmash, warnGiftofGiving, timerGiftOfGivingCD, specWarnPresentPandemonium--Retail
local warnSnowCrash, warnSnowman, warnTree, timerSnowmanCD, timerTreeCD, timerCrushCD, timerSnowCrash--Legacy
local specWarnShrinkHeart, timerShrinkHeartCD--Shared
if isRetail then
	--warn39TonSmash				= mod:NewSpellAnnounce(451185, 3)
	--warnGiftofGiving			= mod:NewSpellAnnounce(451046, 2)
--
	--specWarnShrinkHeart			= mod:NewSpecialWarningDispel(426643, "RemoveMagic", nil, nil, 1, 2)
	--specWarnPresentPandemonium	= mod:NewSpecialWarningSwitch(451254, nil, nil, nil, 1, 2)
--
	--timerShrinkHeartCD			= mod:NewCDTimer(32.5, 426643, nil, nil, nil, 2)--Unknown recast time
--	--timer39TonSmashCD			= mod:NewCDTimer(10, 451185, nil, nil, nil, 3)--Unknown recast time
	--timerGiftOfGivingCD			= mod:NewCDTimer(13.6, 451046, nil, nil, nil, 3)--Iffy recast time
else
	warnSnowman					= mod:NewSpellAnnounce(101910, 2)
	warnSnowCrash				= mod:NewCastAnnounce(101907, 3)
	warnTree					= mod:NewSpellAnnounce(101938, 2)--Needs a custom icon, i'll find one soon.

	specWarnShrinkHeart			= mod:NewSpecialWarningMove(101873, nil, nil, nil, 1, 2)

	timerShrinkHeartCD			= mod:NewCDTimer(32.5, 101873, nil, nil, nil, 2)
	timerSnowmanCD				= mod:NewCDTimer(10, 101910, nil, nil, nil, 3)--He alternates these
	timerTreeCD					= mod:NewCDTimer(10, 101938, nil, nil, nil, 3)
	timerCrushCD				= mod:NewCDTimer(5, 101885, nil, nil, nil, 3)--Used 5 seconds after tree casts (on the tree itself). Right before stomp he stops targeting tank. He has no target during stomp, usable for cast trigger? Only trigger in log is the stomp landing.
	timerSnowCrash				= mod:NewCastTimer(5, 101907)
end

function mod:OnCombatStart(delay)
	if isRetail then
--		timerShrinkHeartCD:Start(5-delay)
--		timerGiftOfGivingCD:Start(10-delay)
	else
--		timerShrinkHeartCD:Start(5-delay)
--		timerCrushCD:Start(15-delay)
--		timerTreeCD:Start(20-delay)
		timerSnowmanCD:Start(-delay)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 101907 then
		warnSnowCrash:Show()
		timerSnowCrash:Start()
	--elseif args.spellId == 451185 then
		--warn39TonSmash:Show()
		--timer39TonSmashCD:Start()
	--elseif args.spellId == 451046 then
		--warnGiftofGiving:Show()
		--timerGiftOfGivingCD:Start()
	--elseif args.spellId == 451251 then
		--specWarnPresentPandemonium:Show()
		--specWarnPresentPandemonium:Play("targetchange")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 101873 then--or args.spellId == 426643
		timerShrinkHeartCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 101860 and args:IsPlayer() and self:AntiSpam(2) then
		--LuaLS can't use right diagnostic for an object that has two different definitions in same file
		---@diagnostic disable-next-line: param-type-mismatch
		specWarnShrinkHeart:Show()
		specWarnShrinkHeart:Play("keepmove")
	--elseif args.spellId == 426643 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
	--	specWarnShrinkHeart:CombinedShow(1, args.destName)
	--	specWarnShrinkHeart:ScheduleVoice(1, "helpdispel")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
--	The Abominable Greench:Possible Target<Omegathree>:target:Throw Strange Snowman Trigger::0:101942", -- [230]
	if spellId == 101942 then
		self:SendSync("SnowMan")
--	The Abominable Greench:Possible Target<Omegathree>:target:Throw Winter Veil Tree Trigger::0:101945", -- [493]
	elseif spellId == 101945 then
		self:SendSync("Tree")
	end
end

--Use syncing since these unit events require "target" or "focus" to detect.
--At least someone in group should be targeting this stuff and sync it to those that aren't (like a healer)
function mod:OnSync(event)
	if not self:IsInCombat() then return end
	if event == "SnowMan" then
		warnSnowman:Show()
		timerTreeCD:Start()--Not a bug, it's intended to start opposite timer off each trigger.
	elseif event == "Tree" then
		warnTree:Show()
		timerCrushCD:Start()
		timerSnowmanCD:Start()
	end
end
