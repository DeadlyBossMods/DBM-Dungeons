local mod	= DBM:NewMod("z2687", "DBM-Delves-WarWithin", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2687, 2767)

mod:RegisterCombat("scenario", 2687, 2767)--2767 likely not used player facing
