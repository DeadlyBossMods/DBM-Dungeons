if DBM:IsPostMidnight() then return end
local mod	= DBM:NewMod("SkyreachTrash", "DBM-Party-WoD", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_AURA_APPLIED 160303 160288"
)

local specWarnSolarDetonation		= mod:NewSpecialWarningMoveAway(160288, nil, nil, nil, 1, 2)

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled or self:IsDifficulty("normal5") or self:IsTrivial() then return end
	local spellId = args.spellId
	if spellId == 160303 or spellId == 160288 then
		if args:IsPlayer() then
			specWarnSolarDetonation:Show()
			specWarnSolarDetonation:Play("runout")
		end
	end
end
