if GetLocale() ~= "koKR" then return end
local L

-----------------------
-- <<<Black Rook Hold>>> --
-----------------------
-----------------------
-- The Amalgam of Souls --
-----------------------
L= DBM:GetModLocalization(1518)

-----------------------
-- Illysanna Ravencrest --
-----------------------
L= DBM:GetModLocalization(1653)

-----------------------
-- Smashspite the Hateful --
-----------------------
L= DBM:GetModLocalization(1664)

-----------------------
-- Lord Kur'talos Ravencrest --
-----------------------
L= DBM:GetModLocalization(1672)

-----------------------
--Black Rook Hold Trash
-----------------------
L = DBM:GetModLocalization("BRHTrash")

L:SetGeneralLocalization({
	name =	"검은 떼까마귀 요새 일반몹"
})

-----------------------
-- <<<Darkheart Thicket>>> --
-----------------------
-----------------------
-- Arch-Druid Glaidalis --
-----------------------
L= DBM:GetModLocalization(1654)

-----------------------
-- Oakheart --
-----------------------
L= DBM:GetModLocalization(1655)

-----------------------
-- Dresaron --
-----------------------
L= DBM:GetModLocalization(1656)

-----------------------
-- Shade of Xavius --
-----------------------
L= DBM:GetModLocalization(1657)

-----------------------
--Darkheart Thicket Trash
-----------------------
L = DBM:GetModLocalization("DHTTrash")

L:SetGeneralLocalization({
	name =	"어둠심장 숲 일반몹"
})

L:SetMiscLocalization({
	GlaidalisRP	= "타락한 자들아... 너희 피에서 악몽의 냄새가 난다. 이 숲에서 꺼지지 않으면, 자연의 분노를 맛보게 되리라!"
})

-----------------------
-- <<<Eye of Azshara>>> --
-----------------------
-----------------------
-- Warlord Parjesh --
-----------------------
L= DBM:GetModLocalization(1480)

-----------------------
-- Lady Hatecoil --
-----------------------
L= DBM:GetModLocalization(1490)

L:SetWarningLocalization({
	specWarnStaticNova			= "정전기 회오리 - 땅으로 이동",
	specWarnFocusedLightning	= "집중된 번개 - 물로 이동"
})

-----------------------
-- King Deepbeard --
-----------------------
L= DBM:GetModLocalization(1491)

-----------------------
-- Serpentrix --
-----------------------
L= DBM:GetModLocalization(1479)

-----------------------
-- Wrath of Azshara --
-----------------------
L= DBM:GetModLocalization(1492)

-----------------------
--Eye of Azshara Trash
-----------------------
L = DBM:GetModLocalization("EoATrash")

L:SetGeneralLocalization({
	name =	"아즈샤라의 눈 일반몹"
})

-----------------------
-- <<<Halls of Valor>>> --
-----------------------
-----------------------
-- Hymdall --
-----------------------
L= DBM:GetModLocalization(1485)

-----------------------
-- Hyrja --
-----------------------
L= DBM:GetModLocalization(1486)

-----------------------
-- Fenryr --
-----------------------
L= DBM:GetModLocalization(1487)

-----------------------
-- God-King Skovald --
-----------------------
L= DBM:GetModLocalization(1488)

L:SetMiscLocalization({
	SkovaldRP		= "안 돼! 나도 내 가치를 증명했다, 오딘. 나는 신왕 스코발드다! 나의 아이기스에 어찌 감히 필멸자가 손을 댄단 말이냐!",
	SkovaldRPTwo	= "이 가짜 용사들이 아이기스를 포기하지 않는다면... 목숨을 포기해야 할 거다!"
})

-----------------------
-- Odyn --
-----------------------
L= DBM:GetModLocalization(1489)

L:SetOptionLocalization({
	RuneBehavior		= "룬 낙인때 보스 모드 작동 방식을 설정합니다.",
	Icon				= "룬 색과 일치하는 공격대 징표 기반 음성 경고 제공 (징표 기둥 사용)",
	Entrance			= "입구가 남쪽 옥좌가 북쪽인 동서남북 음성 경고 제공",
	Minimap				= "미니맵 기준으로 옥좌가 남쪽 입구가 북쪽인 동서남북 음성 경고 제공",
	Generic				= "당신이 대상입니다 음성 알림만 제공합니다. 방향 지시는 하지 않습니다"--Default
})

