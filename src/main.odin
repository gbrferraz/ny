package ny

import rl "vendor:raylib"


main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	canvas := init_canvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	game := init_game()

	tileset := rl.LoadTexture("res/tileset.png")
	defer rl.UnloadTexture(tileset)

	for !rl.WindowShouldClose() {
		update_game(&game)

		rl.BeginTextureMode(canvas.render_texture)
		rl.ClearBackground(rl.RAYWHITE)
		rl.BeginMode2D(game.cam)

		draw_level(game.level, tileset)
		draw_game(game, canvas)

		rl.EndMode2D()
		rl.EndTextureMode()

		rl.BeginDrawing()
		rl.ClearBackground(rl.RED)

		draw_canvas(canvas)

		rl.EndDrawing()
	}
}

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
