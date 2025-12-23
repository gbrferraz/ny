package ny

to_vec2 :: proc(vec2i: [2]int) -> [2]f32 {
	return {f32(vec2i.x), f32(vec2i.y)}
}
