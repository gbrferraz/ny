package ny

import rl "vendor:raylib"

GRAVITY :: 1500.0
MOVE_SPEED :: 200.0
JUMP_FORCE :: -350.0

move_player :: proc(player: ^Entity, game: ^Game, dt: f32) {
	if player.state == .Dying {
		player.vel.y += GRAVITY * dt
		move_entity_y(player, game.level, player.vel.y * dt)
		return
	}

	input_x: f32 = 0
	if rl.IsKeyDown(.LEFT) do input_x -= 1
	if rl.IsKeyDown(.RIGHT) do input_x += 1

	player.vel.x = input_x * MOVE_SPEED

	move_entity_x(player, game.level, player.vel.x * dt)

	player.vel.y += GRAVITY * dt

	if rl.IsKeyPressed(.Z) && is_grounded(game.level.player, game.level) {
		player.vel.y = JUMP_FORCE
	}

	if rl.IsKeyPressed(.X) {
		shoot_arrow(&game.level)
	}

	move_entity_y(player, game.level, player.vel.y * dt)

	if check_hazard(player^, game.level) {
		player_death(player, game)
	}

	update_entity_state(player, game.level)

	clamped_player_pos := rl.Vector2Clamp(
		to_vec2(game.level.player.pos),
		{0, 0},
		{
			f32(game.level.width * TILE_SIZE - game.level.player.size.x),
			f32(game.level.height * TILE_SIZE - game.level.player.size.y),
		},
	)
	player.pos = to_vec2i(clamped_player_pos)

	ent_collision := check_entity_collisions(player^, player.pos, game.level)

	switch ent_collision {
	case .None:
	case .Player:
	case .Arrow:
	case .Goal:
		player_win(game)
	}
}

draw_player :: proc(player: Entity) {
	color: rl.Color

	switch player.state {
	case .Idle:
		color = rl.GREEN
	case .Running:
		color = rl.BLUE
	case .Jumping:
		color = rl.YELLOW
	case .Dying:
		color = rl.RED
	}

	rl.DrawRectangle(
		i32(player.pos.x),
		i32(player.pos.y),
		i32(player.size.x),
		i32(player.size.y),
		color,
	)
}

shoot_arrow :: proc(level: ^Level) {
	arrow := Entity {
		type = .Arrow,
		pos  = level.player.pos + {0, 8},
		vel  = {400, 0},
		size = {14, 1},
	}

	append(&level.entities, arrow)
}

player_death :: proc(player: ^Entity, game: ^Game) {
	// player.state = .Dying
	game.level = load_level("res/levels.ldtk", 0)
}

player_win :: proc(game: ^Game) {
	game.level = load_level("res/levels.ldtk", 1)
}
