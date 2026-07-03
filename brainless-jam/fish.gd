extends CharacterBody2D

@export var base_min_speed = 50.0
@export var base_max_speed = 800.0
@export var stop_distance = 4.0
@export var max_distance = 400.0
@export var acceleration = 1.6
@export var turn_speed = 1.4
@export var speed_per_fish = 5.0
@export var separation_radius = 40.0
@export var separation_strength = 90.0

static var all_fish: Array = []

var think_timer := 0.0
var target_velocity := Vector2.ZERO

var stop_distance_sq: float
var separation_radius_sq: float

# small wandering motion (makes fish less robotic)
var wander_angle := 0.0

func _ready():
	add_to_group("fish")
	all_fish.append(self)

	stop_distance_sq = stop_distance * stop_distance
	separation_radius_sq = separation_radius * separation_radius

	wander_angle = randf() * TAU

func _exit_tree():
	all_fish.erase(self)

func _on_area_2d_body_entered(body):
	if body.is_in_group("hazard"):
		queue_free()

func _physics_process(delta):

	# AI tick (reduces CPU load)
	think_timer -= delta
	if think_timer <= 0.0:
		think_timer = 0.1
		update_ai()

	# smooth acceleration (momentum feel)
	velocity += (target_velocity - velocity) * acceleration * delta

	# only rotate if moving
	if velocity.length_squared() > 10.0:
		rotation = lerp_angle(rotation, velocity.angle(), turn_speed * delta)

	move_and_slide()


func update_ai():

	var mouse_position = get_global_mouse_position()
	var to_mouse = mouse_position - global_position
	var dist_sq = to_mouse.length_squared()

	var fish_count = all_fish.size()

	var current_max_speed = base_max_speed + fish_count * speed_per_fish
	var current_min_speed = base_min_speed + fish_count * speed_per_fish * 0.25

	var seek_velocity = Vector2.ZERO

	# --- SEEK (mouse follow) ---
	if dist_sq > stop_distance_sq:
		var dist = sqrt(dist_sq)
		var speed_factor = clamp(dist / max_distance, 0.0, 1.0)
		var speed = lerp(current_min_speed, current_max_speed, speed_factor)
		seek_velocity = to_mouse.normalized() * speed

	# --- WANDER (smooth randomness) ---
	wander_angle += randf_range(-0.25, 0.25)
	var wander = Vector2.RIGHT.rotated(wander_angle) * 25.0

	seek_velocity += wander

	# --- SEPARATION ---
	var separation_velocity = Vector2.ZERO

	for other in all_fish:
		if other == self:
			continue

		var away = global_position - other.global_position
		var d_sq = away.length_squared()

		if d_sq > 0.0 and d_sq < separation_radius_sq:
			var d = sqrt(d_sq)
			var push = 1.0 - (d / separation_radius)
			separation_velocity += away.normalized() * push

	separation_velocity *= separation_strength

	# --- FINAL TARGET ---
	target_velocity = seek_velocity + separation_velocity
