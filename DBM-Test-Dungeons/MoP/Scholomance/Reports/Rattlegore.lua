DBM.Test:Report[[
Test: MoP/Party/Scholomance/Rattlegore/MoP-Remix
Mod:  DBM-Party-MoP/665

Findings:
	Unused event registration: CHAT_MSG_MONSTER_YELL
	Unused event registration: SPELL_AURA_REMOVED 113996 (Bone Armor)
	Unused event registration: SPELL_DAMAGE 114009 (Soulflame)

Unused objects:
	[Special Warning] Get Bone Armor, type=nil, spellId=<none>
	[Special Warning] The doctor is in!, type=nil, spellId=<none>
	[Special Warning] %s damage - move away, type=gtfo, spellId=114009

Timers:
	Rusting ends, time=15.00, type=active, spellId=113765, triggerDeltas = 50.84, 2.11, 4.39, 2.30, 2.41, 7.83
		[50.84] SPELL_AURA_APPLIED: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 0
		[52.95] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 2, 0
			 Triggered 5x, delta times: 52.95, 4.39, 2.30, 2.41, 7.83
		[71.73] SPELL_AURA_REMOVED: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 0
	Bone Spike, time=8.00, type=cd, spellId=113999, triggerDeltas = 48.30, 5.81, 9.73
		[48.30] ENCOUNTER_START: 1428, Rattlegore, 1, 5, 0
		[54.11] SPELL_CAST_START: [Rattlegore: Bone Spike] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, "", nil, 0x0, 113999, Bone Spike, 0, 0
			 Triggered 2x, delta times: 54.11, 9.73

Announces:
	Bone Spike on >%s<, type=target, spellId=113999, triggerDeltas = 54.21, 9.73
		[54.21] Scheduled at 54.11 by SPELL_CAST_START: [Rattlegore: Bone Spike] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, "", nil, 0x0, 113999, Bone Spike, 0, 0
		[63.94] Scheduled at 63.84 by SPELL_CAST_START: [Rattlegore: Bone Spike] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, "", nil, 0x0, 113999, Bone Spike, 0, 0

Special warnings:
	%d stacks of Rusting on you, type=stack, spellId=113765, triggerDeltas = 62.05, 7.83
		[62.05] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 5, 0
			 Triggered 2x, delta times: 62.05, 7.83

Yells:
	None

Voice pack sounds:
	VoicePack/stackhigh
		[62.05] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 5, 0
			 Triggered 2x, delta times: 62.05, 7.83

Icons:
	None

Event trace:
	[ 0.00] ADDON_LOADED: DBM-Party-MoP, 0
		RegisterEvents: Regular, CHAT_MSG_MONSTER_YELL
	[48.30] ENCOUNTER_START: 1428, Rattlegore, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_AURA_APPLIED 113765, SPELL_AURA_APPLIED_DOSE 113765, SPELL_AURA_REMOVED 113996 113765, SPELL_CAST_START 113999, SPELL_DAMAGE 114009
		StartTimer: 6.5, Bone Spike
	[50.84] SPELL_AURA_APPLIED: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 0
		StartTimer: 15.0, Rusting ends
	[52.95] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 2, 0
		StartTimer: 15.0, Rusting ends
	[54.11] SPELL_CAST_START: [Rattlegore: Bone Spike] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, "", nil, 0x0, 113999, Bone Spike, 0, 0
		ScheduleTask: mod:BoneSpikeTarget() at 54.21 (+0.10)
			ShowAnnounce: Bone Spike on Nothankies
		StartTimer: 8.0, Bone Spike
	[57.34] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 3, 0
		StartTimer: 15.0, Rusting ends
	[59.64] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 4, 0
		StartTimer: 15.0, Rusting ends
	[62.05] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 5, 0
		StartTimer: 15.0, Rusting ends
		AntiSpam: 3
		ShowSpecialWarning: 5 stacks of Rusting on you
		PlaySound: VoicePack/stackhigh
	[63.84] SPELL_CAST_START: [Rattlegore: Bone Spike] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, "", nil, 0x0, 113999, Bone Spike, 0, 0
		ScheduleTask: mod:BoneSpikeTarget() at 63.94 (+0.10)
			ShowAnnounce: Bone Spike on Nothankies
		StartTimer: 8.0, Bone Spike
	[69.88] SPELL_AURA_APPLIED_DOSE: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 6, 0
		StartTimer: 15.0, Rusting ends
		AntiSpam: 3
		ShowSpecialWarning: 6 stacks of Rusting on you
		PlaySound: VoicePack/stackhigh
	[71.73] SPELL_AURA_REMOVED: [Rattlegore->Rattlegore: Rusting] Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, Creature-0-3888-1007-7106-59153-00004B39E7, Rattlegore, 0xa48, 113765, Rusting, 0, BUFF, 0
		StopTimer: Timer113765active
	[71.73] ENCOUNTER_END: 1428, Rattlegore, 1, 5, 1, 0
		EndCombat: ENCOUNTER_END
	Unknown trigger
		UnregisterEvents: Regular, SPELL_AURA_REMOVED 113996 113765
]]
