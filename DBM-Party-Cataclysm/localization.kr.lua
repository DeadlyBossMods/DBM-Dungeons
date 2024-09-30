if GetLocale() ~= "koKR" then return end
local L

-------------------------
--  Blackrock Caverns  --
--------------------------
-- Rom'ogg Bonecrusher --
--------------------------
L= DBM:GetModLocalization(105)

-------------------------------
-- Corla, Herald of Twilight --
-------------------------------
L= DBM:GetModLocalization(106)

L:SetWarningLocalization({
	WarnAdd		= "쫄 풀려남"
})

L:SetOptionLocalization({
	WarnAdd		= "쫄에 $spell:75608 버프가 사라지면 알림 보기"
})

-----------------------
-- Karsh SteelBender --
-----------------------
L= DBM:GetModLocalization(107)

L:SetTimerLocalization({
	TimerSuperheated 	= "과열된 수은갑옷 (%d)"
})

L:SetOptionLocalization({
	TimerSuperheated	= "$spell:75846 지속 시간 타이머 바 보기"
})

------------
-- Beauty --
------------
L= DBM:GetModLocalization(108)

-----------------------------
-- Ascendant Lord Obsidius --
-----------------------------
L= DBM:GetModLocalization(109)

---------
--Trash--
---------
L = DBM:GetModLocalization("BlackrockCavernsTrash")

L:SetGeneralLocalization({
	name =	"검은바위 동굴 일반몹"
})

---------------------
--  The Deadmines  --
---------------------
-- Glubtok --
-------------
L= DBM:GetModLocalization(89)

-----------------------
-- Helix Gearbreaker --
-----------------------
L= DBM:GetModLocalization(90)

---------------------
-- Foe Reaper 5000 --
---------------------
L= DBM:GetModLocalization(91)

----------------------
-- Admiral Ripsnarl --
----------------------
L= DBM:GetModLocalization(92)

----------------------
-- "Captain" Cookie --
----------------------
L= DBM:GetModLocalization(93)

----------------------
-- Vanessa VanCleef --
----------------------
L= DBM:GetModLocalization(95)

L:SetTimerLocalization({
	achievementGauntlet	= "업적 달성"
})

------------------
--  Grim Batol  --
---------------------
-- General Umbriss --
---------------------
L= DBM:GetModLocalization(131)

--------------------------
-- Forgemaster Throngus --
--------------------------
L= DBM:GetModLocalization(132)

-------------------------
-- Drahga Shadowburner --
-------------------------
L= DBM:GetModLocalization(133)

------------
-- Erudax --
------------
L= DBM:GetModLocalization(134)

---------
--Trash--
---------
L = DBM:GetModLocalization("BoralusTrash")

L:SetGeneralLocalization({
	name =	"그럼 바톨 일반몹"
})

----------------------------
--  Halls of Origination  --
----------------------------
-- Temple Guardian Anhuur --
----------------------------
L= DBM:GetModLocalization(124)

---------------------
-- Earthrager Ptah --
---------------------
L= DBM:GetModLocalization(125)

L:SetMiscLocalization{
	Kill		= "프타는... 이젠..."
}

--------------
-- Anraphet --
--------------
L= DBM:GetModLocalization(126)

L:SetTimerLocalization({
	achievementGauntlet	= "업적 달성"
})

L:SetMiscLocalization({
	Brann		= "좋아요. 갑시다! 최종 출입 암호를 넣기만 하면 이 출입문이 작동할 거예요..."
})

------------
-- Isiset --
------------
L= DBM:GetModLocalization(127)

L:SetWarningLocalization({
	WarnSplitSoon	= "곧 분리"
})

L:SetOptionLocalization({
	WarnSplitSoon	= "분리 사전 경고 보기"
})

-------------
-- Ammunae --
-------------
L= DBM:GetModLocalization(128)

-------------
-- Setesh  --
-------------
L= DBM:GetModLocalization(129)

----------
-- Rajh --
----------
L= DBM:GetModLocalization(130)

--------------------------------
--  Lost City of the Tol'vir  --
--------------------------------
-- General Husam --
-------------------
L= DBM:GetModLocalization(117)

--------------
-- Lockmaw --
--------------
L= DBM:GetModLocalization(118)

L:SetOptionLocalization{
	RangeFrame	= "거리 창 보기 (5m)"
}

----------
-- Augh --
----------
L = DBM:GetModLocalization("Augh")

L:SetGeneralLocalization({
	name = "오우"
})

------------------------
-- High Prophet Barim --
------------------------
L= DBM:GetModLocalization(119)

