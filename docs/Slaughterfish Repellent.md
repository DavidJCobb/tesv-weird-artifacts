
# Slaughterfish Repellent

A potion inspired by the Treasure item of the same name in Elder Scrolls Online. Consuming one will cause Slaughterfish (that aren't frenzied) to ignore you.


## Implementation

Bethesda uses Factions to manage aggression between actors, but also between creatures. For example, all Slaughterfish belong to the `SlaughterfishFaction`, and all netches from Solstheim belong to `DLC2NetchFaction`; and after you progress a ways into the Dragonborn DLC, a quest script will mark those two factions as friends with each other. This means that even the most aggressive actors in either faction won't attack members of the other faction unless frenzied.

Slaughterfish Repellent uses a similar trick. We have a `WeirdArtifactsSlaughterfishFriendFaction` defined in the editor with no faction relationships initially set up. When you consume Slaughterfish Repellent, we use scripts to make that faction and `SlaughterfishFaction` friends with each other, and we then add you to our "Slaughterfish friend faction." This means that any Slaughterfish that aren't already aggroed to you will no longer aggro to you by default.

Of course, if you consume the repellent while a Slaughterfish is actively targeting you, we want it to stop. To do this, the repellent also contains a Cloak-archetype effect which casts a spell. That spell uses conditions to apply only to Slaughterfish, and it uses scripts to check the Slaughterfish's current combat target[^combat-target]. If it's targeting a member of our "friend" faction, then we stop its combat.

[^combat-target]: When actors are in combat, they have a "combat target:" this is the actor they have decided to focus on. Even if an actor is in combat with multiple enemies, it will only have one combat target at a time; it's never trying to bite, hit, or shoot more than one enemy at a time, but it will change its mind about who to bite, hit, or shoot as circumstances change during a fight.
