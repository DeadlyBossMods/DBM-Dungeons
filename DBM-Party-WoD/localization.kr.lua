if GetLocale() ~= "koKR" then return end
local L

-----------------------
-- <<<Auchindoun>>> --
-----------------------
-----------------------
-- Protector of Auchindoun --
-----------------------
L= DBM:GetModLocalization(1185)

-----------------------
-- Soulbinder Nyami --
-----------------------
L= DBM:GetModLocalization(1186)

-----------------------
-- Azzakel, Vanguard of the Legion --
-----------------------
L= DBM:GetModLocalization(1216)

-----------------------
-- Teron'gor --
-----------------------
L= DBM:GetModLocalization(1225)

-------------
--  Auch Trash  --
-------------
L = DBM:GetModLocalization("AuchTrash")

L:SetGeneralLocalization({
	name =	"아킨둔 일반몹"
})

-----------------------
-- <<<Bloodmaul Slag Mines>>> --
-----------------------
-----------------------
-- Magmolatus --
-----------------------
L= DBM:GetModLocalization(893)

-----------------------
-- Slave Watcher Crushto --
-----------------------
L= DBM:GetModLocalization(888)

-----------------------
-- Roltall --
-----------------------
L= DBM:GetModLocalization(887)

-----------------------
-- Gug'rokk --
-----------------------
L= DBM:GetModLocalization(889)

-------------
--  BSM Trash  --
-------------
L = DBM:GetModLocalization("BSMTrash")

L:SetGeneralLocalization({
	name =	"피망치 잿가루 광산 일반몹"
})

-----------------------
-- <<<Grimrail Depot>>> --
-----------------------
-----------------------
-- Railmaster Rocketspark and Borka the Brute --
-----------------------
L= DBM:GetModLocalization(1138)

-----------------------
-- Blackrock Assault Commander --
-----------------------
L= DBM:GetModLocalization(1163)

L:SetWarningLocalization({
	warnGrenadeDown			= "%s 떨굼",
	warnMortarDown			= "%s 떨굼"
})

-----------------------
-- Thunderlord General --
-----------------------
L= DBM:GetModLocalization(1133)

L:SetMiscLocalization({
	Rakun	= "라쿤"
})

-------------
--  GRD Trash  --
-------------
L = DBM:GetModLocalization("GRDTrash")

L:SetGeneralLocalization({
	name =	"파멸철로 정비소 일반몹"
})

-----------------------
-- <<<Iron Docks>>> --
-----------------------
---------------------
-- Fleshrender Nok'gar --
---------------------
L= DBM:GetModLocalization(1235)

-------------
-- Grimrail Enforcers --
-------------
L= DBM:GetModLocalization(1236)

-----------------------
-- Oshir --
-----------------------
L= DBM:GetModLocalization(1237)

-----------------------------
-- Skulloc, Son of Gruul --
-----------------------------
L= DBM:GetModLocalization(1238)

-----------------------
-- <<<EverBloom>>> --
-----------------------
-----------------------
-- Witherbark --
-----------------------
L= DBM:GetModLocalization(1214)

-----------------------
-- Ancient Protectors --
-----------------------
L= DBM:GetModLocalization(1207)

-----------------------
-- Archmage Sol --
-----------------------
L= DBM:GetModLocalization(1208)

-----------------------
-- Xeri'tac --
-----------------------
L= DBM:GetModLocalization(1209)

L:SetMiscLocalization({
	Pull	= "당신의 머리 위로 산성 새끼 거미를 쏟아붓습니다!"
})

-----------------------
-- Yalnu --
-----------------------
L= DBM:GetModLocalization(1210)

L:SetMiscLocalization({
	YalnuRP	= "차원문이! 괴물이 탈출하기 전에 막아야 합니다!"
})

-----------------------
-- Trash --
-----------------------
L = DBM:GetModLocalization("EverBloomTrash")

L:SetGeneralLocalization({
	name =	"상록숲 일반몹"
})

-----------------------
-- <<<Shadowmoon Buriel Grounds>>> --
-----------------------
-----------------------
-- Sadana Bloodfury --
-----------------------
L= DBM:GetModLocalization(1139)

-----------------------
-- Nhallish, Feaster of Souls --
-----------------------
L= DBM:GetModLocalization(1168)

-----------------------
-- Bonemaw --
-----------------------
L= DBM:GetModLocalization(1140)

-----------------------
-- Ner'zhul --
-----------------------
L= DBM:GetModLocalization(1160)

-------------
--  SMBG Trash  --
-------------
L = DBM:GetModLocalization("SMBGTrash")

L:SetGeneralLocalization({
	name =	"어둠달 지하묘지 일반몹"
})

-----------------------
-- <<<Skyreach>>> --
-----------------------
-----------------------
-- Ranjit, Master of the Four Winds --
-----------------------
L= DBM:GetModLocalization(965)

-----------------------
-- Araknath --
-----------------------
L= DBM:GetModLocalization(966)

-----------------------
-- Rukhran --
-----------------------
L= DBM:GetModLocalization(967)

-----------------------
-- High Sage Viryx --
-----------------------
L= DBM:GetModLocalization(968)

L:SetWarningLocalization({
	warnAdd			= DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.spell:format("하늘탑 보호 피조물"),
	specWarnAdd		= DBM_CORE_L.AUTO_SPEC_WARN_TEXTS.switch:format("하늘탑 보호 피조물")
})

L:SetOptionLocalization({
	warnAdd			= "하늘탑 보호 피조물 알림 보기",
	specWarnAdd		= "하늘탑 보호 피조물로 대상 변경 특수 알림 보기"
})

-------------
--  Skyreach Trash  --
-------------
L = DBM:GetModLocalization("SkyreachTrash")

L:SetGeneralLocalization({
	name =	"하늘탑 일반몹"
})

-----------------------
-- <<<Upper Blackrock Spire>>> --
-----------------------
-----------------------
-- Orebender Gor'ashan --
-----------------------
L= DBM:GetModLocalization(1226)

-----------------------
-- Kyrak --
-----------------------
L= DBM:GetModLocalization(1227)

-----------------------
-- Commander Tharbek --
-----------------------
L= DBM:GetModLocalization(1228)

-----------------------
-- Ragewind the Untamed --
-----------------------
L= DBM:GetModLocalization(1229)

-----------------------
-- Warlord Zaela --
-----------------------
L= DBM:GetModLocalization(1234)

L:SetTimerLocalization({
	timerZaelaReturns	= "젤라 착지"
})

L:SetOptionLocalization({
	timerZaelaReturns	= "젤라 착지 타이머 바 보기"
})

-------------
--  UBRS Trash  --
-------------
L = DBM:GetModLocalization("UBRSTrash")

L:SetGeneralLocalization({
	name =	"검은바위 첨탑 상층 일반몹"
})
