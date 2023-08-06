extends Node3D

@onready var player = $Player
@onready var parent = $"."
var player_death = false

#send players location to enemy
func _physics_process(_delta):
	if player_death == false:
		get_tree().call_group("enemies", "update_location", player.global_transform.origin)
		
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_player_player_death():
	player_death = true
	var end_screen = preload("res://end_screen/end_screen.tscn").instantiate()
	end_screen.text = "You Died"
	get_tree().current_scene.add_child(end_screen)
	#LoadingScreenCall.call_loading_screen("res://level_1/level_1.tscn", parent)
