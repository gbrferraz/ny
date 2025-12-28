package ny

import "core:math"
import rl "vendor:raylib"

Entity :: struct {
	type:        EntityType,
	state:       EntityState,
	pos:         Vec2i,
	remainder:   Vec2,
	size:        Vec2i,
	vel:         Vec2,
	speed:       f32,
	last_input:  int,
	use_gravity: bool,
}

EntityType :: enum {
	None,
	Player,
	Arrow,
	Goal,
}

EntityState :: enum {
	Idle,
	Running,
	Jumping,
	Dying,
}

CollisionType :: enum {
	None,
	Solid,
	Hazard,
}

update_entity_state :: proc(entity: ^Entity, level: Level) {
	if entity.state == .Dying {return}

	if !is_grounded(entity^, level) {
		entity.state = .Jumping
	} else if math.abs(entity.vel.x) > 10.0 {
		entity.state = .Running
	} else {
		entity.state = .Idle
	}
}

move_entity_x :: proc(entity: ^Entity, level: Level, amount: f32) {
	entity.remainder.x += amount
	move := int(math.round(entity.remainder.x))

	if move != 0 {
		entity.remainder.x -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			collision := collide_at(entity^, entity.pos + {sign, 0}, level)
			if !collision {
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
	entity.remainder.y += amount
	move := int(math.round(entity.remainder.y))

	if move != 0 {
		entity.remainder.y -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			collision := collide_at(entity^, entity.pos + {0, sign}, level)
			if !collision {
				entity.pos.y += sign
				move -= sign
			} else {
				entity.vel.y = 0
				break
			}
		}
	}
}

collide_at :: proc(entity: Entity, pos: Vec2i, level: Level) -> bool {
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
				tile := CollisionType(level.col_tiles[idx])
				if tile == .Solid {return true}
			}
		}
	}

	ent_collision := check_entity_collisions(entity, pos, level)
	if ent_collision == .Arrow {return true}

	return false
}

is_grounded :: proc(entity: Entity, level: Level) -> bool {
	return collide_at(entity, entity.pos + {0, 1}, level)
}

check_hazard :: proc(entity: Entity, level: Level) -> bool {
	local_x := f32(entity.pos.x)
	local_y := f32(entity.pos.y)

	start_x := int(math.floor(local_x / f32(TILE_SIZE)))
	start_y := int(math.floor(local_y / f32(TILE_SIZE)))

	// Subtract 1 from the size to prevent edge bleed
	end_x := int(math.floor((local_x + f32(entity.size.x) - 1) / f32(TILE_SIZE)))
	end_y := int(math.floor((local_y + f32(entity.size.y) - 1) / f32(TILE_SIZE)))

	for y in start_y ..= end_y {
		for x in start_x ..= end_x {
			if x >= 0 && x < level.width && y >= 0 && y < level.height {
				idx := y * level.width + x
				tile := CollisionType(level.col_tiles[idx])
				if tile == .Hazard {return true}
			}
		}
	}

	return false
}

check_entity_collisions :: proc(entity: Entity, pos: Vec2i, level: Level) -> EntityType {
	entity_rec := rl.Rectangle{f32(pos.x), f32(pos.y), f32(entity.size.x), f32(entity.size.y)}

	for &other in level.entities {
		if entity == other {continue}

		collision_rec := rl.Rectangle {
			f32(other.pos.x),
			f32(other.pos.y),
			f32(other.size.x),
			f32(other.size.y),
		}
		if rl.CheckCollisionRecs(entity_rec, collision_rec) {
			if other.type == .Arrow {
				if entity.vel.y < 0 {continue}

				entity_bottom := entity.pos.y + entity.size.y
				arrow_top := other.pos.y

				if entity_bottom > arrow_top {continue}
			}

			return other.type
		}
	}

	return .None
}

update_entities :: proc(game: ^Game, dt: f32) {
	for &entity in game.level.entities {
		if entity.use_gravity {entity.vel.y += GRAVITY * dt}

		if entity.type == .Player {move_player(&entity, game)}

		move_entity_x(&entity, game.level, entity.vel.x * dt)
		move_entity_y(&entity, game.level, entity.vel.y * dt)

		if entity.type == .Player {
			update_camera(entity.pos, game)
			clamp_entity_to_level(&entity, game.level)
		}
	}
}

clamp_entity_to_level :: proc(entity: ^Entity, level: Level) {
	clamped_pos := rl.Vector2Clamp(
		to_vec2(entity.pos),
		{0, 0},
		{
			f32((level.width * TILE_SIZE) - entity.size.x),
			f32((level.height * TILE_SIZE) - entity.size.y),
		},
	)

	entity.pos = to_vec2i(clamped_pos)
}
