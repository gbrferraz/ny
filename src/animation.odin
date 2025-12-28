package ny

import rl "vendor:raylib"

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	current_frame: int,
	frame_timer:   f32,
	frame_length:  f32,
	type:          AnimationType,
}

AnimationType :: enum {
	Idle,
	Run,
}

update_animation :: proc(anim: ^Animation) {
	anim.frame_timer += rl.GetFrameTime()

	for anim.frame_timer > anim.frame_length {
		anim.current_frame += 1
		anim.frame_timer -= anim.frame_length
		if anim.current_frame == anim.num_frames {
			anim.current_frame = 0
		}
	}
}

draw_animation :: proc(anim: Animation, pos: Vec2i, flip: bool) {
	if anim.num_frames == 0 {return}

	width := f32(anim.texture.width)
	height := f32(anim.texture.height)

	source := rl.Rectangle {
		x      = f32(anim.current_frame) * width / f32(anim.num_frames),
		y      = 0,
		width  = width / f32(anim.num_frames),
		height = height,
	}

	if flip {source.width = -source.width}

	dest := rl.Rectangle {
		x      = f32(pos.x),
		y      = f32(pos.y),
		width  = width / f32(anim.num_frames),
		height = height,
	}

	rl.DrawTexturePro(anim.texture, source, dest, {0, 0}, 0, rl.WHITE)
}
