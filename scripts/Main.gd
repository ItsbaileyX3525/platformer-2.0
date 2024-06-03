extends Node2D

const PlayerNode = preload("res://scenes/player.tscn")
const TutorialScene = preload("res://scenes/tutorial.tscn")
const Level1Scene = preload("res://scenes/level_1.tscn")

@onready var levelTimer = $NextLevel
@onready var levelCompleteSFX = $LevelComplete

var Player: Node2D
var Tutorial: Node2D
var Level1: Node2D
var goingTo = 1

var finishedLoading = false
var FinishedTutorial = false
var loadedLevel1 = false

func _on_next_level_timeout() -> void:
	levelTimer.stop()
	match goingTo:
		1:
			if is_instance_valid(Tutorial):
				Tutorial.queue_free() 
				print("Freed")
			else:
				print("Tried freeing Tutorial")
			Level1 = Level1Scene.instantiate()
			add_child(Level1)
			Player.hide_transition()

func loadLevel(whichLevel: int) -> void:
	match whichLevel:
		1:
			Player.show_transition()
			levelCompleteSFX.play()
			goingTo = 1
			levelTimer.start()

func _ready() -> void:
	Player = PlayerNode.instantiate()
	Tutorial = TutorialScene.instantiate()
	add_child(Player)
	Player.position = Vector2(26, 516)
	Tutorial.init(Player) # Allows the player to be passed into the tutorial script to be modified 
	add_child(Tutorial)
	Tutorial.position = Vector2(0,0)

	finishedLoading = true

func _process(delta: float) -> void:
	if finishedLoading:
		if is_instance_valid(Tutorial):
			if !FinishedTutorial and Tutorial.NextLevel  and not loadedLevel1:
				loadLevel(1)
				loadedLevel1 = true
