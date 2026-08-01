
# Cheese Strategist's Helm

A helmet which waits for your health to drop below 30%, and then "gives you the means to restore it." It does this by adding hundreds of "Bound Cheese Wheels" to your inventory, instantly overencumbering you. (The in-game description is intentionally vague about this. That's the joke.) Bound Cheese Wheels can be eaten, but they'll demanifest if dropped, transferred to a container or another actor, or after a timed delay.

## Implementation

The enchantment has three parts: the "trigger" spell script, the "exec" spell script, and the "revoke" spell script.

The "trigger" script just listens to `OnHit`, to apply the "exec" spell to the player when a hit brings them below 30% health. There's one minor detail that's fairly important here: even though the "exec" effect is flagged as "No Recast," a hit from an enchanted weapon can generate multiple `OnHit` calls very close in time; and if each `OnHit` call attempts to apply the spell, the spell still gets applied multiple times (i.e. with multiple Active Effects) even despite the flag. For this reason, the "trigger" script uses a throttle.

The "exec" script adds Bound Cheese Wheels to the target; the amount added is the higher of: the amount of Bound Cheese Wheels needed to restore the target's health to full, presuming that each heals 15 points; and the target's Carry Weight.[^carry-weight] It also applies the "revoke" spell to the target. (The "exec" script also removes all Bound Cheese Wheels from the target when they die; this *shouldn't* be necessary to prevent the player from e.g. reverse-pickpocketing the helmet onto an actor, killing them, and harvesting bound cheese from them, since the script on the cheese should delete cheese when transferred; but I see no reason to remove the behavior, and I guess it's nice to have as a failsafe.)

[^carry-weight]: Not the amount of Bound Cheese Wheels needed to exactly overencumber the target, but just their Carry Weight. If they can carry 200 pounds, they'll get 200 Bound Cheese Wheels. This is a mistake, but I'm not going to fix it, because I think it's funny.

The "revoke" spell and its script remove all Bound Cheese Wheels from the target's inventory once the spell wears off. This is used to prevent the player from hoarding Bound Cheese Wheels indefinitely.

