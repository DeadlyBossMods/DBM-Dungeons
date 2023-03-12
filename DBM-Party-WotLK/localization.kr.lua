if GetLocale() ~= "koKR" then return end
local L

----------------------------------
--  Ahn'Kahet: The Old Kingdom  --
----------------------------------
--  Prince Taldaram  --
-----------------------
L = DBM:GetModLocalization(581)

L:SetGeneralLocalization{
	name 		= "공작 탈다람"
}

-------------------
--  Elder Nadox  --
-------------------
L = DBM:GetModLocalization(580)

L:SetGeneralLocalization{
	name 		= "장로 나독스"
}

---------------------------
--  Jedoga Shadowseeker  --
---------------------------
L = DBM:GetModLocalization(582)

L:SetGeneralLocalization{
	name 		= "어둠추적자 제도가"
}

---------------------
--  Herald Volazj  --
---------------------
L = DBM:GetModLocalization(584)

L:SetGeneralLocalization{
	name 		= "사자 볼라즈"
}

----------------
--  Amanitar  --
----------------
L = DBM:GetModLocalization(583)

L:SetGeneralLocalization{
	name 		= "아마니타르"
}

-------------------
--  Azjol-Nerub  --
---------------------------------
--  Krik'thir the Gatewatcher  --
---------------------------------
L = DBM:GetModLocalization(585)

L:SetGeneralLocalization{
	name 		= "문지기 크릭시르"
}

----------------
--  Hadronox  --
----------------
L = DBM:GetModLocalization(586)

L:SetGeneralLocalization{
	name 		= "하드로녹스"
}

-------------------------
--  Anub'arak (Party)  --
-------------------------
L = DBM:GetModLocalization(587)

L:SetGeneralLocalization{
	name 		= "아눕아락 (던전)"
}

---------------------------------------
--  Caverns of Time: Old Stratholme  --
---------------------------------------
--  Meathook  --
----------------
L = DBM:GetModLocalization(611)

L:SetGeneralLocalization{
	name 		= "살덩이갈고리"
}

--------------------------------
--  Salramm the Fleshcrafter  --
--------------------------------
L = DBM:GetModLocalization(612)

L:SetGeneralLocalization{
	name 		= "살덩이창조자 살람"
}

-------------------------
--  Chrono-Lord Epoch  --
-------------------------
L = DBM:GetModLocalization(613)

L:SetGeneralLocalization{
	name 		= "시간의 군주 에포크"
}

-----------------
--  Mal'Ganis  --
-----------------
L = DBM:GetModLocalization(614)

L:SetGeneralLocalization{
	name 		= "말가니스"
}

L:SetMiscLocalization({
	Outro	= "너의 여정은 이제 막 시작이다, 젊은 왕자여. 병사들을 모아 극한의 땅, 노스렌드로 나를 찾아와라. 그곳에서 모든 일이 결판날 것이다. 네 진정한 운명도 그곳에서 시작되지."
})

-------------------
--  Wave Timers  --
-------------------
L = DBM:GetModLocalization("StratWaves")

L:SetGeneralLocalization({
	name = "스트라솔름 스컬지 공격"
})

L:SetWarningLocalization({
	WarningWaveNow	= "공격 %d: %s 등장"
})

L:SetTimerLocalization({
	TimerWaveIn		= "다음 공격 (6)",
	TimerRoleplay	= "아서스 대사"
})

L:SetOptionLocalization({
	WarningWaveNow	= "공격 시작시 경고 보기",
	TimerWaveIn		= "다음 스컬지 공격 타이머 바 보기 (5번 공격 우두머리 이후)",
	TimerRoleplay	= "시작시 대사 이벤트 타이머 바 보기"
})

L:SetMiscLocalization({
	Devouring	= "게걸스러운 구울",
	Enraged		= "격노한 구울",
	Necro		= "강령술사",
	Fiend		= "지하마귀",
	Stalker		= "무덤 거미",
	Abom		= "기워붙인 피조물",
	Acolyte		= "수행사제",
	Wave1		= "%d %s",
	Wave2		= "%d %s|1과;와; %d %s",
	Wave3		= "%d %s, %d %s|1와;과; %d %s",
	Wave4		= "%d %s, %d %s, %d %s|1와;과; %d %s",
	WaveBoss	= "%s",
	Roleplay	= "드디어 나타나셨군, 우서.",
	Roleplay2	= "준비가 된 것 같군. 명심해라. 이들은 끔찍한 역병에 걸렸고, 어차피 죽을 것이다. 스컬지의 손아귀에서 로데론을 지키려면 스트라솔름을 정화해야 한다. 가자."
})

