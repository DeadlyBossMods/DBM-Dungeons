-- Simplified Chinese by Diablohu
-- http://wow.gamespot.com.cn
-- Last Update: 12/13/2008

-- author: callmejames @《凤凰之翼》 一区藏宝海湾
-- commit by: yaroot <yaroot AT gmail.com>
-- Last Update: 9/16/2010

if GetLocale() ~= "zhCN" then return end

local L

local optionWarning	= "显示%s警报"		-- translate
local optionPreWarning	= "显示%s预警"	-- translate

----------------------------------
--  Ahn'Kahet: The Old Kingdom  --
----------------------------------
--  Prince Taldaram  --
-----------------------
L = DBM:GetModLocalization(581)

L:SetGeneralLocalization{
	name 		= "塔达拉姆王子"
}

-------------------
--  Elder Nadox  --
-------------------
L = DBM:GetModLocalization(580)

L:SetGeneralLocalization{
	name 		= "纳多克斯长老"
}

---------------------------
--  Jedoga Shadowseeker  --
---------------------------
L = DBM:GetModLocalization(582)

L:SetGeneralLocalization{
	name 		= "耶戈达·觅影者"
}

---------------------
--  Herald Volazj  --
---------------------
L = DBM:GetModLocalization(584)

L:SetGeneralLocalization{
	name 		= "传令官沃拉兹"
}

----------------
--  Amanitar  --
----------------
L = DBM:GetModLocalization(583)

L:SetGeneralLocalization{
	name 		= "埃曼尼塔"
}

-------------------
--  Azjol-Nerub  --
---------------------------------
--  Krik'thir the Gatewatcher  --
---------------------------------
L = DBM:GetModLocalization(585)

L:SetGeneralLocalization{
	name 		= "看门者克里克希尔"
}

----------------
--  Hadronox  --
----------------
L = DBM:GetModLocalization(586)

L:SetGeneralLocalization{
	name 		= "哈多诺克斯"
}

-------------------------
--  Anub'arak (Party)  --
-------------------------
L = DBM:GetModLocalization(587)

L:SetGeneralLocalization({
	name = "阿努巴拉克(5人副本)"
})

---------------------------------------
--  Caverns of Time: Old Stratholme  --
---------------------------------------
--  Meathook  --
----------------
L = DBM:GetModLocalization(611)

L:SetGeneralLocalization{
	name 		= "肉钩"
}

--------------------------------
--  Salramm the Fleshcrafter  --
--------------------------------
L = DBM:GetModLocalization(612)

L:SetGeneralLocalization{
	name 		= "塑血者沙尔拉姆"
}

-------------------------
--  Chrono-Lord Epoch  --
-------------------------
L = DBM:GetModLocalization(613)

L:SetGeneralLocalization{
	name 		= "时光领主埃博克"
}

-----------------
--  Mal'Ganis  --
-----------------
L = DBM:GetModLocalization(614)

L:SetGeneralLocalization{
	name 		= "玛尔加尼斯"
}

L:SetMiscLocalization({
	Outro	= "你的旅程才刚开始，年轻的王子。集合你的部队，到诺森德再次挑战我。在那里，我们将了结彼此之间的恩怨，你将了解到你真正的命运。"
})

-------------------
--  Wave Timers  --
-------------------
L = DBM:GetModLocalization("StratWaves")

L:SetGeneralLocalization({
	name = "斯坦索姆小怪"
})

L:SetWarningLocalization({
	WarningWaveNow	= "第%d波: %s 出现了"
})

L:SetTimerLocalization({
	TimerWaveIn		= "下一波(6)",
	TimerRoleplay	= "角色扮演事件计时"
})

L:SetOptionLocalization({
	WarningWaveNow	= optionWarning:format("新一波"),
	TimerWaveIn		= "为下一波显示计时条 (之后的5批小怪)",
	TimerRoleplay	= "为角色扮演事件显示计时条"
})

L:SetMiscLocalization({
	Devouring	= "狼吞虎咽的食尸鬼",
	Enraged		= "暴怒的食尸鬼",
	Necro		= "通灵大师",
	Fiend		= "地穴恶魔",
	Stalker		= "墓穴猎手",
	Abom		= "缝补构造体",
	Acolyte		= "侍僧",
	Wave1		= "%d %s",
	Wave2		= "%d %s 和 %d %s",
	Wave3		= "%d %s，%d %s 和 %d %s",
	Wave4		= "%d %s，%d %s，%d %s 和 %d %s",
	WaveBoss	= "%s",
	WaveCheck	= "天灾波次 = (%d+)/10",
	Roleplay	= "乌瑟尔，你总算及时赶到了。",
	Roleplay2	= "大家都做好准备了吧。记住，斯坦索姆的城民已经受到感染，很快就会丧命。我们必须清洗斯坦索姆，确保洛丹伦的其它地区免受天灾军团的侵蚀。出发吧。"
})

