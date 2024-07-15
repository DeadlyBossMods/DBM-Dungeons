DBM.Test:Report[[
Test: SoD/Party/DemonFall/DestructorsWraith
Mod:  DBM-Party-Vanilla/DestructorsWraith

Findings:
	None

Unused objects:
	[Special Warning] Destructor's Devastation - dodge attack, type=dodge, spellId=462222

Timers:
	Nether Nova, time=4.00, type=cast, spellId=460401, triggerDeltas = 29.49, 42.02
		[29.49] SPELL_CAST_START: [The Destructor's Wraith: Nether Nova] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 460401, Nether Nova, 0, 0
			 Triggered 2x, delta times: 29.49, 42.02
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
	Nether Nova - dodge attack, type=dodge, spellId=460401, triggerDeltas = 29.49, 42.02
		[29.49] SPELL_CAST_START: [The Destructor's Wraith: Nether Nova] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 460401, Nether Nova, 0, 0
			 Triggered 2x, delta times: 29.49, 42.02

Yells:
	None

Voice pack sounds:
	VoicePack/justrun
		[29.49] SPELL_CAST_START: [The Destructor's Wraith: Nether Nova] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 460401, Nether Nova, 0, 0
			 Triggered 2x, delta times: 29.49, 42.02
	VoicePack/shockwave
		[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
			 Triggered 3x, delta times: 18.20, 35.53, 29.10

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 3028, Destructor's Wraith, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_CAST_START 462222 460401
		StartTimer: 16.0, Destructor's Devastation
	[18.20] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		PlaySound: VoicePack/shockwave
		StartTimer: 2.5, Destructor's Devastation (1)
		StartTimer: 5.5, Destructor's Devastation (2)
		StartTimer: 8.5, Destructor's Devastation (3)
		StartTimer: 28.0, Destructor's Devastation
	[29.49] SPELL_CAST_START: [The Destructor's Wraith: Nether Nova] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 460401, Nether Nova, 0, 0
		StartTimer: 4.0, Nether Nova
		ShowSpecialWarning: Nether Nova - dodge attack
		PlaySound: VoicePack/justrun
	[53.73] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		PlaySound: VoicePack/shockwave
		StartTimer: 2.5, Destructor's Devastation (1)
		StartTimer: 5.5, Destructor's Devastation (2)
		StartTimer: 8.5, Destructor's Devastation (3)
		StartTimer: 28.0, Destructor's Devastation
	[71.51] SPELL_CAST_START: [The Destructor's Wraith: Nether Nova] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 460401, Nether Nova, 0, 0
		StartTimer: 4.0, Nether Nova
		ShowSpecialWarning: Nether Nova - dodge attack
		PlaySound: VoicePack/justrun
	[82.83] SPELL_CAST_START: [The Destructor's Wraith: Destructor's Devastation] Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, "", nil, 0x0, 462222, Destructor's Devastation, 0, 0
		PlaySound: VoicePack/shockwave
		StartTimer: 2.5, Destructor's Devastation (1)
		StartTimer: 5.5, Destructor's Devastation (2)
		StartTimer: 8.5, Destructor's Devastation (3)
		StartTimer: 28.0, Destructor's Devastation
	[84.52] UNIT_DIED: [->The Destructor's Wraith] "", nil, 0x0, Creature-0-5252-2784-26746-228022-000012DAD5, The Destructor's Wraith, 0xa48, -1, false, 0, 0
		EndCombat: Main CID Down
]]