------------------------
--  Drak'Tharon Keep  --
------------------------
--  Trollgore  --
-----------------
L = DBM:GetModLocalization(588)

L:SetGeneralLocalization{
	name 		= "송곳아귀"
}

--------------------------
--  Novos the Summoner  --
--------------------------
L = DBM:GetModLocalization(589)

L:SetGeneralLocalization{
	name 		= "소환사 노보스"
}

L:SetMiscLocalization({
	YellPull		= "견딜 수 없는 한기가 죽음을 몰고 오리니.",
	HandlerYell		= "와서 나를 보호해라! 어서! 망할 놈들아!",
	Phase2			= "부질없는 짓인 줄 잘 알고 있겠지!",
	YellKill		= "이래 봤자... 아무 소용 없다."
})

-----------------
--  King Dred  --
-----------------
L = DBM:GetModLocalization(590)

L:SetGeneralLocalization{
	name 		= "랩터왕 서슬발톱"
}

-----------------------------
--  The Prophet Tharon'ja  --
-----------------------------
L = DBM:GetModLocalization(591)

L:SetGeneralLocalization{
	name 		= "예언자 타론자"
}

---------------
--  Gundrak  --
----------------
--  Slad'ran  --
----------------
L = DBM:GetModLocalization(592)

L:SetGeneralLocalization{
	name 		= "슬라드란"
}

---------------
--  Moorabi  --
---------------
L = DBM:GetModLocalization(594)

L:SetGeneralLocalization{
	name 		= "무라비"
}

-------------------------
--  Drakkari Colossus  --
-------------------------
L = DBM:GetModLocalization(593)

L:SetGeneralLocalization{
	name 		= "드라카리 거대골렘"
}

-----------------
--  Gal'darah  --
-----------------
L = DBM:GetModLocalization(596)

L:SetGeneralLocalization{
	name 		= "갈다라"
}

-------------------------
--  Eck the Ferocious  --
-------------------------
L = DBM:GetModLocalization(595)

L:SetGeneralLocalization{
	name 		= "사나운 엑크"
}

--------------------------
--  Halls of Lightning  --
--------------------------
--  General Bjarngrim  --
-------------------------
L = DBM:GetModLocalization(597)

L:SetGeneralLocalization{
	name 		= "장군 비야른그림"
}

-------------
--  Ionar  --
-------------
L = DBM:GetModLocalization(599)

L:SetGeneralLocalization{
	name 		= "아이오나"
}

---------------
--  Volkhan  --
---------------
L = DBM:GetModLocalization(598)

L:SetGeneralLocalization{
	name 		= "볼칸"
}

-------------
--  Loken  --
-------------
L = DBM:GetModLocalization(600)

L:SetGeneralLocalization{
	name 		= "로켄"
}

----------------------
--  Halls of Stone  --
-----------------------
--  Maiden of Grief  --
-----------------------
L = DBM:GetModLocalization(605)

L:SetGeneralLocalization{
	name 		= "고뇌의 마녀"
}

------------------
--  Krystallus  --
------------------
L = DBM:GetModLocalization(604)

L:SetGeneralLocalization{
	name 		= "크리스탈루스"
}

------------------------------
--  Sjonnir the Ironshaper  --
------------------------------
L = DBM:GetModLocalization(607)

L:SetGeneralLocalization{
	name 		= "무쇠구체자 쇼니르"
}

--------------------------------------
--  Brann Bronzebeard Escort Event  --
--------------------------------------
L = DBM:GetModLocalization(606)

L:SetGeneralLocalization{
	name 		= "브란 이벤트"
}

L:SetWarningLocalization({
	WarningPhase	= "%d단계"
})

L:SetTimerLocalization({
	timerEvent	= "남은 시간"
})

L:SetOptionLocalization({
	WarningPhase	= "단계 전환 경고 보기",
	timerEvent		= "이벤트 시간 타이머 바 보기"
})

L:SetMiscLocalization({
	Pull		= "이제 잘 보시라고요! 제가 눈 깜짝할 사이에 정보를...",
	Phase1		= "보안 경보를 발령합니다. 출처 불명의 역사 자료 분석은 하위 등급 대기열로 이전됩니다. 방어 작업을 시작합니다.",
	Phase2		= "위협 지수가 임계점을 돌파했습니다. 천체 기록을 중단합니다. 보안 수준이 상승했습니다.",
	Phase3		= "위협 지수가 높습니다. 공허 분석을 종료합니다. 안전성 검증을 시작합니다.",
	Kill		= "경고, 보안 잠금장치가 비활성화되었습니다. 기억 장치 소거를 시작합..."
})

