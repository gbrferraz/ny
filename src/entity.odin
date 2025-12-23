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

move_entity_x :: proc(entity: ^Entity, solids: [dynamic]Solid, amount: f32) {
	entity.x_remainder += amount
	move := int(math.round(entity.x_remainder))

	if move != 0 {
		entity.x_remainder -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			if !collide_at(entity^, solids, entity.pos + {sign, 0}) {
				entity.pos.x += sign
				move -= sign
			} else {
				break
			}
		}
	}
}

move_entity_y :: proc(entity: ^Entity, solids: [dynamic]Solid, amount: f32) {
	entity.y_remainder += amount
	move := int(math.round(entity.y_remainder))

	if move != 0 {
		entity.y_remainder -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			if !collide_at(entity^, solids, entity.pos + {0, sign}) {
				entity.pos.y += sign
				move -= sign
			} else {
				break
			}
		}
	}
}

collide_at :: proc(entity: Entity, solids: [dynamic]Solid, check_pos: Vec2i) -> bool {
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

	return false
}

is_grounded :: proc(entity: Entity, solids: [dynamic]Solid) -> bool {
	return collide_at(entity, solids, entity.pos + {0, 1})
}
