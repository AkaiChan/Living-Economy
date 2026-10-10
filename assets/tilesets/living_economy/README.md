# Living Economy — Godot 4 Isometric Tile Kit (Prototype)

## Contents
- `assets/terrain_atlas_128x64.png`: 4×4 isometric terrain atlas, 16 tiles (each 128×64 px).
- `assets/objects_atlas_128x160.png`: 4×3 transparent decoration/structure sprite atlas (12 sprites, each 128×160 px).
- `terrain_tileset.tres`: Godot 4 isometric TileSet resource with 16 terrain atlas tiles.
- `demo_world.tscn` / `demo_world.gd`: a small generated scene with TileMapLayer and separate object sprites.
- `project.godot`: optional standalone sample project.
- `preview.png`: overview of the tile atlas and object sprites.

## Terrain index (left-to-right, top-to-bottom)
0 grass; 1 meadow; 2 forest floor; 3 dirt;
4 road; 5 sand; 6 stone; 7 mountain;
8 snow; 9 water; 10 shallow water; 11 farmland;
12 cobblestone; 13 mud; 14 dry grass; 15 dark water.

## Object index (left-to-right, top-to-bottom)
0 pine; 1 oak; 2 boulder; 3 bush;
4 wooden house; 5 carpenter; 6 inn; 7 mine;
8 market stall; 9 fishing hut; 10 crates; 11 signpost.

## Godot usage
1. For the standalone demo, unzip and open the directory with Godot 4.3+; run `demo_world.tscn`.
2. For an existing project, copy `assets/` and `terrain_tileset.tres` into your project root; add a `TileMapLayer` and set its Tile Set to `terrain_tileset.tres`.
3. TileSet is isometric (`tile_shape = 1`), logical tile size 128×64. Atlas texture regions are also 128×64.
4. Place buildings/trees as `Sprite2D` or in a dedicated object layer, using sprite regions 128×160. Objects are intentionally not baked into terrain.
5. Keep collisions, navigation and sorting configured separately for your game. This kit does not yet contain autotile transitions, collision polygons or animations.

## Design note
These are newly drawn *prototype* tiles in a similar warm, illustrated isometric palette, **not** losslessly extracted from the earlier concept art; the concept art is a composite image with embedded text, shadows and irregular shapes, so cutting it into seamless tiles would not be reliable.

**No modifications were made to the user's Living Economy repository or Build #11.**
