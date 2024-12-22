if GetLocale() ~= "ruRU" then return end
local L

-----------------------
-- <<<Atal'Dazar >>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("AtalDazarTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Атал'Дазар"
})

-----------------------
-- <<<Freehold >>> --
-----------------------
-----------------------
-- Council o' Captains --
-----------------------
L= DBM:GetModLocalization(2093)

L:SetWarningLocalization({
	warnGoodBrew		= "Применение %s: 3 сек",
	specWarnBrewOnBoss	= "Хорошее пойло под %s"
})

L:SetOptionLocalization({
	warnGoodBrew		= "Предупреждение при применении хорошего пойла",
	specWarnBrewOnBoss	= "Спецпредупреждение, когда хорошее пойло под боссом"
})

L:SetMiscLocalization({
	critBrew		= "Пойло на крит",
	hasteBrew		= "Пойло на скорость"
})

-----------------------
-- Ring of Booty --
-----------------------
L= DBM:GetModLocalization(2094)

L:SetMiscLocalization({
	openingRP = "Делайте ваши ставки! К нам пожаловали новые жерт... претенденты! А теперь слово Гаргтоку и Водину!"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("FreeholdTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Вольная Гавань"
})

-----------------------
-- <<<Kings' Rest >>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("KingsRestTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Гробница Королей"
})

-----------------------
-- Lord Stormsong --
-----------------------
L= DBM:GetModLocalization(2155)

L:SetMiscLocalization({
	openingRP	= "Похоже, у тебя гости, лорд Штормсонг."
})

---------
--Trash--
---------
L = DBM:GetModLocalization("SotSTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Святилище Штормов"
})

-----------------------
-- <<<Siege of Boralus >>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("BoralusTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Осада Боралуса"
})

-----------------------
-- <<<Temple of Sethraliss>>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("SethralissTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Храм Сетралисс"
})

-----------------------
-- <<<MOTHERLOAD>>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("MotherloadTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы ЗОЛОТАЯ ЖИЛА!!!"
})

-----------------------
-- <<<The Underrot>>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("UnderrotTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Подгнилье"
})

-----------------------
-- <<<Tol Dagor >>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("TolDagorTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Тол Дагор"
})

-----------------------
-- <<<Waycrest Manor>>> --
-----------------------
---------
--Trash--
---------
L = DBM:GetModLocalization("WaycrestTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Усадьба Уэйкрестов"
})

-----------------------
-- <<<Operation: Mechagon>>> --
-----------------------
-----------------------
-- Tussle Tonks --
-----------------------
L= DBM:GetModLocalization(2336)

L:SetMiscLocalization({
	openingRP		= "Что это? Ошибка в расчетах? Наши гости еще живы!"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("MechagonTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Мехагон"
})
