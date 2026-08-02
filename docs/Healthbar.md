
# Healthbar

A spell that displays a floating healthbar above an NPC's head. The healthbar isn't "true" UI; it's a 3D model that renders above the player's head, using animation and scripting tricks to adjust how full it is. To make the meter mimic the vanilla UI, I just ripped the vanilla SVGs, deleted a few redundant vertices and quadratic curves, and ported the resulting paths into a 3D mesh.

This is actually a pretty bad way to display a healthbar, but if you need something that can run without SKSE or any UI mods, it's not *terrible.* The main issue is that since it's an in-world 3D node with a fixed offset to its actor, it can become illegible at far distances, it can be obscured by scenery, and displaying multiple such meters on the same actor would be... complicated.

The inability to display multiple such meters on the same actor is probably the worst limitation. Based on the knowledge I have presently, you'd need one NIF for every possible combination of displayed meter and position. If there were some way to feed the value of a Havok behavior graph variable directly into the position of an animation bone, then you could potentially give each meter its own variable to influence its Z-offset, and then manage the value of those variables using Papyrus, but even that is still janky as hell.


## Implementation

A model used for an Art Object can elect to attach itself to a specific node on the target actor. This is accomplished by adding a `NiStringsExtraData` to the root node, with name `AttachT`. The value should be a single string with the text `NamedNode&NODE NAME HERE`, e.g. `NamedNode&NPC Head [Head]`.

If you need a NIF that can be interpolated between two animation states based on the value of a float-type Havok behavior graph variable, you can have the NIF use the "blend between states" behavior graph from the vanilla game.[^nif-using-graph] If this NIF is an Art Object or ArmorAddon, you can call `Actor.SetSubGraphFloatVariable` on the actor to whom it has been attached. Bear in mind that the "blend betwen states" graph is used by some DLC effects that are applied to the player during cutscenes.

[^nif-using-graph]: You can attach a `BSBehaviorGraphExtraData` to the root node with name `BGED`. For the "blend between states" graph, use the following graph path, and have Papyrus adjust the `fToggleBlend` variable. Your two states should be `NiControllerSequence`s on the root node's `NiControllerManager` named `partA` and `partB`, where a variable value of 1 displays `partA` in full, and a value of 0 displays `partB` in full.
    
    `meshes\genericbehaviors\blendbetweenstatesvariable\blendbetweenstatesvariable.hkx`

The healthbar is a skinned mesh, i.e. it has a single "extent" bone and the "end" edge of the healthbar fill is weighted to that bone. This means that moving that bone will stretch or shrink the healthbar. The healthbar NIF's `partA` and `partB` animations move that bone to full or empty positions, so interpolating between them allows us to control how full the meter is.


## Miscellaneous notes

* I don't know why, but I had to give the "fill" portion of the health meter a very unusual rotation in order for it to display properly. It seems that when a skinned mesh is inside of a billboard node, the game just... doesn't calculate its rotation properly.
  
  This was actually a *nightmare* to investigate, because until I managed to get the camera at the exact right angle, I couldn't see the "fill." The meter looked empty, so I had no idea what was going wrong.

* The "fill" portion of the meter also had to be flagged as a "Decal." Otherwise, it Z-fought with the meter background despite the fact that everything is in a `BSOrderedNode`, which should've prevented that.

* I had wanted to create a copy of the "blend between states variable" Havok project and have it use a unique variable name. Unfortunately, doing this breaks compatibility with the vanilla game: Skyrim absolutely *will not properly handle* any Havok project that isn't listed in `Meshes/AnimationDataSingleFile.txt`.[^animation-data-single-file] This means that the approach this spell uses represents a run-time compatibility risk: I can't apply two visual effects to the same actor using this same behavior graph, because they'll end up sharing the same animation variable name, and it won't be possible to control them independently. (It seems that Bethesda ran into this very problem with their DLCs, given that they shipped a "blend between states variable alt" behavior graph that just uses a different variable name.)

[^animation-data-single-file]: The `Meshes/AnimationDataSingleFile.txt` text file is loaded if the INI setting `[Animation]bLoadCollatedAnimTextData` is set to true, and its contents are stored in the `AnimationClipDataSingleton`. The apparent purpose of this singleton is to facilitate bulk loading of all Havok files related to a given Havok project, all at once, as early as possible; without an index like this, the game would have to load and parse the root project file; then scan it to find relevant character files, and load and parse those; then scan those to find relevant behavior files, and load and parse those; and so on. Indexing all of the content in `AnimationDataSingleFile.txt` means the game doesn't have to follow links between files one at a time; it knows everything it needs to load right off rip.
    
    I don't feel that storing *every single Havok project*'s asset list in *one global index file* was good design, though, and it definitely impedes moddability: this is one of the files that FNIS/Nemesis/Pandora/etc. has to patch for you, so you fundamentally *cannot* ship a mod that contains a new Havok project without taking on an implicit dependency on those tools. To be blunt: I feel that Bethesda did a terrible job of designing this functionality. It would've been far more flexible and mod-friendly to have a `.txt` [sidecar](https://en.wikipedia.org/wiki/Sidecar_file) for each individual Havok project file, and to fall back to the slower, more "manual" approach to loading a Havok project if that project lacks a sidebar.
    
    I don't know what happens if you disable the INI setting. The setting *is* functional insofar as it makes the game skip loading these text files, but I don't know if it's *supported*: maybe disabling it causes the game to fall back to loading files one at a time, allowing greater flexibility at the cost of slower asset loading; or maybe disabling it just prevents the game from looking up Havok files at all, so every Havok-based animation in the game just breaks. No clue. I don't see any point in testing it right now, because disabling the setting isn't an option for this mod: I don't want it to require external dependencies or user-side INI edits.
