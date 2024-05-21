DBM.Test:Report[[
Test: Dragonflight/Party/UldamanLegacyOfTyr/TheLostDwarves/MythicPlus
Mod:  DBM-Party-Dragonflight/2475

Findings:
	Unused event registration: SPELL_PERIODIC_DAMAGE 377825 (Burning Pitch)
	Unused event registration: SPELL_PERIODIC_MISSED 377825 (Burning Pitch)

Unused objects:
	None

Timers:
	Wild Cleave, time=17.00, type=cd, spellId=369563, triggerDeltas = 1.00, 7.25, 17.50, 24.98, 18.18
		[ 1.00] Scheduled at 0.00 by ENCOUNTER_START: 2555, The Lost Dwarves, 8, 5, 0
		[ 8.25] SPELL_CAST_START: [Baelog: Wild Cleave] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369563, Wild Cleave, 0, 0
			 Triggered 3x, delta times: 8.25, 42.48, 18.18
		[25.75] SPELL_CAST_START: [Baelog: Longboat Raid!] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
			 Triggered 2x, delta times: 25.75, 49.20
	Heavy Arrow, time=20.60, type=cd, spellId=369573, triggerDeltas = 1.00, 19.41, 5.34, 35.88
		[ 1.00] Scheduled at 0.00 by ENCOUNTER_START: 2555, The Lost Dwarves, 8, 5, 0
		[20.41] SPELL_CAST_START: [Baelog: Heavy Arrow] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369573, Heavy Arrow, 0, 0
			 Triggered 2x, delta times: 20.41, 41.22
		[25.75] SPELL_CAST_START: [Baelog: Longboat Raid!] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
			 Triggered 2x, delta times: 25.75, 49.20
	Defensive Bulwark, time=32.40, type=cd, spellId=369602, triggerDeltas = 1.00, 17.21, 6.33, 34.97
		[ 1.00] Scheduled at 0.00 by ENCOUNTER_START: 2555, The Lost Dwarves, 8, 5, 0
		[18.21] SPELL_AURA_APPLIED: [Olaf->Olaf: Defensive Bulwark] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, 369602, Defensive Bulwark, 0, BUFF, 0
			 Triggered 2x, delta times: 18.21, 41.30
		[24.54] SPELL_CAST_START: [Olaf: Longboat Raid!] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
			 Triggered 2x, delta times: 24.54, 56.50
	Ricocheting Shield, time=16.90, type=cd, spellId=369677, triggerDeltas = 1.00, 16.10, 7.44, 33.83, 16.96
		[ 1.00] Scheduled at 0.00 by ENCOUNTER_START: 2555, The Lost Dwarves, 8, 5, 0
		[17.10] SPELL_CAST_SUCCESS: [Olaf->Legendomega: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Player-121-07C08FEE, Legendomega, 0x511, 369677, Ricocheting Shield, 0, 0
			 Triggered 2x, delta times: 17.10, 41.27
		[24.54] SPELL_CAST_START: [Olaf: Longboat Raid!] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
			 Triggered 2x, delta times: 24.54, 56.50
		[75.33] SPELL_CAST_SUCCESS: [Olaf->Krátos-AzjolNerub: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Player-121-0AC9BA6B, Krátos-AzjolNerub, 0x512, 369677, Ricocheting Shield, 0, 0
	Skullcracker, time=25.50, type=cd, spellId=369791, triggerDeltas = 1.00, 6.05, 17.49, 23.75
		[ 1.00] Scheduled at 0.00 by ENCOUNTER_START: 2555, The Lost Dwarves, 8, 5, 0
		[ 7.05] SPELL_CAST_START: [Eric "The Swift": Skullcracker] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 369791, Skullcracker, 0, 0
			 Triggered 2x, delta times: 7.05, 41.24
		[24.54] SPELL_CAST_START: [Eric "The Swift": Longboat Raid!] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
			 Triggered 2x, delta times: 24.54, 44.37
	Longboat Raid!, time=27.40, type=cd, spellId=375924, triggerDeltas = 24.54
		[24.54] SPELL_CAST_START: [Eric "The Swift": Longboat Raid!] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0

Announces:
	Wild Cleave, type=spell, spellId=369563, triggerDeltas = 8.25, 42.48, 18.18
		[ 8.25] SPELL_CAST_START: [Baelog: Wild Cleave] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369563, Wild Cleave, 0, 0
			 Triggered 3x, delta times: 8.25, 42.48, 18.18
	Ricocheting Shield on >%s<, type=target, spellId=369677, triggerDeltas = 71.53
		[71.53] Scheduled at 71.33 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0

Special warnings:
	Heavy Arrow - dodge attack, type=dodge, spellId=369573, triggerDeltas = 20.41, 41.22
		[20.41] SPELL_CAST_START: [Baelog: Heavy Arrow] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369573, Heavy Arrow, 0, 0
			 Triggered 2x, delta times: 20.41, 41.22
	Defensive Bulwark - interrupt >%s<!, type=interrupt, spellId=369602, triggerDeltas = 18.21, 41.30
		[18.21] SPELL_AURA_APPLIED: [Olaf->Olaf: Defensive Bulwark] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, 369602, Defensive Bulwark, 0, BUFF, 0
			 Triggered 2x, delta times: 18.21, 41.30
	Ricocheting Shield on you, type=you, spellId=369677, triggerDeltas = 13.30, 41.26
		[13.30] Scheduled at 13.10 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
		[54.56] Scheduled at 54.36 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
	Skullcracker - dodge attack, type=dodge, spellId=369791, triggerDeltas = 7.05, 41.24
		[ 7.05] SPELL_CAST_START: [Eric "The Swift": Skullcracker] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 369791, Skullcracker, 0, 0
			 Triggered 2x, delta times: 7.05, 41.24
	%s damage - move away, type=gtfo, spellId=377825, triggerDeltas = 36.05, 7.06
		[36.05] SPELL_AURA_APPLIED: [->Legendomega: Burning Pitch] "", nil, 0x0, Player-121-07C08FEE, Legendomega, 0x511, 377825, Burning Pitch, 0, DEBUFF, 0
			 Triggered 2x, delta times: 36.05, 7.06

Yells:
	Ricocheting Shield on PlayerName, type=yell, spellId=369677
		[13.30] Scheduled at 13.10 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
		[54.56] Scheduled at 54.36 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0

Voice pack sounds:
	VoicePack/chargemove
		[ 7.05] SPELL_CAST_START: [Eric "The Swift": Skullcracker] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 369791, Skullcracker, 0, 0
			 Triggered 2x, delta times: 7.05, 41.24
	VoicePack/kickcast
		[18.21] SPELL_AURA_APPLIED: [Olaf->Olaf: Defensive Bulwark] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, 369602, Defensive Bulwark, 0, BUFF, 0
			 Triggered 2x, delta times: 18.21, 41.30
	VoicePack/shockwave
		[20.41] SPELL_CAST_START: [Baelog: Heavy Arrow] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369573, Heavy Arrow, 0, 0
			 Triggered 2x, delta times: 20.41, 41.22
	VoicePack/targetyou
		[13.30] Scheduled at 13.10 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
		[54.56] Scheduled at 54.36 by SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
	VoicePack/watchfeet
		[36.05] SPELL_AURA_APPLIED: [->Legendomega: Burning Pitch] "", nil, 0x0, Player-121-07C08FEE, Legendomega, 0x511, 377825, Burning Pitch, 0, DEBUFF, 0
			 Triggered 2x, delta times: 36.05, 7.06

Icons:
	None

Event trace:
	[ 0.00] ENCOUNTER_START: 2555, The Lost Dwarves, 8, 5, 0
		StartCombat: ENCOUNTER_START
		RegisterEvents: Regular, SPELL_CAST_START 369573 369563 369791 369677 375924, SPELL_CAST_SUCCESS 369677, SPELL_AURA_APPLIED 369602 377825, SPELL_PERIODIC_DAMAGE 377825, SPELL_PERIODIC_MISSED 377825
		ScheduleTask: (anonymous function) at 1.00 (+1.00)
			StartTimer: 5.0, Skullcracker
			StartTimer: 11.1, Ricocheting Shield
			StartTimer: 16.2, Defensive Bulwark
			StartTimer: 7.1, Wild Cleave
			StartTimer: 19.6, Heavy Arrow
	[ 7.05] SPELL_CAST_START: [Eric "The Swift": Skullcracker] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 369791, Skullcracker, 0, 0
		ShowSpecialWarning: Skullcracker - dodge attack
		PlaySound: VoicePack/chargemove
		StartTimer: 25.5, Skullcracker
	[ 8.25] SPELL_CAST_START: [Baelog: Wild Cleave] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369563, Wild Cleave, 0, 0
		ShowAnnounce: Wild Cleave
		StartTimer: 17.0, Wild Cleave
	[13.10] SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-3135-2451-29622-184580-00003D9B92", "ShieldTarget", 0.1, 8.0, true) at 13.30 (+0.20)
			ShowSpecialWarning: Ricocheting Shield on you
			PlaySound: VoicePack/targetyou
			ShowYell: Ricocheting Shield on PlayerName
	[17.10] SPELL_CAST_SUCCESS: [Olaf->Legendomega: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Player-121-07C08FEE, Legendomega, 0x511, 369677, Ricocheting Shield, 0, 0
		StartTimer: 12.9, Ricocheting Shield
	[18.21] SPELL_AURA_APPLIED: [Olaf->Olaf: Defensive Bulwark] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, 369602, Defensive Bulwark, 0, BUFF, 0
		StartTimer: 32.4, Defensive Bulwark
		ShowSpecialWarning: Defensive Bulwark - interrupt Olaf!
		PlaySound: VoicePack/kickcast
	[20.41] SPELL_CAST_START: [Baelog: Heavy Arrow] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369573, Heavy Arrow, 0, 0
		ShowSpecialWarning: Heavy Arrow - dodge attack
		PlaySound: VoicePack/shockwave
		StartTimer: 20.6, Heavy Arrow
	[24.54] SPELL_CAST_START: [Eric "The Swift": Longboat Raid!] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
		AntiSpam: 1
			Filtered: 2x SPELL_CAST_START at 24.54, 25.75
		StartTimer: 77.7, Longboat Raid!
		StopTimer: Timer369791cd\tCreature-0-3135-2451-29622-184582-00003D9B92
		StartTimer: 23.7, Skullcracker
	[24.54] SPELL_CAST_START: [Olaf: Longboat Raid!] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
		StopTimer: Timer369677cd\tCreature-0-3135-2451-29622-184580-00003D9B92
		StopTimer: Timer369602cd\tCreature-0-3135-2451-29622-184580-00003D9B92
		StartTimer: 29.8, Ricocheting Shield
		StartTimer: 34.1, Defensive Bulwark
	[25.75] SPELL_CAST_START: [Baelog: Longboat Raid!] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
		StopTimer: Timer369573cd\tCreature-0-3135-2451-29622-184581-00003D9B92
		StartTimer: 23.8, Wild Cleave
		StartTimer: 35.0, Heavy Arrow
	[36.05] SPELL_AURA_APPLIED: [->Legendomega: Burning Pitch] "", nil, 0x0, Player-121-07C08FEE, Legendomega, 0x511, 377825, Burning Pitch, 0, DEBUFF, 0
		AntiSpam: 2
		ShowSpecialWarning: Burning Pitch damage - move away
		PlaySound: VoicePack/watchfeet
	[43.11] SPELL_AURA_APPLIED: [->Legendomega: Burning Pitch] "", nil, 0x0, Player-121-07C08FEE, Legendomega, 0x511, 377825, Burning Pitch, 0, DEBUFF, 0
		AntiSpam: 2
		ShowSpecialWarning: Burning Pitch damage - move away
		PlaySound: VoicePack/watchfeet
	[48.29] SPELL_CAST_START: [Eric "The Swift": Skullcracker] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 369791, Skullcracker, 0, 0
		ShowSpecialWarning: Skullcracker - dodge attack
		PlaySound: VoicePack/chargemove
		StartTimer: 25.5, Skullcracker
	[50.73] SPELL_CAST_START: [Baelog: Wild Cleave] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369563, Wild Cleave, 0, 0
		ShowAnnounce: Wild Cleave
		StartTimer: 17.0, Wild Cleave
	[54.36] SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-3135-2451-29622-184580-00003D9B92", "ShieldTarget", 0.1, 8.0, true) at 54.56 (+0.20)
			ShowSpecialWarning: Ricocheting Shield on you
			PlaySound: VoicePack/targetyou
			ShowYell: Ricocheting Shield on PlayerName
	[58.37] SPELL_CAST_SUCCESS: [Olaf->Legendomega: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Player-121-07C08FEE, Legendomega, 0x511, 369677, Ricocheting Shield, 0, 0
		StartTimer: 12.9, Ricocheting Shield
	[59.51] SPELL_AURA_APPLIED: [Olaf->Olaf: Defensive Bulwark] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, 369602, Defensive Bulwark, 0, BUFF, 0
		StartTimer: 32.4, Defensive Bulwark
		ShowSpecialWarning: Defensive Bulwark - interrupt Olaf!
		PlaySound: VoicePack/kickcast
	[61.63] SPELL_CAST_START: [Baelog: Heavy Arrow] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369573, Heavy Arrow, 0, 0
		ShowSpecialWarning: Heavy Arrow - dodge attack
		PlaySound: VoicePack/shockwave
		StartTimer: 20.6, Heavy Arrow
	[68.91] SPELL_CAST_START: [Baelog: Wild Cleave] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 369563, Wild Cleave, 0, 0
		ShowAnnounce: Wild Cleave
		StartTimer: 17.0, Wild Cleave
	[68.91] SPELL_CAST_START: [Eric "The Swift": Longboat Raid!] Creature-0-3135-2451-29622-184582-00003D9B92, Eric "The Swift", 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
		StopTimer: Timer369791cd\tCreature-0-3135-2451-29622-184582-00003D9B92
	[71.33] SPELL_CAST_START: [Olaf: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 369677, Ricocheting Shield, 0, 0
		ScheduleTask: mod:BossTargetScanner("Creature-0-3135-2451-29622-184580-00003D9B92", "ShieldTarget", 0.1, 8.0, true) at 71.53 (+0.20)
			ShowAnnounce: Ricocheting Shield on Krátos
	[74.95] SPELL_CAST_START: [Baelog: Longboat Raid!] Creature-0-3135-2451-29622-184581-00003D9B92, Baelog, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
		StopTimer: Timer369573cd\tCreature-0-3135-2451-29622-184581-00003D9B92
		StopTimer: Timer369563cd\tCreature-0-3135-2451-29622-184581-00003D9B92
	[75.33] SPELL_CAST_SUCCESS: [Olaf->Krátos-AzjolNerub: Ricocheting Shield] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, Player-121-0AC9BA6B, Krátos-AzjolNerub, 0x512, 369677, Ricocheting Shield, 0, 0
		StartTimer: 12.9, Ricocheting Shield
	[81.04] SPELL_CAST_START: [Olaf: Longboat Raid!] Creature-0-3135-2451-29622-184580-00003D9B92, Olaf, 0xa48, "", nil, 0x0, 375924, Longboat Raid!, 0, 0
		StopTimer: Timer369677cd\tCreature-0-3135-2451-29622-184580-00003D9B92
		StopTimer: Timer369602cd\tCreature-0-3135-2451-29622-184580-00003D9B92
	[81.05] ENCOUNTER_END: 2555, The Lost Dwarves, 8, 5, 1, 0
		EndCombat: ENCOUNTER_END
]]
