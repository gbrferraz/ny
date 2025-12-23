package ny

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

init_game :: proc() -> Game {
	game := Game {
		player = {size = {16, 16}},
		canvas = rl.LoadRenderTexture(CANVAS_WIDTH, CANVAS_HEIGHT),
		cam = {zoom = 1, offset = {(CANVAS_WIDTH / 2) - 8, (CANVAS_HEIGHT / 2) - 8}},
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

	return game
}

update_game :: proc(game: ^Game) {
	dt := rl.GetFrameTime()

	// Apply player gravity
	move_entity_y(&game.player, game.solids, GRAVITY * dt)

	move_player(&game.player, game^, dt)

	game.cam.target = to_vec2(game.player.pos)
}

draw_game :: proc(game: Game, canvas: Canvas) {
	rl.BeginTextureMode(canvas.render_texture)
	rl.ClearBackground(rl.RAYWHITE)
	rl.BeginMode2D(game.cam)

	draw_player(game.player)
	draw_solids(game)

	rl.EndMode2D()
	rl.EndTextureMode()
}
