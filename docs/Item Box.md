
# Item Box

A MiscItem with destruction data; when destroyed, it spawns a random item drop.

The item box's visual design was inspired by Mario Kart 64's item boxes, though in the future I'd like to design something more ornate that matches Skyrim's visual style better. For now, I went with something that was reasonably simple to put together by hand in NifSkope, since that was less hassle than trying to remember how to use Blender or where to find the right NIF plug-in for it.


## Miscellaneous tricks and notes

* The item box has a "shatter" animation that is triggered by hand when it advances to the right destruction stage, and the item box ceases to be solid during this animation. The way this was achieved was by attaching the collision to a nested node, and having the animation teleport this node several miles below the model. This trick was inspired by the `PoisonPlant01.nif` mesh from Dawnguard, which has an animated "collision dummy" node.

* The item box basically always remains upright, no matter how it's influenced by collisions and physics. This was done by tampering with its inertia tensor. [This PDF by Dan Morris](https://dmorris.net/projects/tutorials/inertia.tensor.summary.pdf) does a wonderful job of explaining what the values in an inertia tensor matrix actually *are*, but the ones we care about are the diagonals: these control how much force is required to rotate the model about a given axis. I just set the item box to require an absurd amount of force to rotate about the X and Y axes.

* The Mario Kart 64 decompilation project includes [the exact rotation values used for item boxes' tilting animation](https://github.com/n64decomp/mk64/blob/44c71a7978e6abae95399db732a40186a165e2ee/src/actors/item_box/update.inc.c#L51) in that game: +1 degrees per tick on X and Z, and -2 degrees per tick on Y. The game simulates at 60 TPS, though it renders at a lower FPS as needed to maintain a stable frame rate. I recreated these values in the NIF's animation, but I don't know Mario Kart 64's axis conventions, so it's entirely probable that my model rotates at the wrong speed on one axis.

  * The video [Item Box Evolution in Mario Kart (1992 - 2025)](https://www.youtube.com/watch?v=7LgCKsiggvI) was also a great resource for examining item boxes' animations by eye.





