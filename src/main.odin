package ny

import "core:fmt"
import rl "vendor:raylib"

GameScreen :: enum {
	Logo,
	Title,
	Settings,
	Gameplay,
	Ending,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()
	rl.SetMasterVolume(0.1)

	canvas := init_canvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	screen: GameScreen
	game := init_game()

	screen = .Logo

	selected_index := 0
	menu_options := []cstring{"Start Game", "Options", "Quit"}

	logo_texture := load_texture_embedded(LOGO_PNG)

	tileset := load_texture_embedded(TILESET_PNG)
	defer rl.UnloadTexture(tileset)

	for !rl.WindowShouldClose() {
		switch screen {
		case .Logo:
			key_pressed := rl.GetKeyPressed() != rl.KeyboardKey(0)
			if rl.GetTime() > 2 || key_pressed {screen = .Title}
		case .Title:
			update_title(&selected_index, menu_options)
		case .Settings:
		case .Gameplay:
			update_game(&game)
		case .Ending:
		}

		rl.BeginTextureMode(canvas.render_texture)
		rl.ClearBackground(rl.RAYWHITE)

		switch screen {
		case .Logo:
			rl.DrawTexture(logo_texture, 0, 0, rl.WHITE)
		case .Title:
			draw_title(&screen, selected_index, menu_options)
		case .Settings:
		case .Gameplay:
			draw_game(game, canvas)
		case .Ending:
		}

		rl.EndTextureMode()

		rl.BeginDrawing()
		rl.ClearBackground(rl.RED)
		draw_canvas(canvas)
		rl.EndDrawing()
	}
}

update_title :: proc(selected_index: ^int, menu_options: []cstring) {
	if rl.IsKeyPressed(.W) || rl.IsGamepadButtonPressed(0, .LEFT_FACE_UP) {
		selected_index^ -= 1
		if selected_index^ < 0 {
			selected_index^ = len(menu_options) - 1
		}
	}

	if rl.IsKeyPressed(.S) || rl.IsGamepadButtonPressed(0, .LEFT_FACE_DOWN) {
		selected_index^ += 1
		if selected_index^ >= len(menu_options) {
			selected_index^ = 0
		}
	}
}

draw_title :: proc(screen: ^GameScreen, selected_index: int, menu_options: []cstring) {
	rl.DrawText("Ny", 10, 10, 10, rl.BLACK)

	start_y := 20
	button_height := 16
	button_width := 64
	spacing := 4

	center_x := (CANVAS_WIDTH - button_width) / 2

	for i in 0 ..< len(menu_options) {
		y_pos := start_y + (i * (button_height + spacing))
		rect := rl.Rectangle{f32(center_x), f32(y_pos), f32(button_width), f32(button_height)}

		is_focused := (i == selected_index)
		if is_focused {
			rl.DrawRectangleLinesEx(
				{rect.x - 1, rect.y - 1, rect.width + 2, rect.height + 2},
				1,
				rl.RED,
			)

			rl.DrawTriangle(
				{rect.x - 20, rect.y},
				{rect.x - 20, rect.y + rect.height},
				{rect.x - 5, rect.y + rect.height / 2},
				rl.RED,
			)
		}

		rl.DrawRectangleRec(rect, rl.LIGHTGRAY)
		rl.DrawText(menu_options[i], i32(rect.x + 4), i32(rect.y + 4), 0, rl.BLACK)

		button_pressed :=
			is_focused &&
			(rl.IsGamepadButtonPressed(0, .RIGHT_FACE_DOWN) || rl.IsKeyPressed(.ENTER))

		if button_pressed {
			fmt.println("Activated options: ", menu_options[i])
			switch menu_options[i] {
			case "Start Game":
				screen^ = .Gameplay
			case "Quit":
				rl.CloseWindow()
			}
		}
	}
}