------------------------------------
-- Siamat, Lord of the South Wind --
------------------------------------
L= DBM:GetModLocalization(122)

L:SetWarningLocalization{
	specWarnPhase2Soon	= "5초 후 2단계"
}

L:SetOptionLocalization{
	specWarnPhase2Soon	= "곧 2단계 특수 알림 보기 (5초)"
}

-----------------------
--  Shadowfang Keep  --
-----------------------
-- Baron Ashbury --
-------------------
L= DBM:GetModLocalization(96)

-----------------------
-- Baron Silverlaine --
-----------------------
L= DBM:GetModLocalization(97)

--------------------------
-- Commander Springvale --
--------------------------
L= DBM:GetModLocalization(98)

L:SetTimerLocalization({
	TimerAdds		= "다음 쫄"
})

L:SetOptionLocalization{
	TimerAdds		= "쫄 타이머 바 보기"
}

L:SetMiscLocalization{
	YellAdds		= "침입자를 물리쳐라!"
}

-----------------
-- Lord Walden --
-----------------
L= DBM:GetModLocalization(99)

L:SetWarningLocalization{
	specWarnCoagulant	= "녹색 혼합물 - 계속 이동!",	-- Green light
	specWarnRedMix		= "빨강 혼합물 - 이동 금지!"		-- Red light
}

L:SetOptionLocalization{
	RedLightGreenLight	= "녹색/빨강 이동 지침 특수 알림 보기"
}

------------------
-- Lord Godfrey --
------------------
L= DBM:GetModLocalization(100)

---------------------
--  The Stonecore  --
---------------------
-- Corborus --
--------------
L= DBM:GetModLocalization(110)

L:SetWarningLocalization({
	WarnEmerge		= "등장",
	WarnSubmerge	= "잠수"
})

L:SetTimerLocalization({
	TimerEmerge		= "다음 등장",
	TimerSubmerge	= "다음 잠수"
})

L:SetOptionLocalization({
	WarnEmerge		= "등장 알림 보기",
	WarnSubmerge	= "잠수 알림 보기",
	TimerEmerge		= "다음 등장 타이머 바 보기",
	TimerSubmerge	= "다음 잠수 타이머 바 보기",
	RangeFrame		= "거리 창 보기 (5m)"
})

--------------
-- Slabhide --
--------------
L= DBM:GetModLocalization(111)

L:SetWarningLocalization({
	WarnAirphase				= "공중 단계",
	WarnGroundphase				= "지상 단계",
	specWarnCrystalStorm		= "수정 폭풍 - 숨으세요"
})

L:SetTimerLocalization({
	TimerAirphase				= "다음 공중 단계",
	TimerGroundphase			= "다음 지상 단계"
})

L:SetOptionLocalization({
	WarnAirphase				= "돌거죽이 도약하면 알림 보기",
	WarnGroundphase				= "도럭죽이 착지하면 알림 보기",
	TimerAirphase				= "다음 공중 단계 타이머 바 보기",
	TimerGroundphase			= "다음 지상 단계 타이머 바 보기",
	specWarnCrystalStorm		= "$spell:92265 특수 알림 보기"
})

-----------
-- Ozruk --
-----------
L= DBM:GetModLocalization(112)

-------------------------
-- High Priestess Azil --
------------------------
L= DBM:GetModLocalization(113)

---------
--Trash--
---------
L = DBM:GetModLocalization("StonecoreTrash")

L:SetGeneralLocalization({
	name =	"바위심장부 일반몹"
})

---------------------------
--  The Vortex Pinnacle  --
---------------------------
-- Grand Vizier Ertan --
------------------------
L= DBM:GetModLocalization(114)

L:SetMiscLocalization{
	Retract		= "회오리 방패를 가까이 끌어당깁니다!"
}

--------------
-- Altairus --
--------------
L= DBM:GetModLocalization(115)

-----------
-- Asaad --
-----------
L= DBM:GetModLocalization(116)

---------
--Trash--
---------
L = DBM:GetModLocalization("VortexPinnacleTrash")

L:SetGeneralLocalization({
	name =	"소용돌이 누각 일반몹"
})

---------------------------
--  The Throne of Tides  --
---------------------------
-- Lady Naz'jar --
------------------
L= DBM:GetModLocalization(101)

-----======-----------
-- Commander Ulthok --
----------------------
L= DBM:GetModLocalization(102)

-------------------------
-- Erunak Stonespeaker --
-------------------------
L= DBM:GetModLocalization(103)

------------
-- Ozumat --
------------
L= DBM:GetModLocalization(104)

