
# Post-launch plans

## Improvements to existing artifacts

**Blazing Hood:** Change from Fire Resist to boosting fire damage.

**Cheese Strategist's Helm:** Can we get the cheese's "bound item" animation to play initially, so that it plays in the inventory menu? We don't need a "begin" animation, but we do need an "end" animation.

**Boots of the Rain Dancer:** if multiple actors are wearing these, they'll both set weather overrides at the same time. This could lead to scripts fighting over the ability to change the weather, or the ability to release the override. Given that the inspiration for this artifact is Pokemon, let's take inspiration from that and make the fact of Rain Dance being active be global state. Have a dedicated quest to centrally manage the Rain Dance weather override, and have the Magic Effects (that currently trigger weather) just relay events to that quest for it to act on.

## New artifact ideas

### Specific concepts, low-detail
I haven't done much, if anything, to evaluate whether these ideas would be possible or not.

**Club of Limited Familiarity:** Restores the wielder's stamina (maybe via an Absorb effect?) when used to attack hork**er**s, drau**gr**, Heims**kr**, and similarly named enemies. The item description only says, "I hardly know 'er!"

**Invertible Boots / Invertible Gloves:** Gloves and boots that use destruction stages: when you drop the gloves into the world and hit them, they turn into the gloves, and vice versa.

**Point-Blank Bow:** An enchanted bow that does very little damage unless used at extremely close range, in which case it does more damage than an average bow.

**Prod of the World's Center:** A cattle prod (using a stretched fork model) implemented as a weapon that deals no damage and doesn't count as committing a crime. When the player strikes a cow with it, they are teleported to Tamriel cell (0, 0) as a pun on the `CenterOnWorld` console command. If the player speaks to Khahana with this weapon drawn, she can remark on it: "Ah, the prod. Khahana found some texts that mention it. The texts also claim that the world is centered on cows. This one thinks something has been lost in translation."

**Shelled Nut:** A destructible item similar to the Item Box, but it takes multiple hits to destroy, with visible cracks appearing as it takes damage (refer to the TG01 Dwemer Urn for an example to follow). It'd be a consumable item: if eaten intact, it restores a very small amount of health; if destroyed, it'd drop an Unshelled Nut which restores much more health when eaten.

**Thief's Brand:** A ring that significantly boosts thievery-related skills, including by perk entry points. However, it has a random chance of spontaneously framing the player (via `SendStealAlarm` and `SendTrespassAlarm`) for trespassing and for the attempted theft of every single item in their immediate surroundings.

### Vague concepts

* It'd be fun if we had an artifact that encouraged some kind of combo, e.g. building up charge by attacking one enemy and then expending it when attacking another enemy.

### Specific concepts, high-detail

#### Language-Learner's Guide
I originally thought of a book named "BOOK" that, when read, would cause the names of most or all objects and actors to be temporarily replaced with simple nouns For example, bird critters, bird eggs, hagravens, dragons, and Vampire Lords would all display as "BIRD" instead of with their normal names. However, there isn't a good way to implement this outside of possibly UI mods or SKSE DLLs. We can override the label shown on an activation prompt, but not the names displayed in e.g. the combat HUD.

