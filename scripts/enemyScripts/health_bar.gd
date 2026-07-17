class_name HealthBar
extends ProgressBar

func set_health(current: float, max_health: float) -> void:
	self.max_value = max_health
	var tween := create_tween()
	tween.tween_property(self, "value", current, 0.3)
