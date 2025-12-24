package ny

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Entity :: struct {
	pos:         Vec2i,
	x_remainder: f32,
	y_remainder: f32,
	size:        Vec2i,
	vel:         Vec2,
	speed:       f32,
	is_grounded: bool,
}

EntityType :: enum {
	Player,
	Hazard,
}

move_entity_x :: proc(entity: ^Entity, level: Level, amount: f32) {
	entity.x_remainder += amount
	move := int(math.round(entity.x_remainder))

	if move != 0 {
		entity.x_remainder -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			if !collide_at(entity^, level, entity.pos + {sign, 0}) {
				entity.pos.x += sign
				move -= sign
			} else {
				entity.vel.x = 0
				break
			}
		}
	}
}

move_entity_y :: proc(entity: ^Entity, level: Level, amount: f32) {
	entity.y_remainder += amount
	move := int(math.round(entity.y_remainder))

	if move != 0 {
		entity.y_remainder -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			if !collide_at(entity^, level, entity.pos + {0, sign}) {
				entity.pos.y += sign
				move -= sign
			} else {
				entity.vel.y = 0
				break
			}
		}
	}
}

collide_at :: proc(entity: Entity, level: Level, pos: Vec2i) -> bool {
	entity_rec := rl.Rectangle{f32(pos.x), f32(pos.y), f32(entity.size.x), f32(entity.size.y)}

	local_x := f32(pos.x)
	local_y := f32(pos.y)

	start_x := int(math.floor(local_x / f32(TILE_SIZE)))
	start_y := int(math.floor(local_y / f32(TILE_SIZE)))

	// Subtract 1 from the size to prevent edge bleed
	end_x := int(math.floor((local_x + f32(entity.size.x) - 1) / f32(TILE_SIZE)))
	end_y := int(math.floor((local_y + f32(entity.size.y) - 1) / f32(TILE_SIZE)))

	for y in start_y ..= end_y {
		for x in start_x ..= end_x {
			if x >= 0 && x < level.width && y >= 0 && y < level.height {
				idx := y * level.width + x

				// Assuming 1 is the solid id
				if level.collision_tiles[idx] == 1 {
					return true
				} else if level.collision_tiles[idx] == 2 {
					fmt.println("Died")
					return true
				}
			}
		}
	}

	return false
}

is_grounded :: proc(entity: Entity, level: Level) -> bool {
	return collide_at(entity, level, entity.pos + {0, 1})
}
