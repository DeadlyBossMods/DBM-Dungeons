-- Diablohu(diablohudream@gmail.com)
-- yleaf(yaroot@gmail.com)
-- Mini_Dragon(projecteurs@gmail.com)
-- Yike Xia
-- Last update: Sep 23 2015, 06:10 UTC@14543
-- 泰坦重铸时光服-时光2-法师-旺仔芒果/椰奶冻-2026.11.13--

if GetLocale() ~= "zhCN" then return end

local L

------------
--  Omen  --
------------
L = DBM:GetModLocalization("Omen")

L:SetGeneralLocalization({
	name = "年兽"
})

------------------------------
--  The Crown Chemical Co.  --
------------------------------
L = DBM:GetModLocalization("d288")

L:SetTimerLocalization({
	HummelActive		= "汉摩尔加入战斗",
	BaxterActive		= "拜克斯特加入战斗",
	FryeActive		= "弗莱加入战斗"
})

L:SetOptionLocalization({
	TrioActiveTimer		= "计时条：药剂师何时加入战斗"
})

L:SetMiscLocalization({
	SayCombatStart		= "他们顾得上告诉你我是谁或者我在做些什么吗？"
})

----------------------------
--  The Frost Lord Ahune  --
----------------------------
L = DBM:GetModLocalization("d286")

L:SetWarningLocalization({
	Submerged		= "埃霍恩已隐没",
	Emerged			= "埃霍恩已现身",
	specWarnAttack		= "埃霍恩拥有易伤 - 现在攻击!"
})

L:SetTimerLocalization({
	SubmergeTimer		= "隐没",
	EmergeTimer		= "现身",
	TimerCombat		= "战斗开始"
})

L:SetOptionLocalization({
	Submerged		= "警报：埃霍恩隐没",
	Emerged			= "警报：埃霍恩现身",
	specWarnAttack		= "特殊警报：埃霍恩拥有易伤",
	SubmergeTimer		= "计时条：隐没",
	EmergeTimer		= "计时条：现身",
	TimerCombat		= "计时条：战斗开始"
})

L:SetMiscLocalization({
	Pull			= "冰石已经溶化了!"
})

----------------------
--  Coren Direbrew  --
----------------------
L = DBM:GetModLocalization("d287")

L:SetWarningLocalization({
	specWarnBrew		= "在他再丢你一个前喝掉酒！",
	specWarnBrewStun	= "提示：你疯狂了，记得下一次喝啤酒！"
})

L:SetOptionLocalization({
	specWarnBrew		= "特殊警报：$spell:47376",
	specWarnBrewStun	= "特殊警报：$spell:47340"
})

L:SetMiscLocalization({
	YellBarrel		= "我中了空桶！"
})

----------------
--  Brewfest  --
----------------
L = DBM:GetModLocalization("Brew")

L:SetGeneralLocalization({
	name = "美酒节"
})

L:SetOptionLocalization({
	NormalizeVolume			= "在美酒节任务区域内，自动将对话声道的音量调节成音乐声道的音量。(如果音乐没有开启，对话声道会变静音。)"
})

-------------------------
--  Headless Horseman  --
-------------------------
L = DBM:GetModLocalization("d285")

L:SetGeneralLocalization({
	name = "无头骑士"
})

L:SetWarningLocalization({
	WarnPhase				= "第%d阶段",
	warnHorsemanSoldiers	= "跃动的南瓜出现了",
	warnHorsemanHead		= "打脑袋！"
})

L:SetTimerLocalization{
	TimerCombatStart		= "战斗开始"
}

L:SetOptionLocalization({
	WarnPhase				= "警报：阶段转换",
	TimerCombatStart		= "计时条：战斗开始",
	warnHorsemanSoldiers	= "警报：跃动的南瓜出现",
	warnHorsemanHead		= "特殊警报：无头骑士的脑袋出现"
})

L:SetMiscLocalization({
	HorsemanSummon			= "无头骑士来了……",
	HorsemanSoldiers		= "士兵们，起来战斗吧！为死去的骑士带来胜利的荣耀！"
})

------------------------------
--  The Abominable Greench  --
------------------------------
L = DBM:GetModLocalization("Greench")

