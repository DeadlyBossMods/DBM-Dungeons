-- 泰坦重铸时光服-时光2-法师-旺仔芒果/椰奶冻-2026.11.13--
if GetLocale() ~= "zhCN" then return end
local L

-------------------------
--  Hellfire Ramparts  --
-----------------------------
--  Watchkeeper Gargolmar  --
-----------------------------
L = DBM:GetModLocalization(527)

L:SetGeneralLocalization{
	name = "巡视者加戈玛"
}

--------------------------
--  Omor the Unscarred  --
--------------------------
L = DBM:GetModLocalization(528)

L:SetGeneralLocalization{
	name = "无疤者奥摩尔"
}

------------------------
--  Nazan & Vazruden  --
------------------------
L = DBM:GetModLocalization(529)

L:SetGeneralLocalization{
	name = "纳赞与瓦兹德"
}

-------------------------
--  The Blood Furnace  --
-------------------------
--  The Maker  --
-----------------
L = DBM:GetModLocalization(555)

L:SetGeneralLocalization{
	name = "制造者"
}

---------------
--  Broggok  --
---------------
L = DBM:GetModLocalization(556)

L:SetGeneralLocalization{
	name = "布洛戈克"
}

----------------------------
--  Keli'dan the Breaker  --
----------------------------
L = DBM:GetModLocalization(557)

L:SetGeneralLocalization{
	name = "击碎者克里丹"
}

---------------------------
--  The Shattered Halls  --
--------------------------------
--  Grand Warlock Nethekurse  --
--------------------------------
L = DBM:GetModLocalization(566)

L:SetGeneralLocalization{
	name = "高阶术士奈瑟库斯"
}

--------------------------
--  Blood Guard Porung  --
--------------------------
L = DBM:GetModLocalization(728)

L:SetGeneralLocalization{
	name = "血警卫普罗恩"
}

--------------------------
--  Warbringer O'mrogg  --
--------------------------
L = DBM:GetModLocalization(568)

L:SetGeneralLocalization{
	name = "战争使者沃姆罗格"
}

----------------------------------
--  Warchief Kargath Bladefist  --
----------------------------------
L = DBM:GetModLocalization(569)

L:SetGeneralLocalization{
	name = "酋长卡加斯·刃拳"
}

L:SetWarningLocalization({
	warnHeathen			= "异教徒守卫：%s",
	warnReaver			= "掠夺者守卫：%s",
	warnSharpShooter	= "神射手守卫：%s"
})

L:SetTimerLocalization({
	timerHeathen		= "异教徒守卫",
	timerReaver			= "掠夺者守卫",
	timerSharpShooter	= "神射手守卫"
})

L:SetOptionLocalization({
	warnHeathen			= "显示异教徒守卫的警告",
	timerHeathen		= "显示异教徒守卫的计时器",
	warnReaver			= "显示掠夺者守卫的警告",
	timerReaver			= "显示掠夺者守卫的计时器",
	warnSharpShooter	= "显示神射手守卫的警告",
	timerSharpShooter	= "显示神射手守卫的计时器"
})

------------------
--  Slave Pens  --
--------------------------
--  Mennu the Betrayer  --
--------------------------
L = DBM:GetModLocalization(570)

L:SetGeneralLocalization{
	name = "背叛者门努"
}

---------------------------
--  Rokmar the Crackler  --
---------------------------
L = DBM:GetModLocalization(571)

L:SetGeneralLocalization{
	name = "巨钳鲁克玛尔"
}

------------------
--  Quagmirran  --
------------------
L = DBM:GetModLocalization(572)

L:SetGeneralLocalization{
	name = "夸格米拉"
}

--------------------
--  The Underbog  --
--------------------
--  Hungarfen  --
-----------------
L = DBM:GetModLocalization(576)

L:SetGeneralLocalization{
	name = "霍加尔芬"
}

---------------
--  Ghaz'an  --
---------------
L = DBM:GetModLocalization(577)

L:SetGeneralLocalization{
	name = "加兹安"
}