------------------------
--  Drak'Tharon Keep  --
------------------------
--  Trollgore  --
-----------------
L = DBM:GetModLocalization(588)

L:SetGeneralLocalization{
	name 		= "托尔戈"
}

--------------------------
--  Novos the Summoner  --
--------------------------
L = DBM:GetModLocalization(589)

L:SetGeneralLocalization{
	name 		= "召唤者诺沃斯"
}

L:SetMiscLocalization({
	YellPull		= "笼罩你的寒气就是厄运的先兆。",
	HandlerYell		= "协助防御！快点，废物们！",
	Phase2			= "很快你们就会发现一切都是徒劳无功。",
	YellKill		= "这一切……都是毫无意义的。"
})

-----------------
--  King Dred  --
-----------------
L = DBM:GetModLocalization(590)

L:SetGeneralLocalization{
	name 		= "暴龙之王爵德"
}

-----------------------------
--  The Prophet Tharon'ja  --
-----------------------------
L = DBM:GetModLocalization(591)

L:SetGeneralLocalization{
	name 		= "先知萨隆亚"
}

---------------
--  Gundrak  --
----------------
--  Slad'ran  --
----------------
L = DBM:GetModLocalization(592)

L:SetGeneralLocalization{
	name 		= "斯拉德兰"
}

---------------
--  Moorabi  --
---------------
L = DBM:GetModLocalization(594)

L:SetGeneralLocalization{
	name 		= "莫拉比"
}

-------------------------
--  Drakkari Colossus  --
-------------------------
L = DBM:GetModLocalization(593)

L:SetGeneralLocalization{
	name 		= "达卡莱巨像"
}

-----------------
--  Gal'darah  --
-----------------
L = DBM:GetModLocalization(596)

L:SetGeneralLocalization{
	name 		= "迦尔达拉"
}

-------------------------
--  Eck the Ferocious  --
-------------------------
L = DBM:GetModLocalization(595)

L:SetGeneralLocalization{
	name 		= "凶残的伊克"
}

--------------------------
--  Halls of Lightning  --
--------------------------
--  General Bjarngrim  --
-------------------------
L = DBM:GetModLocalization(597)

L:SetGeneralLocalization{
	name 		= "比亚格里将军"
}

-------------
--  Ionar  --
-------------
L = DBM:GetModLocalization(599)

L:SetGeneralLocalization{
	name 		= "艾欧纳尔"
}

---------------
--  Volkhan  --
---------------
L = DBM:GetModLocalization(598)

L:SetGeneralLocalization{
	name 		= "沃尔坎"
}

--------------
--  Loken  --
--------------
L = DBM:GetModLocalization(600)

L:SetGeneralLocalization{
	name 		= "洛肯"
}

----------------------
--  Halls of Stone  --
-----------------------
--  Maiden of Grief  --
-----------------------
L = DBM:GetModLocalization(605)

L:SetGeneralLocalization{
	name 		= "悲伤圣女"
}

------------------
--  Krystallus  --
------------------
L = DBM:GetModLocalization(604)

L:SetGeneralLocalization{
	name 		= "克莱斯塔卢斯"
}

------------------------------
--  Sjonnir the Ironshaper  --
------------------------------
L = DBM:GetModLocalization(607)

L:SetGeneralLocalization{
	name 		= "塑铁者斯约尼尔"
}

--------------------------------------
--  Brann Bronzebeard Escort Event  --
--------------------------------------
L = DBM:GetModLocalization(606)

L:SetGeneralLocalization{
	name 		= "布莱恩 事件"
}

L:SetWarningLocalization({
	WarningPhase	= "第%d阶段"
})

L:SetTimerLocalization({
	timerEvent	= "剩余时间"
})

L:SetOptionLocalization({
	WarningPhase	= optionWarning:format("阶段数"),
	timerEvent		= "为事件的持续时间显示计时条"
})

L:SetMiscLocalization({
	Pull	= "嗯，你们帮我看着点外面。我这样的强者只要锤两下就能搞定这破烂……",
	Phase1	= "安全系统发现不明入侵。历史文档的分析工作优先级转为低。对策程序立即启动。",
	Phase2	= "已超出威胁指数标准。天界文档中断。提高安全级别。",
	Phase3	= "威胁指数过高。虚空分析程序关闭。启动清理协议。",
	Kill	= "警告：安全系统自动修复装置已被关闭。立刻消除化全部存储器内容并……"
})

