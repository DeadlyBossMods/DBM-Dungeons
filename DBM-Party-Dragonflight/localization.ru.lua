if GetLocale() ~= "ruRU" then return end
local L

-----------------------
-- <<<Brackenhide Hollow >>> --
-----------------------
-----------------------
-- Hackclaw's War-Band --
-----------------------
--L= DBM:GetModLocalization(2471)

-----------------------
-- Treemouth  --
-----------------------
--L= DBM:GetModLocalization(2473)

-----------------------
-- Gutshot --
-----------------------
--L= DBM:GetModLocalization(2472)

-----------------------
-- Decatriarch Wratheye --
-----------------------
--L= DBM:GetModLocalization(2474)

---------
--Trash--
---------
L = DBM:GetModLocalization("BrackenhideHollowTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Пещера Бурошкуров"
})

-----------------------
-- <<<Uldaman: Legacy of Tyr >>> --
-----------------------
-----------------------
-- The Lost Dwarves --
-----------------------
--L= DBM:GetModLocalization(2475)

-----------------------
-- Bromach --
-----------------------
--L= DBM:GetModLocalization(2487)

-----------------------
-- Sentinel Talondras --
-----------------------
--L= DBM:GetModLocalization(2484)

-----------------------
-- Emberon --
-----------------------
--L= DBM:GetModLocalization(2476)

-----------------------
-- Chrono-Lord Deios --
-----------------------
--L= DBM:GetModLocalization(2479)

---------
--Trash--
---------
L = DBM:GetModLocalization("UldamanLegacyofTyrTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Ульдаман: наследие Тира"
})

-----------------------
-- <<<The Nokhud Offensive >>> --
-----------------------
-----------------------
-- Granyth --
-----------------------
--L= DBM:GetModLocalization(2498)

-----------------------
-- The Raging Tempest --
-----------------------
--L= DBM:GetModLocalization(2497)

-----------------------
-- Teera and Maruuk --
-----------------------
--L= DBM:GetModLocalization(2478)

-----------------------
-- Balakar Khan --
-----------------------
--L= DBM:GetModLocalization(2477)


---------
--Trash--
---------
L = DBM:GetModLocalization("TheNokhudOffensiveTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Наступление клана Нокхуд"
})

L:SetMiscLocalization({
	Soul = "Душа"
})

-----------------------
-- <<<Neltharus >>> --
-----------------------
-----------------------
-- Chargath, Bane of Scales --
-----------------------
--L= DBM:GetModLocalization(2490)

-----------------------
-- The Scorching Forge --
-----------------------
--L= DBM:GetModLocalization(2489)

-----------------------
-- Magmatusk --
-----------------------
--L= DBM:GetModLocalization(2494)

-----------------------
-- Warlord Sargha --
-----------------------
--L= DBM:GetModLocalization(2501)

---------
--Trash--
---------
L = DBM:GetModLocalization("NeltharusTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Нелтарий"
})

-----------------------
-- <<<Algeth'ar Academy >>> --
-----------------------
-----------------------
-- Crawth --
-----------------------
--L= DBM:GetModLocalization(2495)

-----------------------
-- Vexamus --
-----------------------
L= DBM:GetModLocalization(2509)

L:SetMiscLocalization({
	VexRP		= "Кхе-кхе... Итак... давным-давно синие драконы случайно подвергли чародейский элементаль перегрузке, создав могучего Вексама, который сразу же принялся сеять разрушения!"
})

-----------------------
-- Overgrown Ancient --
-----------------------
L= DBM:GetModLocalization(2512)

L:SetMiscLocalization({
	TreeRP	= "Превосходно, мы как раз собирались... стой, Ихистраз! Магии жизни слишком много! Что ты делаешь?"
})

-----------------------
-- Echo of Doragosa --
-----------------------
--L= DBM:GetModLocalization(2514)

---------
--Trash--
---------
L = DBM:GetModLocalization("AlgetharAcademyTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Академия Алгет'ар"
})

-----------------------
-- <<<The Azure Vault>>> --
-----------------------
-----------------------
-- Leymor --
-----------------------
--L= DBM:GetModLocalization(2492)

-----------------------
-- Talash Greywing --
-----------------------
--L= DBM:GetModLocalization(2483)

-----------------------
-- Umbrelskul --
-----------------------
--L= DBM:GetModLocalization(2508)

-----------------------
-- Azureblade --
-----------------------
--L= DBM:GetModLocalization(2505)

---------
--Trash--
---------
L = DBM:GetModLocalization("TheAzurevaultTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Лазурное хранилище"
})

-----------------------
-- <<<Ruby Life Pools>>> --
-----------------------
-----------------------
-- Melidrussa Chillworn --
-----------------------
--L= DBM:GetModLocalization(2488)

-----------------------
-- Kokia Blazehoof --
-----------------------
--L= DBM:GetModLocalization(2485)

-----------------------
-- Kyrakka and Erkhart Stormvein --
-----------------------
L= DBM:GetModLocalization(2503)

L:SetMiscLocalization({
	North	= "На север",
	West	= "На запад",
	South	= "На юг",
	East	= "На восток"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("RubyLifePoolsTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Рубиновые Омуты Жизни"
})

-----------------------
-- <<<Halls of Infusion>>> --
-----------------------
-----------------------
-- Watcher Irideus --
-----------------------
--L= DBM:GetModLocalization(2504)

-----------------------
-- Gulping Goliath --
-----------------------
--L= DBM:GetModLocalization(2507)

-----------------------
-- Khajin the Unyielding --
-----------------------
--L= DBM:GetModLocalization(2510)

-----------------------
-- Primal Tsunami --
-----------------------
--L= DBM:GetModLocalization(2511)

---------
--Trash--
---------
L = DBM:GetModLocalization("HallsofInfusionTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Чертоги Насыщения"
})

-----------------------
-- Chronikar --
-----------------------
--L= DBM:GetModLocalization(2521)

-----------------------
-- Manifested Timeways --
-----------------------
L= DBM:GetModLocalization(2528)

L:SetMiscLocalization({
	PrePullRP		= "Даже Аспект Времени не должен менять временные пути!"
})

-----------------------
-- Blight of Galakrond --
-----------------------
--L= DBM:GetModLocalization(2535)

-----------------------
-- Iridikron the Stonescaled --
-----------------------
L= DBM:GetModLocalization(2537)

L:SetMiscLocalization({
	PrePullRP		= "Слуги титанов пришли сразиться со мной."
})

-----------------------
-- Tyr, the infinite Keeper --
-----------------------
--L= DBM:GetModLocalization(2526)

-----------------------
-- Morchie --
-----------------------
--L= DBM:GetModLocalization(2536)

-----------------------
-- Time-Lost Battlefield  --
-----------------------
L= DBM:GetModLocalization(2533)--Alliance ID used for both factions (2534 is horde id)

L:SetGeneralLocalization({
	name =	"Time-Lost Battlefield"--Manual local because auto inserts Alliance or horde to name and mod combines them since singular encounter ID
})

L:SetMiscLocalization({
	customWAMessage = "Используйте |cff69ccf0%s|r для |cff4565ffАльянса|r и |cff69ccf0%s|r для |cffff0000Орды|r"
})

-----------------------
-- Chrono-Lord Deios --
-----------------------
--L= DBM:GetModLocalization(2538)

---------
--Trash--
---------
L = DBM:GetModLocalization("DawnoftheInfiniteTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Рассвет Бесконечности"
})

L:SetOptionLocalization({
	AutoRift	= "Автоматический выбор диалога для активации разлома после испытания"
})