L:SetMiscLocalization({
	tempestModeMessage		=	"폭풍우 시퀀스 아님: %s. 8초 후 다시 검사합니다.",
	OdynRP					= "정말 놀랍군! 발라리아르의 힘에 견줄 만큼 강력한 자를 보게 될 줄은 몰랐거늘, 이렇게 너희가 나타나다니."
})

-----------------------
--Halls of Valor Trash
-----------------------
L = DBM:GetModLocalization("HoVTrash")

L:SetGeneralLocalization({
	name =	"용맹의 전당 일반몹"
})

-----------------------
-- <<<Neltharion's Lair>>> --
-----------------------
-----------------------
-- Rokmora --
-----------------------
L= DBM:GetModLocalization(1662)

-----------------------
-- Ularogg Cragshaper --
-----------------------
L= DBM:GetModLocalization(1665)

-----------------------
-- Naraxas --
-----------------------
L= DBM:GetModLocalization(1673)

-----------------------
-- Dargrul the Underking --
-----------------------
L= DBM:GetModLocalization(1687)

-----------------------
--Neltharion's Lair Trash
-----------------------
L = DBM:GetModLocalization("NLTrash")

L:SetGeneralLocalization({
	name =	"넬타리온의 둥지 일반몹"
})

-----------------------
-- <<<The Arcway>>> --
-----------------------
-----------------------
-- Ivanyr --
-----------------------
L= DBM:GetModLocalization(1497)

-----------------------
-- Nightwell Sentry --
-----------------------
L= DBM:GetModLocalization(1498)

-----------------------
-- General Xakal --
-----------------------
L= DBM:GetModLocalization(1499)

L:SetMiscLocalization({
	batSpawn		=	"나에게 박쥐 붙음!"
})

-----------------------
-- Nal'tira --
-----------------------
L= DBM:GetModLocalization(1500)

-----------------------
-- Advisor Vandros --
-----------------------
L= DBM:GetModLocalization(1501)

-----------------------
--The Arcway Trash
-----------------------
L = DBM:GetModLocalization("ArcwayTrash")

L:SetGeneralLocalization({
	name =	"비전로 일반몹"
})

-----------------------
-- <<<Court of Stars>>> --
-----------------------
-----------------------
-- Patrol Captain Gerdo --
-----------------------
L= DBM:GetModLocalization(1718)

-----------------------
-- Talixae Flamewreath --
-----------------------
L= DBM:GetModLocalization(1719)

-----------------------
-- Advisor Melandrus --
-----------------------
L= DBM:GetModLocalization(1720)

L:SetMiscLocalization({
	MelRP		= "벌써 떠나셔야 합니까, 대마법학자님?"
})

-----------------------
--Court of Stars Trash
-----------------------
L = DBM:GetModLocalization("CoSTrash")

L:SetGeneralLocalization({
	name =	"별의 궁정 일반몹"
})

L:SetOptionLocalization({
	warnAvailableItems	= "파티에 주변의 버프 오브젝트 알림",
	SpyHelper			= "첩자 색출을 위해 수다쟁이 호사가 NPC에게 말을 걸면 대화 내용을 자동으로 감지하여 정보 창에 표시 (다른 DBM/BW 사용자와 동기화)",
	SpyHelperClose2			= "0.3초 후 대화창 자동 닫기 (다른 모드나 WA가 대화 내역을 감지할 시간을 주기 위한 지연)",
	SendToChat2			= "대화창에도 힌트 알려주기 (위의 설정을 켜야 작동)"
})

