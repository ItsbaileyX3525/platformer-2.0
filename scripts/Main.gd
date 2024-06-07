extends Node2D

const PlayerNode = preload("res://scenes/player.tscn")

@onready var levelTimer = $NextLevel
@onready var levelCompleteSFX = $LevelComplete
@onready var PlayerLayer = $Player
@onready var background = $Background

@export var levelToLoad: int = 0

var Player: Node2D
var child_instance
var canShowDiscord = false #Note this is not like sending your data to discord its just to update
#the rich presence on your discord profile ;P

var levels = {
	0: preload("res://scenes/tutorial.tscn"),
	1: preload("res://scenes/level_1.tscn"),
	2: preload("res://scenes/level_2.tscn"),
	3: preload("res://scenes/level_3.tscn"),
	4: preload("res://scenes/level_4.tscn")
}

func loadNextLevel(level):
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


func _ready() -> void:
	Player = PlayerNode.instantiate()
	PlayerLayer.add_child(Player)
	Player.position = Vector2(26, 516)
	if OS.get_name() == "Windows":
		DiscordRPC.app_id = 1247248712359739444
		DiscordRPC.details = "Jumping from platform to platform"
		DiscordRPC.large_image = "https://cdn.discordapp.com/app-assets/1247248712359739444/1247251657406943333.png"
		DiscordRPC.large_image_text = "Chonky - Platformer"
		DiscordRPC.small_image = "https://cdn.discordapp.com/app-assets/1247248712359739444/1247261773778911252.png"
		DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		DiscordRPC.refresh()

	child_instance = levels[levelToLoad].instantiate()
	add_child(child_instance)
	child_instance.nextLevel.connect(loadNextLevel)
		
func _process(delta: float) -> void:
	if OS.get_name() == "Windows":
		DiscordRPC.run_callbacks()
	if Player:
		background.position.x = Player.position.x
		background.position.y = Player.position.y - 310
