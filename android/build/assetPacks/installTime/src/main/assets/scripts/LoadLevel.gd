extends Node

var loadingScreen := load("res://scenes/load_game.tscn")
var scenePath: String
var levelLoaded: int
var previousScene: String
var isLoadingLevel: bool = false

func changeLevel(path: String) -> void:
	scenePath = path
	get_tree().change_scene_to_packed(loadingScreen)