--------------------------
--  Swamplord Musel'ek  --
--------------------------
L = DBM:GetModLocalization(578)

L:SetGeneralLocalization{
	name = "沼地领主穆塞雷克"
}

-------------------------
--  The Black Stalker  --
-------------------------
L = DBM:GetModLocalization(579)

L:SetGeneralLocalization{
	name = "黑色阔步者"
}

----------------------
--  The Steamvault  --
---------------------------
--  Hydromancer Thespia  --
---------------------------
L = DBM:GetModLocalization(573)

L:SetGeneralLocalization{
	name = "水术师瑟丝比娅"
}

-----------------------------
--  Mekgineer Steamrigger  --
-----------------------------
L = DBM:GetModLocalization(574)

L:SetGeneralLocalization{
	name = "机械师斯蒂里格"
}

L:SetWarningLocalization({
	warnSummon	= "斯蒂里格机械师 - 转换目标"
})

L:SetOptionLocalization({
	warnSummon	= "显示斯蒂里格机械师的警告"
})

L:SetMiscLocalization({
	Mechs	= "好好的修理它们，孩子们!"
})

--------------------------
--  Warlord Kalithresh  --
--------------------------
L = DBM:GetModLocalization(575)

L:SetGeneralLocalization{
	name = "督军卡利瑟里斯"
}

-----------------------
--  Auchenai Crypts  --
--------------------------------
--  Shirrak the Dead Watcher  --
--------------------------------
L = DBM:GetModLocalization(523)

L:SetGeneralLocalization{
	name = "死亡观察者希尔拉克"
}

-----------------------
--  Exarch Maladaar  --
-----------------------
L = DBM:GetModLocalization(524)

L:SetGeneralLocalization{
	name = "大主教玛拉达尔"
}

------------------
--  Mana-Tombs  --
------------------
--    Trash     --
------------------
L = DBM:GetModLocalization("AuctTombsTrash")

L:SetGeneralLocalization{
	name = "法力陵墓小怪"
}

-------------------
--  Pandemonius  --
-------------------
L = DBM:GetModLocalization(534)

L:SetGeneralLocalization{
	name = "潘德莫努斯"
}

---------------
--  Tavarok  --
---------------
L = DBM:GetModLocalization(535)

L:SetGeneralLocalization{
	name = "塔瓦洛克"
}

----------------------------
--  Nexus-Prince Shaffar  --
----------------------------
L = DBM:GetModLocalization(537)

L:SetGeneralLocalization{
	name = "节点亲王沙法尔"
}

-----------
--  Yor  --
-----------
L = DBM:GetModLocalization(536)

L:SetGeneralLocalization{
	name = "尤尔"
}

---------------------
--  Sethekk Halls  --
-----------------------
--  Darkweaver Syth  --
-----------------------
L = DBM:GetModLocalization(541)

L:SetGeneralLocalization{
	name = "黑暗编织者塞斯"
}

L:SetWarningLocalization({
	warnSummon	= "召唤元素"
})

L:SetOptionLocalization({
	warnSummon	= "显示召唤元素的警告"
})

------------
--  Anzu  --
------------
L = DBM:GetModLocalization(542)

L:SetGeneralLocalization{
	name = "安苏"
}

L:SetWarningLocalization({
	warnBrood	= "安苏的子嗣",
	warnStoned	= "%s 变回了石头"
})

L:SetOptionLocalization({
	warnBrood	= "显示安苏的子嗣的警告",
	warnStoned	= "显示灵魂变回石头的警告"
})

L:SetMiscLocalization({
	BirdStone	= "%s 变回了石头。"
})

------------------------
--  Talon King Ikiss  --
------------------------
L = DBM:GetModLocalization(543)

L:SetGeneralLocalization{
	name = "利爪之王艾吉斯"
}

------------------------
--  Shadow Labyrinth  --
--------------------------
--  Ambassador Hellmaw  --
--------------------------
L = DBM:GetModLocalization(544)

