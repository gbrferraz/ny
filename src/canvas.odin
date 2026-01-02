package ny

import "core:c"
import rl "vendor:raylib"

Canvas :: struct {
	render_texture: rl.RenderTexture,
	src, dest:      rl.Rectangle,
}

init_canvas :: proc(width, height: c.int) -> Canvas {
	canvas := Canvas {
		render_texture = rl.LoadRenderTexture(width, height),
		src            = {0, 0, f32(width), -f32(height)},
		dest           = {
			-CANVAS_RATIO,
			-CANVAS_RATIO,
			SCREEN_WIDTH + (CANVAS_RATIO * 2),
			SCREEN_HEIGHT + (CANVAS_RATIO * 2),
		},
	}

	update_canvas_mouse(canvas)

	return canvas
}

update_canvas_mouse :: proc(canvas: Canvas) {
	scale_x := canvas.src.width / canvas.dest.width
	scale_y := abs(canvas.src.height) / canvas.dest.height
	rl.SetMouseScale(scale_x, scale_y)
	rl.SetMouseOffset(i32(-canvas.dest.x), i32(-canvas.dest.y))
}

reset_canvas_mosue :: proc() {
	rl.SetMouseOffset(0, 0)
	rl.SetMouseScale(1, 1)
}

draw_canvas :: proc(canvas: Canvas) {
	rl.DrawTexturePro(canvas.render_texture.texture, canvas.src, canvas.dest, {0, 0}, 0, rl.WHITE)
}
