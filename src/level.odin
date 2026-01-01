package ny

import "ldtk"
import rl "vendor:raylib"

LEVEL_DATA :: #load("../res/levels.ldtk")

Level :: struct {
	player:    Entity,
	entities:  [dynamic]Entity,
	width:     int,
	height:    int,
	tiles:     []Tile,
	col_tiles: []u8,
}

Tile :: struct {
	src:    rl.Rectangle,
	dest:   rl.Rectangle,
	flip_x: bool,
	flip_y: bool,
}

load_level :: proc(index: int) -> Level {
	project, ok := ldtk.load_from_memory(LEVEL_DATA).?
	if !ok {return {}}

	if index < 0 || index >= len(project.levels) {return {}}

	raw_level := project.levels[index]
	level: Level

	for layer in raw_level.layer_instances {
		switch layer.type {
		case .IntGrid:
			level.width = layer.c_width
			level.height = layer.c_height

			level.col_tiles = make([]u8, level.width * level.height)
			level.tiles = make([]Tile, len(layer.auto_layer_tiles))

			for val, idx in layer.int_grid_csv {
				level.col_tiles[idx] = u8(val)
			}

			for val, idx in layer.auto_layer_tiles {
				level.tiles[idx].src = rl.Rectangle {
					f32(val.src[0]),
					f32(val.src[1]),
					TILE_SIZE,
					TILE_SIZE,
				}

				level.tiles[idx].dest = rl.Rectangle {
					f32(val.px[0]),
					f32(val.px[1]),
					TILE_SIZE,
					TILE_SIZE,
				}

				level.tiles[idx].flip_x = (val.f & 1) != 0
				level.tiles[idx].flip_y = (val.f & 2) != 0
			}

			return level
		case .Entities:
			for entity in layer.entity_instances {
				pos := Vec2i{entity.px[0], entity.px[1]}
				new_entity: Entity

				switch entity.identifier {
				case "Player":
					new_entity = {
						type        = .Player,
						pos         = pos,
						size        = {16, 16},
						last_input  = 1,
						use_gravity = true,
					}
					level.player = new_entity
					continue
				case "Goal":
					new_entity = Entity {
						type = .Goal,
						pos  = pos,
						size = {entity.width, entity.height},
					}
				case "Enemy":
					new_entity = Entity {
						type        = .Enemy,
						pos         = pos,
						size        = {16, 16},
						vel         = {-ENEMY_SPEED, 0},
						last_input  = -1,
						use_gravity = true,
					}
				}
				append(&level.entities, new_entity)
			}
		case .Tiles:
		case .AutoLayer:
		}
	}

	return {}
}

draw_level :: proc(level: Level, tileset: rl.Texture2D) {
	for tile in level.tiles {
		src := tile.src

		if tile.flip_x {src.width *= -1}
		if tile.flip_y {src.height *= -1}

		rl.DrawTexturePro(tileset, src, tile.dest, {0, 0}, 0, rl.WHITE)
	}
}
