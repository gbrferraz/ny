package ny

ENEMY_SPEED: f32 = 50

move_enemy :: proc(enemy: ^Entity, level: Level) {
	if is_on_wall(enemy^, enemy.last_input, level) {
		enemy.last_input = -enemy.last_input
		enemy.vel.x = -enemy.vel.x
	}
}
