extends Area2D

export (bool) var show_effect = true

const HitEffect = preload("res://scripts/Effects/HitEffect.tscn")

func _on_Hurtbox_area_entered(area):
	if show_effect:
		var effect = HitEffect.instance()
		var main = get_tree().current_scene
		main.add_child(effect)
		effect.global_position = global_position 
