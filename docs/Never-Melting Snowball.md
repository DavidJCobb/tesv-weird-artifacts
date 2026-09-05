
# Never-Melting Snowball

A snowball implemented as a Scroll; it can be equipped and thrown. It deals one point of frost damage to any actors hostile to the user, but is otherwise benign and won't provoke actors it hits. It was inspired by the Never-Freezing Snowball, a Treasure item in Elder Scrolls Online.

In Bethesda's Fallout games, grenades and other throwables are implemented as weapons. Skyrim doesn't support throwable weapons, but Scrolls can be used as a hacky replacement; Bethesda themselves did this for the "Spider Scrolls" in the Dragonborn DLC.


## Implementation

To implement a throwable as a scroll, you need three model files: a world/inventory model, a projectile model, and a casting art model. The world/inventory model is the most straightforward: it's just an ordinary 3D model, like you'd make for any new item, with collision and potentially an `INV` marker.

The projectile model should look similar (if not identical) to the world/inventory model, but it *must not* have any Havok collision inside. When a projectile model lacks collision data, the game will set up collision data and physics state for it based on the Projectile form's settings; however, if the model already has its own collision, the game won't bother setting up *any* of that information, including things like the projectile's initial velocity.

The casting art model is the 3D model that will be rendered in an actor's hands when they have the throwable equipped. This should be similar to the world/inventory model, but it shouldn't have collision, and you'll need to give it some animations to make throws look better. We'll move onto that in a moment.

In terms of the form setup you want for your throwable, you'll want to create:

* An Explosion form, to be used when your throwable impacts something.

* A Projectile, with its type set to Missile, using your Explosion. You'll probably want to give it non-zero gravity. This is where you'll specify your projectile model.

* An Art Object, and a Visual Effefct which uses it. This is where you'll specify your casting art model.

* A Magic Effect (Fire and Forget/Aimed) which uses that Projectile. It should also use the Visual Effect as its Casting Art. If there's anything you want your projectile to do to an actor on direct impact (e.g. deal damage, apply an EffectShader, etc.), specify it on this Magic Effect.

* A Scroll which uses that Magic Effect, with a zero casting/charge duration. This is where you'll specify your world/inventory model.

In the case of the snowball, the model itself is pretty simple: an ico-sphere with a tiling snow texture. (I used Blender's Cube Projection to UV it, and while the result looks like an absolute *mess* in a UV editor, it somehow looks good on the actual model with no easily-visible seams. I won't claim to understand it.) This means that the snowball models will hopefully be good as minimal examples.


### Casting art animations

Scrolls are co-opting the game's spellcasting system and animations. This means that if you take your world/inventory model and use it as casting art "verbatim," the act of actually throwing your item will look pretty janky: the game will spawn the projectile in front of the player's hands and animate it forward, but the throwable will still be visible in the player's hands.

Bethesda worked around this with Spider Scrolls by giving the casting art model a casting animation that shrinks it to a very small size. Likewise, they gave it a non-looping(!) intro animation that enlarges it back up to normal size. This shrinking is very fast, and causes the player's view of the casting art to be obscured by their own hands; in essence, it's the closest thing to making the casting art temporarily disappear.[^NiVisController]

[^NiVisController]: In theory, you should be able to use a `NiVisController` to make the casting art disappear. I wasn't able to get this to work properly. NifSkope is *close* to being game-accurate, but it isn't quite there, and it seems to struggle with multiple `NiVisController`s conditionally applying to the same node. I didn't want to have to mess about with the Creation Kit to preview the casting art, so I just went with a downscaling effect instead.

Accordingly:

* Give your casting art model a `BSBehaviorGraphExtraData` block that specifies the vanilla behavior graph `Magic\CastingBasic.hkx`.

* Give your casting art model a `NiControllerManager`, and give that a `NiMultiTargetTransformController` and a `NiDefaultAVObjectPalette`.

  * The multi-target transform controller is needed to be able to manage changes to the transforms (position, rotation, scale) of multiple nodes, or of a single node by multiple animations. This controller should list the NIF's root node as its Target, and any other nodes whose transforms need to be adjusted should be added to the Extra Targets list.
  
  * The object palette is used to map name strings to blocks in the NIF. (Yes, even though blocks already *have* names. No, I don't see the point in why it's architected this way.) Add an entry to it for each node you wish to be able to reference in your animations.

* Create the following `NiControllerSequence`s, and link them to the manager. Each "sequence" is a single animation, and the Havok behavior graph we're using is set up to trigger these animations when the game asks it to.

  * `mIdle`
  * `mCharge`
  * `mReady`
  * `mCast`
  * `mIdleStaff`
  * `mIntro`

  We'll be leaving most of these empty, but it's nice to already have them in the model in case you want to add additional animated effects.

