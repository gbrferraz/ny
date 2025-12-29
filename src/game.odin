package ny

import rl "vendor:raylib"

Vec2i :: [2]int
Vec2 :: [2]f32

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

CANVAS_WIDTH :: 320
CANVAS_HEIGHT :: 180

CANVAS_RATIO: f32 : SCREEN_WIDTH / CANVAS_WIDTH

TILE_SIZE :: 8

Game :: struct {
	level:       Level,
	level_index: int,
	canvas:      rl.RenderTexture,
	cam:         rl.Camera2D,
}

init_game :: proc() -> Game {
	game := Game {
		level = load_level("res/levels.ldtk", 0),
		canvas = rl.LoadRenderTexture(CANVAS_WIDTH, CANVAS_HEIGHT),
		cam = {zoom = 1, offset = {(CANVAS_WIDTH / 2) - 8, (CANVAS_HEIGHT / 2) - 8}},
	}

	init_player()

	return game
}

update_game :: proc(game: ^Game) {
	dt := rl.GetFrameTime()
	update_entities(game, dt)
	move_player(&game.level.player, dt, game)
	update_camera(game.level.player.pos, game)
}

draw_game :: proc(game: Game, canvas: Canvas) {
	for entity in game.level.entities {
		rl.DrawRectangleV(to_vec2(entity.pos), to_vec2(entity.size), rl.WHITE)
	}

	draw_player(game.level.player)
}
