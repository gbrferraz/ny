package ny

import rl "vendor:raylib"

Vec2i :: [2]int
Vec2 :: [2]f32

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

CANVAS_WIDTH :: 320
CANVAS_HEIGHT :: 180

CANVAS_RATIO: f32 : SCREEN_WIDTH / CANVAS_WIDTH

Game :: struct {
	player: Entity,
	canvas: rl.RenderTexture,
	cam:    rl.Camera2D,
}

init_game :: proc() -> Game {
	return {
		player = {size = {16, 16}},
		canvas = rl.LoadRenderTexture(CANVAS_WIDTH, CANVAS_HEIGHT),
		cam = {zoom = 1, offset = {(CANVAS_WIDTH / 2) - 8, (CANVAS_HEIGHT / 2) - 8}},
	}
}

update_game :: proc(game: ^Game, level: Level) {
	dt := rl.GetFrameTime()

	move_player(&game.player, level, game^, dt)

	game.cam.target = to_vec2(game.player.pos)
}

draw_game :: proc(game: Game, canvas: Canvas) {
	draw_player(game.player)
}
