package ny

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	game := init_game()
	canvas := init_canvas(320, 180)

	for !rl.WindowShouldClose() {
		update_game(&game)

		draw_game(game, canvas)

		rl.BeginDrawing()
		rl.ClearBackground(rl.RED)

		draw_canvas(canvas)

		rl.EndDrawing()
	}
}
