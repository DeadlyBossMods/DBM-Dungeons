DBM.Test:Report[[
Test: MoP/Party/Scholomance/JandiceBarov/MoP-Remix
Mod:  DBM-Party-MoP/663

Findings:
	Unused event registration: SPELL_AURA_REMOVED 114062 (Wondrous Rapidity)
	Unused event registration: SPELL_CAST_START 114062 (Wondrous Rapidity)

Unused objects:
	[Announce] Gravity Flux on >%s<, type=target, spellId=114059
	[Announce] Wondrous Rapidity, type=spell, spellId=114062
	[Special Warning] Wondrous Rapidity - dodge attack, type=dodge, spellId=114062
	[Timer] Wondrous Rapidity fades, time=7.50, type=fades, spellId=114062

Timers:
	Gravity Flux, time=12.00, type=cd, spellId=114059, triggerDeltas = 29.42
		[29.42] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-114047-0005CB398B, 114047, 0
	Wondrous Rapidity, time=14.00, type=cd, spellId=114062, triggerDeltas = 0.00
		[ 0.00] ENCOUNTER_START: 1427, Jandice Barov, 1, 5, 0

Announces:
	Whirl of Illusion, type=spell, spellId=113808, triggerDeltas = 7.09, 14.59
		[ 7.09] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-113808-0007CB3974, 113808, 0
		[21.68] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-113808-00024B3983, 113808, 0

Special warnings:
	None

Yells:
	None

Voice pack sounds:
	None

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 1427, Jandice Barov, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_AURA_REMOVED 114062, SPELL_CAST_START 114062, UNIT_SPELLCAST_SUCCEEDED boss1
		StartTimer: 6.0, Wondrous Rapidity
	[ 7.09] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-113808-0007CB3974, 113808, 0
		AntiSpam: 2
		ShowAnnounce: Whirl of Illusion
	[21.68] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-113808-00024B3983, 113808, 0
		AntiSpam: 2
		ShowAnnounce: Whirl of Illusion
	[29.42] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-114047-0005CB398B, 114047, 0
		AntiSpam: 1
		ScheduleTask: mod:GravityFluxTarget() at 29.52 (+0.10)
			Unscheduled by ENCOUNTER_END at 29.43
		StartTimer: 12.0, Gravity Flux
	[29.43] ENCOUNTER_END: 1427, Jandice Barov, 1, 5, 1, 0
		EndCombat: ENCOUNTER_END
		UnscheduleTask: mod:GravityFluxTarget() scheduled by ScheduleTask at 29.42
	Unknown trigger
		UnregisterEvents: Regular, SPELL_AURA_REMOVED 114062
]]
