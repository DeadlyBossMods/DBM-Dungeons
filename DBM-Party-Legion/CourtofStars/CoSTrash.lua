local mod	= DBM:NewMod("CoSTrash", "DBM-Party-Legion", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetOOCBWComms()
mod:SetMinSyncRevision(20221228000000)
mod:SetZone(1571)

mod.isTrashMod = true

--LW solution, unregister/reregister other addons/WA frames from GOSSIP_SHOW
--This is to prevent things like https://wago.io/M+Timer/114 from breaking clue helper do to advancing
--dialog before we get a chance to read gossipID
local frames = {GetFramesRegisteredForEvent("GOSSIP_SHOW")}
for i = 1, #frames do
	frames[i]:UnregisterEvent("GOSSIP_SHOW")
end
mod:RegisterEvents(
	"SPELL_CAST_START 209027 212031 209485 209410 209413 211470 211464 209404 209495 225100 211299 209378 397892 397897 207979 212784 207980 212773 210261 209033",
	"SPELL_AURA_APPLIED 209033 209512 397907 373552",
	"SPELL_AURA_REMOVED 397907",
	"CHAT_MSG_MONSTER_SAY",
	"GOSSIP_SHOW"
)
for i = 1, #frames do
	frames[i]:RegisterEvent("GOSSIP_SHOW")
end

--TODO, at least 1-2 more GTFOs I forgot names of
--TODO, target scan https://www.wowhead.com/beta/spell=397897/crushing-leap ?
--TODO, few more auto gossips
--Buffs/Utility (professions and classs perks)
--45278 Haste Buff Court of Stars (cooking/herbalism?)
--Distractions (to separate boss)
--45473 Warrior Distraction Court of Stars
--45168 Cooking Interaction buff
--45332 Engineering interaction to break robots
--[[
(ability.id = 209033 or ability.id = 209027 or ability.id = 212031 or ability.id = 207979 or ability.id = 209485 or ability.id = 209410
 or ability.id = 209413 or ability.id = 211470 or ability.id = 225100 or ability.id = 211299 or ability.id = 207980 or ability.id = 212773
 or ability.id = 211464 or ability.id = 209404 or ability.id = 209495 or ability.id = 209378 or ability.id = 397892 or ability.id = 397897
 or ability.id = 212784) and type = "begincast"
--]]
local warnImpendingDoom				= mod:NewTargetAnnounce(397907, 2)
local warnSoundAlarm				= mod:NewCastAnnounce(210261, 4)
local warnSubdue					= mod:NewCastAnnounce(212773, 3)
local warnCrushingLeap				= mod:NewCastAnnounce(397897, 3)
local warnEyeStorm					= mod:NewCastAnnounce(212784, 4)
local warnHypnosisBat				= mod:NewTargetNoFilterAnnounce(373552, 3)

local specWarnFortificationDispel	= mod:NewSpecialWarningDispel(209033, "MagicDispeller", nil, nil, 1, 2)
local specWarnQuellingStrike		= mod:NewSpecialWarningDodge(209027, "Melee", nil, 2, 1, 2)
local specWarnChargedBlast			= mod:NewSpecialWarningDodge(212031, "Tank", nil, nil, 1, 2)
local specWarnChargedSmash			= mod:NewSpecialWarningDodge(209495, "Melee", nil, 2, 1, 2)
local specWarnShockwave				= mod:NewSpecialWarningDodge(207979, nil, nil, nil, 2, 2)
local specWarnSubdue				= mod:NewSpecialWarningInterrupt(212773, "HasInterrupt", nil, nil, 1, 2)
local specWarnFortification			= mod:NewSpecialWarningInterrupt(209033, false, nil, nil, 1, 2)--Opt in. There are still higher prio interrupts in most packs with guards and this can be dispelled after the fact
local specWarnDrainMagic			= mod:NewSpecialWarningInterrupt(209485, "HasInterrupt", nil, nil, 1, 2)
local specWarnNightfallOrb			= mod:NewSpecialWarningInterrupt(209410, "HasInterrupt", nil, nil, 1, 2)
local specWarnSuppress				= mod:NewSpecialWarningInterrupt(209413, "HasInterrupt", nil, nil, 1, 2)
local specWarnBewitch				= mod:NewSpecialWarningInterrupt(211470, "HasInterrupt", nil, nil, 1, 2)
local specWarnChargingStation		= mod:NewSpecialWarningInterrupt(225100, "HasInterrupt", nil, nil, 1, 2)
local specWarnSearingGlare			= mod:NewSpecialWarningInterrupt(211299, "HasInterrupt", nil, nil, 1, 2)
local specWarnDisintegrationBeam	= mod:NewSpecialWarningInterrupt(207980, "HasInterrupt", nil, nil, 1, 2)
local specWarnFelDetonation			= mod:NewSpecialWarningMoveTo(211464, nil, nil, nil, 2, 2)
local specWarnSealMagic				= mod:NewSpecialWarningRun(209404, false, nil, 2, 4, 2)
local specWarnWhirlingBlades		= mod:NewSpecialWarningRun(209378, "Melee", nil, nil, 4, 2)
local specWarnScreamofPain			= mod:NewSpecialWarningCast(397892, "SpellCaster", nil, nil, 1, 2)
local specWarnImpendingDoom			= mod:NewSpecialWarningMoveAway(397907, nil, nil, nil, 1, 2)
local yellImpendingDoom				= mod:NewYell(397907)
local yellImpendingDoomFades		= mod:NewShortFadesYell(397907)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(209512, nil, nil, nil, 1, 8)

local timerQuellingStrikeCD			= mod:NewCDTimer(12, 209027, nil, "Tank", nil, 3, nil, DBM_COMMON_L.TANK_ICON)--Mostly for tank to be aware of mob positioning before CD comes off
local timerFortificationCD			= mod:NewCDTimer(18.1, 209033, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSealMagicCD				= mod:NewCDTimer(18.1, 209404, nil, "SpellCaster", nil, 3)
local timerChargingStationCD		= mod:NewCDTimer(13.3, 225100, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSuppressCD				= mod:NewCDTimer(17, 209413, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSearingGlareCD			= mod:NewCDTimer(9.8, 211299, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerEyeStormCD				= mod:NewCDTimer(20.6, 212784, nil, nil, nil, 5)--Role color cause it needs a disrupt (stun, knockback) to interrupt.
local timerBewitchCD				= mod:NewCDTimer(17, 211470, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerFelDetonationCD			= mod:NewCDTimer(12.1, 211464, nil, nil, nil, 2)
local timerScreamofPainCD			= mod:NewCDTimer(14.6, 397892, nil, nil, nil, 2)
local timerWhirlingBladesCD			= mod:NewCDTimer(18.2, 209378, nil, "Melee", nil, 2)
local timerDisintegrationBeamCD		= mod:NewCDTimer(7.2, 207980, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerShockwaveCD				= mod:NewCDTimer(8.4, 207979, nil, nil, nil, 3)
local timerCrushingLeapCD			= mod:NewCDTimer(16.9, 397897, nil, nil, nil, 3)

mod:AddBoolOption("AGBoat", true)
mod:AddBoolOption("AGDisguise", true)
mod:AddBoolOption("SpyHelper", true)
mod:AddBoolOption("SendToChat2", true)
mod:AddBoolOption("SpyHelperClose2", false)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 generalized, 7 GTFO

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 209027 then
		timerQuellingStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnQuellingStrike:Show()
			specWarnQuellingStrike:Play("shockwave")
		end
	elseif spellId == 212031 and self:AntiSpam(3, 2) then
		specWarnChargedBlast:Show()
		specWarnChargedBlast:Play("shockwave")
	elseif spellId == 207979 then
		timerShockwaveCD:Start()
		if self:AntiSpam(3, 2) then
			specWarnShockwave:Show()
			specWarnShockwave:Play("shockwave")
		end
	elseif spellId == 209033 then
		timerFortificationCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFortification:Show(args.sourceName)
			specWarnFortification:Play("kickcast")
		end
	elseif spellId == 209485 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDrainMagic:Show(args.sourceName)
		specWarnDrainMagic:Play("kickcast")
	elseif spellId == 209410 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnNightfallOrb:Show(args.sourceName)
		specWarnNightfallOrb:Play("kickcast")
	elseif spellId == 209413 then
		timerSuppressCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSuppress:Show(args.sourceName)
			specWarnSuppress:Play("kickcast")
		end
	elseif spellId == 211470 then
		timerBewitchCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBewitch:Show(args.sourceName)
			specWarnBewitch:Play("kickcast")
		end
	elseif spellId == 225100 then
		timerChargingStationCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChargingStation:Show(args.sourceName)
			specWarnChargingStation:Play("kickcast")
		end
	elseif spellId == 211299 then
		timerSearingGlareCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSearingGlare:Show(args.sourceName)
			specWarnSearingGlare:Play("kickcast")
		end
	elseif spellId == 207980 then
		timerDisintegrationBeamCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDisintegrationBeam:Show(args.sourceName)
			specWarnDisintegrationBeam:Play("kickcast")
		end
	elseif spellId == 212773 then
		if self.Options.SpecWarn212773interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSubdue:Show(args.sourceName)
			specWarnSubdue:Play("kickcast")
		elseif self:AntiSpam(3, 5) then
			warnSubdue:Show()
		end
	elseif spellId == 211464 then
		timerFelDetonationCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnFelDetonation:Show(DBM_COMMON_L.BREAK_LOS)
			specWarnFelDetonation:Play("findshelter")
		end
	elseif spellId == 209404 then
		timerSealMagicCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnSealMagic:Show()
			specWarnSealMagic:Play("runout")
		end
	elseif spellId == 209495 then
		specWarnChargedSmash:Show()
		specWarnChargedSmash:Play("watchstep")
	elseif spellId == 209378 then
		timerWhirlingBladesCD:Start()
		if self:AntiSpam(3, 1) then
			specWarnWhirlingBlades:Show()
			specWarnWhirlingBlades:Play("runout")
		end
	elseif spellId == 397892 then
		specWarnScreamofPain:Show()
		specWarnScreamofPain:Play("stopcast")
		timerScreamofPainCD:Start()
	elseif spellId == 397897 then
		timerCrushingLeapCD:Start()
		if self:AntiSpam(3, 6) then
			warnCrushingLeap:Show()
		end
	elseif spellId == 212784 then
		timerEyeStormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnEyeStorm:Show()
		end
	elseif spellId == 210261 then--No throttle
		warnSoundAlarm:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 209033 and not args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
		specWarnFortificationDispel:Show(args.destName)
		specWarnFortificationDispel:Play("dispelnow")
	elseif spellId == 209512 and args:IsPlayer() and self:AntiSpam(3, 7) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 397907 then
		warnImpendingDoom:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnImpendingDoom:Show()
			specWarnImpendingDoom:Play("scatter")
			yellImpendingDoom:Yell()
			yellImpendingDoomFades:Countdown(spellId)
		end
	elseif spellId == 373552 then
		warnHypnosisBat:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 397907 and args:IsPlayer() then
		yellImpendingDoomFades:Cancel()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 104246 then--Duskwatch Guard
		timerQuellingStrikeCD:Stop(args.destGUID)
		timerFortificationCD:Stop(args.destGUID)
	elseif cid == 104247 then--Duskwatch Arcanist
		timerSealMagicCD:Stop(args.destGUID)
	elseif cid == 104270 then--Guardian Construct
		timerChargingStationCD:Stop(args.destGUID)
		timerSuppressCD:Stop(args.destGUID)
	elseif cid == 105715 then--Watchful Inquisitor
		timerSearingGlareCD:Stop(args.destGUID)
		timerEyeStormCD:Stop(args.destGUID)
	elseif cid == 104300 then--Shadow Mistress
		timerBewitchCD:Stop(args.destGUID)
	elseif cid == 104278 then--Felbound Enforcer
		timerFelDetonationCD:Stop(args.destGUID)
	elseif cid == 104275 then--Imacu'tya
		timerScreamofPainCD:Stop()
		timerWhirlingBladesCD:Stop()
	elseif cid == 104274 then--Baalgar the Watchful
		timerDisintegrationBeamCD:Stop()
	elseif cid == 104273 then--Jazshariu
		timerShockwaveCD:Start()
		timerCrushingLeapCD:Stop()
	end
end

do
	local clueTotal = 0
	local hintTranslations = {
		[1] = L.Cape or "cape",
		[2] = L.Nocape or "no cape",
		[3] = L.Pouch or "pouch",
		[4] = L.Potions or "potions",
		[5] = L.LongSleeve or "long sleeves",
		[6] = L.ShortSleeve or "short sleeves",
		[7] = L.Gloves or "gloves",
		[8] = L.NoGloves or "no gloves",
		[9] = L.Male or "male",
		[10] = L.Female or "female",
		[11] = L.LightVest or "light vest",
		[12] = L.DarkVest or "dark vest",
		[13] = L.NoPotions or "no potions",
		[14] = L.Book or "book",
	}
	local hints = {}
	local clueIds = {
		[45674] = 1,--Cape
		[45675] = 2,--No Cape
		[45660] = 3,--Pouch
		[45666] = 4,--Potions
		[45676] = 5,--Long Sleeves
		[45677] = 6,--Short Sleeves
		[45673] = 7,--Gloves
		[45672] = 8,--No Gloves
		[45657] = 9,--Male
		[45658] = 10,--Female
		[45636] = 11,--Light Vest
		[45635] = 12,--Dark Vest
		[45667] = 13,--No Potions
		[45659] = 14--Book
	}

	local function updateInfoFrame()
		local lines = {}
		for hint, _ in pairs(hints) do
			local text = hintTranslations[hint]
			lines[text] = ""
		end
		return lines
	end

	local function callUpdate(clue)
		clueTotal = clueTotal + 1
		DBM.InfoFrame:SetHeader(L.CluesFound:format(clueTotal))
		DBM.InfoFrame:Show(5, "function", updateInfoFrame)
		local text = hintTranslations[clue]
		DBM:AddMsg(L.ClueShort:format(clueTotal, text))
	end

	function mod:ResetGossipState()--/run DBM:GetModByName("CoSTrash"):ResetGossipState()
		table.wipe(hints)
		clueTotal = 0
		DBM.InfoFrame:Hide()
	end

	function mod:CHAT_MSG_MONSTER_SAY(msg, _, _, _, target)
		if msg:find(L.Found) or msg == L.Found then
			self:SendSync("Finished", target)
			if self.Options.SpyHelper and self.Options.SendToChat2 and target == UnitName("player") then
				local text = L.SpyFoundP
				if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
					SendChatMessage("DBM: "..text, "INSTANCE_CHAT")
				elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
					SendChatMessage("DBM: "..text, "PARTY")
				end
			end
		end
	end

	function mod:GOSSIP_SHOW()
		local gossipOptionID = self:GetGossipID()
		if gossipOptionID then
			DBM:Debug("GOSSIP_SHOW triggered with a gossip ID of: "..gossipOptionID)
			if self.Options.AGBoat and gossipOptionID == 45624 then -- Boat
				self:SelectGossip(gossipOptionID)
			elseif self.Options.AGDisguise and gossipOptionID == 45656 then -- Disguise
				self:SelectGossip(gossipOptionID)
			elseif clueIds[gossipOptionID] then -- SpyHelper
				if not self.Options.SpyHelper then return end
				local clue = clueIds[gossipOptionID]
				if not hints[clue] then
					if self.Options.SendToChat2 then
						local text = hintTranslations[clue]
						if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
							SendChatMessage("DBM: "..text, "INSTANCE_CHAT")
						elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
							SendChatMessage("DBM: "..text, "PARTY")
						end
					end
					hints[clue] = true
					self:SendSync("CoS", clue)
					callUpdate(clue)
					--Still required to advance dialog or demon hunters can't use spectral sight
					--We try to delay it by .1 so other mods can still parse gossip ID in theory
					C_Timer.After(0.1, function() self:SelectGossip(gossipOptionID) end)
				end
				if self.Options.SpyHelperClose2 then
					--Delay used so DBM doesn't prevent other mods or WAs from parsing data
					C_Timer.After(0.3, function() C_GossipInfo.CloseGossip() end)
				end
			end
		end
	end

	function mod:OnSync(msg, clue)
		if not self.Options.SpyHelper then return end
		if msg == "CoS" and clue then
			clue = tonumber(clue)
			if clue and not hints[clue] then
				hints[clue] = true
				callUpdate(clue)
			end
		elseif msg == "Finished" then
			self:ResetGossipState()
			if clue then
				local targetname = DBM:GetUnitFullName(clue) or clue
				DBM:AddMsg(L.SpyFound:format(targetname))
			end
		end
	end
	function mod:OnBWSync(msg, extra)
		if not self.Options.SpyHelper then return end
		if msg ~= "clue" then return end
		extra = tonumber(extra)
		if extra and extra > 0 and extra < 15 and not hints[extra] then
			DBM:Debug("Recieved BigWigs Comm:"..extra)
			hints[extra] = true
			callUpdate(extra)
		end
	end
end