-----------------
--  The Nexus  --
-----------------
--  Anomalus  --
----------------
L = DBM:GetModLocalization(619)

L:SetGeneralLocalization{
	name 		= "아노말루스"
}

-------------------------------
--  Ormorok the Tree-Shaper  --
-------------------------------
L = DBM:GetModLocalization(620)

L:SetGeneralLocalization{
	name 		= "정원사 오르모로크"
}

----------------------------
--  Grand Magus Telestra  --
----------------------------
L = DBM:GetModLocalization(618)

L:SetGeneralLocalization{
	name 		= "대학자 텔레스트라"
}

L:SetMiscLocalization({
	SplitTrigger1	= "여기엔 내가 참 많지.",
	SplitTrigger2 	= "과연 나를 감당할 수 있겠느냐!"
})

-------------------
--  Keristrasza  --
-------------------
L = DBM:GetModLocalization(621)

L:SetGeneralLocalization{
	name 		= "케리스트라자"
}

-----------------------------------
--  Commander Kolurg/Stoutbeard  --
-----------------------------------
L = DBM:GetModLocalization("Commander")

local commander = "알 수 없음"
if UnitFactionGroup("player") == "Alliance" then
	commander = "사령관 콜루르그"
elseif UnitFactionGroup("player") == "Horde" then
	commander = "사령관 스타우트비어드"
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
	name 		= "심문관 드라코스"
}

L:SetOptionLocalization({
	MakeitCountTimer	= "매 순간을 소중히 타이머 바 보기 (업적)"
})

L:SetMiscLocalization({
	MakeitCountTimer	= "매 순간을 소중히"
})

----------------------
--  Mage-Lord Urom  --
----------------------
L = DBM:GetModLocalization(624)

L:SetGeneralLocalization{
	name 		= "마법사 군주 우롬"
}

L:SetMiscLocalization({
	CombatStart		= "어리석은 족속들!"
})

--------------------------
--  Varos Cloudstrider  --
--------------------------
L = DBM:GetModLocalization(623)

L:SetGeneralLocalization{
	name 		= "바로스 클라우드스트라이더"
}

---------------------------
--  Ley-Guardian Eregos  --
---------------------------
L = DBM:GetModLocalization(625)

L:SetGeneralLocalization{
	name 		= "지맥 수호자 에레고스"
}

L:SetMiscLocalization({
	MakeitCountTimer	= "매 순간을 소중히"
})

--------------------
--  Utgarde Keep  --
-----------------------
--  Prince Keleseth  --
-----------------------
L = DBM:GetModLocalization(638)

L:SetGeneralLocalization{
	name 		= "공작 켈레세스"
}

--------------------------------
--  Skarvald the Constructor  --
--  & Dalronn the Controller  --
--------------------------------
L = DBM:GetModLocalization(639)

L:SetGeneralLocalization{
	name 		= "스카발드와 달론"
}

----------------------------
--  Ingvar the Plunderer  --
----------------------------
L = DBM:GetModLocalization(640)

L:SetGeneralLocalization{
	name 		= "약탈자 잉그바르"
}

L:SetMiscLocalization({
	YellCombatEnd	= "안 돼! 난 더 잘할 수... 있는데..."
})

------------------------
--  Utgarde Pinnacle  --
--------------------------
--  Skadi the Ruthless  --
--------------------------
L = DBM:GetModLocalization(643)

L:SetGeneralLocalization{
	name 		= "학살자 스카디"
}

L:SetMiscLocalization({
	CombatStart		= "웬 놈들이 감히 여길? 정신 차려라, 형제들아! 녀석들을 처치하면 거하게 한 상 차려 주마!",
	Phase2			= "피도 눈물도 없는 것들아! 불쌍한 비룡을 괴롭히다니, 가만두지 않겠다!"
})

-------------------
--  King Ymiron  --
-------------------
L = DBM:GetModLocalization(644)

L:SetGeneralLocalization{
	name 		= "왕 이미론"
}

-------------------------
--  Svala Sorrowgrave  --
-------------------------
L = DBM:GetModLocalization(641)

L:SetGeneralLocalization{
	name 		= "스발라 소로우그레이브"
}

L:SetTimerLocalization({
	timerRoleplay		= "스발라 소로우그레이브 활성화"
})

L:SetOptionLocalization({
	timerRoleplay		= "스발라 소로우그레이브 활성화 전 대사 타이머 바 보기"
})

