if GetLocale() ~= "koKR" then return end
local L

-------------------------
--  Darkflame Cleft (1210/2651)  --
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
	name =	"어둠불꽃 동굴 일반몹"
})

-------------------------
--  Priory of the Sacred Flame (1267/2649)  --
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
	name =	"불꽃의 수도원 일반몹"
})

-------------------------
--  The Rookery (1268/2648)  --
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
	name =	"부화장 일반몹"
})

-------------------------
--  The Stonevault (1269/2652)  --
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
L = DBM:GetModLocalization(2590)

L:SetMiscLocalization{
	SafeVent		= "안전한 배기구"
}

-----------------------------
--  High Speaker Eirich  --
-----------------------------
L = DBM:GetModLocalization(2582)

L:SetWarningLocalization({
	specWarnVoidCorruption	= "공허의 타락 - 근처 균열로 이동 (닿으면 안됨)"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("TheStonevaultTrash")

L:SetGeneralLocalization({
	name =	"바위금고 일반몹"
})

-------------------------
--  The Dawnbreaker (1270/2662)  --
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
	name =	"여명파괴자 일반몹"
})

-------------------------
--  Ara-Kara, City of Echoes (1271/2660)  --
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
	name =	"아라카라 일반몹"
})

-------------------------
--  Cinderbrew Meadery (1272/2661)  --
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
	name =	"잿불맥주 양조장 일반몹"
})

L:SetOptionLocalization({
	AGBuffs		= "전문기술 버프 클릭시 대화 자동 선택"
})

-------------------------
--  City of Threads (1274/2669)  --
-----------------------------
--  Orator Krix'vizk  --
-----------------------------
--L = DBM:GetModLocalization(2594)

-----------------------------
--  Fangs of the Queen  --
-----------------------------
L = DBM:GetModLocalization(2595)

L:SetMiscLocalization{
	RolePlay		= "변신소는 원래 신성한 진화의 본산이었다."
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
	name =	"실타래의 도시 일반몹"
})
