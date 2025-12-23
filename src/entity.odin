package ny

import "core:math"
import rl "vendor:raylib"

Entity :: struct {
	pos:         Vec2i,
	x_remainder: f32,
	y_remainder: f32,
	size:        Vec2i,
	vel:         Vec2i,
	speed:       f32,
	is_grounded: bool,
}

move_entity_x :: proc(entity: ^Entity, level: Level, solids: [dynamic]Solid, amount: f32) {
	entity.x_remainder += amount
	move := int(math.round(entity.x_remainder))

	if move != 0 {
		entity.x_remainder -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			if !collide_at(entity^, level, solids, entity.pos + {sign, 0}) {
				entity.pos.x += sign
				move -= sign
			} else {
				entity.vel.x = 0
				break
			}
		}
	}
}

move_entity_y :: proc(entity: ^Entity, level: Level, solids: [dynamic]Solid, amount: f32) {
	entity.y_remainder += amount
	move := int(math.round(entity.y_remainder))

	if move != 0 {
		entity.y_remainder -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			if !collide_at(entity^, level, solids, entity.pos + {0, sign}) {
				entity.pos.y += sign
				move -= sign
			} else {
				entity.vel.y = 0
				break
			}
		}
	}
}

collide_at :: proc(
	entity: Entity,
	level: Level,
	solids: [dynamic]Solid,
	check_pos: Vec2i,
) -> bool {
	entity_rec := rl.Rectangle {
		f32(check_pos.x),
		f32(check_pos.y),
		f32(entity.size.x),
		f32(entity.size.y),
	}

	for solid in solids {
		solid_rec := rl.Rectangle {
			f32(solid.pos.x),
			f32(solid.pos.y),
			f32(solid.size.x),
			f32(solid.size.y),
		}

		if rl.CheckCollisionRecs(entity_rec, solid_rec) {
			return true
		}
	}

	local_x := f32(check_pos.x)
	local_y := f32(check_pos.y)

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
				}
			}
		}
	}

	return false
}

is_grounded :: proc(entity: Entity, level: Level, solids: [dynamic]Solid) -> bool {
	return collide_at(entity, level, solids, entity.pos + {0, 1})
}