* For `mCast`, add "Controlled Block" entries for each node that you want to scale down. For each of those entries, set the controller to the `NiMultiTargetTransformController`, set the Controller Type to the string "NiTransformController", come up with any unique strings for the Controller ID and Interpolator ID, and then create a `NiTransformInterpolator`.
  
  Within the `NiTransformInterpolator`, create a `NiTrnasformData` and define your animation keys in there. In our case, we want two Scale keys. Bethesda scales spiders down to about 0.23 scale over a third of a second.

* For `mIntro`, follow the same steps, but use different scale values, so that the throwable scales up from nothing in the player's hands. Ensure that the animation is set to `CYCLE_CLAMP` and not `CYCLE_LOOP`, as contrary to its name, it seems to play for the entire time the throwable is being held idly in the player's hands (so "clamp" will ensure it plays once and then waits on its last frame).
  
  The effect of this animation is to make it so that after the player tosses out one throwable, the next "grows" out of thin air in their hands. (There's no way to make the actor run a "reaching down to grab another" animation, at least using vanilla tech only.) This is admittedly pretty cartoony, though not enough so to stop Bethesda from using it for Spider Scrolls. If your throwable has a special theme, you could decide to design a different animation. For example, a magically summoned throwable could play some visual effect as it appears in the actor's hand.


### Explosion model

The above describes the bare-minimum models needed to get a working throwable. However, without an explosion NIF, you'll find that the throwable just vanishes when it hits something.

The Never-Melting Snowball uses an explosion NIF that consists of an editor marker and a particle emitter. NifSkope can't render particle emitters (as of this writing), so we need to preview this NIF in the Creation Kit. The Creation Kit's Preview Window controls are based on the size of the model, so we need an editor marker; otherwise, the model will be zero-size, so it will be impossible to pan or zoom the Preview Window camera.

All you need for an editor marker is the following. (Note that NifSkope is programmed to hide editor markers even if you direct it to show hidden objects, so once you apply these settings, you should see your editor marker disappear from NifSkope's render. You can still see its wireframe if you select the tri-shape directly.)

* A `NiTriShape` whose name is set to `EditorMarker`. For the snowball, I went with a simple ring, borrowing shader data from the XMarker model.

* `BSXFlags` on the root node with the "Editor Marker" flag set. This is necessary to ensure that the marker is hidden in-game.

The particle emitter is quite a bit harder. There are two parts to this. First, we need a `NiControllerManager`, with a `NiControllerSequence` named `SpecialIdle_AreaEffect`: the game is coded to play this animation name automatically when the NIF is spawned as an explosion. Second, we need a `NiNode` containing a `NiParticleSystem` with a boatload of added particle data underneath that. That particle data is... not the *easiest* to edit.


#### A crash course on particle data

This is gonna be *far* from scientific, but I'd argue that a "scientific" overview of things isn't even all that useful when the experience of editing them is so clumsy and janky.

`NiParticleSystem` is the root of the particle data.[^effect-shaders-dead-end] It contains the following elements:

* `NiPSysData`, defining a few core elements of particles.
* A particle emitter such as `NiPSysBoxEmitter`, which defines the bulk of information about how particles are emitted and how they behave.
* Various modifiers that alter the lifespan, movement, or other behaviors of particles as and after they're emitted.

I *highly* recommend that you copy particle systems from existing vanilla NIFs and then tweak them, instead of trying to construct the data fully from scratch in NifSkope. Some good NIFs to pull from include:

| Path | Description |
| :- | :- |
| `meshes/effects/FXSparkFountainToggle.nif` | Emits sparks upward. Contains two animations: `partA` emits particles rapidly and to a large height; `partB` is more subdued and emits particles to a very short height. Model includes an editor marker. |
| `meshes/effects/FXCobwebExplosion02.nif` | Contains two animations: `AutoPlay` releases a spray of large cobweb particles that drift gently horizontally; `AutoLoop` deactivates the emitter. |

It is probably easiest to copy entire NIFs and then alter them. Just remember to add an editor marker if the NIF doesn't already have one, so you can properly preview your particle emitter in the Creation Kit.

If you use an animated NIF, then you'll need to tamper with the animations. If the NIF alters particle behavior (other than by turning things on and off) via its animations, you'll need to either edit behavior values in the animations to configure things like movement, or dismantle those animations. (In other words: the cobweb explosion model might be the easiest to work with, even if you need to bring your own editor marker and even if you want to strip out the drag modifiers.)

[^effect-shaders-dead-end]: Minor fun fact about this: EffectShaders actually use a *completely different* particle system involving `BSParticleShaderProperty` objects and the like, created by the game engine on demand. This has the benefit that EffectShaders *shouldn't* conflict with NIF-based particle systems, I *assume*, but it also means that reverse-engineering either system (like, in a disassembler) won't teach you much about the other.

##### Are there things that I should avoid messing with too much?

Yep! `NiPSysPositionModifier` and `NiPSysBoundUpdateModifier` are required for particle animations to function at all, but they don't contain any useful options for us. Don't mess with them.

`NiPSysModifierActiveCtlr` is an animation controller that can be attached to the particle system itself. When animations defined in a `NiControllerManager` want to toggle a particle modifier on and off, the particle system will have a `NiPSysModifierActiveCtlr` for that modifier whose data just says, "Look, buddy, I don't have anything to tell ya. Go talk to the manager." Unless you're flat-out deleting whatever modifier a modifier-active controller applies to, you should probably just leave the controller alone.

Likewise, `NiPSysEmitterCtlr` plays the same role for the actual particle emitter, referring the game's particle engine to the `NiControllerManager` to control properties like the emitter's particle birth rate and particle radius.

You probably shouldn't tamper with the `NiPSysUpdateCtlr`.

##### How do my particles move?

Initial velocity is determined by values in the `NiPSysBoxEmitter`. 

* Declination and Declination Variation are measured in radians and determines the particle's initial vertical angle. An angle of 0 will send particles straight upward.

* Planar Angle and Planar Angle Variation are also measured in radians, and determine the particle's initial lateral angle (i.e. rotated about the Z-axis).

* Speed and Speed Variation determine the particle's initial movement speed in the direction determined above.

* The "variation" options are random offsets that are added or subtracted from their respective values (i.e. Something +/- Something Variation).

After that, there are a few influences on how particles move:

* `NiPSysGravityModifier` applies a consistent force to each particle, and this is typically used to implement gravity. The force is calculated relative to the specified Gravity Object, a `NiNode`. You can get gravity in a consistent direction by using the `FORCE_PLANAR` force type. Alternatively, you can pull particles toward the Gravity Object by using `FORCE_SPHERICAL`.
  
  The Gravity Axis indicates the direction of the force, and the World-Aligned option controls whether this is relative to the rotation of the Gravity Object. If you want objects to fall straight down, then use a World-Aligned Gravity Axis of (0, 0, -1).
  
  The Strength indicates how quickly particles are pulled, while a non-zero Decay will cause gravity to become weaker the further a particle is from the Gravity Object.

* `NiPSysDragModifier` gradually slows down the movement of particles by some Percentage along a given Drag Axis. You can limit this effect to happen only when particles are within a given Range of a Drag Object. Alternatively, if you want the effect to always apply, you still have to specify a Drag Object, but you can use `<float_max>` as the Range.

* `NiPSysBombModifier` applies an explosive force around a specified Bomb Object (any `NiNode`), blasting particles away. The blast can be spherical, launching particles uniformly away from the Bomb Object; or you can specify a Bomb Axis (relative to the Bomb Object's rotation) and use a cylindrical or planar force.

* `NiPSysRotationModifier` rotates particles about some desired axis as they animate. You can have them rotate about a consistent axis, or randomize the axis per particle.

Note that any of those modifiers can be enabled and disabled using animations. (Accordingly, if you decide to remove a modifier entirely, you'll also need to remove any animation data that referenced the modifier, e.g. "Controlled Blocks" entries in `NiControllerSequences`.)

I don't know what unit of measurement is used for particles. I've found that for the case of a snowball crumbling after being thrown, an initial speed of 80 (+/-)20 and a gravity of 200 looks plausible.

##### How large are my particles?

Check the Initial Radius and Radius Variation values on the `NiPSysBoxEmitter`. You should ensure that the Initial Radius is the larger of the two values, to avoid the game calculating negative sizes.

Additionally, if the particle system has a `BSPSysScaleModifier`, that can specify scaling values. These *appear* to define an animation, scaling particles' sizes over their lifetimes.

##### How long do my particles last?

Check the Life Span and Life Span Variation values on the `NiPSysBoxEmitter`.

You can use a `NiPSysSpawnModifier` to add additional variation to particles' lifespans, as well as enabling them to respawn for a given number of times ("generations"). It can also reduce the percentage of particles that spawn with each generation.

Something to note: I'm not altogether sure how the game decides when an explosion is "done," but I would *expect* that the game at least *might* base its decision on duration of the `SpecialIdle_AreaEffect` animation. If you're trying to adjust the duration of your particle effect, ensure that you're updating the animation values and not just the particle system values.

##### What color are my particles?

The `NiPSysBoxEmitter` sets particles' initial color. However, a `BSPSysSimpleColorModifier` can alter colors further, with its properties behaving as follows:

| Name in NifSkope | Name it *should* have | Effect |
| :- | :- | :- |
| Fade In Percent | Alpha Intro Fade End | The portion of a particle's lifespan spent transitioning from Color 1's alpha to Color 2's alpha. A value in the range \[0, 1\]. |
| Fade Out Percent | Alpha Outro Fade Start | The portion of a particle's lifespan at which it begins transitioning from Color 2's alpha to Color 3's alpha. A value in the range \[0, 1\]. |
| Color 1 End Percent | Color Intro Fade Start | The portion of a particle's lifespan at which it begins transitioning from Color 1's RGB to Color 2's RGB. |
| Color 1 Start Percent | Color Intro Fade End | The portion of a particle's lifespan at which it finishes transitioning from Color 1's RGB to Color 2's RGB. |
| Color 2 End Percent | Color Outro Fade Start | The portion of a particle's lifespan at which it begins transitioning from Color 2's RGB to Color 3's RGB. |
| Color 2 Start Percent | Color Outro Fade End | The portion of a particle's lifespan at which it finishes transitioning from Color 2's RGB to Color 3's RGB. |
| Colors | Colors | The intro, normal, and outro colors, respectively. |

Options on the particle system's `BSEffectShaderProperty` can also influence color, e.g. the emissive color, emissive multiplier, and the "external emittance" shader flag. Remember that the shader property's "Falloff" options can influence the alpha transparency depending on the angle from which you look at the particles; if you set the Falloff Start Angle, Falloff Stop Angle, Falloff Start Opacity, and Falloff Stop Opacity to 1, 0, 1, and 0, respectively, then the particle's alpha won't decrease depending on camera angle.

##### What sprites do my particles use?

Specify the spritesheet texture in the `NiParticleSystem`'s `BSEffectShaderProperty`, as the Source Texture.

Specify the bounding boxes for each sprite (measured in UV coordinates) via the Subtexture Offsets array in `NiPSysData`. NifSkope lists each array element as X, Y, Z, and W; these define the sprite's left edge, width, top edge, and height, respectively. If your sprites are non-square, then you'll want to also check the Aspect Ratio field directly after the array.

If you want to use animated sprites, then you can add a `BSPSysSubTexModifier`. This treats every sprite (subtexture) as a single frame of animation. The meanings of its options aren't fully understood, but after looking at some vanilla NIFs, I believe I can at least say that if you want an animation that doesn't loop, you need to set the End Frame and Loop Start Frame to the same index, and set the Loop Start Frame Fudge to zero.

##### When are my particles emitted?

Whether an emitter (e.g. `NiPSysBoxEmitter`) is active by default is controlled by its "Active" field. However, this is usually overridden by animation controllers.

Your `NiParticleSystem` should have a `NiPSysEmitterCtlr`. This will specify a `NiBlendFloatInterpolator` to control the particle birth rate, and a `NiBlendBoolInterpolator` to control when the emitter is active. If these interpolators have the `MANAGER_CONTROLLED` flag, then the true animation values are provided by other controllers buried in your model's `NiControllerManager`: this means that the birth rate and emitter state can vary depending on what named animation is playing.

When these properties are manager-controlled, the "Controlled Blocks" list for a `NiControllerSequence` (a named animation) will have entries which specify the same `NiPSysEmitterCtlr` but with interpolators unique to the sequence. The "interpolator IDs" will be `BirthRate` and `EmitterActive`.

The birth rate value is measured in seconds. As an example, consider the following data for birth rate, taken from the `fxcobwebexplosion02` NIF:

| Key time | Key value | Quadratic Forward | Quadratic Backward |
| -: | -: |
| 0.000000 | 390 |
| 0.133333 | 390 | 
| 0.466667 |   0 |
| 6.666667 |   0 |

This defines a six-second animation. For the first 2/15ths of a second, the birth rate is 390 particles per second, producing about 52 particles in total over those 2/15ths of a second. Over the next third of a second, the birth rate rapidly drops to 0, such that even if the emitter remains active, it won't produce anything.

##### Where are my particles emitted from?

The `NiPSysBoxEmitter` will specify an Emitter Object (any `NiNode`) and the Width, Height, and Depth of a box-shaped area around that object. Your particles will spawn within that area.

