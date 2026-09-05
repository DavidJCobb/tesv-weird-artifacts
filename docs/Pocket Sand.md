
# Pocket Sand

A throwable that can be used to blind enemies within a short range. This has the same basic implementation as the Never-Melting Snowball, as far as throwable weapons go; where it differs is in the effects it applies to the target.


## Implementation

### Blindness

Since at least *Oblivion*, Bethesda's games have defined a "Blindness" actor value that influences how well an actor can visually detect others. The value is measured in the range [0, 100] such that increasing it will make it harder for the actor to see other people; when it's at 100, the actor will be totally incapable of detecting targets by sight.

To increase Blindness, you have to define a Magic Effect using the Peak Value Modifier archetype[^pvm] targeting the Blindness actor value, with Recover enabled and Detrimental disabled[^detrimental]. The effect magnitude influences how much an actor's vision is impaired.

[^pvm]: Using a Value Modifier effect will not work. The game checks an actor's current blindness and clamps it to the a value between 0 and 100, inclusive. However, actors' max blindness is zero by default. You need to buff an actor's max blindness (which implicitly also buffs their current blindness).

[^detrimental]: By default, Detrimental effects will decrease an actor value. Bethesda *can* mark an actor value as being inverted, to signal to the game engine that higher values are worse, and in that case a Detrimental effect will increase that actor value. However, Bethesda forgot to do this for the Blindness actor value, so a Detrimental effect will actually attempt to *reduce* an actor's blindness. It may be easier to keep this straight in your head if you think in terms of whether your effect is detrimental to *the blindness itself.*

Unfortunately, although increasing Blindness *does* impair an actor's ability to detect targets by sight, actors are extremely capable of detecting targets through other means. Actors can have surprisingly robust hearing, and even if an actor can't see or hear you at all, they can still detect you if their Sneak skill is high enough, if yours is low enough, or if the actor's current state (e.g. alerted[^alerted] or in combat) has the effect of boosting the influence of their Sneak skill on detection. This means that even forcing an actor to 100% Blindness isn't enough to prevent them from being able to detect a player. If you COC from the main menu, console-add Silent Casting, cast Muffle on yourself, and then aggro and blind an actor using the default test character, your enemy may still be able to accurately track your movements and hit you with ranged attacks from several meters away.

[^alerted]: An actor is "alerted" if they're aware of the potential presence of an enemy due to that enemy having made a sound, without having fully detected that enemy yet.

As such, Pocket Sand also applies a very large negative modifier to the target's Sneak skill. This completely hoses the actor's ability to detect targets; in combination with blindness, it well ensures that the actor won't be able to detect targets except by sound or direct physical contact. However, it also has some negative side effects: if no one else has come to the target's defense, they may exit combat while still blinded, resuming normal behavior.

It also must be noted that Blindness only influences an actor's detection, i.e. their awareness of enemies' locations. It doesn't affect their ability to path around the environment, their ability to aim with ranged wepaons and spells, their ability to lead moving targets, their ability to dodge incoming projectiles, or any other abilities that would typically rely heavily on sight.


### Strengthening the illusion

Alongside the blindness-related effects, Pocket Sand also applies a few additional effects just to make itself more noticeable: targets are staggered, and their movement speed is lowered, to help sell the illusion that they're struggling to find their way around. Additionally, a subtle particle effect is attached to the actor's head using an Art Object, to make it look like sand is falling out of their eyes.


### The projectile

...is a mess. Projectile forms are almost completely undocumented, which is a problem because the projectile system is, in my experience, *extremely brittle.* Projectiles that aren't set up exactly as Bethesda's programmers expected will malfunction in a wide variety of ways, which is a problem given that they didn't tell us anything useful about how to set them up.[^useful] At this point, I feel like the only way I'll get any usable amount of information about the projectile system is by poring over every inch of it in a disassembler, which I don't have time to do because I'd like to ship the mod (and DovahKit's alpha with it) first.

[^useful]: The CK wiki lists the abstract meanings of the settings, but offers no definite information. It's full of tautologies, telling us that the "gravity" setting controls how much gravity affects the projectile, and the "speed" setting controls the speed of the projectile, without ever giving us units of measurement or points of reference. The list of projectile types tells us what sorts of things they're used for, but not how they actually *behave.* Nothing outlines exactly when and why projectiles de-spawn, or how their physics and collision are set up and processed. There's a "collision layer" setting, but it's totally undocumented, most projectiles set it to "none," and setting it to, say, the "projectile" collision layer will actually *break* your projectile; so the setting appears to be a pointless footgun. Et cetera, et cetera.

My original plan was to use a particle emitter mesh and some basic "cone" settings. However, cones don't actually seem to register hits on targets unless they're given a very high speed. If I give them a high speed, however, then my particle emitter doesn't render. In the final shipped mesh, I kept the emitter anyway but just glued a barebones "puff of smoke" mesh to the model pivot. That's the only visual effect you can see in-game, and it looks slapdash and boring.

I'd also tried a "flame" projectile, which registered hits far more accurately even with a zero speed, but was never visible at all. I tested a dozen other configurations through trial-and-error tinkering and got a variety of bizarre errors, including projectiles that never registered a collision, never played their animations, *and* never de-spawned.
