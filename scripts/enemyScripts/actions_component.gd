class_name ActionsComponent

# -----------------------------------------------------------------------------
# get_actions_with_costs
# Returns actions array with costs calculated from current urge state.
# Called by GuardAgent during replan.
# -----------------------------------------------------------------------------

# Cache urge values here
var _comfort: float = 0.5
var _duty: float = 0.5
var _curiosity: float = 0.5
var _aggression: float = 0.5

# -----------------------------------------------------------------------------
# update_urge_state
# Updates cached urge values. Will be called by GuardAgent when urges change.
# -----------------------------------------------------------------------------
func update_urge_state(comfort: float, duty: float, curiosity: float, aggression: float) -> void:
	_comfort = comfort
	_duty = duty
	_curiosity = curiosity
	_aggression = aggression

func get_actions_with_costs() -> Array:
	# Use cached values directly - no more reaching into UrgeComponent!
	var comfort = _comfort
	var duty = _duty
	var curiosity = _curiosity
	var aggression = _aggression
	
	print(">>> CALCULATING COSTS — comfort: %.2f | duty: %.2f | curiosity: %.2f | aggression: %.2f" % [_comfort, _duty, _curiosity, _aggression])
	
	return [
		# --- BeSafe (is_safe: true) -------------------------------------------
		{
			"name":          "GoHome",
			# High comfort urge = wants to go home
			# Low duty = willing to abandon post
			"cost":          1.0 + (1.0 - comfort) * 2.0 + duty * 1.5,
			"preconditions": {"at_home": false},
			"effects":       {"at_home": true, "is_safe": true}
		},
		{
			"name":          "Flee",
			# High comfort urge = cheap to flee
			# High aggression = expensive (wants to fight instead)
			"cost":          1.3 + (1.0 - comfort) * 3.0 + aggression * 2.5,
			"preconditions": {"threat_nearby": true},
			"effects":       {"is_safe": true}
		},
		{
			"name":          "Heal",
			# High comfort urge = wants to heal and recover
			"cost":          1.0 + (1.0 - comfort) * 1.5,
			"preconditions": {"is_injured": true, "threat_nearby": false},
			"effects":       {"is_safe": true}
		},
		
		# --- DoWork (working: true) -------------------------------------------
		{
			"name":          "Patrol",
			# High duty = cheap to patrol
			# High comfort = expensive (wants to go home instead)
			"cost":          1.0 + (1.0 - duty) * 2.0 + comfort * 1.5,
			"preconditions": {"is_safe": true, "sees_target": false},
			"effects":       {"working": true, "at_home": false}
		},
		{
			"name":          "StandGuard",
			# High duty = cheap to stand guard
			# High comfort = expensive (wants to rest)
			"cost":          1.0 + (1.0 - duty) * 1.5 + comfort * 1.0,
			"preconditions": {"at_post": true, "sees_target": false},
			"effects":       {"working": true}
		},
		{
			"name":          "ChaseAsWork",
			# Duty-driven chase (doing the job)
			# High duty = cheap
			# Low aggression = more expensive (not emotionally motivated)
			"cost":          1.5 + (1.0 - duty) * 2.0 + (1.0 - aggression) * 1.0,
			"preconditions": {"sees_target": true},
			"effects":       {"working": true}
		},
		
		# --- ClearDanger (danger_cleared: true) -------------------------------
		{
			"name":          "Attack",
			# High aggression = cheap to attack
			# High comfort = expensive (too scared)
			"cost":          1.0 + (1.0 - aggression) * 3.0 + comfort * 2.0,
			"preconditions": {"in_range": true, "meter_is_full": true},
			"effects":       {"danger_cleared": true}
		},
		{
			"name":          "HoldGround",
			# Moderate aggression + duty = cheap (disciplined defense)
			# Too aggressive = wants to attack instead
			# Too scared = wants to flee instead
			"cost":          1.8 + abs(aggression - 0.5) * 2.0 + comfort * 1.5,
			"preconditions": {"threat_nearby": true},
			"effects":       {"danger_cleared": true}
		},
		{
			"name":          "ChaseAsDanger",
			# Aggression-driven chase (wants to eliminate threat)
			# High aggression = cheap
			"cost":          1.5 + (1.0 - aggression) * 2.5,
			"preconditions": {"sees_target": true},
			"effects":       {"danger_cleared": true}
		},
		
		# --- ResolveUnknown (unknown_resolved: true) --------------------------
		{
			"name":          "Search",
			# High curiosity = cheap to search
			# High comfort = expensive (wants to give up and go home)
			"cost":          1.0 + (1.0 - curiosity) * 2.0 + comfort * 1.0,
			"preconditions": {"target_lost": true},
			"effects":       {"unknown_resolved": true}
		},
		{
			"name":          "ChaseAsUnknown",
			# Curiosity-driven chase (what was that?)
			# High curiosity = cheap
			"cost":          1.2 + (1.0 - curiosity) * 2.5,
			"preconditions": {"target_lost": true, "curiosity_high": true},
			"effects":       {"unknown_resolved": true}
		}
	]
