if GetLocale() ~= "koKR" then return end
local L

------------
--  Omen  --
------------
L = DBM:GetModLocalization("Omen")

L:SetGeneralLocalization({
	name = "오멘"
})

------------------------------
--  The Crown Chemical Co.  --
------------------------------
L = DBM:GetModLocalization("d288")

L:SetTimerLocalization{
	HummelActive	= "훔멜 활성화",
	BaxterActive	= "벡스터 활성화",
	FryeActive		= "프라이 활성화"
}

L:SetOptionLocalization({
	TrioActiveTimer		= "연금술사 삼인방 활성화 타이머 바 보기"
})

L:SetMiscLocalization({
	SayCombatStart		= "저들이 내가 누군지와 왜 이 일을 하는지 말해주려고 귀찮게 하든가?"
})

----------------------------
--  The Frost Lord Ahune  --
----------------------------
L = DBM:GetModLocalization("d286")

L:SetWarningLocalization({
	Emerged			= "등장",
	specWarnAttack	= "아훈 약화 - 공격 시작!"
})

L:SetTimerLocalization{
	SubmergeTimer	= "잠복",
	EmergeTimer		= "등장"
}

L:SetOptionLocalization({
	Emerged			= "등장 경고 보기",
	specWarnAttack	= "아훈 약화 특별 경고 보기",
	SubmergeTimer	= "잠복 타이머 바 보기",
	EmergeTimer		= "등장 타이머 바 보기"
})

L:SetMiscLocalization({
	Pull			= "얼음 기둥이 녹아 내렸다!"
})

--------------------
-- Coren Direbrew --
--------------------
L = DBM:GetModLocalization("d287")

L:SetWarningLocalization({
	specWarnBrew		= "다른 맥주가 넘어오기 전에 가방에 있는 맥주를 사용하세요!",
	specWarnBrewStun	= "힌트: 기절했습니다. 다음엔 맥주를 꼭 마시세요!"
})

L:SetOptionLocalization({
	specWarnBrew		= "$spell:47376 특별 경고 보기",
	specWarnBrewStun	= "$spell:47340 특별 경고 보기"
})

L:SetMiscLocalization{
	YellBarrel			= "나에게 맥주통!"
}

----------------
--  Brewfest  --
----------------
L = DBM:GetModLocalization("Brew")

L:SetGeneralLocalization({
	name = "가을 축제"
})

L:SetOptionLocalization({
	NormalizeVolume			= "가을 축제 지역에선 자동으로 대화 음량이 배경음 음량에 맞게 평준화되어 소음을 해소합니다. (배경음이 설정되지 않았을 경우 대화 음량은 음소거 됩니다.)"
})

-----------------------------
--  The Headless Horseman  --
-----------------------------
L = DBM:GetModLocalization("d285")

L:SetWarningLocalization({
	WarnPhase				= "%d단계",
	warnHorsemanSoldiers	= "고동치는 호박 생성",
	warnHorsemanHead		= "저주받은 기사의 머리 등장"
})

L:SetOptionLocalization({
	WarnPhase				= "단계 전환 경고 보기",
	warnHorsemanSoldiers	= "고동치는 호박 등장 경고 보기",
	warnHorsemanHead		= "저주받은 기사 머리 등장 경고 보기"
})

L:SetMiscLocalization({
	HorsemanSummon		= "기사여, 일어나라...",
	HorsemanSoldiers	= "일어나라, 병사들이여. 나가서 싸워라! 이 쇠락한 기사에게 승리를 안겨다오!"
})

------------------------------
--  The Abominable Greench  --
------------------------------
L = DBM:GetModLocalization("Greench")

L:SetGeneralLocalization({
	name = "썩은내 그린치"
})

--------------------------
--  Plants Vs. Zombies  --
--------------------------
L = DBM:GetModLocalization("PlantsVsZombies")

L:SetGeneralLocalization({
	name = "평온초 대 구울"
})

L:SetWarningLocalization({
	warnTotalAdds	= "총공격 전까지 생성된 적 수: %d",
	specWarnWave	= "총공격!"
})

