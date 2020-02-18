# flame_tileformer

This is a work-in-progress 2D game framework on top of Flame.
As the name suggests it is specifically geared toward 2D platformers,
and uses a tile map based system.

It includes:
 - Physics and collision detection, inspired by:
[Type #2: Tile Based](http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/)
 - Tile based rendering of levels
 - `PhysicalComponent` which is the base class of all components participating in the
physics system.
 - `Tile` a special case physical component for floors/walls/etc
 - `CharacaterComponent` a physical component for anything that moves, has health, etc.