L:SetMiscLocalization({
	Found			= "자, 너무 그렇게 다그치지 마십시오",
	--Add translationss, but keep english termss for cross language groups since these post to chat
	--Format "localized / english"
	CluesFound				= "단서 발견: %d/5",
	ClueShort				= "단서 %d/5: %s",
	Gloves					= "장갑 / gloves",
	NoGloves				= "장갑 없음 / no gloves",
	Cape					= "망토 / cape",
	Nocape					= "망토 없음 / no cape",
	LightVest				= "밝은색 조끼 / light vest",
	DarkVest				= "어두운색 조끼 / dark vest",
	Female					= "여자 / female",
	Male					= "남자 / male",
	ShortSleeve				= "짧은 소매 / short sleeve",
	LongSleeve				= "긴 소매 / long sleeve",
	Potions					= "물약 / potions",
	NoPotions				= "물약 없음 / no potions",
	Book					= "책 / book",
	Pouch					= "주머니 / pouch",

	SpyFoundP 				= "첩자 발견",
	SpyFound 				= "%s|1이;가; 첩자를 발견했습니다",
	SpyGoingAway				= "첩자 색출 도우미는 10.0.7 패치에서 너프로 없어질 예정입니다. 이 던전에 대한 블리자드의 의도는 악마 사냥꾼을 활용하거나 보이스챗으로 협력해서 찾으라는 것입니다",
	--Profession				 stuff
	Nightshade					= "밤그늘 간식",
	UmbralBloom					= "그림자 꽃",
	InfernalTome				= "지옥불 고서",
	MagicalLantern				= "마법 초롱",
	StarlightRoseBrew			= "별빛 장미 차",
	WaterloggedScroll			= "물에 젖은 두루마리",
	DiscardedJunk				= "버려진 쓰레기",
	BazaarGoods					= "장터 물품",
	WoundedNightborneCivilian	= "부상당한 나이트본 주민",
	LifesizedNightborneStatue	= "실물 크기의 나이트본 석상",
	--
	Available					= "%s|cffffffff%s|r 있음",
	UsableBy					= "%s|1이;가; 사용 가능"
})


-----------------------
-- <<<The Maw of Souls>>> --
-----------------------
-----------------------
-- Ymiron, the Fallen King --
-----------------------
L= DBM:GetModLocalization(1502)

-----------------------
-- Harbaron --
-----------------------
L= DBM:GetModLocalization(1512)

-----------------------
-- Helya --
-----------------------
L= DBM:GetModLocalization(1663)

-----------------------
--Maw of Souls Trash
-----------------------
L = DBM:GetModLocalization("MawTrash")

L:SetGeneralLocalization({
	name =	"영혼의 아귀 일반몹"
})

-----------------------
-- <<<Assault Violet Hold>>> --
-----------------------
-----------------------
-- Mindflayer Kaahrj --
-----------------------
L= DBM:GetModLocalization(1686)

-----------------------
-- Millificent Manastorm --
-----------------------
L= DBM:GetModLocalization(1688)

-----------------------
-- Festerface --
-----------------------
L= DBM:GetModLocalization(1693)

-----------------------
-- Shivermaw --
-----------------------
L= DBM:GetModLocalization(1694)

-----------------------
-- Blood-Princess Thal'ena --
-----------------------
L= DBM:GetModLocalization(1702)

-----------------------
-- Anub'esset --
-----------------------
L= DBM:GetModLocalization(1696)

-----------------------
-- Sael'orn --
-----------------------
L= DBM:GetModLocalization(1697)

-----------------------
-- Fel Lord Betrug --
-----------------------
L= DBM:GetModLocalization(1711)

-----------------------
--Assault Violet Hold Trash
-----------------------
L = DBM:GetModLocalization("AVHTrash")

L:SetGeneralLocalization({
	name =	"보랏빛 요새 침공 일반몹"
})

L:SetWarningLocalization({
	WarningPortalSoon	= "곧 새 차원문 열림",
	WarningPortalNow	= "차원문 #%d",
	WarningBossNow		= "보스 등장"
})

L:SetTimerLocalization({
	TimerPortal			= "차원문 가능"
})

L:SetOptionLocalization({
	WarningPortalNow		= "새 차원문 등장시 경고 표시",
	WarningPortalSoon		= "새 차원문 사전 경고 표시",
	WarningBossNow			= "보스 등장 경고 표시",
	TimerPortal				= "다음 차원문 타이머 표시 (보스 처치 이후)"
})

