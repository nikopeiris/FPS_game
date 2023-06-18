extends Node3D

@onready var player = $Player

#send players location to enemy
func _physics_process(_delta):
	get_tree().call_group("enemies", "update_location", player.global_transform.origin)