L:SetTimerLocalization{
	timerWave		= "다음 총공격"
}

L:SetOptionLocalization({
	warnTotalAdds	= "각 총공격마다 이전 단계에 생성된 적 수 보기",
	specWarnWave	= "총공격 특별 경고 보기",
	timerWave		= "다음 총공격 타이머 바 보기"
})

L:SetMiscLocalization({
	MassiveWave		= "좀비의 총공격이 시작됐습니다!"
})

-- Quest
L = DBM:GetModLocalization("EscortQuests")

L:SetGeneralLocalization{
	name = "퀘스트",
}

L:SetOptionLocalization{
	Timers = "몇가지 호위 퀘스트의 타이머 바 보기"
}


--------------------------
--  Demonic Invasions  --
--------------------------
L = DBM:GetModLocalization("DemonInvasions")

L:SetGeneralLocalization({
	name = "악마 침공"
})

--------------------------
--  Memories of Azeroth: Burning Crusade  --
--------------------------
L = DBM:GetModLocalization("BCEvent")

L:SetGeneralLocalization({
	name = "추억: 불타는 성전"
})

--------------------------
--  Memories of Azeroth: Wrath of the Lich King  --
--------------------------
L = DBM:GetModLocalization("WrathEvent")

L:SetGeneralLocalization({
	name = "추억: 리치 왕의 분노"
})

L:SetWarningLocalization{
	WarnEmerge				= "아눕아락 등장",
	WarnEmergeSoon			= "10초 후 등장",
	WarnSubmerge			= "아눕아락 잠복",
	WarnSubmergeSoon		= "10초 후 잠복",
	WarningTeleportNow		= "순간이동",
	WarningTeleportSoon		= "10초 후 순간이동"
}

L:SetTimerLocalization{
	TimerEmerge				= "등장",
	TimerSubmerge			= "잠복",
	TimerTeleport			= "순간이동"
}

L:SetMiscLocalization{
	Emerge					= "땅속에서 모습을 드러냅니다!",
	Burrow					= "땅속으로 숨어버립니다!"
}

L:SetOptionLocalization{
	WarnEmerge				= "등장 경고 보기",
	WarnEmergeSoon			= "등장 사전 경고 보기",
	WarnSubmerge			= "잠복 경고 보기",
	WarnSubmergeSoon		= "잠복 사전 경고 보기",
	TimerEmerge				= "등장 타이머 바 보기",
	TimerSubmerge			= "잠복 타이머 바 보기",
	WarningTeleportNow		= "순간이동 경고 보기",
	WarningTeleportSoon		= "순간이동 사전 경고 보기",
	TimerTeleport			= "순간이동 타이머 바 보기"
}

--------------------------
--  Memories of Azeroth: Cataclysm  --
--------------------------
L = DBM:GetModLocalization("CataEvent")

L:SetGeneralLocalization({
	name = "추억: 대격변"
})

L:SetWarningLocalization({
	warnSplittingBlow		= "%2$s에 %1$s",--Spellname in Location
	warnEngulfingFlame		= "%2$s에 %1$s"--Spellname in Location
})

L:SetOptionLocalization({
	warnSplittingBlow			= "$spell:98951 위치 경고 보기",
	warnEngulfingFlame			= "$spell:99171 위치 경고 보기"
})

----------------------------------
--  Azeroth Event World Bosses  --
----------------------------------

-- Lord Kazzak (Badlands)
L = DBM:GetModLocalization("KazzakClassic")

L:SetGeneralLocalization{
	name = "군주 카자크"
}

L:SetMiscLocalization({
	Pull		= "불타는 군단과 킬제덴을 위하여!"
})

-- Azuregos (Azshara)
L = DBM:GetModLocalization("Azuregos")

L:SetGeneralLocalization{
	name = "아주어고스"
}

L:SetMiscLocalization({
	Pull		= "여기는 내가 지킨다. 어느 누구도 비전술의 신비를 건드리지 못할 것이다."
})

-- Taerar (Ashenvale)
L = DBM:GetModLocalization("Taerar")

L:SetGeneralLocalization{
	name = "타에라"
}

