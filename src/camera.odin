package ny

import rl "vendor:raylib"

update_camera :: proc(target: Vec2i, game: ^Game) {
	game.cam.target = to_vec2(target)

	level_w_px := f32(game.level.width * TILE_SIZE)
	level_h_px := f32(game.level.height * TILE_SIZE)

	min_x := game.cam.offset.x
	min_y := game.cam.offset.y

	max_x := level_w_px - f32(CANVAS_WIDTH) + game.cam.offset.x
	max_y := level_h_px - f32(CANVAS_HEIGHT) + game.cam.offset.y

	max_x = max(max_x, min_x)
	max_y = max(max_y, min_y)

	game.cam.target = rl.Vector2Clamp(game.cam.target, {min_x, min_y}, {max_x, max_y})
}