-----------------
--  The Nexus  --
-----------------
--  Anomalus  --
----------------
L = DBM:GetModLocalization(619)

L:SetGeneralLocalization{
	name 		= "阿诺玛鲁斯"
}

-------------------------------
--  Ormorok the Tree-Shaper  --
-------------------------------
L = DBM:GetModLocalization(620)

L:SetGeneralLocalization{
	name 		= "塑树者奥莫洛克"
}

----------------------------
--  Grand Magus Telestra  --
----------------------------
L = DBM:GetModLocalization(618)

L:SetGeneralLocalization{
	name 		= "大魔导师泰蕾丝塔"
}

L:SetMiscLocalization({
	SplitTrigger1		= "这里有我千万个分身。",
	SplitTrigger2		= "我要让你们尝尝无所适从的滋味!"
})

-------------------
--  Keristrasza  --
-------------------
L = DBM:GetModLocalization(621)

L:SetGeneralLocalization{
	name 		= "克莉斯塔萨"
}

-----------------------------------
--  Commander Kolurg/Stoutbeard  --
-----------------------------------
L = DBM:GetModLocalization("Commander")

local commander = "未知"
if UnitFactionGroup("player") == "Alliance" then
	commander = "指挥官库鲁尔格"
elseif UnitFactionGroup("player") == "Horde" then
	commander = "指挥官斯托比德"
end

L:SetGeneralLocalization({
	name = commander
})

------------------
--  The Oculus  --
-------------------------------
--  Drakos the Interrogator  --
-------------------------------
L = DBM:GetModLocalization(622)

L:SetGeneralLocalization{
	name 		= "审讯者达库斯"
}

L:SetOptionLocalization({
	MakeitCountTimer	= "为成就：分秒必争显示计时条"
})

L:SetMiscLocalization({
	MakeitCountTimer	= "分秒必争"
})

----------------------
--  Mage-Lord Urom  --
----------------------
L = DBM:GetModLocalization(624)

L:SetGeneralLocalization{
	name 		= "法师领主伊洛姆"
}

L:SetMiscLocalization({
	CombatStart		= "可怜而无知的蠢货！"
})

--------------------------
--  Varos Cloudstrider  --
--------------------------
L = DBM:GetModLocalization(623)

L:SetGeneralLocalization{
	name 		= "瓦尔洛斯·云击"
}

---------------------------
--  Ley-Guardian Eregos  --
---------------------------
L = DBM:GetModLocalization(625)

L:SetGeneralLocalization{
	name 		= "魔网守护者埃雷苟斯"
}

L:SetMiscLocalization({
	MakeitCountTimer	= "分秒必争"
})

--------------------
--  Utgarde Keep  --
-----------------------
--  Prince Keleseth  --
-----------------------
L = DBM:GetModLocalization(638)

L:SetGeneralLocalization{
	name 		= "凯雷塞斯王子"
}

--------------------------------
--  Skarvald the Constructor  --
--  & Dalronn the Controller  --
--------------------------------
L = DBM:GetModLocalization(639)

L:SetGeneralLocalization{
	name 		= "控制者达尔隆"
}

----------------------------
--  Ingvar the Plunderer  --
----------------------------
L = DBM:GetModLocalization(640)

L:SetGeneralLocalization{
	name 		= "掠夺者因格瓦尔"
}

L:SetMiscLocalization({
	YellCombatEnd	= "不！不！我还可以……做得更好。"
})

------------------------
--  Utgarde Pinnacle  --
--------------------------
--  Skadi the Ruthless  --
--------------------------
L = DBM:GetModLocalization(643)

L:SetGeneralLocalization{
	name 		= "残忍的斯卡迪"
}

L:SetMiscLocalization({
	CombatStart		= "什么样的狗杂种竟然胆敢入侵这里？快点，弟兄们！谁要是能把他们的头提来，就赏他吃肉！",
	Phase2			= "你这只无能的蠢龙！你的尸体干脆给我的新飞龙拿去当点心算了！"
})

-------------------
--  King Ymiron  --
-------------------
L = DBM:GetModLocalization(644)

L:SetGeneralLocalization{
	name 		= "伊米隆国王"
}

-------------------------
--  Svala Sorrowgrave  --
-------------------------
L = DBM:GetModLocalization(641)

L:SetGeneralLocalization{
	name 		= "席瓦拉·索格蕾"
}

L:SetTimerLocalization({
	timerRoleplay		= "席瓦拉·索格蕾 开始攻击"
})

L:SetOptionLocalization({
	timerRoleplay		= "为席瓦拉·索格蕾开始攻击前的角色扮演显示计时条"
})

