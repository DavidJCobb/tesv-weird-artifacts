
# Spring-Loaded Wine

A bottle of wine. If dropped, it launches itself upward. If consumed, it launches the consuming actor upward.


## Limitations

If the player drinks the wine while in first-person, they won't launch as far as they're supposed to, and they'll begin to play the "standing back up" animation in mid-air. This is some sort of engine bug, and there doesn't appear to be any reliable mitigation.

Things I've tried:

* `akTarget.ForceAddRagdollToWorld()` prior to launching. This has no apparent effect.

* Having the actor push themselves away with a small push first, followed by the full push. This launches the actor in the wrong direction, because `ObjectReference.PushActorAway` uses the pushing object's local up-vector, and apparently, that gets skewed for ragdolling actors.

* Spawning an invisible ref near the actor, and having it apply a small push to the actor, followed by the full push. Sometimes, this pushes the actor in the wrong direction. Other times, it has no apparent effect, except that when the player stops being ragdolled, the camera remains stuck in the "ragdoll" state (behaving similarly to `animcam`).

* Using `PushActorAway` to ragdoll the actor, and then `ApplyHavokImpulse` to actually launch the actor. The latter function has no apparent effect even with large force values, even though this is precisely the approach the CK wiki recommends. It's possible that this is uniquely broken for players in first-person view.

* Using `Game.ForceThirdPerson()` to force the player into third-person prior to launch, and `Game.ForceFirstPerson()` after the launch.[^detect-first-person] This completely breaks the player actor: apparently, forcing them into first-person while ragdolling will render the actor completely immobile and stop their physics simulation.

* Using `Game.ForceThirdPerson()` to force the player into third-person prior to launch, listening to an animation event for the player standing back up, and then using `Game.ForceFirstPerson()` at that point. This fails because... I just can't find an event that Papyrus is actually able to detect, pertaining to the actor standing back up. I have the means to convert Havok behavior files from HKX to XML and see all defined event names, but no one has documented (and maybe no one knows) how to tell which events are sent from the graph to the game, rather than vice versa.

* Using `Game.ForceThirdPerson()` to force the player into third-person prior to launch, and just straightforwardly not giving a damn about the player's gameplay preferences. This is still unacceptably disruptive: normally, when you manually switch cameras, the third-person camera zooms out from its minimum distance to the player's preferred distance, and it seems that the Papyrus function does the same thing; but it seems that if this zoom-out is preempted by the player being ragdolled, the player's preferred camera distance will be overwritten by whatever distance the camera managed to zoom out to prior to the ragdoll state. In practice, this means that after the player exits the ragdoll state, the third-person camera snaps to its minimum distance until the player manually zooms out.

[^detect-first-person]: The game offers no direct API for detecting whether the player is currently in first-person view, but it *seems* like you can check whether the player-actor's `i1stPerson` animation graph variable is non-zero.

It's kind of impressive how completely, frustratingly broken Skyrim's player ragdoll behavior is. I've run into even more spectacular bugs with it when working on other projects (e.g. moving the player to a marker in another world or cell, while they're ragdolling, won't reliably update their coordinates, so they may end up stuck out of bounds). I suspect that there's nothing Papyrus alone can do to fix whatever mistakes Bethesda made when they glued the player character code to Havok, so I'm declaring the item's weak effect in first-person a `WONTFIX`.
