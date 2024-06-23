-- Mini Dragon(projecteurs@gmail.com)
-- 夏一可
-- Blizzard Entertainment
-- Last update: 20230502

if GetLocale() ~= "zhCN" then return end
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
	name =	"黑鸦堡垒小怪"
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
	name =	"黑心林地小怪"
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
	specWarnStaticNova			= "静电新星 - 快站沙丘",
	specWarnFocusedLightning	= "凝聚闪电 - 快进水域"
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
	name =	"艾萨拉之眼小怪"
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
	SkovaldRP		= 	"不！我也证明了自己，奥丁。我是神王斯科瓦尔德！这些凡人休想抢走我的圣盾！",
	SkovaldRPTwo	= 	"如果这些所谓的“勇士”不肯放弃圣盾……那就让他们去死吧！"
})

-----------------------
-- Odyn --
-----------------------
L= DBM:GetModLocalization(1489)

L:SetOptionLocalization({
	RuneBehavior		= "设置符文烙印的模组行为",
	Icon				= "通过语音提示符文的颜色",
	Entrance			= "通过语音提示位置，入口是南边，王座是北边",
	Minimap				= "通过语音提示位置，王座是南边，入口是北边",
	Generic				= "只提示你被标记，不提供位置信息" --默认
})

L:SetMiscLocalization({
	tempestModeMessage		=	"非明光风暴序列: %s. 8秒后再检查.",
	OdynRP					=	"真了不起！没想到还有人能对抗瓦拉加尔的力量……而他们就站在我面前。"
})

-----------------------
--Halls of Valor Trash
-----------------------
L = DBM:GetModLocalization("HoVTrash")

L:SetGeneralLocalization({
	name =	"英灵殿小怪"
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
	name =	"奈萨里奥的巢穴小怪"
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
	batSpawn		=	"援助我！快！" --offical
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
	name =	"魔法回廊小怪"
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
	MelRP		= "这么快就走了吗，大魔导师？"
})

-----------------------
--Court of Stars Trash
-----------------------
L = DBM:GetModLocalization("CoSTrash")

L:SetGeneralLocalization({
	name =	"群星庭院小怪"
})

L:SetWarningLocalization({
	warnAvailableItems	= "%s"
})

L:SetOptionLocalization({
	warnAvailableItems	= "根据小组在区域内通告可用交互",
	SpyHelper			= "在对话时帮忙识别密探，并在信息窗显示（同步DBM/BW用户）",
	SpyHelperClose2		= "0.3秒后自动关闭对话窗（给与其他插件扫描延迟）",
	SendToChat2			= "自动在聊天中显示提示（需要上面那个功能开启）"
})

L:SetMiscLocalization({ --神坑
	Found		= "喂喂，别急着下结论", --给s大大疯狂打电话
	--Add translations, but keep english termss for cross language groups since these post to chat
	--Format "localized / english"
	Gloves		= "手套 / gloves",
	NoGloves	= "没手套 / no gloves",
	Cape		= "斗篷 / cape",
	Nocape		= "没斗篷 / no cape",
	LightVest	= "浅色上衣 / light vest",
	DarkVest	= "深色上衣 / dark vest",
	Female		= "女性 / female",
	Male		= "男性 / male",
	ShortSleeve = "短袖 / short sleeve",
	LongSleeve	= "长袖 / long sleeve",
	Potions		= "腰上药水 / potions",
	NoPotions	= "没有药水 / no potions",
	Book		= "带书 / book",
	Pouch		= "挂腰包 / pouch",

	SpyFoundP 					= "我找到间谍了",
	SpyFound 					= "间谍已经被%s找到了",
	SpyGoingAway				= "暴雪貌似不让我们用这个功能了",
	--Profession				stuff
	Nightshade					= "夜影小食",
	UmbralBloom					= "深黯之花",
	InfernalTome				= "地狱火宝典",
	MagicalLantern				= "魔法灯笼",
	StarlightRoseBrew			= "星光玫瑰茶",
	WaterloggedScroll			= "浸水的卷轴",
	DiscardedJunk				= "丢弃的垃圾",
	BazaarGoods					= "集市货物",
	WoundedNightborneCivilian	= "受伤的夜之子平民",
	LifesizedNightborneStatue	= "夜之子等身雕像",
	--
	Available					= "%s|cffffffff%s|r 可用",
	UsableBy					= "被%s使用"
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
	name =	"噬魂之喉小怪"
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
	name =	"突袭紫罗兰监狱小怪"
})

L:SetWarningLocalization({
	WarningPortalSoon	= "准备开门",
	WarningPortalNow	= "第%d个传送门",
	WarningBossNow		= "Boss来了"
})

L:SetTimerLocalization({
	TimerPortal			= "传送门CD"
})

L:SetOptionLocalization({
	WarningPortalNow		= "警报：新的传送门",
	WarningPortalSoon		= "警报：准备开门",
	WarningBossNow			= "警报：Boss来了",
	TimerPortal				= "计时条：Boss后的下一个门"
})

L:SetMiscLocalization({
	Malgath		=	"督军马尔加斯" --offical
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
--Vault of the Wardens Trash
-----------------------
L = DBM:GetModLocalization("")

L:SetGeneralLocalization({
	name =	"守望者地窟小怪"
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
	name =	"夜之魇"
})

-----------------------
--Return To Karazhan Trash
-----------------------
L = DBM:GetModLocalization("RTKTrash")

L:SetGeneralLocalization({
	name =	"重返卡拉赞小怪"
})

L:SetMiscLocalization({
	speedRun		=	"空气中弥漫着某种诡异的黑暗寒风……"
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
	bookCase	=	"书架后面"
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
	name =	"永夜大教堂小怪"
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
	name =	"执政团之座小怪"
})
