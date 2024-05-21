DBM.Test:Report[[
Test: MoP/Party/Scholomance/Chillheart/MoP-Remix
Mod:  DBM-Party-MoP/659

Findings:
	Unused event registration: SPELL_CAST_START 111606 (Touch of the Grave)
	Unused event registration: SPELL_DAMAGE 120037 (Ice Wave)

Unused objects:
	[Announce] Berserk in %s %s, type=nil, spellId=<none>
	[Announce] Berserk in %s %s, type=nil, spellId=<none>
	[Announce] Touch of the Grave, type=spell, spellId=111606
	[Special Warning] %s damage - move away, type=gtfo, spellId=120037

Timers:
	Berserk, time=134.00, type=berserk, spellId=<none>, triggerDeltas = 0.00
		[ 0.00] ENCOUNTER_START: 1426, Instructor Chillheart, 1, 5, 0
		[19.21] UNIT_SPELLCAST_SUCCEEDED: boss2, Cast-3-3888-1007-7106-111669-0006CB390B, 111669, 0
	Frigid Grasp, time=10.50, type=next, spellId=111209, triggerDeltas = 0.00, 10.76
		[ 0.00] ENCOUNTER_START: 1426, Instructor Chillheart, 1, 5, 0
		[10.76] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-111209-00044B3903, 111209, 0
		[19.21] UNIT_SPELLCAST_SUCCEEDED: boss2, Cast-3-3888-1007-7106-111669-0006CB390B, 111669, 0

Announces:
	Stage 2, type=stage, spellId=<none>, triggerDeltas = 19.21
		[19.21] UNIT_SPELLCAST_SUCCEEDED: boss2, Cast-3-3888-1007-7106-111669-0006CB390B, 111669, 0
	Frigid Grasp, type=spell, spellId=111209, triggerDeltas = 10.76
		[10.76] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-111209-00044B3903, 111209, 0

Special warnings:
	None

Yells:
	None

Voice pack sounds:
	None

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 1426, Instructor Chillheart, 1, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_CAST_START 111606, SPELL_DAMAGE 120037, UNIT_SPELLCAST_SUCCEEDED boss1 boss2
		StartTimer: 10.5, Frigid Grasp
		StartTimer: 134.0, Berserk
		ScheduleTask: announce:Schedule(1.0, "min") at 74.00 (+74.00)
			Unscheduled by UNIT_SPELLCAST_SUCCEEDED at 19.21
		ScheduleTask: announce:Schedule(30.0, "sec") at 104.00 (+104.00)
			Unscheduled by UNIT_SPELLCAST_SUCCEEDED at 19.21
		ScheduleTask: announce:Schedule(10.0, "sec") at 124.00 (+124.00)
			Unscheduled by UNIT_SPELLCAST_SUCCEEDED at 19.21
	[10.76] UNIT_SPELLCAST_SUCCEEDED: boss1, Cast-3-3888-1007-7106-111209-00044B3903, 111209, 0
		AntiSpam: 2
		ShowAnnounce: Frigid Grasp
		StartTimer: 10.5, Frigid Grasp
	[19.21] UNIT_SPELLCAST_SUCCEEDED: boss2, Cast-3-3888-1007-7106-111669-0006CB390B, 111669, 0
		AntiSpam: 3
		ShowAnnounce: Stage 2
		StopTimer: Timer111209next
		UnscheduleTask: announce:Schedule(10.0, "sec") scheduled by ScheduleTask at 0.00
		UnscheduleTask: announce:Schedule(30.0, "sec") scheduled by ScheduleTask at 0.00
		UnscheduleTask: announce:Schedule(1.0, "min") scheduled by ScheduleTask at 0.00
		StopTimer: Berserk
	[21.67] UNIT_DIED: [->Instructor Chillheart's Phylactery] "", nil, 0x0, Creature-0-3888-1007-7106-58664-00004B386C, Instructor Chillheart's Phylactery, 0xa48, -1, false, 0, 0
		EndCombat: All Mobs Down
]]
