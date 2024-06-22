if GetLocale() ~= "koKR" then return end
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
	name =	"담쟁이가죽 골짜기 일반몹"
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
	name =	"울다만: 티르의 유산 일반몹"
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
	name =	"노쿠드 공격대 일반몹"
})

L:SetMiscLocalization({
	Soul = "영혼"
})

-----------------------
-- <<<Neltharus >>> --
-----------------------
-----------------------
-- Chargath, Bane of Scales --
-----------------------
--L= DBM:GetModLocalization(2490)

-----------------------
-- Forgemaster Gorek --
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
	name =	"넬타루스 일반몹"
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
	VexRP		= "아! 수업 자료가 여기 있었네. 어흠! 아주 먼 옛날, 푸른용군단의 구성원들이 실수로 비전 정령을 과부하시킨 적 있었답니다. 그 결과 벡사무스라는 강력한 피조물이 탄생해 난동을 부리기 시작했죠!"
})


-----------------------
-- Overgrown Ancient --
-----------------------
L= DBM:GetModLocalization(2512)

L:SetMiscLocalization({
	TreeRP	= "완벽해요. 이제 곧... 잠깐, 이치스트라즈 님! 생명 마법이 너무 과하잖아요! 뭐 하시는 거예요?"
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
	name =	"알게타르 대학 일반몹"
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
	name =	"하늘빛 보관소 일반몹"
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
	North	= "북쪽",
	West	= "서쪽",
	South	= "남쪽",
	East	= "동쪽"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("RubyLifePoolsTrash")

L:SetGeneralLocalization({
	name =	"루비 생명의 웅덩이 일반몹"
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
	name =	"주입의 전당 일반몹"
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
	PrePullRP		= "아무리 시간의 위상이라도 시간의 길을 어지럽히게 둘 순 없다!"
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
	PrePullRP		= "티탄의 꼭두각시가 왔군."
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
	name =	"잃어버린 시간의 전장"--Manual local because auto inserts Alliance or horde to name and mod combines them since singular encounter ID
})

L:SetMiscLocalization({
	customWAMessage = "|cff4565ff얼라|r가 풀링하면 |cff69ccf0%s|r|1을;를; |cffff0000호드|r가 풀링하면 |cff69ccf0%s|r|1을;를; 사용"
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
	name =	"무한의 여명 일반몹"
})

L:SetOptionLocalization({
	AutoRift	= "구슬 피하기 통과 후 균열 활성화 대화 자동 선택"
})
