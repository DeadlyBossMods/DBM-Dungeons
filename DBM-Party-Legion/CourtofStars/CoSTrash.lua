local mod	= DBM:NewMod("CoSTrash", "DBM-Party-Legion", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetOOCBWComms()
mod:SetMinSyncRevision(20221228000000)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 209027 212031 209485 209410 209413 211470 211464 209404 209495 225100 211299 209378 397892 397897 207979 212784",
	"SPELL_AURA_APPLIED 209033 209512 397907 373552",
	"SPELL_AURA_REMOVED 397907",
	"CHAT_MSG_MONSTER_SAY",
	"GOSSIP_SHOW"
)

--TODO, at least 1-2 more GTFOs I forgot names of
--TODO, verify if Disintegration beam is interruptable at 207980 or 207981
--TODO, target scan https://www.wowhead.com/beta/spell=397897/crushing-leap ?
local warnImpendingDoom				= mod:NewTargetAnnounce(397907, 2)
local warnCrushingLeap				= mod:NewCastAnnounce(397897, 3)
local warnEyeStorm					= mod:NewCastAnnounce(212784, 3)
local warnHypnosisBat				= mod:NewTargetNoFilterAnnounce(373552, 3)

local specWarnFortification			= mod:NewSpecialWarningDispel(209033, "MagicDispeller", nil, nil, 1, 2)
local specWarnQuellingStrike		= mod:NewSpecialWarningDodge(209027, "Tank", nil, nil, 1, 2)
local specWarnChargedBlast			= mod:NewSpecialWarningDodge(212031, "Tank", nil, nil, 1, 2)
local specWarnChargedSmash			= mod:NewSpecialWarningDodge(209495, "Tank", nil, nil, 1, 2)
local specWarnShockwave				= mod:NewSpecialWarningDodge(207979, nil, nil, nil, 2, 2)
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

mod:AddBoolOption("SpyHelper", true)
mod:AddBoolOption("SendToChat2", true)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 generalized, 7 GTFO

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 209027 and self:AntiSpam(3, 2) then
		specWarnQuellingStrike:Show()
		specWarnQuellingStrike:Play("shockwave")
	elseif spellId == 212031 and self:AntiSpam(3, 2) then
		specWarnChargedBlast:Show()
		specWarnChargedBlast:Play("shockwave")
	elseif spellId == 207979 and self:AntiSpam(3, 2) then
		specWarnShockwave:Show()
		specWarnShockwave:Play("shockwave")
	elseif spellId == 209485 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDrainMagic:Show(args.sourceName)
		specWarnDrainMagic:Play("kickcast")
	elseif spellId == 209410 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnNightfallOrb:Show(args.sourceName)
		specWarnNightfallOrb:Play("kickcast")
	elseif spellId == 209413 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSuppress:Show(args.sourceName)
		specWarnSuppress:Play("kickcast")
	elseif spellId == 211470 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBewitch:Show(args.sourceName)
		specWarnBewitch:Play("kickcast")
	elseif spellId == 225100 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnChargingStation:Show(args.sourceName)
		specWarnChargingStation:Play("kickcast")
	elseif spellId == 211299 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSearingGlare:Show(args.sourceName)
		specWarnSearingGlare:Play("kickcast")
	elseif spellId == 207980 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDisintegrationBeam:Show(args.sourceName)
		specWarnDisintegrationBeam:Play("kickcast")
	elseif spellId == 211464 and self:AntiSpam(3, 4) then
		specWarnFelDetonation:Show(DBM_COMMON_L.BREAK_LOS)
		specWarnFelDetonation:Play("findshelter")
	elseif spellId == 209404 and self:AntiSpam(3, 5) then
		specWarnSealMagic:Show()
		specWarnSealMagic:Play("runout")
	elseif spellId == 209495 then
		--Don't want to move too early, just be moving already as cast is finishing
		specWarnChargedSmash:Schedule(1.2)
		specWarnChargedSmash:ScheduleVoice(1.2, "chargemove")
	elseif spellId == 209378 and self:AntiSpam(3, 1) then
		specWarnWhirlingBlades:Show()
		specWarnWhirlingBlades:Play("runout")
	elseif spellId == 397892 then
		specWarnScreamofPain:Show()
		specWarnScreamofPain:Play("stopcast")
	elseif spellId == 397897 and self:AntiSpam(3, 6) then
		warnCrushingLeap:Show()
	elseif spellId == 212784 and self:AntiSpam(3, 6) then
		warnEyeStorm:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 209033 and not args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
		specWarnFortification:Show(args.destName)
		specWarnFortification:Play("dispelnow")
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