After having done so much with Art Objects, however, I've had an alternate take on the concept. I could create an Art Object that is literally just some text, acting as a label, to be affixed to arbitrary refs. Instead of the book being named "BOOK," the core conceit of the artifact could be that it's a book meant to help people learn English (or whatever it'd be called in-universe; Cyrodilic?) via a magical enchantment that shows labels next to objects.

##### Implementation

There are two basic implementation ideas, each with different strengths and drawbacks:

* The simplest approach would be to have a different mesh for each word we might want to display. This unfortunately would mean creating a *lot* of meshes. Moreover, if we want to attach certain labels to different nodes on a target ref (e.g. actor heads in different animation skeletons), we'd actually need a different NIF for each combination of word to show and `AttachT` to display it near. This approach would, however, work in an otherwise vanilla setup.

* An alternative approach would be to use a custom Havok behavior graph to trigger NetImmerse animations on a single Art Object mesh. That mesh could contain a "palette" of letters, each given its own animation bone, with NetImmerse animations that move and scale these bones as appropriate to display words contextually. However, the use of a custom Havok behavior graph means the user would have to run Pandora/Nemesis for this to work at all. I don't know if either tool generates data that we could check for in Papyrus or conditions, so we'd have no way to make this artifact unavailable to players who haven't installed the mod properly.

Either way, we must consider how to display the labels. The naive approach would be to use one polygon per glyph, with a texture atlas of letters and symbols. However, I'd prefer something closer to vector graphics. The problem is that 3D models are made of triangles; we can't get smooth curves.

An idea I had is to create a texture atlas of different curve shapes: concave, convex, and if necessary "hollow" (i.e. concave on one side and convex on another). Then, the letters can be 3D-modeled and use textures only for round edges. Something like the letter "A" would be a "perfect" vector, since that letter (in Futura Condensed) has no curves; while something like the letter "C" would use curves from the texture atlas to try and get a reasonably smooth curve without a massive polycount.

##### Label ideas

| Word | Entities |
| :- | :- |
| BAG | Sack containers |
| BIRD | Birds; bird eggs (flora and items both); hagravens; dragons (unless dead and souls absorbed); Vampire Lords |
| BONE | Bone-themed items; skeletal NPCs; dead-and-burned dragons |
| BOOK | All books (but, if possible, not slips of paper, letters, etc.; for those see DOCUMENT) |
| BUG | Insectoid ingredients and critters; insectoid or arachnoid enemies; spider grenades from Solstheim |
| CHAIR | Chairs and benches; horses |
| CLOTHES | All apparel that doesn't qualify for a more specific label |
| CONTAINER | All Container forms; beverage/potion bottles, empty or full; coffin furniture |
| CURRENCY | Gold coins; coinpurses |
| DECORATION | Weapon plaques/racks; display cases; mannequins; Dragon Priest mask pedestals; Civil War maps and the flags placed on them; Torygg's War Horn |
| DOCUMENT | notes, letters, and slips of paper, if possible; scrolls, but not throwable weapons implemented as Scroll forms; Elder Scrolls |
| DOG | All canid actors including wolves, Death Hounds, werewolves, familiars, and Barbas |
| DOOR |
| EGG |
| FISH | All fish ingredients and critters; slaughterfish |
| FLOWER | All harvestable flowers and flower-like items |
| FOOD | All food items except those regarded as CONTAINRES; all berry ingredient items (e.g. Snowberries); all dead actors that can be cannibalized, but only while the player is wearing the Ring of Namira |
| GLOVES |
| HAT | Hats; helmets; circlets |
| LADDER |
| HUMAN | All humanoid actors, including draugr, dragon priests, and falmer |
| MECHANISM | All traps that can be disarmed, including strings for rock traps; all pull-chains and buttons; bows and crossbows; Civil War catapults; Dwemer automatons; interactable sawmills and grain mills; musical instruments; Dwemer lexicons; the Imbuing Switch in Solstheim |
| ROCK | Ores, ore deposits, ingots, gemstones, soul gems; Standing Stones; interactable Nordic puzzle pillars; Ash Spawn, gargoyles, fire atronachs, and storm atronachs; Azura's Star, the Black Star, and Meridia's Beacon |
| SHIELD |
| SHOES |
| STICK | Daggers, swords, maces, staves, torches, arrows, crossbow bolts, spears; spriggans and spriggan matrons; puzzle levers |
| TABLE |
| TREE | all harvestable trees; wood chopping blocks |
| WATER | ice wraiths, frost atronachs |

Fallback labels:

* ANIMAL
* CREATURE
* PLANT
* THING

### Specific concepts, high-detail, not doable in vanilla alone
These ideas require either SKSE and third-party DLLs, or Pandora/Nemesis.

#### Headsman's Spells
A collection of spells that are implied to tell a story about a single headsman and her attitude toward her work. Each spell becomes available for purchase only after the player has learned the previous spell, implying a chronlogy. Some of these spells would require being able to add custom animations to the `0_Master` skeleton, so this idea is unworkable without users running Pandora/Nemesis.

* **Headsman's Smile:** A spell that can only be cast on decapitated corpses (`IsLimbGone`). Dissolves the corpse into an ash pile, and restores health for the caster, playing similar VFX to Soul Trap and word-wall learning.

* **Headsman's Spite:** A spell that can only be cast on decapitated corpses. Primes the corpse so that the next non-essential actor who approaches it will be instantly decapitated. This includes the player, though if they cast the spell while already near the corpse, they will not trigger it unless they step away and then approach again.

* **Headsman's Sorrow:** A spell that can only be cast on decapitated corpses. Dissolves the corlse into a pile of flowers (implemented as an ash pile mesh) and fills its inventory with flowers.

* **Headsman's Repentance:** Instantly decapitates the caster.

The sole vanilla codepath for triggering actor decapitation is via the `BSResponse` system, wherein a text file (`actorresponses.text`) maps hardcoded handler names to animation event names. If an animation event with one of these names is dispatched from a behavior graph to the game (or if this dispatch is faked via the `RecvAnimEvent` console command), the relevant handler is looked up and invoked on the actor that owns the graph. The `Decapitate` event triggers `DecapitateHandler`. Thus, a custom animation can send that event to instantly decapitate an actor (optionally sending a separate event to kill them, too).