L:SetMiscLocalization({
	Malgath		=	"군주 말가스"
})

-----------------------
-- <<<Vault of the Wardens>>> --
-----------------------
-----------------------
-- Tirathon Saltheril --
-----------------------
L= DBM:GetModLocalization(1467)

-----------------------
-- Inquisitor Tormentorum --
-----------------------
L= DBM:GetModLocalization(1695)

-----------------------
-- Ash'golm --
-----------------------
L= DBM:GetModLocalization(1468)

-----------------------
-- Glazer --
-----------------------
L= DBM:GetModLocalization(1469)

-----------------------
-- Cordana --
-----------------------
L= DBM:GetModLocalization(1470)

-----------------------
--Vault of Wardens Trash
-----------------------
L = DBM:GetModLocalization("VoWTrash")

L:SetGeneralLocalization({
	name =	"감시관의 금고 일반몹"
})

-----------------------
-- <<<Return To Karazhan>>> --
-----------------------
-----------------------
-- Maiden of Virtue --
-----------------------
L= DBM:GetModLocalization(1825)

-----------------------
-- Opera Hall: Wikket  --
-----------------------
L= DBM:GetModLocalization(1820)

-----------------------
-- Opera Hall: Westfall Story --
-----------------------
L= DBM:GetModLocalization(1826)

-----------------------
-- Opera Hall: Beautiful Beast  --
-----------------------
L= DBM:GetModLocalization(1827)

-----------------------
-- Attumen the Huntsman --
-----------------------
L= DBM:GetModLocalization(1835)

-----------------------
-- Moroes --
-----------------------
L= DBM:GetModLocalization(1837)

-----------------------
-- The Curator --
-----------------------
L= DBM:GetModLocalization(1836)

-----------------------
-- Shade of Medivh --
-----------------------
L= DBM:GetModLocalization(1817)

-----------------------
-- Mana Devourer --
-----------------------
L= DBM:GetModLocalization(1818)

-----------------------
-- Viz'aduum the Watcher --
-----------------------
L= DBM:GetModLocalization(1838)

-----------------------
--Nightbane
-----------------------
L = DBM:GetModLocalization("Nightbane")

L:SetGeneralLocalization({
	name =	"파멸의 어둠"
})

-----------------------
--Return To Karazhan Trash
-----------------------
L = DBM:GetModLocalization("RTKTrash")

L:SetGeneralLocalization({
	name =	"다시 찾은 카라잔 일반몹"
})

L:SetMiscLocalization({
	speedRun		=	"어둠의 존재를 알리는 기묘한 한기가 주위에 퍼져나갑니다..."
})

-----------------------
-- <<<Cathedral of Eternal Night >>> --
-----------------------
-----------------------
-- Agronox --
-----------------------
L= DBM:GetModLocalization(1905)

-----------------------
-- Trashbite the Scornful  --
-----------------------
L= DBM:GetModLocalization(1906)

L:SetMiscLocalization({
	bookCase	=	"책장 뒤"
})

-----------------------
-- Domatrax --
-----------------------
L= DBM:GetModLocalization(1904)

-----------------------
-- Mephistroth  --
-----------------------
L= DBM:GetModLocalization(1878)

-----------------------
--Cathedral of Eternal Night Trash
-----------------------
L = DBM:GetModLocalization("CoENTrash")

L:SetGeneralLocalization({
	name =	"영원한 밤의 대성당 일반몹"
})

-----------------------
-- <<<Seat of Triumvirate >>> --
-----------------------
-----------------------
-- Zuraal --
-----------------------
L= DBM:GetModLocalization(1979)

-----------------------
-- Saprish  --
-----------------------
L= DBM:GetModLocalization(1980)

-----------------------
-- Viceroy Nezhar --
-----------------------
L= DBM:GetModLocalization(1981)

-----------------------
-- L'ura  --
-----------------------
L= DBM:GetModLocalization(1982)

-----------------------
--Seat of Triumvirate Trash
-----------------------
L = DBM:GetModLocalization("SoTTrash")

L:SetGeneralLocalization({
	name =	"삼두정의 권좌 일반몹"
})
