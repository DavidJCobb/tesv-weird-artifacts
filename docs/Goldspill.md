
# Goldspill

This magic effect causes gold to spill out of the victim's inventory when they're hit. It's available as a ranged spell, and Khahana also has a sword with a Goldspill enchantment that affects targets on contact.

There were a few implementation challenges associated with preventing this effect from bogging down performance; I needed to be able to have hundreds of coins drop in the world without tanking frame rates.


## Initial design

The initial implementation used `akVictim.DropObject` to make the victim drop gold coins. To avoid the coins dropping as a single stack, the script used a loop and dropped coins one at a time; it also attempted to apply a Havok impulse to each one to nudge it in a random-looking angle, but this effect never worked.

(Since `DropObject` and `ApplyHavokImpulse` are both latent functions, I originally attempted to spawn multiple Papyrus call stacks (via `OnUpdate` and `OnItemRemoved`) in order to allow the calls to be made side-by-side. I wanted to avoid there being visible delays between the appearance of each coin. Unfortunately, this had no effect; the additional stacks never ran. I'm not really sure why. It's possible that the execution of a latent call doesn't unlock the caller script-object, which is what would've been necessary for those other stacks to run.)

I couldn't get the Havok impulses to work at all, and worse, I found that frame rates tanked hard after several hundred coins dropped.


## Final design

I had two ideas to try and reduce the burden this effect could have on the game engine:

* Instead of dropping individual coins, create a custom "coin group" object. This object would have a mesh containing five coins (each existing as separate rigid bodies, for independent physics), and it'd be an activator named "Gold (5)" scripted to add the appropriate amount of gold to an actor's inventory when activated.

  My thinking was that this would reduce the number of refs in the area, which would hopefully cut down on a lot of the processing the game would ordinarily have to do. There would still be just as many rigid bodies for the physics engine to crunch through, but there'd be less for Bethesda's own systems (AI, etc.) to have to process.

* Find some way to detect the number of coin-groups in the loaded area, and use this to enforce a cap on how many the Goldspill effect is allowed to spawn.

The typical approach to searching the loaded area for multiple objects is to use quest aliases; however, if your goal is to *count* objects, then you need <var>N</var> aliases in order to count up to <var>N</var>. I wasn't keen on polling by starting and stopping a quest with hundreds of aliases on it, so I tested an alternative approach: trigger volumes. Triggers can be set to only listen for objects in specific collision layers, and they can be given arbitrary sizes, so they seemed perfect for my use case. I could pre-place a trigger volume, give it a massive area (enough to fully cover a loaded outdoor area assuming `uGridsToLoad` is 5), and then move it to the player whenever gold is being spilled.

There were a few snags.

* The Creation Kit allows you to create custom Collision Layers, which can be marked as trigger volumes and associated with individual triggers, so I believed I could create a new Collision Layer in order to have a trigger that detects (i.e. collides with) only `L_CLUTTER` and nothing else. ***Do not ever do this.***
  
  Collision Layer forms exist as a "friendly" way for Bethesda to edit the settings associated with the game's hardcoded collision layers. Each form has a unique ID (separate from the form ID), and the Creation Kit doesn't allow you to view or edit that UID (since changing it on vanilla layers would break them). Layer settings are associated with the UID, not the form ID, during play; the way the Creation Kit assigns UIDs practically guarantees conflicts between mods; and the range of UIDs that are actually safe to use is *extremely small*, so if you try to be clever and use xEdit to edit the `COLL/BNAM` subrecord, you're just going to screw yourself.
  
  The mistake I ran into with this was to try and pick the integer `0x00C0BB01` as a unique ID that I knew no other mod would use. The problem is that the maximum working ID is 63 and the maximum safe ID is 127. Past that, you end up corrupting other information that Skyrim passes to Havok to help it filter out potential collisions as early as possible. I don't know *exactly* how that goes wrong, but having a very large trigger volume use that as its layer UID ended up dropping my performance to *seconds per frame.* The exact same trigger using the normal `L_TRIGGER` layer worked just fine.

* Trigger volumes fire `OnTriggerEnter` and `OnTriggerLeave` whenever an object enters or leaves the trigger. The precise operational definition of "being in a trigger" is that the trigger has a Havok collision shape, the object has a Havok collision shape, and the two are overlapping. If something causes either object to unload its 3D, that will dispatch a "leave" event. If the object then reloads its 3D, such that the overlap is restored, that will dispatch an "enter" event.
  
  This means that if a trigger has a hundred detected refs in it, and the player fast-travels or COCs away, *all of those hundred refs* will *immediately* unload 3D, dispatching a hundred `OnTriggerLeave` Papyrus call stacks *all at once.* I don't know if those are dispatched before or after `OnCellDetach`, but I *do* know that the chances of your script being able to handle `OnCellDetach` before the deluge of `OnTriggerLeave` events is virtually nil. For multiple hundreds of refs, you *will* overburden the script engine and cause it to dump debug information about suspended stacks[^stack-dump] to the Papyrus log.
  
  In turn, this means that we're now subject to two limits: the number of coins we can have in the area before the frame rate tanks, and the number of coins we can have in the area before we risk overstressing the script engine upon abruptly leaving the area. The "coin group" idea is extremely valuable for stretching the latter limit as far as possible, but the more coins we have in a group, the less granularly we can make a Goldspill victim drop coins (i.e. if the number of coins in your inventory is too low, you won't drop anything, because having you drop a coin-group would effectively create gold out of thin air).

* Adding to the above bullet point, the trigger will unload its own 3D (i.e. its Havok collision volume) if you call `MoveTo` and friends on it. When the trigger is in the loaded area, you need to use `TranslateToRef` to move it without unloading its 3D.

[^stack-dump]: The Papyrus script engine executes on multiple threads at a time, allowing multiple script call stacks to run simultaneously. The VM basically maintains a queue and will only process so many call stacks at a time, with the other stacks being "suspended." If the engine ends up with too many suspended stacks, it'll print debug information about all of them to the Papyrus log.

In testing, I found that frame rates would tank at around 280 coin groups, or 1400 rigid bodies for coins. Papyrus stack dumps remained a risk at 200 coin groups (1000 coins), so I lowered the maximum to 140 coin groups (700 coins).

There were a few more minor problems that I had to work out:

* Initially, I tried using `PlaceAtMe` on the player to spawn multiple coin groups using a single latent function call. However, this spawned the coins at or near the player's pivot, which was generally on the ground; the coins would spawn below the ground and fall into the void. I had to switch to looping `PlaceAtMe` calls so I could adjust each ref's position. I ended up spawning the coin groups initially-disabled, fixing their position, and capturing them in an array; then, I'd loop over the array to `EnableNoWait` them all at once.

* It's important that the trigger volume be a persistent ref, so the script that keeps it anchored on the player can always access it.
