extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

#enemy gun settings
@export var damage = int()

@export var ammo = int()
@export var max_ammo = int()
@export var spare_ammo = int()

@export var ammo_per_shot = int()
@export var inf_spare_ammo = bool()

@export var full_auto = bool()

@export var reload_time = float()
@export var firerate = float()

var bullethole  = preload("res://weapon/bullet_VFX.tscn")


var can_shoot = true
var reloading = false
var paused = false

#enemy settings
var SPEED = 6.0
var idle = true
var attack = false
var player_detected = false
var hp = 200
const TURN_SPEED = 8
@onready var raycast = $Face/RayCast3D
@onready var face = $Face
@onready var target =  $"../Player"

func _ready():
	randomize()

func _physics_process(_delta):
	var dis_to_player = nav_agent.distance_to_target()
	if idle:
		attack = false
		player_detected = false
		enemy_idle()
	if player_detected:
		if raycast.get_collider() != null and raycast.get_collider().is_in_group("player"):
			enemy_attack()
		else:
			enemy_find_player()
	# check if player is detected 
	if raycast.get_collider() != null and raycast.get_collider().is_in_group("player"):
		player_detected = true
	
	#enemy death
	if hp <= 0:
		queue_free()
	
	if dis_to_player <= 10:
		look_at_target()
		
		if ammo <= 0:
			reloading = true
			can_shoot = false


func update_location(tagrget_location):
	nav_agent.set_target_position(tagrget_location)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	#execute movement 
	velocity = velocity.move_toward(safe_velocity, 0.99)
	move_and_slide()


func enemy_idle():
	pass

func enemy_attack():
	look_at_target()
	if can_shoot:
		var enemy_acc = randf()
		if enemy_acc <= 0.05:
			if reloading == false:
				can_shoot = false
				ammo -= ammo_per_shot
				raycast.get_collider().health -= damage
				print("hit")
				if  $Face/enemy_weapon/AnimationPlayer != null:
					$Face/enemy_weapon/AnimationPlayer.stop(true)
					$Face/enemy_weapon/AnimationPlayer.play("shooting")
				await get_tree().create_timer(firerate).timeout
				if reloading == false:
					can_shoot = true
	if reloading:
		can_shoot = false
		#reloading = false
		print("reload")
		if $Face/enemy_weapon/AnimationPlayer != null:
			$Face/enemy_weapon/AnimationPlayer.stop(true)
			$Face/enemy_weapon/AnimationPlayer.play("reload")
		ammo = 15
		reloading = false
		await get_tree().create_timer(reload_time).timeout
		can_shoot = true

func enemy_find_player():
	look_at_target()
	#calculate movement 
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	nav_agent.set_velocity(new_velocity)
	
func look_at_target():
	face.look_at(target.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(face.rotation.y * TURN_SPEED))
