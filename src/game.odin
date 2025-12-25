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
	level:    Level,
	player:   Entity,
	entities: [dynamic]Entity,
	canvas:   rl.RenderTexture,
	cam:      rl.Camera2D,
}

init_game :: proc() -> Game {
	game := Game {
		level = load_level("ldtk/levels.ldtk", 0),
		player = {type = .Player, size = {16, 16}},
		canvas = rl.LoadRenderTexture(CANVAS_WIDTH, CANVAS_HEIGHT),
		cam = {zoom = 1, offset = {(CANVAS_WIDTH / 2) - 8, (CANVAS_HEIGHT / 2) - 8}},
	}

	goal := Entity {
		type = .Goal,
		pos  = {224, 96},
		size = {32, 32},
	}

	append(&game.entities, goal)

	return game
}

update_game :: proc(game: ^Game) {
	dt := rl.GetFrameTime()
	move_player(&game.player, game, dt)
	update_camera(game)
}

draw_game :: proc(game: Game, canvas: Canvas) {
	draw_player(game.player)

	for entity in game.entities {
		rl.DrawRectangleV(to_vec2(entity.pos), to_vec2(entity.size), rl.WHITE)
	}
}
