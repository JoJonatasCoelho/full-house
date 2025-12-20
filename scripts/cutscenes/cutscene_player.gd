extends Control

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	if Global.next_video_path != "":
		var stream
		if Global.extra_cutscene != "":
			stream = load(Global.extra_cutscene)
			print("suposta extra scene")
		else: 
			stream = load(Global.next_video_path)
		video_player.stream = stream
		video_player.play()
		await video_player.finished
		_on_video_finished()
	else:
		print("Erro: Nenhum vídeo definido no Global.")
		_on_video_finished()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_on_video_finished()

func _on_video_stream_player_finished() -> void:
	_on_video_finished()

func _on_video_finished() -> void:
	video_player.stop()
	if Global.extra_cutscene != "":
		Global.reset_extra_cutscene()
		get_tree().change_scene_to_file("res://scenes/levels/cutscene_player.tscn")

	elif Global.scene_after_video != "":
		get_tree().change_scene_to_file(Global.scene_after_video)
	else:
		get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
