class_name ActionsComponent
# -----------------------------------------------------------------------------
# ActionsComponent
# Actions have names, costs, preconditions, and effects.
# 1.0 = natural response, no friction.
# Above 1.0 = resistance — effort, risk, or conflict with nature.
# Costs are base values for a 5/5/5/5 guard. Personality tuning comes later.
# Chase appears in three goals — cost reflects motivation behind it.
# -----------------------------------------------------------------------------
var actions: Array = [

	# --- BeSafe (is_safe: true) -------------------------------------------
	{
		"name":          "GoHome",
		"cost":          1.0,
		"preconditions": {"at_home": false},
		"effects":       {"at_home": true, "is_safe": true}
	},
	{
		"name":          "Flee",
		"cost":          1.3,
		"preconditions": {"threat_nearby": true},
		"effects":       {"is_safe": true}
	},
	{
		"name":          "Heal",
		"cost":          1.0,
		"preconditions": {"is_injured": true, "threat_nearby": false},
		"effects":       {"is_safe": true}
	},

	# --- DoWork (working: true) -------------------------------------------
	{
		"name":          "Patrol",
		"cost":          1.0,
		"preconditions": {"is_safe": true, "sees_target": false},
		"effects":       {"working": true, "at_home": false}
	},
	{
		"name":          "StandGuard",
		"cost":          1.0,
		"preconditions": {"at_post": true, "sees_target": false},
		"effects":       {"working": true}
	},
	{
		"name":          "ChaseAsWork",
		"cost":          1.5,
		"preconditions": {"sees_target": true},
		"effects":       {"working": true}
	},

	# --- ClearDanger (danger_cleared: true) -------------------------------
	{
		"name":          "Attack",
		"cost":          1.0,
		"preconditions": {"in_range": true, "meter_is_full": true},
		"effects":       {"danger_cleared": true}
	},
	{
		"name":          "HoldGround",
		"cost":          1.8,
		"preconditions": {"threat_nearby": true},
		"effects":       {"danger_cleared": true}
	},
	{
		"name":          "ChaseAsDanger",
		"cost":          1.5,
		"preconditions": {"sees_target": true},
		"effects":       {"danger_cleared": true}
	},

	# --- ResolveUnknown (unknown_resolved: true) --------------------------
	{
		"name":          "Search",
		"cost":          1.0,
		"preconditions": {"target_lost": true},
		"effects":       {"unknown_resolved": true}
	},
	{
		"name":          "ChaseAsUnknown",
		"cost":          1.2,
		"preconditions": {"target_lost": true, "curiosity_high": true},
		"effects":       {"unknown_resolved": true}
	}
]
# -----------------------------------------------------------------------------
# get_actions_with_costs
# Returns actions array with costs calculated from current urge state.
# Called by GuardAgent during replan.
# -----------------------------------------------------------------------------
func get_actions_with_costs(urge_component: UrgeComponent) -> Array:
	var comfort    = urge_component.get_comfort_urge()
	var duty       = urge_component.get_duty_urge()
	var curiosity  = urge_component.get_curiosity_urge()
	var aggression = urge_component.get_aggression_urge()
	
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