L:SetMiscLocalization({
	SvalaRoleplayStart	= "주인님! 당신께서 주신 일을 행했습니다. 이제, 축복을 내려 주소서!"
})

-----------------------
--  Gortok Palehoof  --
-----------------------
L = DBM:GetModLocalization(642)

L:SetGeneralLocalization{
	name 		= "고르톡 페일후프"
}

-----------------------
--  The Violet Hold  --
-----------------------
--  Cyanigosa  --
-----------------
L = DBM:GetModLocalization(632)

L:SetGeneralLocalization{
	name 		= "시아니고사"
}

L:SetMiscLocalization({
	CyanArrived			= "훌륭한 방어였다만, 도시를 지키게 둘 수는 없지! 내 직접 말리고스 님의 의지를 실현하리라!"
})

--------------
--  Erekem  --
--------------
L = DBM:GetModLocalization(626)

L:SetGeneralLocalization{
	name 		= "에레켐"
}

---------------
--  Ichoron  --
---------------
L = DBM:GetModLocalization(628)

L:SetGeneralLocalization{
	name 		= "이코론"
}

-----------------
--  Lavanthor  --
-----------------
L = DBM:GetModLocalization(630)

L:SetGeneralLocalization{
	name 		= "라반토르"
}

--------------
--  Moragg  --
--------------
L = DBM:GetModLocalization(627)

L:SetGeneralLocalization{
	name 		= "모라그"
}

--------------
--  Xevozz  --
--------------
L = DBM:GetModLocalization(629)

L:SetGeneralLocalization{
	name 		= "제보즈"
}

-------------------------------
--  Zuramat the Obliterator  --
-------------------------------
L = DBM:GetModLocalization(631)

L:SetGeneralLocalization{
	name 		= "파멸자 주라마트"
}

---------------------
--  Portal Timers  --
---------------------
L = DBM:GetModLocalization("PortalTimers")

L:SetGeneralLocalization({
	name = "차원문 타이머"
})

L:SetWarningLocalization({
	WarningPortalSoon	= "곧 새 차원문",
	WarningPortalNow	= "차원문 #%d",
	WarningBossNow		= "우두머리 등장"
})

L:SetTimerLocalization({
	TimerPortalIn	= "차원문 #%d" ,
})

L:SetOptionLocalization({
	WarningPortalNow	= "새 차원문 경고 보기",
	WarningPortalSoon	= "새 차원문 생성 전에 경고 보기",
	WarningBossNow		= "우두머리 등장 경고 보기",
	TimerPortalIn		= "다음 차원문 타이머 바 보기 (우두머리 잡은 후)",
	ShowAllPortalTimers	= "모든 차원문 타이머 바 보기 (부정확함)"
})

L:SetMiscLocalization({
	Sealbroken	= "문을 부쉈다! 달라란으로 가는 길이 열렸다! 이제 마력 전쟁의 끝을 내자!",
})

-----------------------------
--  Trial of the Champion  --
-----------------------------
--  The Black Knight  --
------------------------
L = DBM:GetModLocalization(637)

L:SetGeneralLocalization{
	name 		= "흑기사"
}

L:SetOptionLocalization({
	AchievementCheck	= "'이건 약과야' 업적 실패시 파티 대화로 알림"
})

L:SetMiscLocalization({
	Pull				= "잘했네. 오늘 자네의 가치를 잘 보여주었...",
	AchievementFailed	= ">> 업적 실패: %s|1이;가; 구울 폭발에 맞음 <<",
	YellCombatEnd		= "안 돼! 또 무릎 꿇을 수는... 없는데..."	-- can also be "No! I must not fail... again ..."
})

-----------------------
--  Grand Champions  --
-----------------------
L = DBM:GetModLocalization(634)

L:SetGeneralLocalization{
	name 		= "최고 용사"
}

L:SetMiscLocalization({
	YellCombatEnd	= "잘 싸웠네! 다음 상대는 은빛십자군의 일원이라네. 그들을 상대로 자신의 무용을 증명해 보게."
})

----------------------------------
--  Argent Confessor Paletress  --
----------------------------------
L = DBM:GetModLocalization(636)

L:SetGeneralLocalization{
	name 		= "은빛 고해사제 페일트레스"
}

L:SetMiscLocalization({
	YellCombatEnd	= "훌륭히 해내셨군요!"
})

-----------------------
--  Eadric the Pure  --
-----------------------
L = DBM:GetModLocalization(635)

L:SetGeneralLocalization{
	name 		= "성기사 에드릭"
}
L:SetMiscLocalization({
	YellCombatEnd	= "항복! 제가 졌습니다. 훌륭한 솜씨군요. 이제 집에 가도 되겠습니까?"
})