do
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
	local clues = {
		[L.Cape1] = 1,
		[L.Cape2] = 1,

		[L.NoCape1] = 2,
		[L.NoCape2] = 2,

		[L.Pouch1] = 3,
		[L.Pouch2] = 3,
		[L.Pouch3] = 3,
		[L.Pouch4] = 3,

		[L.Potions1] = 4,
		[L.Potions2] = 4,
		[L.Potions3] = 4,
		[L.Potions4] = 4,

		[L.LongSleeve1] = 5,
		[L.LongSleeve2] = 5,
		[L.LongSleeve3] = 5,
		[L.LongSleeve4] = 5,

		[L.ShortSleeve1] = 6,
		[L.ShortSleeve2] = 6,
		[L.ShortSleeve3] = 6,
		[L.ShortSleeve4] = 6,

		[L.Gloves1] = 7,
		[L.Gloves2] = 7,
		[L.Gloves3] = 7,
		[L.Gloves4] = 7,

		[L.NoGloves1] = 8,
		[L.NoGloves2] = 8,
		[L.NoGloves3] = 8,
		[L.NoGloves4] = 8,

		[L.Male1] = 9,
		[L.Male2] = 9,
		[L.Male3] = 9,
		[L.Male4] = 9,

		[L.Female1] = 10,
		[L.Female2] = 10,
		[L.Female3] = 10,
		[L.Female4] = 10,

		[L.LightVest1] = 11,
		[L.LightVest2] = 11,
		[L.LightVest3] = 11,

		[L.DarkVest1] = 12,
		[L.DarkVest2] = 12,
		[L.DarkVest3] = 12,
		[L.DarkVest4] = 12,

		[L.NoPotions1] = 13,
		[L.NoPotions2] = 13,

		[L.Book1] = 14,
		[L.Book2] = 14
	}

	local function updateInfoFrame()
		local lines = {}
		for hint, _ in pairs(hints) do
			local text = hintTranslations[hint]
			lines[text] = ""
		end
		return lines
	end

	function mod:ResetGossipState()--/run DBM:GetModByName("CoSTrash"):ResetGossipState()
		table.wipe(hints)
		DBM.InfoFrame:Hide()
	end

	function mod:CHAT_MSG_MONSTER_SAY(msg, _, _, _, target)
		if msg:find(L.Found) then
			self:SendSync("Finished", target)
		end
	end

	function mod:GOSSIP_SHOW()
		if not self.Options.SpyHelper then return end
		local guid = UnitGUID("target")
		if not guid then return end
		local cid = self:GetCIDFromGUID(guid)
		if cid == 107486 then--Chatty Rumormonger
			local table = C_GossipInfo.GetOptions()
			if table[1] and table[1].gossipOptionID then
				C_GossipInfo.SelectOption(table[1].gossipOptionID)
			else
				local clue = clues[C_GossipInfo.GetText()]
				if clue and not hints[clue] then
--					C_GossipInfo.CloseGossip()
					if self.Options.SendToChat2 then
						local text = hintTranslations[clue]
						if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
							SendChatMessage(text, "INSTANCE_CHAT")
						elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
							SendChatMessage(text, "PARTY")
						end
					end
					hints[clue] = true
					self:SendSync("CoS", clue)
					DBM.InfoFrame:Show(5, "function", updateInfoFrame)
				end
			end
		end
	end

	function mod:OnSync(msg, clue)
		if not self.Options.SpyHelper then return end
		if msg == "CoS" and clue then
			clue = tonumber(clue)
			if clue then
				hints[clue] = true
				DBM.InfoFrame:Show(5, "function", updateInfoFrame)
			end
		elseif msg == "Finished" then
			self:ResetGossipState()
			if clue then
				local targetname = DBM:GetUnitFullName(clue)
				DBM:AddMsg(L.SpyFound:format(targetname))
			end
		end
	end
	function mod:OnBWSync(msg, extra)
		if msg ~= "clue" then return end
		extra = tonumber(extra)
		if extra and extra > 0 and extra < 15 then
			DBM:Debug("Recieved BigWigs Comm:"..extra)
			hints[extra] = true
			DBM.InfoFrame:Show(5, "function", updateInfoFrame)
		end
	end
end
