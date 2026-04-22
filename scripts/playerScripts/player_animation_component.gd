class_name PlayerAnimationComponent
extends Node
# -----------------------------------------------------------------------------
# PlayerAnimationComponent
# Receives direction + state from PlayerAgent.
# Picks the correct directional animation and plays it.
# Knows nothing about input or movement — just animations.
# -----------------------------------------------------------------------------

var animation_player: AnimationPlayer
var current_direction: Vector2 = Vector2.DOWN
var current_animation: String  = ""

func setup(player: AnimationPlayer) -> void:
	animation_player = player

func update(direction: Vector2, state: String) -> void:
	if direction != Vector2.ZERO:
		current_direction = direction

	var anim_name = state + "_" + _direction_to_string(current_direction)

	if anim_name != current_animation:
		current_animation = anim_name
		animation_player.play(anim_name)

func _direction_to_string(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"
