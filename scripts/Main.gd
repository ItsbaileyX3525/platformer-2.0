extends Node2D

var PlayerNode := load("res://scenes/player.tscn")
var Intro := ResourceLoader.load_threaded_get("res://scenes/intro.tscn")

@onready var levelTimer := $NextLevel
@onready var levelCompleteSFX := $LevelComplete
@onready var levelCompleteSFX2 := $"LevelComplete?"
@onready var PlayerLayer := $Player

@export var levelToLoad: int = 0

var intro: Node2D
var playerExists := false
var Player: Node2D
var child_instance: Node2D

func saveGame(dictToSave: Dictionary) -> void:
	var gameFile := FileAccess.open("user://saveLevel.json", FileAccess.WRITE)
	
	var jsonString := JSON.stringify(dictToSave)
	gameFile.store_line(jsonString)

func loadGame() -> Dictionary:
	var loadedData: Dictionary
	if not FileAccess.file_exists("user://saveLevel.json"): 
		var save_dict := {
			"levelsCompleted": 1
		}
		return save_dict
	else:
		var gameSave := FileAccess.get_file_as_string("user://saveLevel.json")

		loadedData = JSON.parse_string(gameSave)

	
	return loadedData

var data := loadGame()

func loadNextLevel(level: int) -> void:
	var levels := {
		0 : "res://scenes/tutorial.tscn",
		1 : "res://scenes/level_1.tscn",
		2 : "res://scenes/level_2.tscn",
		3 : "res://scenes/level_3.tscn",
		4 : "res://scenes/level_4.tscn",
		5 : "res://scenes/level_5.tscn",
		6 : "res://scenes/level_6.tscn",
		7 : "res://scenes/level_7.tscn",
	}
	DialougeManager.clearDialogue()
	if level == 99999:
		Player.addPoint()
	else:
		if level!=0:
			if not data.has(str(level-1)):
				data[str(level-1)] = true
				if not "levelsCompleted" in data:
					data["levelsCompleted"] = 1
				else:
					data["levelsCompleted"] += 1
				saveGame(data)
		Player.show_transition()
		levelTimer.start()
		levelCompleteSFX.play()
		await levelTimer.timeout
		child_instance.queue_free()
		LoadLevel.levelLoaded = level
		LoadLevel.isLoadingLevel = true
		LoadLevel.changeLevel(levels[level])

func handleIntroEvents(event: int) -> void:
	var levels := {
		0 : "res://scenes/tutorial.tscn",
		1 : "res://scenes/level_1.tscn",
		2 : "res://scenes/level_2.tscn",
		3 : "res://scenes/level_3.tscn",
		4 : "res://scenes/level_4.tscn",
		5 : "res://scenes/level_5.tscn",
		6 : "res://scenes/level_6.tscn",
		7 : "res://scenes/level_7.tscn",
	}
	intro.queue_free()
	if !playerExists:
		Player = PlayerNode.instantiate()
	
	Player.position = Vector2(26, 516)
	
	playerExists = true

	LoadLevel.levelLoaded = event
	LoadLevel.isLoadingLevel = true
	LoadLevel.changeLevel(levels[event])
		
func _ready() -> void:
	var levels := {
		"End" : ResourceLoader.load_threaded_get("res://scenes/REDACTED.tscn"),
		0 : ResourceLoader.load_threaded_get("res://scenes/tutorial.tscn"),
		1 : ResourceLoader.load_threaded_get("res://scenes/level_1.tscn"),
		2 : ResourceLoader.load_threaded_get("res://scenes/level_2.tscn"),
		3 : ResourceLoader.load_threaded_get("res://scenes/level_3.tscn"),
		4 : ResourceLoader.load_threaded_get("res://scenes/level_4.tscn"),
		5 : ResourceLoader.load_threaded_get("res://scenes/level_5.tscn"),
		6 : ResourceLoader.load_threaded_get("res://scenes/level_6.tscn"),
		7 : ResourceLoader.load_threaded_get("res://scenes/level_7.tscn"),
	}
	Player = PlayerNode.instantiate()
	
	if levelToLoad == 0:
		if not LoadLevel.isLoadingLevel:
			intro = Intro.instantiate()
			add_child(intro)
			
			intro.events.connect(handleIntroEvents)
		else:
			var level: int = LoadLevel.levelLoaded
			PlayerLayer.add_child(Player)
			child_instance = levels[level].instantiate()
			add_child(child_instance)
			child_instance.nextLevel.connect(loadNextLevel)
			Player.hide_transition()
			Player.position = Vector2(0, -350)
	else:
		levels = {
			1 : preload("res://scenes/level_1.tscn"),
			2 : preload("res://scenes/level_2.tscn"),
			3 : preload("res://scenes/level_3.tscn"),
			4 : preload("res://scenes/level_4.tscn"),
			5 : preload("res://scenes/level_5.tscn"),
			6 : preload("res://scenes/level_6.tscn"),
			7 : preload("res://scenes/level_7.tscn"),
		}
		PlayerLayer.add_child(Player)
		playerExists = true
		child_instance = levels[levelToLoad].instantiate()
		add_child(child_instance)
		child_instance.nextLevel.connect(loadNextLevel)
		Player.hide_transition()
		Player.position = Vector2(0, -300)
	
