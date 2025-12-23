package ny

import "core:c"
import rl "vendor:raylib"

Canvas :: struct {
	render_texture: rl.RenderTexture,
	src, dest:      rl.Rectangle,
}

init_canvas :: proc(width, height: c.int) -> Canvas {
	return Canvas {
		render_texture = rl.LoadRenderTexture(width, height),
		src = {0, 0, f32(width), -f32(height)},
		dest = {
			-CANVAS_RATIO,
			-CANVAS_RATIO,
			SCREEN_WIDTH + (CANVAS_RATIO * 2),
			SCREEN_HEIGHT + (CANVAS_RATIO * 2),
		},
	}

}

draw_canvas :: proc(canvas: Canvas) {
	rl.DrawTexturePro(canvas.render_texture.texture, canvas.src, canvas.dest, {0, 0}, 0, rl.WHITE)
}
