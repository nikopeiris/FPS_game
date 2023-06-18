extends Node3D

#gun settings
@export var damage = int()

@export var ammo = int()
@export var max_ammo = int()
@export var spare_ammo = int()

@export var ammo_per_shot = int()
@export var inf_spare_ammo = bool()

@export var full_auto = bool()

@export var reload_time = float()
@export var firerate = float()

@export var rayCast : NodePath
@onready var raycast = get_node(rayCast)
var bullethole  = preload("res://weapon/bullet_VFX.tscn")


var can_shoot = true
var reloading = false
var paused = false


func _ready():
	randomize()

func _process(_delta):
	if ammo <= 0:
		can_shoot = false
	if Input.is_action_just_pressed("reload") and reloading == false and paused == false:
		reload()
	if Input.is_action_pressed("shoot") and can_shoot and full_auto and paused == false:
		fire()
	elif Input.is_action_just_pressed("shoot") and can_shoot and full_auto == false and paused == false:
		fire()

#shoot gun if called
func fire():
	can_shoot = false
	ammo -= ammo_per_shot
	if raycast.get_collider() != null and raycast.get_collider().is_in_group("enemies"):
		raycast.get_collider().hp -= damage
	if raycast.is_colliding():
		if raycast.get_collider() != null and raycast.get_collider().is_in_group("enemies"):
			create_bullethole_enemy()
		else:
			create_bullethole()
	if $AnimationPlayer != null:
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("shooting")
	await get_tree().create_timer(firerate).timeout
	if reloading == false:
		can_shoot = true

#reload gun if called
func reload():
	can_shoot = false
	reloading = true
	if $AnimationPlayer != null:
		$AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	if inf_spare_ammo == false:
		var tmp_ammo
		if spare_ammo < max_ammo:
			tmp_ammo = ammo + spare_ammo
			if max_ammo - tmp_ammo >= 0:
				ammo += spare_ammo
				spare_ammo = 0
			else:
				ammo += spare_ammo
				ammo += max_ammo - tmp_ammo
				spare_ammo = -(max_ammo - tmp_ammo)
		else:
			spare_ammo -= max_ammo - ammo
			ammo = max_ammo
	else:
		ammo = max_ammo
	if ammo > 0:
		can_shoot = true
	reloading = false
	
func create_bullethole():
	var collision_point = raycast.get_collision_point()
	var b = bullethole.instantiate()
	get_tree().get_root().add_child(b)
	b.global_transform.origin = collision_point
	if raycast.get_collision_normal() == Vector3(0,1,0):
		b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	elif raycast.get_collision_normal() == Vector3(0,-1,0):
		b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	else:
		b.look_at(raycast.get_collision_point() + raycast.get_collision_normal())
	
	
func create_bullethole_enemy():
	var collision_point = raycast.get_collision_point()
	var collision_normal = raycast.get_collision_normal()
	var b = bullethole.instantiate()
	raycast.get_collider().add_child(b)
	b.global_transform.origin = collision_point
	b.look_at(collision_point - collision_normal, Vector3.UP)
