extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		var grassEffect = load("res://scripts/Effects/GrassEffect.tscn").instance()
		get_tree().current_scene.add_child(grassEffect)
		grassEffect.global_position = global_position
		queue_free()
