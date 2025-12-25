package ny

import "core:fmt"
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

	if rl.IsKeyPressed(.X) && is_grounded(game.player, game.level) {
		player.vel.y = JUMP_FORCE
	}

	move_entity_y(player, game.level, player.vel.y * dt)

	if check_hazard(player^, game.level) {
		player_death(player)
	}

	update_entity_state(player, game.level)

	clamped_player_pos := rl.Vector2Clamp(
		to_vec2(game.player.pos),
		{0, 0},
		{f32(game.level.width * TILE_SIZE), f32(game.level.height * TILE_SIZE)},
	)
	player.pos = to_vec2i(clamped_player_pos)

	ent_collision := check_entity_collisions(player^, game^)

	switch ent_collision {
	case .None:
	case .Player:
	case .Goal:
		fmt.println("Goal achieved")
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

player_death :: proc(player: ^Entity) {
	// player.state = .Dying
	player.pos = {0, 0}
	player.vel = {0, 0}
}

player_win :: proc(game: ^Game) {
	// Level win
	game.level = load_level("ldtk/levels.ldtk", 1)
}