L:SetMiscLocalization({
	SvalaRoleplayStart	= "尊敬的陛下！我已经完成您的全部要求，希望您能不吝赐下伟大的祝福！"
})

-----------------------
--  Gortok Palehoof  --
-----------------------
L = DBM:GetModLocalization(642)

L:SetGeneralLocalization{
	name 		= "戈托克·苍蹄"
}

-----------------------
--  The Violet Hold  --
-----------------------
--  Cyanigosa  --
-----------------
L = DBM:GetModLocalization(632)

L:SetGeneralLocalization{
	name 		= "塞安妮苟萨"
}

L:SetMiscLocalization({
	CyanArrived	= "真是一群英勇的卫兵，但这座城市必须被夷平。我要亲自执行玛里苟斯大人的指令！"
})

--------------
--  Erekem  --
--------------
L = DBM:GetModLocalization(626)

L:SetGeneralLocalization{
	name 		= "埃雷克姆"
}

---------------
--  Ichoron  --
---------------
L = DBM:GetModLocalization(628)

L:SetGeneralLocalization{
	name 		= "艾库隆"
}

-----------------
--  Lavanthor  --
-----------------
L = DBM:GetModLocalization(630)

L:SetGeneralLocalization{
	name 		= "拉文索尔"
}

--------------
--  Moragg  --
--------------
L = DBM:GetModLocalization(627)

L:SetGeneralLocalization{
	name 		= "摩拉格"
}

--------------
--  Xevozz  --
--------------
L = DBM:GetModLocalization(629)

L:SetGeneralLocalization{
	name 		= "谢沃兹"
}

-------------------------------
--  Zuramat the Obliterator  --
-------------------------------
L = DBM:GetModLocalization(631)

L:SetGeneralLocalization{
	name 		= "湮灭者祖拉玛特"
}

---------------------
--  Portal Timers  --
---------------------
L = DBM:GetModLocalization("PortalTimers")

L:SetGeneralLocalization({
	name = "传送门计时"
})

L:SetWarningLocalization({
	WarningPortalSoon	= "新传送门即将开启",
	WarningPortalNow	= "传送门 #%d",
	WarningBossNow		= "首领到来"
})

L:SetTimerLocalization({
	TimerPortalIn	= "传送门 #%d"
})

L:SetOptionLocalization({
	WarningPortalNow		= optionWarning:format("新传送门"),
	WarningPortalSoon		= optionPreWarning:format("新传送门"),
	WarningBossNow			= optionWarning:format("首领到来"),
	TimerPortalIn			= "为下一次 传送门显示计时条(击败首领后)",
	ShowAllPortalTimers		= "为所有传送门显示计时条(不准确)"
})

L:SetMiscLocalization({
	Sealbroken	= "我们冲破了监狱的大门！进入达拉然的道路被清理干净了！魔枢之战终于可以结束了！",
	WavePortal	= "已打开传送门：(%d+)/18"
})

-----------------------------
--  Trial of the Champion  --
-----------------------------
--  The Black Knight  --
------------------------
L = DBM:GetModLocalization(637)

L:SetGeneralLocalization{
	name 		= "黑骑士"
}

L:SetOptionLocalization({
	AchievementCheck		= "报告'这还不算惨'成就的失败信息给小队"
})

L:SetMiscLocalization({
	Pull			= "干得好，今天，你证明了自己的实力。",
	AchievementFailed	= ">> 成就失败: %s 被食尸鬼爆炸击中了 <<",
	YellCombatEnd	= "勇士们，祝贺你们！经历过一系列计划之中和意料之外的试炼，你们终于取得了胜利。"	-- can also be "No! I must not fail... again ..."
})

-----------------------
--  Grand Champions  --
-----------------------
L = DBM:GetModLocalization(634)

L:SetGeneralLocalization{
	name 		= "总冠军"
}

L:SetMiscLocalization({
	YellCombatEnd	= "干得漂亮！你的下一个挑战将来自于十字军的骑士们。他们将以强大的实力对你进行测试。"
})

----------------------------------
--  Argent Confessor Paletress  --
----------------------------------
L = DBM:GetModLocalization(636)

L:SetGeneralLocalization{
	name 		= "银色神官帕尔崔丝"
}

L:SetMiscLocalization({
	YellCombatEnd	= "真是精彩！"
})

-----------------------
--  Eadric the Pure  --
-----------------------
L = DBM:GetModLocalization(635)

L:SetGeneralLocalization{
	name 		= "纯洁者耶德瑞克"
}

