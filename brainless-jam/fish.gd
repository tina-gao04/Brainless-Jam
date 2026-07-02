extends CharacterBody2D

@export var min_speed = 50.0
@export var max_speed = 600.0
@export var stop_distance = 4.0
@export var max_distance = 400.0
@export var acceleration = 4.0     # how quickly velocity eases toward target (higher = snappier)
@export var turn_speed = 3.0       # how quickly rotation eases toward facing the mouse

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var to_mouse = mouse_position - global_position
	var distance = to_mouse.length()

	var target_velocity = Vector2.ZERO

	if distance > stop_distance:
		var speed_factor = clamp(distance / max_distance, 0.0, 1.0)
		var speed = lerp(min_speed, max_speed, speed_factor)
		target_velocity = to_mouse.normalized() * speed

		# smoothly rotate toward the mouse instead of snapping
		var target_angle = to_mouse.angle()
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

	# smoothly ease velocity toward the target instead of snapping
	velocity = velocity.lerp(target_velocity, acceleration * delta)

	move_and_slide()
