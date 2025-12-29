package ny

import "core:fmt"
import rl "vendor:raylib"

GRAVITY :: 1500.0
MOVE_SPEED :: 120.0
ARROW_SPEED :: 500.0
JUMP_FORCE :: -300.0

current_anim: Animation
player_run: Animation
player_idle: Animation

jump_sound: rl.Sound
lose_sound: rl.Sound
win_sound: rl.Sound

shoot_sound: rl.Sound

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

	jump_sound = rl.LoadSound("res/player/jump.wav")
	lose_sound = rl.LoadSound("res/sfx/lose_1.wav")
	shoot_sound = rl.LoadSound("res/arrow/shoot.wav")
}

move_player :: proc(using player: ^Entity, dt: f32, game: ^Game) {
	if state == .Dying {return}

	if use_gravity {vel.y += GRAVITY * dt}

	input_x: f32 = 0
	if rl.IsKeyDown(.LEFT) {
		input_x -= 1
		last_input = -1
	}
	if rl.IsKeyDown(.RIGHT) {
		input_x += 1
		last_input = 1
	}

	vel.x = input_x * MOVE_SPEED

	if rl.IsKeyPressed(.Z) && is_grounded(player^, game.level) {
		vel.y = JUMP_FORCE
		rl.PlaySound(jump_sound)
	}

	if rl.IsKeyPressed(.X) {shoot_arrow(player^, &game.level)}

	if check_hazard(player^, game.level) {player_death(game)}

	update_entity_state(player, game.level)

	#partial switch state {
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

	move_entity_x(player, game.level, vel.x * dt)
	move_entity_y(player, game.level, vel.y * dt)

	other_collision, index := check_entity_collisions(player^, player.pos, game.level)

	if other_collision == .Goal {level_win(game)}
	if other_collision == .Enemy {player_death(game)}

	clamp_entity_to_level(player, game.level)
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

	rl.PlaySound(shoot_sound)
	append(&level.entities, arrow)
}

player_death :: proc(game: ^Game) {
	game.level = load_level("res/levels.ldtk", game.level_index)
	rl.PlaySound(lose_sound)
}

level_win :: proc(game: ^Game) {
	game.level_index += 1
	game.level = load_level("res/levels.ldtk", game.level_index)

	fmt.printfln("Level Win")

	rl.PlaySound(win_sound)
}
