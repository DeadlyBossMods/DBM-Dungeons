if GetLocale() ~= "ruRU" then return end
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
	name =	"Трэш мобы Расселина Темного Пламени"
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
	name =	"Трэш мобы Приорат Священного Пламени"
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
	name =	"Трэш мобы Гнездовье"
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
	SafeVent		= "Безопасные Вытяжные отверстия"
}

-----------------------------
--  High Speaker Eirich  --
-----------------------------
L = DBM:GetModLocalization(2582)

L:SetWarningLocalization({
	specWarnVoidCorruption	= "Порча Бездны — двигайтесь РЯДОМ с Разломом (не в него)"
})

L:SetOptionLocalization({
	specWarnVoidCorruption	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.moveto:format(427329)
})

---------
--Trash--
---------
L = DBM:GetModLocalization("TheStonevaultTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Каменный Свод"
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
	name =	"Трэш мобы Сияющий Рассвет"
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
	name =	"Трэш мобы Ара-Кара, Город Отголосков"
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
	name =	"Трэш мобы Искроварня"
})

L:SetOptionLocalization({
	AGBuffs		= "Автоматический выбор диалога для активации положительных эффектов при взаимодействии с объектами профессии"
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
	RolePlay		= "Раньше Зал трансформаций был колыбелью нашей священной эволюции."
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
	name =	"Трэш мобы Город Нитей"
})

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
	name =	"Трэш мобы Операция Затвор"
})
