package ny

import rl "vendor:raylib"

Vec2 :: [2]f32

Entity :: struct {
	pos:         Vec2,
	vel:         Vec2,
	width:       f32,
	height:      f32,
	is_grounded: bool,
}

main :: proc() {
	rl.InitWindow(1280, 720, "Game")
	rl.SetTargetFPS(60)

	player := Entity {
		width  = 16,
		height = 16,
	}

	player_accel: f32 = 0.1
	player_fric: f32 = 0.9
	player_max_vel: f32 = 4.0

	for !rl.WindowShouldClose() {
		player.pos += player.vel

		if rl.IsKeyDown(.LEFT) {
			if player.vel.x > -player_max_vel {
				player.vel.x -= player_accel
			}
		} else if rl.IsKeyDown(.RIGHT) {
			if player.vel.x < player_max_vel {
				player.vel.x += player_accel
			}
		} else {
			player.vel *= player_fric
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawRectangleV(player.pos, {player.width, player.height}, rl.RED)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
