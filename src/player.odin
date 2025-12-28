package ny

import rl "vendor:raylib"

GRAVITY :: 1500.0
MOVE_SPEED :: 120.0
ARROW_SPEED :: 500.0
JUMP_FORCE :: -300.0

current_anim: Animation
player_run: Animation
player_idle: Animation

init_player :: proc() {
	player_idle = {
		texture      = rl.LoadTexture("res/player/idle.png"),
		num_frames   = 2,
		frame_length = 0.5,
		type         = .Idle,
	}
	player_run = {
		texture      = rl.LoadTexture("res/player/run.png"),
		num_frames   = 4,
		frame_length = 0.1,
		type         = .Run,
	}
	current_anim = player_idle
}

move_player :: proc(player: ^Entity, game: ^Game) {
	if player.state == .Dying {return}

	input_x: f32 = 0
	if rl.IsKeyDown(.LEFT) {
		input_x -= 1
		player.last_input = -1
	}
	if rl.IsKeyDown(.RIGHT) {
		input_x += 1
		player.last_input = 1
	}

	player.vel.x = input_x * MOVE_SPEED

	if rl.IsKeyPressed(.Z) && is_grounded(player^, game.level) {
		player.vel.y = JUMP_FORCE
	}

	if rl.IsKeyPressed(.X) {
		shoot_arrow(player^, &game.level)
	}

	if check_hazard(player^, game.level) {
		player_death(player, game)
	}

	update_entity_state(player, game.level)

	#partial switch player.state {
	case .Idle:
		if current_anim.type != .Idle {
			current_anim = player_idle
		}
	case .Running:
		if current_anim.type != .Run {
			current_anim = player_run
		}
	}

	update_animation(&current_anim)

	ent_collision := check_entity_collisions(player^, player.pos, game.level)

	#partial switch ent_collision {
	case .Goal:
		player_win(game)
	}
}

draw_player :: proc(player: Entity) {
	flipped := player.last_input < 0 ? true : false
	draw_animation(current_anim, player.pos, flipped)
}

shoot_arrow :: proc(entity: Entity, level: ^Level) {
	arrow_pos: Vec2i
	arrow_pos = entity.pos + {0, 6}

	arrow := Entity {
		type = .Arrow,
		pos  = arrow_pos,
		vel  = {ARROW_SPEED * f32(entity.last_input), 0},
		size = {14, 1},
	}

	append(&level.entities, arrow)
}

player_death :: proc(player: ^Entity, game: ^Game) {
	// player.state = .Dying
	game.level = load_level("res/levels.ldtk", 0)
}

player_win :: proc(game: ^Game) {
	game.level = load_level("res/levels.ldtk", 1)
}
