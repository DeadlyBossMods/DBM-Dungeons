if GetLocale() ~= "ruRU" then return end

local L

-----------------------
-- <<<Temple of the Jade Serpent>>> --
-----------------------
-----------------------
-- Wise Mari --
-----------------------
L= DBM:GetModLocalization(672)

-----------------------
-- Lorewalker Stonestep --
-----------------------
L= DBM:GetModLocalization(664)

L:SetWarningLocalization({
	SpecWarnIntensity	= "%s на %s (%d)"
})

L:SetOptionLocalization({
	SpecWarnIntensity2	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.switch:format(113315)
})

L:SetMiscLocalization({
	Event1	= "Ах, это еще не конец. Насколько я могу судить, сейчас мы увидим испытание яунгола. Слушайте...",
	Event2	= "Но что я вижу? Насколько я могу судить, перед нами ожила история Цзао!"
})

-----------------------
-- Liu Flameheart --
-----------------------
L= DBM:GetModLocalization(658)

-----------------------
-- Sha of Doubt --
-----------------------
L= DBM:GetModLocalization(335)

-------------
--  Temple of the Jade Serpent Trash  --
-------------
L = DBM:GetModLocalization("JadeTempleTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Храма Нефритовой Змеи"
})

-----------------------
-- <<<Stormstout Brewery>>> --
-----------------------
-----------------------
-- Ook-Ook --
-----------------------
L= DBM:GetModLocalization(668)

-----------------------
-- Hoptallus --
-----------------------
L= DBM:GetModLocalization(669)

-----------------------
-- Yan Zhu the Uncasked --
-----------------------
L= DBM:GetModLocalization(670)

L:SetWarningLocalization({
	SpecWarnFizzyBubbles	= "Возьмите пузырек и взлетайте"
})

L:SetOptionLocalization({
	SpecWarnFizzyBubbles	= "Спецпредупреждение, когда на Вас нет $spell:114459",
	RangeFrame				= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 106546)
})

-----------------------
-- <<<Shado-Pan Monastery>>> --
-----------------------
-----------------------
-- Gu Cloudstrike --
-----------------------
L= DBM:GetModLocalization(673)

L:SetWarningLocalization({
	warnStaticField	= "%s"
})

L:SetOptionLocalization({
	warnStaticField	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(106923)
})

-----------------------
-- Snowdrift --
-----------------------
L= DBM:GetModLocalization(657)

L:SetWarningLocalization({
	warnRemainingNovice	= "Осталось учеников: %d"
})

L:SetOptionLocalization({
	warnRemainingNovice	= "Показывать количество оставшихся учеников"
})

L:SetMiscLocalization({
	NovicesPulled	= "Это ваша вина! Вы позволили Ша пробудиться после стольких лет!",
	NovicesDefeated = "Вы победили новичков. Теперь вы сразитесь с двумя моими самыми опытными учениками.",
--	Defeat			= "I am bested.  Give me a moment and we will venture forth together to face the Sha."
})

-----------------------
-- Sha of Violence --
-----------------------
L= DBM:GetModLocalization(685)

L:SetMiscLocalization({
	Kill		= "Пока в ваших сердцах есть место жестокости... я могу вернуться..."
})

-----------------------
-- Taran Zhu --
-----------------------
L= DBM:GetModLocalization(686)

L:SetOptionLocalization({
	InfoFrame			= "Показывать информационное окно для $journal:5827"
})

-----------------------
-- <<<The Gate of the Setting Sun>>> --
-----------------------
---------------------
-- Kiptilak --
---------------------
L= DBM:GetModLocalization(655)

L:SetOptionLocalization({
	IconOnSabotage	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(107268)
})

-------------
-- Gadok --
-------------
L= DBM:GetModLocalization(675)

L:SetMiscLocalization({
	StaffingRun		= "Боец Га'док заходит на атаку с бреющего полета!"
})

-----------------------
-- Rimok --
-----------------------
L= DBM:GetModLocalization(676)

-----------------------------
-- Raigonn --
-----------------------------
L= DBM:GetModLocalization(649)

-----------------------
-- <<<Mogu'Shan Palace>>> --
-----------------------
-----------------------
-- Trial of Kings --
-----------------------
L= DBM:GetModLocalization(708)

L:SetMiscLocalization({
	Pull		= "Вы бесполезны! Даже ваша охрана не может преградить этим тварям дорогу в мой дворец.",
	Defeat		= "Кто пропустил этих чужаков? На такое вероломство способны только кланы Каргеш и Хартак!"
})

-----------------------
-- Gekkan --
-----------------------
L= DBM:GetModLocalization(690)

-----------------------
-- Weaponmaster Xin --
-----------------------
L= DBM:GetModLocalization(698)

-----------------------
-- <<<Siege of Niuzao Temple>>> --
-----------------------
-----------------------
-- Jinbak --
-----------------------
L= DBM:GetModLocalization(693)

-----------------------
-- Vo'jak --
-----------------------
L= DBM:GetModLocalization(738)

L:SetTimerLocalization({
	TimerWave	= "Подкрепления: %s"
})

L:SetOptionLocalization({
	TimerWave	= "Отсчёт времени до следующей волны подкреплений"
})

L:SetMiscLocalization({
	WaveStart	= "Глупцы! Вы смеете противостоять армии богомолов? Вы быстро умрете!"
})

-----------------------
-- Pavalak --
-----------------------
L= DBM:GetModLocalization(692)

-----------------------
-- Neronok --
-----------------------
L= DBM:GetModLocalization(727)

-----------------------
-- <<<Scholomance>>> --
-----------------------
-----------------------
-- Instructor Chillheart --
-----------------------
L= DBM:GetModLocalization(659)

-----------------------
-- Jandice Barov --
-----------------------
L= DBM:GetModLocalization(663)

-----------------------
-- Rattlegore --
-----------------------
L= DBM:GetModLocalization(665)

L:SetWarningLocalization({
	SpecWarnGetBoned	= "Возьмите костяной доспех",
	SpecWarnDoctor		= "А вот и доктор!"
})

L:SetOptionLocalization({
	SpecWarnGetBoned	= "Спецпредупреждение, когда на Вас нет $spell:113996",
	SpecWarnDoctor		= "Спецпредупреждение, когда появляется Доктор Теолен Крастинов",
	InfoFrame			= "Показывать информационное окно для игроков без $spell:113996"
})

L:SetMiscLocalization({
	PlayerDebuffs	= "Нет костяного доспеха",
	TheolenSpawn	= "А вот и доктор!"
})

-----------------------
-- Lillian Voss --
-----------------------
L= DBM:GetModLocalization(666)

L:SetMiscLocalization({
	Kill	= "УМРИ, НЕКРОМАНТ!"
})

-----------------------
-- Darkmaster Gandling --
-----------------------
L= DBM:GetModLocalization(684)

-----------------------
-- <<<Scarlet Halls>>> --
-----------------------
-----------------------
-- Braun --
-----------------------
L= DBM:GetModLocalization(660)

-----------------------
-- Harlan --
-----------------------
L= DBM:GetModLocalization(654)

-----------------------
-- Flameweaver Koegler --
-----------------------
L= DBM:GetModLocalization(656)

-----------------------
-- <<<Scarlet Cathedral>>> --
-----------------------
-----------------------
-- Thalnos Soulrender --
-----------------------
L= DBM:GetModLocalization(688)

-----------------------
-- Korlof --
-----------------------
L= DBM:GetModLocalization(671)

-----------------------
-- Durand/High Inquisitor Whitemane --
-----------------------
L= DBM:GetModLocalization(674)