L:SetGeneralLocalization({
	name = "讨厌的格林奇"
})

--------------------------
--  Plants Vs. Zombies  --
--------------------------
L = DBM:GetModLocalization("PlantsVsZombies")

L:SetGeneralLocalization({
	name = "植物大战僵尸"
})

L:SetWarningLocalization({
	warnTotalAdds	= "上一次大波僵尸后僵尸计数：%d",
	specWarnWave	= "一大波僵尸！"
})

L:SetTimerLocalization{
	timerWave		= "下一大波僵尸"
}

L:SetOptionLocalization({
	warnTotalAdds	= "警报：每次大波僵尸之间的僵尸出现计数",
	specWarnWave	= "特殊警报：一大波僵尸",
	timerWave		= "计时条：下一大波僵尸"
})

L:SetMiscLocalization({
	MassiveWave		= "一大波僵尸正在靠近！"
})

-- Quest
L = DBM:GetModLocalization("EscortQuests")

L:SetGeneralLocalization{
	name = "护送任务",
}

L:SetOptionLocalization{
	Timers = "为部分护送任务显示计时条"
}

--------------------------
--  Demonic Invasions  --
--------------------------
L = DBM:GetModLocalization("DemonInvasions")

L:SetGeneralLocalization({
	name = "恶魔入侵"
})

--------------------------
--  Memories of Azeroth: Burning Crusade  --
--------------------------
L = DBM:GetModLocalization("BCEvent")

L:SetGeneralLocalization({
	name = "艾泽拉斯回忆：燃烧的远征"
})

--------------------------
--  Memories of Azeroth: Wrath of the Lich King  --
--------------------------
L = DBM:GetModLocalization("WrathEvent")

L:SetGeneralLocalization({
	name = "艾泽拉斯回忆：巫妖王之怒"
})

L:SetWarningLocalization{
	WarnEmerge				= "阿努巴拉克出现",
	WarnEmergeSoon			= "10秒后出现",
	WarnSubmerge			= "阿努巴拉克钻入地下",
	WarnSubmergeSoon		= "10秒后钻入地下",
	WarningTeleportNow		= "传送",
	WarningTeleportSoon		= "10秒后传送"
}

L:SetTimerLocalization{
	TimerEmerge				= "出现",
	TimerSubmerge			= "钻入地下",
	TimerTeleport			= "传送"
}

L:SetMiscLocalization{
	Emerge				= "钻入了地下！",
	Burrow				= "从地面上升起来了！"
}

L:SetOptionLocalization{
	WarnEmerge				= "为出现显示警告",
	WarnEmergeSoon			= "为出现显示预先警告",
	WarnSubmerge			= "为钻入地下显示警告",
	WarnSubmergeSoon		= "为钻入地下显示预先警告",
	TimerEmerge				= "为出现显示计时条",
	TimerSubmerge			= "为钻入地下显示计时条",
	WarningTeleportNow		= "为传送显示警告",
	WarningTeleportSoon		= "为传送显示预先警告",
	TimerTeleport			= "为传送显示计时条"
}

--------------------------
--  Memories of Azeroth: Cataclysm  --
--------------------------
L = DBM:GetModLocalization("CataEvent")

L:SetGeneralLocalization({
	name = "艾泽拉斯回忆：大地的裂变"
})

L:SetWarningLocalization({
	warnSplittingBlow		= "%s于%s",
	warnEngulfingFlame		= "%s于%s"
})

L:SetOptionLocalization({
	warnSplittingBlow			= "为$spell:98951的位置显示警告",
	warnEngulfingFlame			= "为$spell:99171的位置显示警告"
})

----------------------------------
--  Azeroth Event World Bosses  --
----------------------------------

-- Lord Kazzak (Badlands)
L = DBM:GetModLocalization("KazzakClassic")

L:SetGeneralLocalization{
	name = "卡扎克领主"
}

L:SetMiscLocalization({
	Pull		= "为了军团!为了基尔加德!"
})

-- Azuregos (Azshara)
L = DBM:GetModLocalization("Azuregos")

L:SetGeneralLocalization{
	name = "艾索雷葛斯"
}

