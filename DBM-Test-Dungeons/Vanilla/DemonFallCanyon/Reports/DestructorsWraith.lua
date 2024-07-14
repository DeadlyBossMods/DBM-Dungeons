DBM.Test:Report[[
Test: SoD/Party/DemonFall/DestructorsWraith
Mod:  DBM-Party-Vanilla/DestructorsWraith

Findings:
	Timer for spell ID 460401 (Nether Nova) is triggered by event SPELL_CAST_START 462222 (Destructor's Devastation)

Unused objects:
	[Special Warning] Destructor's Devastation - dodge attack, type=dodge, spellId=462222

Timers:
	Nether Nova, time=11.30, type=cast, spellId=460401, triggerDeltas = 18.20, 35.53, 29.10
		[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
			 Triggered 3x, delta times: 18.20, 35.53, 29.10
	Destructor's Devastation (%s), time=2.00, type=castcount, spellId=462222, triggerDeltas = 18.20, 0.00, 0.00, 35.53, 0.00, 0.00, 29.10, 0.00, 0.00
		[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
			 Triggered 3x, delta times: 18.20, 35.53, 29.10
	Destructor's Devastation, time=28.00, type=cd, spellId=462222, triggerDeltas = 0.00, 18.20, 35.53, 29.10
		[ 0.00] ENCOUNTER_START: 3028, Destructor's Wraith, 1, 5, 0
		[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
			 Triggered 3x, delta times: 18.20, 35.53, 29.10

Announces:
	None

Special warnings:
	Nether Nova - dodge attack, type=dodge, spellId=460401, triggerDeltas = 26.70, 35.53
		[26.70] Scheduled at 18.20 by SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		[62.23] Scheduled at 53.73 by SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0

Yells:
	None

Voice pack sounds:
	VoicePack/shockwave
		[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
			 Triggered 3x, delta times: 18.20, 35.53, 29.10

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 3028, Destructor's Wraith, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_CAST_START 462222
		StartTimer: 16.0, Destructor's Devastation
	[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		PlaySound: VoicePack/shockwave
		StartTimer: 2.0, Destructor's Devastation (1)
		StartTimer: 5.0, Destructor's Devastation (2)
		StartTimer: 8.0, Destructor's Devastation (3)
		StartTimer: 11.3, Nether Nova
		StartTimer: 28.0, Destructor's Devastation
		ScheduleTask: specWarn460401dodge:Schedule() at 26.70 (+8.50)
			ShowSpecialWarning: Nether Nova - dodge attack
			PlaySound: DBM/SpecialWarningSound2
	[53.73] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		PlaySound: VoicePack/shockwave
		StartTimer: 2.0, Destructor's Devastation (1)
		StartTimer: 5.0, Destructor's Devastation (2)
		StartTimer: 8.0, Destructor's Devastation (3)
		StartTimer: 11.3, Nether Nova
		StartTimer: 28.0, Destructor's Devastation
		ScheduleTask: specWarn460401dodge:Schedule() at 62.23 (+8.50)
			ShowSpecialWarning: Nether Nova - dodge attack
			PlaySound: DBM/SpecialWarningSound2
	[82.83] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		PlaySound: VoicePack/shockwave
		StartTimer: 2.0, Destructor's Devastation (1)
		StartTimer: 5.0, Destructor's Devastation (2)
		StartTimer: 8.0, Destructor's Devastation (3)
		StartTimer: 11.3, Nether Nova
		StartTimer: 28.0, Destructor's Devastation
		ScheduleTask: specWarn460401dodge:Schedule() at 91.33 (+8.50)
			Unscheduled by ENCOUNTER_END at 84.52
	[84.52] ENCOUNTER_END: 3028, Destructor's Wraith, 1, 5, 1, 0
		EndCombat: ENCOUNTER_END
		UnscheduleTask: specWarn460401dodge:Schedule() scheduled by ScheduleTask at 82.83
]]
