class_name PatrolComponent
extends Node
# -----------------------------------------------------------------------------
# PatrolComponent
# Home anchored wandering with random dwell time at each point.
# Guard arrives, checks the area for a random duration, moves on.
# After a random number of dwells, guard commits to a post.
# Knows where home is — it's part of the geography it operates in.
# Drives movement via signal — knows nothing about MoveComponent.
# -----------------------------------------------------------------------------
signal new_patrol_target(position: Vector2)
signal at_post_started
signal at_post_ended

const DELAY_MIN: float = 0.5   # shortest check — quick glance
const DELAY_MAX: float = 2.0   # longest check — thorough sweep

@export var nav_region:    NavigationRegion2D
@export var home_position: Vector2

var _timer:          float = 0.0
var _dwelling:       bool  = false
var _dwell_count:    int   = 0
var _post_threshold: int   = 1

func _ready() -> void:
	set_process(false)
	_post_threshold = randi_range(1, 3)

# -----------------------------------------------------------------------------
# _process — counts down dwell time, then picks next point
# -----------------------------------------------------------------------------
func _process(delta: float) -> void:
	if not _dwelling:
		return
	_timer -= delta
	if _timer <= 0.0:
		_dwelling = false
		_dwell_count = 0
		_post_threshold = randi_range(1, 3)
		at_post_ended.emit()
		new_patrol_target.emit(_get_random_point())

# -----------------------------------------------------------------------------
# arrived — called by GuardAgent when destination_reached fires during patrol
# increments dwell count — if threshold met, guard commits to post
# -----------------------------------------------------------------------------
func arrived() -> void:
	_dwelling = true
	_timer    = randf_range(DELAY_MIN, DELAY_MAX)
	_dwell_count += 1
	if _dwell_count >= _post_threshold:
		at_post_started.emit()
	print(">>> PATROL: checking area for %.1f seconds — dwell %d of %d" % [_timer, _dwell_count, _post_threshold])

# -----------------------------------------------------------------------------
# start — kicks off patrol, fresh slate every time
# -----------------------------------------------------------------------------
func start() -> void:
	_dwelling       = false
	_dwell_count    = 0
	_post_threshold = randi_range(1, 3)
	set_process(true)
	new_patrol_target.emit(_get_random_point())

# -----------------------------------------------------------------------------
# stop — guard is done patrolling, cancel any dwell in progress
# -----------------------------------------------------------------------------
func stop() -> void:
	_dwelling    = false
	_timer       = 0.0
	_dwell_count = 0
	at_post_ended.emit()
	set_process(false)

# -----------------------------------------------------------------------------
# _get_random_point — random point on nav mesh
# -----------------------------------------------------------------------------
func _get_random_point() -> Vector2:
	return NavigationServer2D.map_get_random_point(
		nav_region.get_navigation_map(),
		1,
		false
	)