--------------------
--  Pit of Saron  --
---------------------
--  Ick and Krick  --
---------------------
L = DBM:GetModLocalization(609)

L:SetGeneralLocalization{
	name 		= "이크와 크리크"
}
L:SetMiscLocalization({
	Barrage		= "빠른 속도로 지뢰를 만들어냅니다!"
})

----------------------------
--  Forgemaster Garfrost  --
----------------------------
L = DBM:GetModLocalization(608)

L:SetGeneralLocalization{
	name 		= "제련장인 가프로스트"
}
L:SetOptionLocalization({
	AchievementCheck	= "'11번은 제발!' 업적 실패시 파티 대화로 알림"
})

L:SetMiscLocalization({
	SaroniteRockThrow	= "거대한 사로나이트 덩어리를 당신에게 던집니다!",
	AchievementWarning	= "경고: %s의 영구 결빙 %d중첩",
	AchievementFailed	= ">> 업적 실패 : %s의 영구 결빙 %d중첩 <<"
})

----------------------------
--  Scourgelord Tyrannus  --
----------------------------
L = DBM:GetModLocalization(610)

L:SetGeneralLocalization{
	name 		= "스컬지군주 티라누스"
}

L:SetMiscLocalization({
	CombatStart		= "아아. 용감하고 용감한 모험가들아, 참견도 이제 끝이다. 네놈들 뒤에 있는 굴에서 뼈와 칼이 부딪치는 소리가 들리는가? 네놈들에게 곧 닥칠 죽음의 소리다.", --Cannot promise just yet if this is right emote, it may be the second emote after this, will need to do more testing.
	HoarfrostTarget	= "노려보며 얼음 공격을 준비합니다!",
	YellCombatEnd	= "말도 안 돼... 서릿발송곳니... 경고를..."
})

----------------------
--  Forge of Souls  --
----------------------
--  Bronjahm  --
----------------
L = DBM:GetModLocalization(615)

L:SetGeneralLocalization{
	name 		= "브론잠"
}

-------------------------
--  Devourer of Souls  --
-------------------------
L = DBM:GetModLocalization(616)

L:SetGeneralLocalization{
	name 		= "영혼의 포식자"
}

---------------------------
--  Halls of Reflection  --
---------------------------
--  Wave Timers  --
-------------------
L = DBM:GetModLocalization("HoRWaveTimer")

L:SetGeneralLocalization({
	name = "영혼 공격 타이머"
})

L:SetWarningLocalization({
	WarnNewWaveSoon		= "곧 새 영혼 공격",
	WarnNewWave			= "%s 등장"
})

L:SetTimerLocalization({
	TimerNextWave		= "다음 영혼 공격"
})

L:SetOptionLocalization({
	WarnNewWave				= "우두머리 등장 경고 보기",
	WarnNewWaveSoon			= "다음 영혼 공격 전에 경고 보기 (5번 공격 우두머리 이후)",
	ShowAllWaveWarnings		= "모든 영혼 공격 경고 보기",
	TimerNextWave			= "다음 영혼 공격 타이머 바 보기 (5번 공격 우두머리 이후)",
	ShowAllWaveTimers		= "모든 영혼 공격 전에 경고와 타이머 바 보기 (부정확함)"
})

--------------
--  Falric  --
--------------
L = DBM:GetModLocalization(601)

L:SetGeneralLocalization{
	name 		= "팔릭"
}

--------------
--  Marwyn  --
--------------
L = DBM:GetModLocalization(602)

L:SetGeneralLocalization{
	name 		= "마윈"
}

-----------------------
--  Lich King Event  --
-----------------------
L = DBM:GetModLocalization(603)

L:SetGeneralLocalization{
	name 		= "리치 왕 이벤트"
}

L:SetTimerLocalization({
	achievementEscape	= "탈출 제한 시간"
})

L:SetOptionLocalization({
	WarnWave		= "적 등장시 경고 보기"
})

L:SetMiscLocalization({
	ACombatStart	= "그는 너무 강해요. 당장 여길 떠나야 해요! 내 마법으로는 그를 잠깐만 저지할 수 있어요. 영웅들이여, 서두르세요!",
	HCombatStart	= "그는... 너무 강하다. 영웅들이여, 어서... 이쪽으로 오라! 즉시 이곳을 떠나야 한다! 도망치는 동안 그를 잡아놓을 수 있도록 조치를 취하겠다.",
	Ghoul			= "구울",
	Doctor			= "의술사",
	Abom			= "누더기골렘"
})
