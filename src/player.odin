package ny

import rl "vendor:raylib"

move_player :: proc(player: ^Entity, level: Level, game: Game, dt: f32) {
	if rl.IsKeyPressed(.X) && is_grounded(game.player, level, game.solids) {
		move_entity_y(player, level, game.solids, -50)
	}

	if rl.IsKeyDown(.LEFT) {
		move_entity_x(player, level, game.solids, -100 * dt)
	}

	if rl.IsKeyDown(.RIGHT) {
		move_entity_x(player, level, game.solids, 100 * dt)
	}
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