L:SetGeneralLocalization{
	name = "赫尔默大使"
}

------------------------------
--  Blackheart the Inciter  --
------------------------------
L = DBM:GetModLocalization(545)

L:SetGeneralLocalization{
	name = "煽动者布莱卡特"
}

--------------------------
--  Grandmaster Vorpil  --
--------------------------
L = DBM:GetModLocalization(546)

L:SetGeneralLocalization{
	name = "沃匹尔大师"
}

--------------
--  Murmur  --
--------------
L = DBM:GetModLocalization(547)

L:SetGeneralLocalization{
	name = "摩摩尔"
}

-------------------------------
--  Old Hillsbrad Foothills  --
-------------------------------
--  Lieutenant Drake  --
------------------------
L = DBM:GetModLocalization(538)

L:SetGeneralLocalization{
	name = "德拉克中尉"
}

-----------------------
--  Captain Skarloc  --
-----------------------
L = DBM:GetModLocalization(539)

L:SetGeneralLocalization{
	name = "斯卡洛克上尉"
}

--------------------
--  Epoch Hunter  --
--------------------
L = DBM:GetModLocalization(540)

L:SetGeneralLocalization{
	name = "时空猎手"
}

------------------------
--  The Black Morass  --
------------------------
--  Chrono Lord Deja  --
------------------------
L = DBM:GetModLocalization(552)

L:SetGeneralLocalization{
	name = "时空领主德亚"
}

----------------
--  Temporus  --
----------------
L = DBM:GetModLocalization(553)

L:SetGeneralLocalization{
	name = "坦普卢斯"
}

--------------
--  Aeonus  --
--------------
L = DBM:GetModLocalization(554)

L:SetGeneralLocalization{
	name = "埃欧努斯"
}

L:SetMiscLocalization({
	AeonusFrenzy	= "%s被激怒了!"
})

---------------------
--  Portal Timers  --
---------------------
L = DBM:GetModLocalization("PT")

L:SetGeneralLocalization({
	name = "时间裂隙"
})

L:SetWarningLocalization({
	WarnWavePortalSoon	= "新的时间裂隙即将到来",
	WarnWavePortal		= "第%d个时间裂隙",
	WarnBossPortal		= "首领到来"
})

L:SetTimerLocalization({
	TimerNextPortal		= "第%d个时间裂隙"
})

L:SetOptionLocalization({
	WarnWavePortalSoon	= "为新的时间裂隙显示预先警告",
	WarnWavePortal		= "为新的时间裂隙显示警告",
	WarnBossPortal		= "为首领到来显示警告",
	TimerNextPortal		= "为下一次时间裂隙显示计时器(击败首领后)",
	ShowAllPortalTimers	= "为所有时间裂隙显示计时器(不准确)"
})

L:SetMiscLocalization({
	PortalCheck			= "时间裂隙开启:(%d+)/18",
	Shielddown			= "这个该死的躯体既虚弱又平凡!"
})

--------------------
--  The Mechanar  --
-----------------------------
--  Gatewatcher Gyro-Kill  --
-----------------------------
L = DBM:GetModLocalization("Gyrokill")--Not in EJ

L:SetGeneralLocalization({
	name = "看守者盖罗基尔"
})

-----------------------------
--  Gatewatcher Iron-Hand  --
-----------------------------
L = DBM:GetModLocalization("Ironhand")--Not in EJ

L:SetGeneralLocalization({
	name = "看守者铁手"
})

L:SetMiscLocalization({
	JackHammer	= "%s威吓地举起他的锤子..."
})

------------------------------
--  Mechano-Lord Capacitus  --
------------------------------
L = DBM:GetModLocalization(563)

L:SetGeneralLocalization{
	name = "机械领主卡帕西图斯"
}

------------------------------
--  Nethermancer Sepethrea  --
------------------------------
L = DBM:GetModLocalization(564)

L:SetGeneralLocalization{
	name = "灵术师塞比瑟蕾"
}

--------------------------------
--  Pathaleon the Calculator  --
--------------------------------
L = DBM:GetModLocalization(565)

