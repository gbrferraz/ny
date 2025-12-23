package ny

import rl "vendor:raylib"

Solid :: struct {
	pos:         Vec2i,
	size:        Vec2i,
	x_remainder: f32,
	y_remainder: f32,
}

draw_solids :: proc(game: Game) {
	for solid in game.solids {
		rl.DrawRectangle(
			i32(solid.pos.x),
			i32(solid.pos.y),
			i32(solid.size.x),
			i32(solid.size.y),
			rl.RED,
		)
	}
}
