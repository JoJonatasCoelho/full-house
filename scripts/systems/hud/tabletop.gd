extends Node2D

@export var background_tex: Texture2D 
@export var background_node: TextureRect 

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	
	animator.play("intro")
	
	if background_node and background_tex:
		background_node.texture = background_tex
	else:
		print("Erro: Esqueceu de colocar a Textura ou o Nó no Inspector!")
