extends Node2D

@onready var character: AnimatedSprite2D = $Stand

func _ready() -> void:
	character.play("gif")
