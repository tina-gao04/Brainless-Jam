extends Node2D

@export var fish_scene: PackedScene
@export var fish_count = 150

func _ready():
	var screen_center = get_viewport().get_visible_rect().size / 2
	var world_center = get_canvas_transform().affine_inverse() * screen_center

	for i in fish_count:
		var fish = fish_scene.instantiate()
		fish.global_position = world_center + Vector2(randf_range(-150, 150), randf_range(-150, 150))
		get_parent().call_deferred("add_child", fish)

	call_deferred("_report_count")

func _report_count():
	print("Spawned fish count: ", get_tree().get_nodes_in_group("fish").size())