L:SetTimerLocalization{
	TimerPhase		= "2단계"
}

L:SetOptionLocalization{
	TimerPhase		= "2단계 타이머 바 보기"
}

L:SetMiscLocalization{
	RolePlay		= "야수가 돌아왔다! 놈이 물을 오염시키게 두면 안 된다!"
}

---------
--Trash--
---------
L = DBM:GetModLocalization("ThroneofTidesTrash")

L:SetGeneralLocalization({
	name =	"파도의 왕좌 일반몹"
})

----------------
--  Zul'Aman  --
----------------
--  Akil'zon --
---------------
L= DBM:GetModLocalization(186)

L:SetOptionLocalization{
	RangeFrame		= "거리 창 보기 (10m)"
}

---------------
--  Nalorakk --
---------------
L= DBM:GetModLocalization(187)

L:SetWarningLocalization{
	WarnBear		= "곰 형상",
	WarnBearSoon	= "5초 후 곰 형상",
	WarnNormal		= "인간 형상",
	WarnNormalSoon	= "5초 후 인간 형상"
}

L:SetTimerLocalization{
	TimerBear		= "다음 곰 형상",
	TimerNormal		= "다음 인간 형상"
}

L:SetOptionLocalization{
	WarnBear		= "곰 형상 알림 보기",
	WarnBearSoon	= "곰 형상 사전 경고 보기",
	WarnNormal		= "인간 형상 알림 보기",
	WarnNormalSoon	= "인간 형상 사전 경고 보기",
	TimerBear		= "다음 곰 형상 타이머 바 보기",
	TimerNormal		= "다음 인간 형상 타이머 바 보기",
	InfoFrame		= "$spell:42402 대상을 정보 창으로 보기"
}

L:SetMiscLocalization{
	YellBear 		= "너희들이 짐승을 불러냈다. 놀랄 준비나 해라!",
	YellNormal		= "날로라크 나가신다!",
	PlayerDebuffs	= "쇄도 디버프"
}

--------------
-- Jan'alai --
--------------
L= DBM:GetModLocalization(188)

L:SetMiscLocalization{
	YellBomb		= "태워버리겠다!",
	YellHatchAll	= "힘을 보여주마",
	YellAdds		= "다 어디 갔지? 당장 알을 부화시켜!"
}

-------------
-- Halazzi --
-------------
L= DBM:GetModLocalization(189)

L:SetWarningLocalization{
	WarnSpirit	= "영혼 단계",
	WarnNormal	= "일반 단계"
}

L:SetOptionLocalization{
	WarnSpirit	= "영혼 단계 알림 보기",
	WarnNormal	= "일반 단계 알림 보기"
}

L:SetMiscLocalization{
	YellSpirit	= "야생의 혼이 내 편이다...",
	YellNormal	= "혼이여, 이리 돌아오라!"
}

-----------------------
-- Hexlord Malacrass --
-----------------------
L= DBM:GetModLocalization(190)

L:SetOptionLocalization{
	TimerSiphon	= "$spell:43501 타이머 바 보기"
}

L:SetMiscLocalization{
	YellPull	= "너희에게 그림자가 드리우리라..."
}

-------------
-- Daakara --
-------------
L= DBM:GetModLocalization(191)

L:SetTimerLocalization{
	timerNextForm	= "다음 형상 변환"
}

L:SetOptionLocalization{
	timerNextForm	= "형상 변환 타이머 바 보기",
	InfoFrame		= "$spell:42402 대상을 정보 창으로 보기"
}

L:SetMiscLocalization{
	PlayerDebuffs	= "쇄도 디버프"
}

-----------------
--  Zul'Gurub  --
-------------------------
-- High Priest Venoxis --
-------------------------
L= DBM:GetModLocalization(175)

------------------------
-- Bloodlord Mandokir --
------------------------
L= DBM:GetModLocalization(176)

L:SetWarningLocalization{
	WarnRevive		= "유령 %d마리 남음",
	SpecWarnOhgan	= "오간 부활! 공격하세요!"
}

L:SetOptionLocalization{
	WarnRevive		= "영혼 부활 남은횟수 알림 보기",
	SpecWarnOhgan	= "오간이 부활하면 특수 알림 보기"
}

----------------------
-- Cache of Madness --
----------------------
-------------
-- Gri'lek --
-------------
L= DBM:GetModLocalization(177)

---------------
-- Hazza'rah --
---------------
L= DBM:GetModLocalization(178)

--------------
-- Renataki --
--------------
L= DBM:GetModLocalization(179)

