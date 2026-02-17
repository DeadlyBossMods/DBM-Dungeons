local mod	= DBM:NewMod(966, "DBM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(76141)
mod:SetEncounterID(1699)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(154115, true, 1)--Fiery Smash
	mod:AddCustomAlertSoundOption(154162, true, 1)--Energize
	mod:AddCustomAlertSoundOption(154135, true, 2)--Supernova
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(154115, true, 5, 0)
	mod:AddCustomTimerOptions(154162, true, 5, 0)
	mod:AddCustomTimerOptions(154135, true, 2, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(154132, true, 154115, 1)--Failing at smash

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()
		self:EnableAlertOptions(154115, 302, "frontal", 15)
		if not self:IsTank() then
			--Tank frontals are cast during soak
			--so do NOT tell tank to help with the soaking
			self:EnableAlertOptions(154162, 303, "soakbeam", 17)
		end
		self:EnableAlertOptions(154135, 304, "aesoon", 2)

		self:EnableTimelineOptions(154115, 302)
		self:EnableTimelineOptions(154162, 303)
		self:EnableTimelineOptions(154135, 304)

		self:EnablePrivateAuraSound(154132, "screwup", 18)
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 154110 154113 154135",
		"SPELL_AURA_APPLIED 154159"
	)


	--Add smash? it's a 1 sec cast, can it be dodged?
	local warnEnergize		= mod:NewSpellAnnounce(154159, 3)

	local specWarnBurst		= mod:NewSpecialWarningCount(154135, nil, nil, nil, 2, 2)
	local specWarnSmash		= mod:NewSpecialWarningDodge(154110, "Tank", nil, 2, 1, 2)

	local timerEnergozeCD	= mod:NewNextTimer(20, 154159, nil, nil, nil, 5)
	local timerBurstCD		= mod:NewCDCountTimer(23, 154135, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

	mod.vb.burstCount = 0

	function mod:OnCombatStart(delay)
		self.vb.burstCount = 0
		timerBurstCD:Start(20-delay, 1)
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 154135 then
			self.vb.burstCount = self.vb.burstCount + 1
			specWarnBurst:Show(self.vb.burstCount)
			specWarnBurst:Play("aesoon")
			timerBurstCD:Start(nil, self.vb.burstCount+1)
		elseif args:IsSpellID(154110, 154113) then
			specWarnSmash:Show()
			specWarnSmash:Play("watchstep")
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 154159 and self:AntiSpam(2, 1) then
			warnEnergize:Show()
			timerEnergozeCD:Start()
		end
	end
end
