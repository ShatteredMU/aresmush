---
toc: 5 - Magic, FS3 Skills, and Combat
summary: Learning & casting spells
aliases:
- magic
- mana
---
For a full explanation of the Magic system, see the [Magic wiki page](/wiki/magic).
# Spells

##Information & Learning Spells
`spells [<name>]` - See a list of your spells or someone else's spells, including spells you are learning.
`spell <spell>` - See the details of a spell.
`spell/search <spell>` - See all characters who know a spell.
`spell/fatigue [<name>]` - See the mana of a character.
**Tip**: You can use `mana` instead of `spell/fatigue`

`spell/learn <spell>` - Spends 1 XP to work toward learning a spell.
`spell/luck <spell>` - Spend 2 luck to remove a week's learning time from a spell, if you have another spell of the same school at the same level.
`spell/discard <spell>`  - Discards a spell. You do not recover any XP, so be sure before doing this.

##Casting Spells
`spell/cast <spell>[+/-mod]` - Cast a spell on yourself, the environment, or an object.
`spell/cast <spell>[+/-mod]/<target>[<target> <target>]` - Cast a spell on one or more targets.
**Tip**: You can use `cast` instead of `spell/cast`

`spell/npc <npc>/<dice>=<spell>[/<target> <target>]` - Have an NPC cast a spell. NPCs can cast any spell. The dice chosen should reflect their Magic attribute + their School rating.

`shield/off <shield>` - Out of combat, turn off a protective shield such as Mind Shield.

`combat/spell <spell>` - Cast a spell on yourself, the environment, or an object in combat.
`combat/spell <spell>/<target>[<target> <target>]` - Cast a spell on one or more targets in combat.
`combat/spell <npc>=<spell>[/<target>]` - Make NPCs and other combatants cast in combat.
`combat/luck spell` - Spend Luck to gain a +3 dice bonus to your spellcasting for one round.
**Tip**: You can use `combat/cast` instead of `combat/spell`

> Magic attacks, armor, armor special, and healing spells can use the mythic as a target; all other spells must target the mage.

## Combat Organizer Commands
`spell/mod <name>=<mod>` - Set someone's spell mod to affect their spell rolls.
**Tip:** Mods only last for one round.
`fatigue/set <name>=<#>` - Set someone's mana pool to a given percentage between 1 and 100. Use whole numbers. 
`fatigue/refund <name>=<spell>[/fail]` - Refund a miscast spell's mana. 

## Admin commands
`spell/add <name>=<spell>` - Add a spell to someone's spell list without spending XP.
`spell/remove <name>=<spell>` - Remove a spell from someone's spell list.
`shield/off <name>=<shield>` - Out of combat, turn off a protective shield such as Mind Shield, Endure Fire, or Endure Cold.
`manarestore` - Instantly restore full mana to all participants in a combat. Intended for testing.
