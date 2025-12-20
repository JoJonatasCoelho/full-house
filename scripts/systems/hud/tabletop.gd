extends Node2D

@export var background_tex: Texture2D 
@export var background_node: TextureRect 

func _ready() -> void:
	if background_node and background_tex:
		background_node.texture = background_tex
	else:
		print("Erro: Esqueceu de colocar a Textura ou o Nó no Inspector!")
