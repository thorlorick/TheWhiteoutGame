class_name Player
extends CharacterBody2D

@onready var speed_component: SpeedComponent = $SpeedComponent
@onready var move_component: PlayerMoveComponent = $PlayerMoveComponent
@onready var animation_component: PlayerAnimationComponent = $PlayerAnimationComponent
@onready var hurtbox: Area2D = $HurtboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var knockback_component: KnockbackComponent = $KnockbackComponent

func _ready() -> void:
	health_component.max_health = 20.0
	health_component.current_health = 20.0
	health_component.health_changed.emit(20.0, 20.0)

	var anim_player = $HeroAnimations/AnimationPlayer
	animation_component.setup(anim_player)
	move_component.setup(speed_component.get_speed(), speed_component.get_run_speed(), "run")
	move_component.movement_changed.connect(_on_movement_changed)
	hurtbox.hurt.connect(_on_hurt)
	knockback_component.setup(self)
	health_component.health_changed.connect(_on_health_changed)

func _physics_process(delta: float) -> void:
	move_component.process_movement()

func _on_movement_changed(vel: Vector2, state: String) -> void:
	velocity = vel
	move_and_slide()
	animation_component.update(vel.normalized(), state)

func _on_hurt(damage_info: DamageInfo) -> void:
	print(">>> PLAYER: took %.1f damage" % damage_info.amount)
	print(">>> PLAYER: source is — %s" % str(damage_info.source))
	if damage_info.source != null:
		damage_info.knockback_direction = (global_position - damage_info.source.global_position).normalized()
		print(">>> PLAYER: knockback direction — %s" % damage_info.knockback_direction)
	health_component.take_damage(damage_info)
	if damage_info.knockback_direction != Vector2.ZERO:
		print(">>> PLAYER: applying knockback")
		knockback_component.apply(damage_info.knockback_direction, damage_info.knockback_force)
		
func _on_health_changed(current: float, max: float) -> void:
	health_bar.set_health(current, max)
