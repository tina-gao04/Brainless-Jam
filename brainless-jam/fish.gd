extends CharacterBody2D

@export var base_min_speed = 50.0
@export var base_max_speed = 800.0
@export var stop_distance = 4.0
@export var max_distance = 400.0
@export var acceleration = 3.0     # how quickly velocity eases toward target (higher = snappier)
@export var turn_speed = 3.0       # how quickly rotation eases toward facing the mouse
@export var speed_per_fish = 2.0
@export var separation_radius = 40.0
@export var separation_strength = 100.0

func _ready():
	add_to_group("fish")

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var to_mouse = mouse_position - global_position
	var distance = to_mouse.length()
	
	# --- Seeking behaviour (following the mouse) ---
	var neighbours = get_tree().get_nodes_in_group("fish")
	var fish_count = neighbours.size()
	var current_max_speed = base_max_speed + (fish_count * speed_per_fish)
	var current_min_speed = base_min_speed + (fish_count * speed_per_fish * 0.25)
	
	var seek_velocity = Vector2.ZERO
	if distance > stop_distance:
		var speed_factor = clamp(distance / max_distance, 0.0, 1.0)
		var speed = lerp(current_min_speed, current_max_speed, speed_factor)
		seek_velocity = to_mouse.normalized() * speed
		var target_angle = to_mouse.angle()
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

	

	# --- Seperation Behaviour 
	var separation_velocity = Vector2.ZERO
	
	var away = Vector2()
	var d = away.length()
	for other in neighbours:
		if other == self:
			continue
		
		away = global_position - other.global_position
		d = away.length()
		
		if d < separation_radius and d > 0:
			#the closer the other fish is, the stronger the push will be
			var push_strength = (1.0 - d / separation_radius)
			separation_velocity += away.normalized() * push_strength
			
	separation_velocity *= separation_strength
		
		# --- Combine both behaviours
	var target_velocity = seek_velocity + separation_velocity
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	if velocity.length() > 5.0:
		var target_angle = velocity.angle()
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	
	move_and_slide()
