DBM.Test:Report[[
Test: SoD/Party/DemonFall/Grimroot
Mod:  DBM-Party-Vanilla/Grimroot

Findings:
	Unused event registration: SPELL_AURA_REFRESH 460703 (Tender's Rage)
	Unused event registration: SPELL_MISSED 460512 (Corrupted Tears)
	Unused event registration: SPELL_PERIODIC_DAMAGE 460512 (Corrupted Tears)
	Unused event registration: SPELL_PERIODIC_MISSED 460512 (Corrupted Tears)

Unused objects:
	None

Timers:
	Tender's Rage ends, time=8.00, type=active, spellId=460703, triggerDeltas = 19.45, 44.81
		[19.45] SPELL_AURA_APPLIED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
			 Triggered 2x, delta times: 19.45, 44.81
		[27.44] SPELL_AURA_REMOVED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
			 Triggered 2x, delta times: 27.44, 44.82
	Gloom, time=30.70, type=next, spellId=460727, triggerDeltas = 0.00, 30.78, 30.79
		[ 0.00] ENCOUNTER_START: 3023, Grimroot, 1, 5, 0
		[30.78] SPELL_CAST_START: [Grimroot: Gloom] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460727, Gloom, 0, 0
			 Triggered 2x, delta times: 30.78, 30.79

Announces:
	None

Special warnings:
	%s damage - move away, type=gtfo, spellId=460512, triggerDeltas = 9.46, 34.05
		[ 9.46] SPELL_DAMAGE: [->Tandanu: Corrupted Tears] "", nil, 0x0, Player-5826-020CBDBB, Tandanu, 0x511, 460512, Corrupted Tears, 0, 0
			 Triggered 2x, delta times: 9.46, 34.05
	Tender's Rage on >%s< - dispel now, type=dispel, spellId=460703, triggerDeltas = 19.45, 44.81
		[19.45] SPELL_AURA_APPLIED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
			 Triggered 2x, delta times: 19.45, 44.81
	Gloom - interrupt >%s<!, type=interrupt, spellId=460727, triggerDeltas = 30.78, 30.79
		[30.78] SPELL_CAST_START: [Grimroot: Gloom] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460727, Gloom, 0, 0
			 Triggered 2x, delta times: 30.78, 30.79

Yells:
	{rt%1$d}, type=repeaticon, spellId=460512
		[51.95] Scheduled at 51.85 by SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0

Voice pack sounds:
	VoicePack/kickcast
		[30.78] SPELL_CAST_START: [Grimroot: Gloom] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460727, Gloom, 0, 0
			 Triggered 2x, delta times: 30.78, 30.79
	VoicePack/trannow
		[19.45] SPELL_AURA_APPLIED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
			 Triggered 2x, delta times: 19.45, 44.81
	VoicePack/watchfeet
		[ 9.46] SPELL_DAMAGE: [->Tandanu: Corrupted Tears] "", nil, 0x0, Player-5826-020CBDBB, Tandanu, 0x511, 460512, Corrupted Tears, 0, 0
			 Triggered 2x, delta times: 9.46, 34.05

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 3023, Grimroot, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_DAMAGE 460512, SPELL_PERIODIC_DAMAGE 460512, SPELL_MISSED 460512, SPELL_PERIODIC_MISSED 460512, SPELL_CAST_SUCCESS 460509, SPELL_CAST_START 460727, SPELL_AURA_APPLIED 460703, SPELL_AURA_REFRESH 460703, SPELL_AURA_REMOVED 460703
		StartTimer: 30.8, Gloom
	[ 6.46] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 6.56 (+0.10)
			ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 6.66 (+0.10)
				ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 6.76 (+0.10)
					ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 6.86 (+0.10)
	[ 9.46] SPELL_DAMAGE: [->Tandanu: Corrupted Tears] "", nil, 0x0, Player-5826-020CBDBB, Tandanu, 0x511, 460512, Corrupted Tears, 0, 0
		AntiSpam: 1
		ShowSpecialWarning: Corrupted Tears damage - move away
		PlaySound: VoicePack/watchfeet
	[17.82] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 17.92 (+0.10)
			ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 18.02 (+0.10)
				ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 18.12 (+0.10)
					ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 18.22 (+0.10)
	[19.45] SPELL_AURA_APPLIED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
		ShowSpecialWarning: Tender's Rage on Grimroot - dispel now
		PlaySound: VoicePack/trannow
		StartTimer: 8.0, Tender's Rage ends
	[27.44] SPELL_AURA_REMOVED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
		StopTimer: Timer460703active
	[29.16] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 29.26 (+0.10)
			ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 29.36 (+0.10)
				ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 29.46 (+0.10)
					ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 29.56 (+0.10)
	[30.78] SPELL_CAST_START: [Grimroot: Gloom] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460727, Gloom, 0, 0
		StartTimer: 30.7, Gloom
		ShowSpecialWarning: Gloom - interrupt Grimroot!
		PlaySound: VoicePack/kickcast
	[40.52] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 40.62 (+0.10)
	[43.51] SPELL_DAMAGE: [->Tandanu: Corrupted Tears] "", nil, 0x0, Player-5826-020CBDBB, Tandanu, 0x511, 460512, Corrupted Tears, 0, 0
		AntiSpam: 1
		ShowSpecialWarning: Corrupted Tears damage - move away
		PlaySound: VoicePack/watchfeet
	[51.85] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 51.95 (+0.10)
			ShowYell: {rt8}
	[61.57] SPELL_CAST_START: [Grimroot: Gloom] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460727, Gloom, 0, 0
		StartTimer: 30.7, Gloom
		ShowSpecialWarning: Gloom - interrupt Grimroot!
		PlaySound: VoicePack/kickcast
	[64.26] SPELL_AURA_APPLIED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
		ShowSpecialWarning: Tender's Rage on Grimroot - dispel now
		PlaySound: VoicePack/trannow
		StartTimer: 8.0, Tender's Rage ends
	[64.81] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 64.91 (+0.10)
	[72.26] SPELL_AURA_REMOVED: [Grimroot->Grimroot: Tender's Rage] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, 460703, Tender's Rage, 0, BUFF, 0
		StopTimer: Timer460703active
	[76.12] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 76.22 (+0.10)
	[87.44] SPELL_CAST_SUCCESS: [Grimroot: Corrupted Tears] Creature-0-5252-2784-26746-226923-000012D5C6, Grimroot, 0xa48, "", nil, 0x0, 460509, Corrupted Tears, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-5252-2784-26746-226923-000012D5C6", "CorruptedTearsTarget", 0.1, 4.0) at 87.54 (+0.10)
	Unknown trigger
		EndCombat: checkWipe
]]
