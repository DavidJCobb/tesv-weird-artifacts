
# Whimsical Ring

A ring inspired by the equipment item of the same name from *The Legend of Zelda: Oracle of Seasons*. When worn, it drastically lowers the damage the wearer deals with a sword or greatsword, but also gives them a 1% chance to instantly kill an enemy when attacking with either type of weapon.

## Implementation

You might recognize this effect as being very similar to Mehrunes' Razor. The implementation, however, is quite different.

Mehrunes' Razor uses an enchantment with an attached script that checks `Utility.RandomInt()`; the script is also wired up to make certain actors wholly immune to the instant-kill effect. This implementation ensures that the weapon's effect is functional no matter who wields it.

By contrast, the Whimsical Ring uses an armor enchantment whose Magic Effect applies a perk to the wearer. This limits the ring to only affecting the player (because perks can't dynamically be added to NPCs), but it means that the ring can alter the damage dealt by any weapon the wearer wields. (It being limited to the player also prevents potential cheese strats involving reverse-pickpocketing the item onto NPCs and baiting them into equipping it, given that NPC AI probably wouldn't be able to cope with this kind of effect.)

Perk Entry Points are applied in order from higher-priority to lower-priority. As such, the Whimsical Ring has two perk entries: a priority-90 entry that sets the subject's outbound weapon damage to 1 if the subject is using a sword or greatsword; and a priority-89 entry that adds a massive amount of outbound weapon damage if the subject is using a sword or greatsword, and if a random number check passes.

An alternative implementation idea (that I haven't tested) would be to have the enchantment give the player a non-damaging Cloak-archetype effect. The cloak would cast a non-damaging spell on all nearby actors, and this spell would act as a monitoring system: its effect would use a script to listen for `OnHit` and validate any hits taken. If the attacker is wearing the Whimsical Ring and the weapon is a sword or greatsword, the script could roll for the instant-kill check. There would be some jank to work around, stemming from `OnHit` sending multiple events for enchanted weapons; it'd take more effort to implement it this way; but the result would function for anyone wearing the Whimsical Ring, and not just the player.

If there are two lessons you can learn from this implementation, it's not to sleep on perk entry points, and not to consider an implementation better or worse just for (not) having scripts.
