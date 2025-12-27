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
	level:  Level,
	canvas: rl.RenderTexture,
	cam:    rl.Camera2D,
}

init_game :: proc() -> Game {
	game := Game {
		level = load_level("res/levels.ldtk", 0),
		canvas = rl.LoadRenderTexture(CANVAS_WIDTH, CANVAS_HEIGHT),
		cam = {zoom = 1, offset = {(CANVAS_WIDTH / 2) - 8, (CANVAS_HEIGHT / 2) - 8}},
	}

	return game
}

update_game :: proc(game: ^Game) {
	dt := rl.GetFrameTime()
	move_player(&game.level.player, game, dt)
	update_camera(game)


	for &entity in game.level.entities {
		move_entity_x(&entity, game.level, entity.vel.x * dt)
		move_entity_y(&entity, game.level, entity.vel.y * dt)
	}
}

draw_game :: proc(game: Game, canvas: Canvas) {
	draw_player(game.level.player)

	for entity in game.level.entities {
		rl.DrawRectangleV(to_vec2(entity.pos), to_vec2(entity.size), rl.WHITE)
	}
}
