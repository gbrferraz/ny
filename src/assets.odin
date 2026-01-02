package ny

import rl "vendor:raylib"

TILESET_PNG :: #load("../res/tileset.png")
IDLE_PNG :: #load("../res/player/idle.png")
RUN_PNG :: #load("../res/player/run.png")
LOGO_PNG :: #load("../res/logo.png")

JUMP_WAV :: #load("../res/player/jump.wav")
LOSE_WAV :: #load("../res/sfx/lose_1.wav")
SHOOT_WAV :: #load("../res/arrow/shoot.wav")

load_texture_embedded :: proc(data: []u8) -> rl.Texture2D {
	img := rl.LoadImageFromMemory(".png", raw_data(data), i32(len(data)))
	texture := rl.LoadTextureFromImage(img)
	rl.UnloadImage(img)
	return texture
}

load_sound_embedded :: proc(data: []u8) -> rl.Sound {
	wave := rl.LoadWaveFromMemory(".wav", raw_data(data), i32(len(data)))
	sound := rl.LoadSoundFromWave(wave)
	rl.UnloadWave(wave)
	return sound
}
