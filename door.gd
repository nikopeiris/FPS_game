extends Node3D

var door_opened = false
var in_range = false
@onready var raycast = $"../../../../Player/camroot/player_cam/gun_ray"

func _process(delta):
	if in_range and door_opened == false and Input.is_action_just_pressed("interact"):
		if $AnimationPlayer != null:
			$AnimationPlayer.stop(true)
			$AnimationPlayer.play("door_open")
			door_opened = true
	elif in_range and door_opened and Input.is_action_just_pressed("interact"):
		if $AnimationPlayer != null:
			$AnimationPlayer.stop(true)
			$AnimationPlayer.play("door_close")
			door_opened = false
			
	if raycast.get_collider() != null and raycast.get_collider().is_in_group("door") and in_range and door_opened == false:
		$Label.text = "'E' to Open"
		$Label.visible = true
	elif raycast.get_collider() != null and raycast.get_collider().is_in_group("door") and in_range and door_opened:
		$Label.text = "'E' to Close"
		$Label.visible = true
	else:
		$Label.visible = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		in_range = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		in_range = false