L:SetMiscLocalization({
	YellCombatEnd	= "我认输！我投降。你做的很好。我可以走了吧？"
})

--------------------
--  Pit of Saron  --
---------------------
--  Ick and Krick  --
---------------------
L = DBM:GetModLocalization(609)

L:SetGeneralLocalization{
	name 		= "伊克和科瑞克"
}

L:SetMiscLocalization({
	Barrage	= "%s 开始迅速地召唤爆裂地雷!"
})
----------------------------
--  Forgemaster Garfrost  --
----------------------------
L = DBM:GetModLocalization(608)

L:SetGeneralLocalization{
	name 		= "熔炉之主加弗斯特"
}

L:SetOptionLocalization({
	AchievementCheck			= "为'11大限'成就发送报警到队伍频道"
})

L:SetMiscLocalization({
	SaroniteRockThrow	= "%s 向你用力投出一大块萨隆邪铁巨石！",
	AchievementWarning	= "小心: %s 已拥有 %d 层永冻",
	AchievementFailed	= ">> 成就失败: %s 已超过 %d 层永冻 <<"
})

----------------------------
--  Scourgelord Tyrannus  --
----------------------------
L = DBM:GetModLocalization(610)

L:SetGeneralLocalization{
	name 		= "天灾领主泰兰努斯"
}

L:SetMiscLocalization({
	CombatStart	= "唉，勇敢的冒险者，你们的路已经到头了。难道你们没有听到身后隧道里钢铁撞击的声音吗？那就是末日降临的乐章。",
	HoarfrostTarget	= "冰霜巨龙霜牙凝视着(%S+)，准备发动一次冰霜袭击！",
	YellCombatEnd	= "不可能……霜牙……警报……"
})

----------------------
--  Forge of Souls  --
----------------------
--  Bronjahm  --
----------------
L = DBM:GetModLocalization(615)

L:SetGeneralLocalization{
	name 		= "布隆亚姆"
}

-------------------------
--  Devourer of Souls  --
-------------------------
L = DBM:GetModLocalization(616)

L:SetGeneralLocalization{
	name 		= "噬魂者"
}

L:SetWarningLocalization({
	specwarnMirroredSoul	= "停止攻击",
	specwarnWailingSouls	= "哀嚎之魂 - 快躲到boss背后"
})

L:SetOptionLocalization({
	specwarnMirroredSoul	= "为$spell:69051需要停止攻击时显示特别警告",
	specwarnWailingSouls	= "当$spell:68899施放时显示特别警告"
})


---------------------------
--  Halls of Reflection  --
---------------------------
--  Wave Timers  --
-------------------
L = DBM:GetModLocalization("HoRWaveTimer")

L:SetGeneralLocalization({
	name = "波数计时"
})

L:SetWarningLocalization({
	WarnNewWaveSoon	= "新一波 即将到来",
	WarnNewWave		= "%s 到来"
})

L:SetTimerLocalization({
	TimerNextWave	= "下一波"
})

L:SetOptionLocalization({
	WarnNewWave			= "当首领到来时显示警告",
	WarnNewWaveSoon		= "为新一波显示预先警告(击败首领后)",
	ShowAllWaveWarnings	= "为所有波数显示警告",
	TimerNextWave		= "为下一波显示计时条(击败首领后)",
	ShowAllWaveTimers	= "为所有波数显示计时及预先警告(不精确)"
})

L:SetMiscLocalization({
	WaveCheck	= "灵魂波次 = (%d+)/10"
})

--------------
--  Falric  --
--------------
L = DBM:GetModLocalization(601)

L:SetGeneralLocalization{
	name 		= "法瑞克"
}

--------------
--  Marwyn  --
--------------
L = DBM:GetModLocalization(602)

L:SetGeneralLocalization{
	name 		= "玛维恩"
}

-----------------------
--  Lich King Event  --
-----------------------
L = DBM:GetModLocalization(603)

L:SetGeneralLocalization{
	name 		= "逃离巫妖王事件"
}

L:SetWarningLocalization({
	WarnWave		= "%s"
})

L:SetTimerLocalization({
	achievementEscape	= "Time to escape"
})

L:SetOptionLocalization({
	WarnWave	= "为下一波 即将到来显示警告"
})

L:SetMiscLocalization({
	ACombatStart	= "太强大了。我们必须马上离开！我的魔法只能暂时拖住他。快来，英雄们！",
	HCombatStart	= "他……太强大了。英雄们，快，快过来！我们必须马上离开！你们先走。我会尽全力挡住他。",
	Ghoul			= "狂怒食尸鬼",
	Doctor			= "复活的巫医",
	Abom			= "笨拙憎恶体"
})
