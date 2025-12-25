package ny

import "ldtk"
import rl "vendor:raylib"

TILE_SIZE :: 8

Level :: struct {
	width:           int,
	height:          int,
	tiles:           []Tile,
	collision_tiles: []u8,
}

Tile :: struct {
	src:    rl.Rectangle,
	dest:   rl.Rectangle,
	flip_x: bool,
	flip_y: bool,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	game := init_game()
	canvas := init_canvas(320, 180)

	tileset := rl.LoadTexture("res/tileset.png")
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

load_level :: proc(filename: string, index: int) -> Level {
	project, ok := ldtk.load_from_file(filename).?
	if !ok {return {}}

	if index < 0 || index >= len(project.levels) {return {}}

	raw_level := project.levels[index]
	level: Level

	for layer in raw_level.layer_instances {
		switch layer.type {
		case .IntGrid:
			level.width = layer.c_width
			level.height = layer.c_height

			level.collision_tiles = make([]u8, level.width * level.height)
			level.tiles = make([]Tile, len(layer.auto_layer_tiles))

			for val, idx in layer.int_grid_csv {
				level.collision_tiles[idx] = u8(val)
			}

			for val, idx in layer.auto_layer_tiles {
				level.tiles[idx].src = rl.Rectangle {
					f32(val.src[0]),
					f32(val.src[1]),
					TILE_SIZE,
					TILE_SIZE,
				}

				level.tiles[idx].dest = rl.Rectangle {
					f32(val.px[0]),
					f32(val.px[1]),
					TILE_SIZE,
					TILE_SIZE,
				}

				level.tiles[idx].flip_x = (val.f & 1) != 0
				level.tiles[idx].flip_y = (val.f & 2) != 0
			}

			return level

		case .Entities:
		case .Tiles:
		case .AutoLayer:
		}
	}

	return {}
}

draw_level :: proc(level: Level, tileset: rl.Texture2D) {
	for tile in level.tiles {
		src := tile.src

		if tile.flip_x {src.width *= -1}
		if tile.flip_y {src.height *= -1}

		rl.DrawTexturePro(tileset, src, tile.dest, {0, 0}, 0, rl.WHITE)
	}
}

update_camera :: proc(game: ^Game) {
	game.cam.target = to_vec2(game.player.pos)

	level_w_px := f32(game.level.width * TILE_SIZE)
	level_h_px := f32(game.level.height * TILE_SIZE)

	min_x := game.cam.offset.x
	min_y := game.cam.offset.y

	max_x := level_w_px - f32(CANVAS_WIDTH) + game.cam.offset.x
	max_y := level_h_px - f32(CANVAS_HEIGHT) + game.cam.offset.y

	max_x = max(max_x, min_x)
	max_y = max(max_y, min_y)

	game.cam.target = rl.Vector2Clamp(game.cam.target, {min_x, min_y}, {max_x, max_y})
}
