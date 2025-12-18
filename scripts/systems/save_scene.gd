extends Node2D

func _ready() -> void:
	SaveManager.save_data.current_scene = get_tree().current_scene.scene_file_path
	SaveManager._save()