L:SetMiscLocalization({
	Pull		= "我保护着这个地方。神秘的秘法不能受到亵渎。"
})

-- Taerar (Ashenvale)
L = DBM:GetModLocalization("Taerar")

L:SetGeneralLocalization{
	name = "泰拉尔"
}

L:SetMiscLocalization({
	Pull		= "和平不过是短暂的梦想!让梦魇统治整个世界吧!"
})

-- Ysondre (Feralas)
L = DBM:GetModLocalization("Ysondre")

L:SetGeneralLocalization{
	name = "伊森德雷"
}

L:SetMiscLocalization({
	Pull		= "生命的希冀已被切断!梦游者要展开报复!"
})

-- Lethon (Hinterlands)
L = DBM:GetModLocalization("Lethon")

L:SetGeneralLocalization{
	name = "莱索恩"
}

-- Emeriss (Duskwood)
L = DBM:GetModLocalization("Emeriss")

L:SetGeneralLocalization{
	name = "艾莫莉丝"
}

L:SetMiscLocalization({
	Pull		= "希望是灵魂染上的疾病!这片土地应该枯竭，从此死气腾腾!"
})

-- Doomwalker (Tanaris)
L = DBM:GetModLocalization("DoomwalkerEvent")

L:SetGeneralLocalization{
	name = "末日行者（事件）"
}

-- Archavon (???)
L = DBM:GetModLocalization("ArchavonEvent")

L:SetGeneralLocalization{
	name = "阿尔卡冯（事件）"
}

-- Sha of Anger (???)
L = DBM:GetModLocalization("ShaofAngerEvent")

L:SetGeneralLocalization{
	name = "怒之煞（事件）"
}

--------------------------
--  Blastenheimer 5000  --
--------------------------
L = DBM:GetModLocalization("Cannon")

L:SetGeneralLocalization({
	name = "炮弹飞人"
})

L = DBM:GetModLocalization("CannonClassic")

L:SetGeneralLocalization({
	name = "炮弹飞人"
})

-------------
--  Gnoll  --
-------------
L = DBM:GetModLocalization("Gnoll")

L:SetGeneralLocalization({
	name = "打豺狼人"
})

L:SetWarningLocalization({
	warnGameOverQuest	= "得分：%d / %d（可能的最高分数）",
	warnGameOverNoQuest	= "游戏结束，本次可能的最高分数：%d",
	warnGnoll			= "豺狼人出现",
	warnHogger			= "霍格出现",
	specWarnHogger		= "霍格！"
})

L:SetOptionLocalization({
	warnGameOver	= "游戏结束时通报本次游戏可能的最高分数",
	warnGnoll		= "警报：豺狼人出现",
	warnHogger		= "警报：霍格出现",
	specWarnHogger	= "特殊警报：霍格出现"
})

------------------------
--  Shooting Gallery  --
------------------------
L = DBM:GetModLocalization("Shot")

L:SetGeneralLocalization({
	name = "射击场"
})

L:SetOptionLocalization({
	SetBubbles			= "在$spell:101871期间自动关闭聊天气泡（结束后自动恢复）"
})

----------------------
--  Tonk Challenge  --
----------------------
L = DBM:GetModLocalization("Tonks")

L:SetGeneralLocalization({
	name = "坦克大战"
})

---------------------------
--  Fire Ring Challenge  --
---------------------------
L = DBM:GetModLocalization("Rings")

L:SetGeneralLocalization({
	name = "火鸟的挑战"
})

-----------------------
--  Darkmoon Rabbit  --
-----------------------
L = DBM:GetModLocalization("Rabbit")

L:SetGeneralLocalization({
	name = "暗月兔子"
})

-------------------------
--  Darkmoon Moonfang  --
-------------------------
L = DBM:GetModLocalization("Moonfang")

L:SetGeneralLocalization({
	name = "月牙"
})

L:SetWarningLocalization({
	specWarnCallPack		= "召唤狼群 － 远离月牙40码以上!",
	specWarnMoonfangCurse	= "月牙的诅咒 － 远离月牙10码以上!"
})

L:SetOptionLocalization({
	specWarnCallPack		= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.run:format(144602),
	specWarnMoonfangCurse	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.run:format(144590)
})
