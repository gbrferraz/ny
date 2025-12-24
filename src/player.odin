package ny

import rl "vendor:raylib"

GRAVITY :: 1500.0
MOVE_SPEED :: 200.0
JUMP_FORCE :: -350.0

move_player :: proc(player: ^Entity, level: Level, game: Game, dt: f32) {
	input_x: f32 = 0
	if rl.IsKeyDown(.LEFT) do input_x -= 1
	if rl.IsKeyDown(.RIGHT) do input_x += 1

	move_entity_x(player, level, input_x * MOVE_SPEED * dt)

	player.vel.y += GRAVITY * dt

	if rl.IsKeyPressed(.X) && is_grounded(game.player, level) {
		player.vel.y = JUMP_FORCE
	}

	move_entity_y(player, level, player.vel.y * dt)

	if check_hazard(player^, level) {
		player_death(player)
	}

	clamped_player_pos := rl.Vector2Clamp(
		to_vec2(game.player.pos),
		{0, 0},
		{f32(level.width * TILE_SIZE), f32(level.height * TILE_SIZE)},
	)

	player.pos = to_vec2i(clamped_player_pos)
}

draw_player :: proc(player: Entity) {
	rl.DrawRectangle(
		i32(player.pos.x),
		i32(player.pos.y),
		i32(player.size.x),
		i32(player.size.y),
		rl.RED,
	)
}

player_death :: proc(player: ^Entity) {
	player.pos = {0, 0}
}
