extends Node

const SAVE_GAME_PATH := "user://save.tres"
var save_data: SaveDataResource = SaveDataResource.new()

var current_scene

func _ready() -> void:
	_load()

func _save():
	ResourceSaver.save(save_data, SAVE_GAME_PATH)

func _load():
	if FileAccess.file_exists(SAVE_GAME_PATH):
		save_data = ResourceLoader.load(SAVE_GAME_PATH).duplicate(true)
		
func load_game_and_switch_scene():
	_load()
	
	if save_data.current_scene != "":
		get_tree().change_scene_to_file(save_data.current_scene)
	else:
		print("Save carregado, mas nenhuma cena foi salva.")