---------------
-- Wushoolay --
---------------
L= DBM:GetModLocalization(180)

----------------------------
-- High Priestess Kilnara --
----------------------------
L= DBM:GetModLocalization(181)

------------
-- Zanzil --
------------
L= DBM:GetModLocalization(184)

L:SetWarningLocalization{
	SpecWarnToxic	= "고문의 독액 디버프 받기"
}

L:SetOptionLocalization{
	SpecWarnToxic	= "$spell:96328 디버프가 없으면 특수 알림 보기",
	InfoFrame		= "$spell:96328이 없는 대상을 정보 창으로 보기"
}

L:SetMiscLocalization{
	PlayerDebuffs	= "고문의 독액 없음"
}

----------------------------
-- Jindo --
----------------------------
L= DBM:GetModLocalization(185)

L:SetWarningLocalization{
	WarnBarrierDown	= "학카르의 사슬 보호막 깨짐 - %d/3 남음"
}

L:SetOptionLocalization{
	WarnBarrierDown	= "학카르의 사슬 보호막이 깨질때 알림"
}

L:SetMiscLocalization{
	Kill	= "너는 넘어서는 안 될 선을 넘었다, 진도. 감당하지도 못할 힘으로 장난을 치다니. 너는 내가 누군지 잊었느냐? 너는 내가 가진 힘을 잊었느냐?!"
}

----------------
--  End Time  --
-------------------
-- Echo of Baine --
-------------------
L= DBM:GetModLocalization(340)

-------------------
-- Echo of Jaina --
-------------------
L= DBM:GetModLocalization(285)

L:SetTimerLocalization{
	TimerFlarecoreDetonate	= "섬광핵 폭발"
}

L:SetOptionLocalization{
	TimerFlarecoreDetonate	= "$spell:101927 폭발 타이머 바 보기"
}

----------------------
-- Echo of Sylvanas --
----------------------
L= DBM:GetModLocalization(323)

---------------------
-- Echo of Tyrande --
---------------------
L= DBM:GetModLocalization(283)

--------------
-- Murozond --
--------------
L= DBM:GetModLocalization(289)

L:SetMiscLocalization{
	Kill		= "넌 네가 무슨 짓을 저지르는지 모른다. 아만툴... 내가... 본... 것은..."
}

------------------------
--  Well of Eternity  --
------------------------
-- Peroth'arn --
----------------
L= DBM:GetModLocalization(290)

L:SetMiscLocalization{
	Pull		= "필멸자 주제에 내 앞에 서고도 살기를 바라느냐!"
}

-------------
-- Azshara --
-------------
L= DBM:GetModLocalization(291)

L:SetWarningLocalization{
	WarnAdds	= "쫄 등장"
}

L:SetTimerLocalization{
	TimerAdds	= "다음 쫄"
}

L:SetOptionLocalization{
	WarnAdds	= "새로운 쫄이 \"등장\"하면 알림",
	TimerAdds	= "다음 쫄 \"등장\" 시간 타이머 바 보기"
}

L:SetMiscLocalization{
	Kill		= "그만! 너희랑 놀아 주는 것도 재미있다만, 난 더 중요한 일이 있어 이만 가봐야겠다."
}

-----------------------------
-- Mannoroth and Varo'then --
-----------------------------
L= DBM:GetModLocalization(292)

L:SetTimerLocalization{
	TimerTyrandeHelp	= "티란데의 도움 요청"
}

L:SetOptionLocalization{
	TimerTyrandeHelp	= "티란데의 도움 요청까지의 시간 타이머 바 보기"
}

L:SetMiscLocalization{
	Kill		= "말퓨리온, 그가 해냈어! 차원문이 무너지고 있어!"
}

------------------------
--  Hour of Twilight  --
------------------------
-- Arcurion --
--------------
L= DBM:GetModLocalization(322)

L:SetMiscLocalization{
	Event		= "모습을 드러내라!",
	Pull		= "골짜기 위쪽에서 황혼의 군대가 나타납니다."
}

----------------------
-- Asira Dawnslayer --
----------------------
L= DBM:GetModLocalization(342)

L:SetMiscLocalization{
	Pull		= "일단 저놈은 처리했으니, 이제 네놈과 네 멍청한 친구들을 처치하면 되겠군. 음, 날 이렇게 오래 기다리게 하다니!"
}

---------------------------
-- Archbishop Benedictus --
---------------------------
L= DBM:GetModLocalization(341)

L:SetMiscLocalization{
	Event		= "그럼... 주술사, 용의 영혼을 내놓으시지. 당장."
}
