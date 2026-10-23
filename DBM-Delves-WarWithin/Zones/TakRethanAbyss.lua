local mod	= DBM:NewMod("z2689", "DBM-Delves-WarWithin", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2689, 2768)

mod:RegisterCombat("scenario", 2689, 2768)
