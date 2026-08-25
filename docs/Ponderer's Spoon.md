
# Ponderer's Spoon

A MiscItem that can be used from the inventory. Using it will cause the player to enter the Greybeards' "meditating" pose. The player can exit that pose by performing any movement action.


## Implementation

"Furniture" in Skyrim is any object that locks an actor in place and has them perform a specific animation. A furniture object contains one or more "furniture markers," which can be thought of as "seats" that an actor can sit in or, more generally, as "slots" that an actor can fill. For example, a bench that can seat two people has two "sit" markers, and a double bed has two "sleep" markers. An interesting feature is that furniture can be given keywords, and the game's animations can be set to check for those keywords; so for example, a Jarl's throne has the `isJarlChair` keyword, and the game's animations are set up to check for that and play a different (more authoritative) sitting animation when an actor uses a throne.

This functionality is more powerful than you'd think. Furniture isn't just limited to beds and chairs; it also includes workbenches, wall shackles, and various hiding spots that hostile creatures emerge from to attack the player. These objects all have keywords that the game's animations check for: when you use a Tanning Rack, for example, you are "sitting" on it; the "sitting" animation for `isTanning` "chairs" just looks like an actor crouching in front of a Tanning Rack and using it.

Furniture doesn't even have to be a solid or visible object. There are a number of invisible furniture markers that are used for special animations, such as pouring out a bucket of water, leaning against a counter, kneeling or meditating, writing in a ledger, and similar behaviors. There are also creature-specific markers used for things like dragons perching on towers and rooftops, and cutscene-specific markers used for things like Nocturnal's special pose.

Thus Weird Artifacts includes two generic scripts for spawning an invisible furniture marker, forcing an actor to use it, and deleting the marker when it's no longer being used.

`WeirdArtifactsInvisFurnitureItem` is a script to be attached to MiscItems. When the item is used[^misc-item-equipped], it checks if the actor using it is already using a furniture. If they aren't, then it spawns an invisible furniture and puts the actor into that furniture.

`WeirdArtifactsInvisFurniture` is a script attached to the invisible furniture objects that we spawn. It polls on a timer to detect when the furniture is no longer in use, so the furniture can be deleted afterward. Polling begins when the furniture object is made aware of the actor that should be using it.

[^misc-item-equipped]: The `OnItemEquipped` event on `ObjectReference` is fired when the player equips the ref, *or* if the ref is a MiscItem and the player attempts to use it from the inventory menu. The event is fired even though MiscItems are not normally usable, and even though trying to use them shows the player an error notification. This makes it possible to define MiscItems with bespoke behaviors that can be activated from the inventory menu.

### Notes

* Invisible-furniture base forms must have a name, though it can be all-whitespace. The game is hardcoded to prevent the player from activating nameless refs (unless those refs are TalkingActivators).

* Unfortunately, there's no good way to punt the player into third-person while using invisible furniture. The `FurnitureForce3rdPreson` keyword triggers forced third-person view but disables camera controls. The `Game.ForceThirdPerson()` API triggers forced third-person view, but pulls the camera into the minimum distance rather than using the player's preferred camera distance.
  
  This is especially awkward because some invisible furniture markers have no visible "exit" animation if the player is in first-person.

* It is extremely important to avoid disabling the furniture while the player is still using it. Doing so by mistake seems to have the effect of the player no longer being in a furniture state (such that they're now actionable) but still having "in furniture" physics (such that they lack gravity or collision).
