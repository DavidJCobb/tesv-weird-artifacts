
# Compass Arrows

Arrows that unleash a blast of light, which travels directly north. The light deals no damage and has no effect on its environment. (I had wanted it to be a powerful shockwave, but couldn't get that working.)

## Implementation

### Firing a projectile northward

The arrows have a projectile object which spawns an invisible explosion; the explosion, in turn, spawns an activator. The activator is scripted: it identifies compass-north, fires a spell in that direction, and self-deletes.

Figuring out compass-north is actually pretty simple. By default, it's the positive-Y-axis direction. If a cell has a `NorthMarker`, it's [trivial to access that](https://ck.uesp.net/wiki/FindClosestReferenceOfType_-_Game) and check its Z-axis rotation.

### The projectile

The column of light is a stripped-down version of the `FXFrostBallWispyProjectile.nif` mesh from the vanilla game. Most effects were stripped out, and the spinning wisps were duplicated and tiled to form a vertical column.

Figuring out the right projectile type to use was a bit tricky, since the exact behavior of each projectile type isn't documented at this time. The "cone" type had the most consistent behavior, with the projectile traveling in the desired direction with the desired gravity and speed. ("Missiles" had the same behavior, except that they'd be destroyed on impact with any surface; if you fired an arrow upslope, the projectile would hit the terrain immediately and despawn.) Other types, like "lobber" or "flame," never moved, and "barrier" hanged the executable outright.

Unfortunately, it doesn't appear to be possible to make a projectile that snaps to and sweeps along the ground; you can give a projectile relatively high gravity to make it hug slopes as it travels down them, but that same projectile won't (necessarily) elevate upward when it hits an upward slope; it may just pass through the slope. This was the impetus for me making the projectile model a tall column of light.

That, of course, led to further problems. I had wanted the projectile to be a powerful damaging blast; I felt that that could make for some quirky gameplay. However, it seems that projectiles have collision synthesized at run-time, and that colliison is spherical. I couldn't figure out how to make a column of collision; embedding a capsule shape into the NIF caused the projectile to fail to move at all.

I could've dug deeper, but reverse-engineering the projectile system feels like it'd be more appropriate as future work, rather than as a precondition of publishing this mod and, by extension, DovahKit's alpha.

