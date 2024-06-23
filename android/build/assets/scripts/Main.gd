extends Node2D

const PlayerNode = preload("res://scenes/player.tscn")
const Intro = preload("res://scenes/intro.tscn")

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

var levels := {
	"End": preload("res://scenes/REDACTED.tscn"),
	0: preload("res://scenes/tutorial.tscn"),
	1: preload("res://scenes/level_1.tscn"),
	2: preload("res://scenes/level_2.tscn"),
	3: preload("res://scenes/level_3.tscn"),
	4: preload("res://scenes/level_4.tscn"),
	5: preload("res://scenes/level_5.tscn")
}

func loadNextLevel(level: int) -> void:
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
		child_instance = levels[level].instantiate()
		add_child(child_instance)
		child_instance.nextLevel.connect(loadNextLevel)
		Player.hide_transition()
		Player.position = Vector2(0, -350)

func getReadyForIt(event: String) -> void:
	if event == "Return":
		intro = Intro.instantiate()
		child_instance.queue_free()
		playerExists = false
		Player.queue_free()
		intro.events.connect(handleIntroEvents)
		add_child(intro)
	else:
		Player.show_transition()
		levelTimer.start()
		levelCompleteSFX2.play()
		await levelTimer.timeout
		child_instance.queue_free()
		child_instance = levels["End"].instantiate()
		add_child(child_instance)
		Player.hide_transition()
		Player.position = Vector2(0, -350)

func handleIntroEvents(event: int) -> void:
	intro.queue_free()
	if !playerExists:
		Player = PlayerNode.instantiate()
	PlayerLayer.add_child(Player)
	Player.position = Vector2(26, 516)

	Player.yoParentNode.connect(getReadyForIt)
	
	playerExists = true

	child_instance = levels[event].instantiate()
	add_child(child_instance)
	child_instance.nextLevel.connect(loadNextLevel)
		
func _ready() -> void:
	Player = PlayerNode.instantiate()
	if levelToLoad == 0:
		intro = Intro.instantiate()
		add_child(intro)
		
		intro.events.connect(handleIntroEvents)
	else:
		PlayerLayer.add_child(Player)
		playerExists = true
		Player.position = Vector2(26, 516)

		Player.yoParentNode.connect(getReadyForIt)

		child_instance = levels[levelToLoad].instantiate()
		add_child(child_instance)
		child_instance.nextLevel.connect(loadNextLevel)