L:SetMiscLocalization({
	Pull		= "평화란 부질없는 꿈일 뿐! 이 세상은 악몽이 지배할 것이다!"
})

-- Ysondre (Feralas)
L = DBM:GetModLocalization("Ysondre")

L:SetGeneralLocalization{
	name = "이손드레"
}

L:SetMiscLocalization({
	Pull		= "생명의 끈이 끊어졌다! 꿈꾸는 자들이 복수하는 것이 틀림없다!"
})

-- Lethon (Hinterlands)
L = DBM:GetModLocalization("Lethon")

L:SetGeneralLocalization{
	name = "레손"
}

-- Emeriss (Duskwood)
L = DBM:GetModLocalization("Emeriss")

L:SetGeneralLocalization{
	name = "에메리스"
}

L:SetMiscLocalization({
	Pull		= "희망은 영혼의 병! 이 땅은 말라 죽을 것이다!"
})

-- Doomwalker (Tanaris)
L = DBM:GetModLocalization("DoomwalkerEvent")

L:SetGeneralLocalization{
	name = "파멸의 절단기 (이벤트)"
}

-- Archavon (???)
L = DBM:GetModLocalization("ArchavonEvent")

L:SetGeneralLocalization{
	name = "아카본 (이벤트)"
}

-- Sha of Anger (???)
L = DBM:GetModLocalization("ShaofAngerEvent")

L:SetGeneralLocalization{
	name = "분노의 샤 (이벤트)"
}

--------------------------
--  Blastenheimer 5000  --
--------------------------
L = DBM:GetModLocalization("Cannon")

L:SetGeneralLocalization({
	name = "인간 대포알"
})

L = DBM:GetModLocalization("CannonClassic")

L:SetGeneralLocalization({
	name = "인간 대포알"
})
-------------
--  Gnoll  --
-------------
L = DBM:GetModLocalization("Gnoll")

L:SetGeneralLocalization({
	name = "놀 때려잡기"
})

L:SetWarningLocalization({
	warnGameOverQuest	= "게임 종료. 획득 점수 %d 점, 이 게임의 최대 점수 : %d 점",
	warnGameOverNoQuest	= "게임 종료. 이 게임의 최대 점수 : %d 점",
	warnGnoll			= "놀 등장",
	warnHogger			= "들창코 놀 등장",
	specWarnHogger		= "들창코 놀 등장!"
})

L:SetOptionLocalization({
	warnGameOver	= "진행 게임의 최대 점수 알림 보기",
	warnGnoll		= "놀 등장 알림 보기",
	warnHogger		= "들창코 놀 등장 알림 보기",
	specWarnHogger	= "들창코 놀 등장 특별 경고 보기"
})

------------------------
--  Shooting Gallery  --
------------------------
L = DBM:GetModLocalization("Shot")

L:SetGeneralLocalization({
	name = "사격 연습장"
})

L:SetOptionLocalization({
	SetBubbles	= "$spell:101871 중일때 대화 말풍선을 숨김<br/>(전투 종료 후 원상태로 복구됨)"
})

----------------------
--  Tonk Challenge  --
----------------------
L = DBM:GetModLocalization("Tonks")

L:SetGeneralLocalization({
	name = "통통 전차 게임"
})

---------------------------
--  Fire Ring Challenge  --
---------------------------
L = DBM:GetModLocalization("Rings")

L:SetGeneralLocalization({
	name = "불새의 도전"
})


-----------------------
--  Darkmoon Rabbit  --
-----------------------
L = DBM:GetModLocalization("Rabbit")

L:SetGeneralLocalization({
	name = "다크문 토끼"
})

-------------------------
--  Darkmoon Moonfang  --
-------------------------
L = DBM:GetModLocalization("Moonfang")

L:SetGeneralLocalization({
	name = "달송곳니"
})

L:SetWarningLocalization({
	specWarnCallPack		= "무리 소환 - 40미터 이상 떨어지세요!",
	specWarnMoonfangCurse	= "달송곳니의 저주 - 10미터 이상 떨어지세요!"
})
