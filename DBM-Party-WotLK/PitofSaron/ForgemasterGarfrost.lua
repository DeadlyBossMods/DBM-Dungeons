local mod	= DBM:NewMod(608, "DBM-Party-WotLK", 15, 278)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(36494)
mod:SetEncounterID(1999)
mod:SetZone(658)
if not DBM:IsPostMidnight() then
	mod:SetUsedIcons(8)
end

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(1261546, true, 1)--Orebreaker
	mod:AddCustomAlertSoundOption(1261847, true, 2)--Cryostomp
	mod:AddCustomAlertSoundOption(1262029, true, 2)--Glacial overload
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(1261546, nil, 5, 0)
	mod:AddCustomTimerOptions(1261847, nil, 2, 0)
	mod:AddCustomTimerOptions(1261286, nil, 3, 0)--Throw Saronite
	mod:AddCustomTimerOptions(1262029, nil, 2, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1261286, true, 1261286, 1)--Throw Saronite
	mod:AddPrivateAuraSoundOption(1261799, true, 1261799, 1)--Glacial Overload (GTFO)
	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()

		self:EnableAlertOptions(1261546, 144, "moveboss", 2)
		self:EnableAlertOptions(1261847, 145, "aesoon", 2)
		self:EnableAlertOptions(1262029, 147, "breaklos", 12)

		self:EnableTimelineOptions(1261546, 144)
		self:EnableTimelineOptions(1261847, 145)
		self:EnableTimelineOptions(1261286, 146)
		self:EnableTimelineOptions(1262029, 147)

		self:EnablePrivateAuraSound(1261286, "debuffyou", 17)
		self:EnablePrivateAuraSound(1261799, "watchfeet", 8)
	end

else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 68788",
		"SPELL_AURA_APPLIED 70381 68785",
		"SPELL_AURA_APPLIED_DOSE 68786",
	--	"CHAT_MSG_RAID_BOSS_EMOTE",
		"RAID_BOSS_WHISPER",
		"CHAT_MSG_ADDON"
	)

	local warnForgeWeapon			= mod:NewSpellAnnounce(68785, 2)
	local warnDeepFreeze			= mod:NewTargetNoFilterAnnounce(70381, 2)
	local warnSaroniteRock			= mod:NewTargetAnnounce(68789, 3)

	local specWarnSaroniteRock		= mod:NewSpecialWarningYou(68789, nil, nil, nil, 1, 2)
	local yellRock					= mod:NewYell(68789)
	local specWarnPermafrost		= mod:NewSpecialWarningStack(68786, nil, 9, nil, nil, 1, 2)

	local timerSaroniteRockCD		= mod:NewCDTimer(15.5, 68789, nil, nil, nil, 3)--15.5-20
	local timerDeepFreezeCD			= mod:NewCDTimer(19, 70381, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON)
	local timerDeepFreeze			= mod:NewTargetTimer(14, 70381, nil, false, 3, 5)

	mod:AddSetIconOption("SetIconOnSaroniteRockTarget", 68789, true, 0, {8})

	function mod:SPELL_CAST_START(args)
		if args.spellId == 68788 then
			timerSaroniteRockCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 70381 then		-- Deep Freeze
			--Can be warned 2 seconds earlier using emote
			--For now I willn ot change it though
			warnDeepFreeze:Show(args.destName)
			timerDeepFreeze:Start(args.destName)
			timerDeepFreezeCD:Start()
		elseif spellId == 68785 then	-- Forge Frostborn Mace
			warnForgeWeapon:Show()
		end
	end

	function mod:SPELL_AURA_APPLIED_DOSE(args)
		if args.spellId == 68786 then
			local amount = args.amount or 1
			if amount >= 9 and args:IsPlayer() and self:AntiSpam(5) then --11 stacks is what's needed for achievement, 9 to give you time to clear/dispel
				specWarnPermafrost:Show(amount)
				specWarnPermafrost:Play("stackhigh")
			end
		end
	end

	--"<125.43 21:07:21> [CHAT_MSG_RAID_BOSS_EMOTE] %s casts |cFF00AACCDeep Freeze|r at Moonianna.#Forgemaster Garfrost###Moonianna##0#0##0#870#nil#0#false#false#false#false", -- [1]
	--function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, npc, _, _, targetname)
	--	warnDeepFreeze:Show(targetname)
	--end

	function mod:RAID_BOSS_WHISPER(msg)
		--Commented out string check for now, since it should be the only thing on fight sending RAID_BOSS_WHISPER
	--	if msg == L.SaroniteRockThrow or msg:match(L.SaroniteRockThrow) then
			specWarnSaroniteRock:Show()
			specWarnSaroniteRock:Play("watchstep")
			yellRock:Yell()
	--	end
	end

	--per usual, use transcriptor message to get messages from both bigwigs and DBM, all without adding comms to this mod at all
	function mod:CHAT_MSG_ADDON(prefix, msg, channel, targetName)
		if prefix ~= "Transcriptor" then return end
		--Could maybe drop localized text, but it risks breaking if someone happens to be in party (in a different place and is also sending RBW syncs)
		if msg == L.SaroniteRockThrow or msg:find(L.SaroniteRockThrow) then
			targetName = Ambiguate(targetName, "none")
			if self:AntiSpam(5, targetName) then--Antispam sync by target name, since this doesn't use dbms built in onsync handler.
				local uId = DBM:GetRaidUnitId(targetName)
				if uId and not UnitIsUnit(uId, "player") then
					warnSaroniteRock:Show(targetName)
				end
				if self.Options.SetIconOnSaroniteRockTarget then
					self:SetIcon(targetName, 8, 5)
				end
			end
		end
	end
end
