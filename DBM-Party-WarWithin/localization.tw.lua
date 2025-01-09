if GetLocale() ~= "zhTW" then return end
local L

-------------------------
--  Darkflame Cleft (1210/2651)  --暗焰裂縫
-----------------------------
--  Ol' Waxbeard  --
-----------------------------
--L = DBM:GetModLocalization(2569)

-----------------------------
--  Blazikon  --
-----------------------------
--L = DBM:GetModLocalization(2559)

-----------------------------
--  The Candle King  --
-----------------------------
--L = DBM:GetModLocalization(2560)

-----------------------------
--  The Darkness  --
-----------------------------
--L = DBM:GetModLocalization(2561)

---------
--Trash--
---------
L = DBM:GetModLocalization("DarkflameCleftTrash")

L:SetGeneralLocalization({
	name =	"暗焰裂縫小怪"
})

-------------------------
--  Priory of the Sacred Flame (1267/2649)  --聖焰隱修院
-----------------------------
--  Captain Dailcry  --
-----------------------------
--L = DBM:GetModLocalization(2571)

-----------------------------
--  Baron Braunpyke  --
-----------------------------
--L = DBM:GetModLocalization(2570)

-----------------------------
--  Prioress Murrpray  --
-----------------------------
--L = DBM:GetModLocalization(2573)

---------
--Trash--
---------
L = DBM:GetModLocalization("SacredFlameTrash")

L:SetGeneralLocalization({
	name =	"聖焰隱修院小怪"
})

-------------------------
--  The Rookery (1268/2648)  --培育所
-----------------------------
--  Kyrioss  --
-----------------------------
--L = DBM:GetModLocalization(2566)

-----------------------------
--  Stormguard Gorren  --
-----------------------------
--L = DBM:GetModLocalization(2567)

-----------------------------
--  Voidstone Monstrosity  --
-----------------------------
--L = DBM:GetModLocalization(2568)

---------
--Trash--
---------
L = DBM:GetModLocalization("TheRookeryTrash")

L:SetGeneralLocalization({
	name =	"培育所小怪"
})

-------------------------
--  The Stonevault (1269/2652)  --石庫
-----------------------------
--  E.D.N.A.  --
-----------------------------
--L = DBM:GetModLocalization(2572)

-----------------------------
--  Skarmorak  --
-----------------------------
--L = DBM:GetModLocalization(2579)

-----------------------------
--  Forge Speakers  --
-----------------------------
--L = DBM:GetModLocalization(2590)

L:SetMiscLocalization{
	SafeVent		= "安全通風口"
}

-----------------------------
--  High Speaker Eirich  --
-----------------------------
--L = DBM:GetModLocalization(2582)

L:SetWarningLocalization({
	specWarnVoidCorruption	= "虛無裂隙 - 靠近裂隙（而非在裂隙裡）"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("TheStonevaultTrash")

L:SetGeneralLocalization({
	name =	"石庫小怪"
})

-------------------------
--  The Dawnbreaker (1270/2662)  --破曉者號
-----------------------------
--  Speaker Shadowcrown  --
-----------------------------
--L = DBM:GetModLocalization(2580)

-----------------------------
--  Anub'ikkaj  --
-----------------------------
--L = DBM:GetModLocalization(2581)

-----------------------------
--  Rasha'nan  --
-----------------------------
--L = DBM:GetModLocalization(2593)

---------
--Trash--
---------
L = DBM:GetModLocalization("TheDawnbreakerTrash")

L:SetGeneralLocalization({
	name =	"破曉者號小怪"
})

-------------------------
--  Ara-Kara, City of Echoes (1271/2660)  --『回音之城』厄拉卡拉
-----------------------------
--  Avanoxx  --
-----------------------------
--L = DBM:GetModLocalization(2583)

-----------------------------
--  Anub'zekt  --
-----------------------------
--L = DBM:GetModLocalization(2584)

-----------------------------
--  Ki'katal the Harvester  --
-----------------------------
--L = DBM:GetModLocalization(2585)

---------
--Trash--
---------
L = DBM:GetModLocalization("AraKaraTrash")

L:SetGeneralLocalization({
	name =	"『回音之城』厄拉卡拉小怪"
})

-------------------------
--  Cinderbrew Meadery (1272/2661)  --燼釀酒莊
-----------------------------
--  Brew Master Aldryr  --
-----------------------------
--L = DBM:GetModLocalization(2586)

-----------------------------
--  I'pa  --
-----------------------------
--L = DBM:GetModLocalization(2587)

-----------------------------
--  Benk Buzzbee  --
-----------------------------
--L = DBM:GetModLocalization(2588)

-----------------------------
--  Goldie Baronbottom  --
-----------------------------
--L = DBM:GetModLocalization(2589)

---------
--Trash--
---------
L = DBM:GetModLocalization("CinderbrewMeaderyTrash")

L:SetGeneralLocalization({
	name =	"燼釀酒莊小怪"
})

L:SetOptionLocalization({
	AGBuffs		= "與專業物品互動時自動選擇對話啟動增益"
})

-------------------------
--  City of Threads (1274/2669)  --蛛絲城
-----------------------------
--  Orator Krix'vizk  --
-----------------------------
--L = DBM:GetModLocalization(2594)

-----------------------------
--  Fangs of the Queen  --
-----------------------------
--L = DBM:GetModLocalization(2595)

L:SetMiscLocalization{
	RolePlay		= "轉化場過去曾是我們神聖進化的發源地。"
}

-----------------------------
--  The Coaglamation  --
-----------------------------
--L = DBM:GetModLocalization(2600)

-----------------------------
--  Izo, the Grand Splicer  --
-----------------------------
--L = DBM:GetModLocalization(2596)

---------
--Trash--
---------
L = DBM:GetModLocalization("CityofThreadsTrash")

L:SetGeneralLocalization({
	name =	"蛛絲城小怪"
})

----------
-- 水閘行動
-----------------------------
--  Big M.O.M.M.A.  --
-----------------------------
--L = DBM:GetModLocalization(2648)

-----------------------------
--  Demolition Duo  --
-----------------------------
--L = DBM:GetModLocalization(2649)

-----------------------------
--  Swampface  --
-----------------------------
--L = DBM:GetModLocalization(2650)

-----------------------------
--  Geezle Gigazap (aka Geez nuts)  --
-----------------------------
--L = DBM:GetModLocalization(2651)

---------
--Trash--
---------
L = DBM:GetModLocalization("OperationFloodgateTrash")

L:SetGeneralLocalization({
	name =	"水閘行動小怪"
})
