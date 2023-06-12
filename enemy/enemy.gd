extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 6.0
var find_player = true
var hp = 100

func _physics_process(_delta):
	var distance = nav_agent.distance_to_target()
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	nav_agent.set_velocity(new_velocity)
	
	if hp <= 0:
		queue_free()
	
	if distance > 5:
		find_player = true
	else: 
		find_player = false

func update_location(tagrget_location):
	nav_agent.set_target_position(tagrget_location)

func _on_navigation_agent_3d_target_reached():
	find_player = false


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if find_player:
		velocity = velocity.move_toward(safe_velocity, 0.99)
		move_and_slide()
	else:
		pass