L:SetGeneralLocalization{
	name = "计算者帕萨雷恩"
}

--------------------
--  The Botanica  --
--------------------------
--  Commander Sarannis  --
--------------------------
L = DBM:GetModLocalization(558)

L:SetGeneralLocalization{
	name = "指挥官萨拉妮丝"
}

------------------------------
--  High Botanist Freywinn  --
------------------------------
L = DBM:GetModLocalization(559)

L:SetGeneralLocalization{
	name = "高级植物学家弗雷温"
}

-----------------------------
--  Thorngrin the Tender  --
-----------------------------
L = DBM:GetModLocalization(560)

L:SetGeneralLocalization{
	name = "看管者索恩格林"
}

-----------
--  Laj  --
-----------
L = DBM:GetModLocalization(561)

L:SetGeneralLocalization{
	name = "拉伊"
}

---------------------
--  Warp Splinter  --
---------------------
L = DBM:GetModLocalization(562)

L:SetGeneralLocalization{
	name = "迁跃扭木"
}

--------------------
--  The Arcatraz  --
----------------------------
--  Zereketh the Unbound  --
----------------------------
L = DBM:GetModLocalization(548)

L:SetGeneralLocalization{
	name = "自由的瑟雷凯斯"
}

-----------------------------
--  Dalliah the Doomsayer  --
-----------------------------
L = DBM:GetModLocalization(549)

L:SetGeneralLocalization{
	name = "末日预言者达尔莉安"
}

---------------------------------
--  Wrath-Scryer Soccothrates  --
---------------------------------
L = DBM:GetModLocalization(550)

L:SetGeneralLocalization{
	name = "天怒预言者苏克拉底"
}

-------------------------
--  Harbinger Skyriss  --
-------------------------
L = DBM:GetModLocalization(551)

L:SetGeneralLocalization{
	name = "预言者斯克瑞斯"
}

L:SetWarningLocalization({
	warnSplitSoon	= "预言者幻象即将到来",
	warnSplit		= "预言者幻象"
})

L:SetOptionLocalization({
	warnSplitSoon	= "显示预言者幻象即将到来的警告",
	warnSplit		= "显示预言者幻象的警告"
})

L:SetMiscLocalization({
	Split	= "我们跨越宇宙之间，被我们摧毁的世界像星星一样数不尽!"
})

--------------------------
--  Magisters' Terrace  --
--------------------------
--  Selin Fireheart  --
-----------------------
L = DBM:GetModLocalization(530)

L:SetGeneralLocalization{
	name = "塞林·火心"
}

L:SetWarningLocalization({
	warningFelCrystal	= "邪能水晶 - 转换目标"
})

L:SetTimerLocalization({
	timerFelCrystal		= "~邪能水晶"
})

L:SetOptionLocalization({
	warningFelCrystal	= "显示邪能水晶转换目标的特殊警告",
	timerFelCrystal		= "显示邪能水晶的计时器"
})

----------------
--  Vexallus  --
----------------
L = DBM:GetModLocalization(531)

L:SetGeneralLocalization{
	name = "维萨鲁斯"
}

L:SetWarningLocalization({
	warnEnergy	= "纯粹能量 - 转换目标"
})

L:SetOptionLocalization({
	warnEnergy	= "显示纯粹能量的警告"
})

--------------------------
--  Priestess Delrissa  --
--------------------------
L = DBM:GetModLocalization(532)

L:SetGeneralLocalization{
	name = "女祭司德莉希亚"
}

L:SetMiscLocalization({
	DelrissaPull	= "消灭他们。",
	DelrissaEnd		= "跟我计划的...不一样。"
})

------------------------------------
--  Kael'thas Sunstrider (Party)  --
------------------------------------
L = DBM:GetModLocalization(533)

L:SetGeneralLocalization{
	name = "凯尔萨斯·逐日者（5人本）"
}

L:SetMiscLocalization({
	KaelP2	= "我要让你们的世界彻底颠覆。"
})
