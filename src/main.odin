package new_year

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 720, "Game")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
