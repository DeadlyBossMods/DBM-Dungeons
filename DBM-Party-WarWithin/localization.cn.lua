--Mini Dragon <流浪者酒馆-Brilla@金色平原(The Golden Plains-CN)> projecteurs@gmail.NOSPAM.com 20250811
--Blizzard Entertainment

if GetLocale() ~= "zhCN" then return end
local L

-------------------------
--  Darkflame Cleft (1210/2651)  --暗焰裂口
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
	name =	"暗焰裂口小怪"
})

-------------------------
--  Priory of the Sacred Flame (1267/2649)  --圣焰隐修院
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
	name =	"圣焰隐修院小怪"
})

-------------------------
--  The Rookery (1268/2648)  --驭雷栖巢
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
	name =	"驭雷栖巢小怪"
})

-------------------------
--  The Stonevault (1269/2652)  --矶石宝库
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
	SafeVent		= "安全排放口"
}

-----------------------------
--  High Speaker Eirich  --
-----------------------------
--L = DBM:GetModLocalization(2582)

L:SetWarningLocalization({
	specWarnVoidCorruption	= "虚空裂隙 - 靠近裂隙（不是在裂隙里）"
})

---------
--Trash--
---------
L = DBM:GetModLocalization("TheStonevaultTrash")

L:SetGeneralLocalization({
	name =	"矶石宝库小怪"
})

-------------------------
--  The Dawnbreaker (1270/2662)  --破晨号
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
	name =	"破晨号小怪"
})

-------------------------
--  Ara-Kara, City of Echoes (1271/2660)  --艾拉-卡拉，回响之城
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
	name =	"艾拉-卡拉小怪"
})

-------------------------
--  Cinderbrew Meadery (1272/2661)  --燧酿酒庄
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
L = DBM:GetModLocalization(2589)

L:SetMiscLocalization{
	RolePlay		= "好吧，我的员工被你们放倒了。"
}

---------
--Trash--
---------
L = DBM:GetModLocalization("CinderbrewMeaderyTrash")

L:SetGeneralLocalization({
	name =	"燧酿酒庄小怪"
})

L:SetOptionLocalization({
	AGBuffs		= "与专业物品对话时自动选择激活Buff"
})

-------------------------
--  City of Threads (1274/2669)  --千丝之城
-----------------------------
--  Orator Krix'vizk  --
-----------------------------
--L = DBM:GetModLocalization(2594)

-----------------------------
--  Fangs of the Queen  --
-----------------------------
--L = DBM:GetModLocalization(2595)

L:SetMiscLocalization{
	RolePlay		= "蜕躯工厂曾经是我们神圣的进化之家。"
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
	name =	"千丝之城小怪"
})

----------
-- 水闸行动
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
	name =	"水闸行动小怪"
})

----------
-- 奥尔达尼生态圆顶
-----------------------------
--  Azhiccar  --
-----------------------------
--L = DBM:GetModLocalization(2675)

-----------------------------
--  Taah'bat and A'wazj  --
-----------------------------
--L = DBM:GetModLocalization(2676)

-----------------------------
--  Soul-Scribe  --
-----------------------------
--L = DBM:GetModLocalization(2677)

---------
--Trash--
---------
L = DBM:GetModLocalization("EcoDomeAldaniTrash")

L:SetGeneralLocalization({
	name =	"生态圆顶小怪"
})
