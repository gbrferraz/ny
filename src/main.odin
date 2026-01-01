package ny

import rl "vendor:raylib"


main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()
	rl.SetMasterVolume(0.1)

	canvas := init_canvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	game := init_game()

	tileset := load_texture_embedded(TILESET_PNG)
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
