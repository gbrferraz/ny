package ny

import "core:fmt"
import rl "vendor:raylib"

Vec2i :: [2]int
GRAVITY :: 200

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

CANVAS_WIDTH :: 320
CANVAS_HEIGHT :: 180

CANVAS_RATIO: f32 : SCREEN_WIDTH / CANVAS_WIDTH

Game :: struct {
	solids: [dynamic]Solid,
	player: Entity,
	canvas: rl.RenderTexture,
	cam:    rl.Camera2D,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()

	game := Game {
		player = {size = {16, 16}},
		canvas = rl.LoadRenderTexture(CANVAS_WIDTH, CANVAS_HEIGHT),
		cam = {zoom = 1, target = {0, 0}},
	}

	solid := Solid {
		pos  = {0, 180 - 16},
		size = {320, 16},
	}

	solid2 := Solid {
		pos  = {32, 180 - 64},
		size = {16, 16},
	}

	append(&game.solids, solid)
	append(&game.solids, solid2)

	source_rec := rl.Rectangle {
		0,
		0,
		f32(game.canvas.texture.width),
		-f32(game.canvas.texture.height),
	}

	dest_rec := rl.Rectangle {
		-CANVAS_RATIO,
		-CANVAS_RATIO,
		SCREEN_WIDTH + (CANVAS_RATIO * 2),
		SCREEN_HEIGHT + (CANVAS_RATIO * 2),
	}

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		move_entity_y(&game.player, game.solids, GRAVITY * dt)

		if rl.IsKeyPressed(.X) && is_grounded(game.player, game.solids) {
			move_entity_y(&game.player, game.solids, -50)
		}

		if rl.IsKeyDown(.LEFT) {move_entity_x(&game.player, game.solids, -100 * dt)}
		if rl.IsKeyDown(.RIGHT) {move_entity_x(&game.player, game.solids, 100 * dt)}

		rl.BeginTextureMode(game.canvas)
		rl.ClearBackground(rl.RAYWHITE)
		rl.BeginMode2D(game.cam)

		rl.DrawRectangle(
			i32(game.player.pos.x),
			i32(game.player.pos.y),
			i32(game.player.size.x),
			i32(game.player.size.y),
			rl.RED,
		)

		for solid in game.solids {
			rl.DrawRectangle(
				i32(solid.pos.x),
				i32(solid.pos.y),
				i32(solid.size.x),
				i32(solid.size.y),
				rl.RED,
			)
		}

		rl.EndMode2D()
		rl.EndTextureMode()

		rl.BeginDrawing()
		rl.ClearBackground(rl.RED)
		rl.DrawTexturePro(game.canvas.texture, source_rec, dest_rec, {0, 0}, 0, rl.WHITE)
		player_grounded := fmt.ctprintf(
			"Player grounded: %v",
			is_grounded(game.player, game.solids),
		)
		rl.DrawText(player_grounded, 10, 10, 20, rl.BLACK)
		rl.EndDrawing()
	}
}
