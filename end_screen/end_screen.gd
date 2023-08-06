extends Control

var text

func _ready():
	$Label.text = text
	$bg.visible = true
	if $AnimationPlayer != null:
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("end_screen")
