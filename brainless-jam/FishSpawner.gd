extends Node2D

@export var fish_scene: PackedScene
@export var fish_count = 150

func _ready():
	for i in fish_count:
		var fish = fish_scene.instantiate()
		fish.global_position = global_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
		get_tree().current_scene.add_child(fish)
	print("Spawned fish count: ", get_tree().get_nodes_in_group("fish").size())
