extends CharacterBody2D

@export var speed := 300
@export var gravity := 30
@export var jumpForce := 600
@export var climbSpeed := 300
@export var invinc := false
var isClimbing := false

@onready var raycastLeft := $RayCast2D_Left
@onready var raycastLeftH: RayCast2D = $RayCast2D_LeftH
@onready var raycastRight := $RayCast2D_Right
@onready var raycastRightH: RayCast2D = $RayCast2D_RightH

@onready var coinsCounter: RichTextLabel = $RichTextLabel3
@onready var realTimer := $Timer
@onready var idleChonk := $IdleChonky
@onready var idleAnim := $IdleChonky/AnimationPlayer
@onready var leftChonk := $ChonkyLeft
@onready var leftChonkAnim := $ChonkyLeft/AnimationPlayer
@onready var rightChonkAnim := $ChonkyRight/AnimationPlayer
@onready var rightChonk := $ChonkyRight
@onready var danceChonk := $DanceChonky
@onready var backgroundSFX := $BackgroundMusic
@onready var backgroundSFX2 := $BackgroundMusic2
@onready var danceChonkAnim := $DanceChonky/AnimationPlayer
@onready var deathCounter := $RichTextLabel
@onready var transition := $ColorRect
@onready var transitionText := $RichTextLabel2
@onready var deathSFX := $Death
@onready var danceSFX := $Dance
@onready var danceSFX2 := $Dance2
@onready var controlsNode := $MobileControls
@onready var LeftButton := $MobileControls/Left
@onready var RightButton := $MobileControls/Right
@onready var UpButton := $MobileControls/Jump
@onready var MenuNode := $Menu2

signal yoParentNode()
signal characterDeath()

var deaths := 0
var fixedTimestep := 1.0/60.0
var timer := 0.0
var jumpTimer := 0.0
var isDancing := false
var backgroundTime := 0.0
var onMobile := false
var coins := 0
var speedyBoi := false
var speedTimer := 0.0
var speedCanLast := 5.0
var speedMultiplier := 1.5
var canDoubleJump := false
var inMenu := false
var secretsClicked := 0
var doneSecret := false
var canClimb := false

#Mobile controls
var movingLeft := false
var jumping := false
var movingRight := false

func saveGame(dictToSave: Dictionary) -> void:
	var gameFile := FileAccess.open("user://playerSave.json", FileAccess.WRITE)
	
	var jsonString := JSON.stringify(dictToSave)
	gameFile.store_line(jsonString)

func loadGame() -> Dictionary:
	var loadedData: Dictionary 
	if not FileAccess.file_exists("user://playerSave.json"): 
		var save_dict := {
			"deaths": 0,
			"coins": 0
		}
		return save_dict
	else:
		var gameSave := FileAccess.get_file_as_string("user://playerSave.json")

		loadedData = JSON.parse_string(gameSave)

	
	return loadedData

var data := loadGame()

func giveCoin(amount: int) -> void:
	coins += 1
	data["coins"] = coins
	saveGame(data)
	coinsCounter.text = "Coins: %s" % coins
	


func _ready() -> void:
	if "coins" in data:
		coins = data["coins"]
	else:
		coins = 0
	if "deaths" in data:
		deaths = data["deaths"]
	else:
		deaths = 0
	deathCounter.text = "Deaths: %s" % deaths
	coinsCounter.text = "Coins: %s" % coins
	raycastLeft.enabled = true
	raycastRight.enabled = true
	raycastLeftH.enabled = true
	raycastRightH.enabled = true
	match OS.get_name():
		"Android":
			controlsNode.visible=true
		"iOS":
			controlsNode.visible=true
		"Web":
			$Menu2/Quit.visible=false
			onMobile = JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true)
			if onMobile:
				controlsNode.visible=true

func show_transition() -> void:
	transition.visible=true
	transitionText.visible=true
	gravity=0

func hide_transition() -> void:
	transition.visible=false
	transitionText.visible=false
	position.y = -350
	position.x = 0
	gravity=30

func Death(newPos: Vector2) -> void:
	if not invinc:
		position = newPos
		deaths+=1
		deathSFX.play()
		deathCounter.text = "Deaths: %s" % deaths
		characterDeath.emit()
		data["deaths"] = deaths
		saveGame(data)
	
func addPoint() -> void:
	secretsClicked+=1

func addJump() -> void:
	canDoubleJump = true

func addSpeed(length: float = 5, speedAmount: float = 1.5) -> void:
	speedTimer = 0
	speedCanLast = length
	speedMultiplier = speedAmount
	rightChonkAnim.speed_scale = speedAmount
	leftChonkAnim.speed_scale = speedAmount
	danceChonkAnim.speed_scale = speedAmount
	idleAnim.speed_scale = speedAmount
	speedyBoi = true


var collider: StaticBody2D
func  step() -> void:
	if !is_on_floor():
		if not isClimbing:
			velocity.y += gravity
		if velocity.y > 750:
			velocity.y = 750
	if position.y > 1900:
		Death(Vector2(0,250))
	if Input.is_action_just_pressed("pause"):
		MenuNode.visible= not MenuNode.visible
		inMenu = not inMenu
		get_tree().paused = not get_tree().paused
		if Input.get_connected_joypads().size() >= 1:
			$Menu2/Resume.grab_focus()

	if raycastLeft.is_colliding():
		collider = raycastLeft.get_collider()
		var colliderName := collider.name.rstrip("0123456789")
		if collider and colliderName == "Climbable":
			canClimb = true
	elif raycastRight.is_colliding():
		collider = raycastRight.get_collider()
		var colliderName := collider.name.rstrip("0123456789")
		if collider and colliderName  == "Climbable":
			canClimb = true
	elif raycastLeftH.is_colliding():
		collider = raycastLeftH.get_collider()
		var colliderName := collider.name.rstrip("0123456789")
		if collider and colliderName  == "Climbable":
			canClimb = true
	elif raycastRightH.is_colliding():
		collider = raycastRightH.get_collider()
		var colliderName := collider.name.rstrip("0123456789")
		if collider and colliderName  == "Climbable":
			canClimb = true
	else:
		canClimb = false
		isClimbing = false

	if canClimb:
		if Input.is_action_pressed("move_up"):
			isClimbing = true
			velocity.y = -climbSpeed
		elif Input.is_action_pressed("move_down"):
			isClimbing = true
			velocity.y = climbSpeed
		else:
			isClimbing=false

func _physics_process(delta: float) -> void:
	timer += delta
	if timer>= fixedTimestep:
		timer=0
		step()
	
	if secretsClicked == 4 and not doneSecret:
		doneSecret=true
		backgroundSFX.stop()
		yoParentNode.emit()
		realTimer.start()
		await realTimer.timeout
		backgroundSFX2.play()
	
	if speedyBoi:
		speedTimer+=delta
	if speedTimer >= speedCanLast:
		speedyBoi=false
		speedTimer=0
		rightChonkAnim.speed_scale = 1
		leftChonkAnim.speed_scale = 1
		danceChonkAnim.speed_scale = 1
		idleAnim.speed_scale = 1
	
	if not inMenu:
		if Input.is_action_just_pressed("jump"):
			jumpTimer = 0.1
		jumpTimer-=delta
		if jumpTimer > 0 and is_on_floor():
			jumpTimer = 0.0
			velocity.y = -jumpForce
		elif jumpTimer > 0 and canDoubleJump:
			jumpTimer = 0.0
			velocity.y = -jumpForce
			canDoubleJump=false
	
		var hDirection := Input.get_axis("move_left", "move_right") 
		
		if not speedyBoi:
			velocity.x = speed * hDirection
		else:
			velocity.x = speed * hDirection * speedMultiplier
	
		move_and_slide()
		
		if Input.is_action_pressed("move_right") && Input.is_action_pressed("move_left"):
			if not idleAnim.is_playing() and not isDancing:
				idleAnim.play("idle")
				leftChonkAnim.stop()
				rightChonkAnim.stop()
				idleChonk.visible = true
				rightChonk.visible=false
				leftChonk.visible=false
				danceChonk.visible=false
		elif Input.is_action_pressed("move_left"):
			if not leftChonkAnim.is_playing():
				idleAnim.stop()
				leftChonk.visible = true
				leftChonkAnim.play("move_left")
				rightChonkAnim.stop()
				rightChonk.visible = false
				idleChonk.visible = false
				danceChonk.visible=false
				danceSFX.stop()
				danceChonkAnim.stop()
				if not backgroundSFX.playing and not doneSecret:
					backgroundSFX.play()
					backgroundSFX.seek(backgroundTime)
		elif Input.is_action_pressed("move_right"):
			if not rightChonkAnim.is_playing():
				idleAnim.stop()
				leftChonk.visible = false
				leftChonkAnim.stop()
				rightChonkAnim.play("move_right")
				rightChonk.visible = true
				danceSFX.stop()
				idleChonk.visible = false
				danceChonk.visible=false
				danceChonkAnim.stop()
				if not backgroundSFX.playing and not doneSecret:
					backgroundSFX.play()
					backgroundSFX.seek(backgroundTime)
		else:
			if not idleAnim.is_playing() and not isDancing:
				idleAnim.play("idle")
				leftChonkAnim.stop()
				rightChonkAnim.stop()
				idleChonk.visible = true
				rightChonk.visible=false
				leftChonk.visible=false
				danceChonk.visible=false

		if Input.is_action_just_pressed("dance"):
			if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
				if not danceChonkAnim.is_playing():
					danceChonk.visible=true
					danceChonkAnim.play("dance")
					if doneSecret:
						danceSFX2.play()
						backgroundTime = backgroundSFX2.get_playback_position()
						backgroundSFX2.stop()
					else:
						danceSFX.play()
						backgroundTime = backgroundSFX.get_playback_position()
						backgroundSFX.stop()
					
					idleChonk.visible=false
					rightChonk.visible=false
					leftChonk.visible=false

func _on_jump_pressed() -> void:
	Input.action_press("jump")

func _on_jump_released() -> void:
	Input.action_release("jump")

func _on_right_pressed() -> void:
	Input.action_press("move_right")

func _on_right_released() -> void:
	Input.action_release("move_right")

func _on_left_pressed() -> void:
	Input.action_press("move_left")

func _on_left_released() -> void:
	Input.action_release("move_left")

func _on_interact_pressed() -> void:
	Input.action_press("click")
	Input.action_press("advance_dialogue")

func _on_interact_released() -> void:
	Input.action_release("click")
	Input.action_release("advance_dialogue")

func _on_menu_pressed() -> void:
	Input.action_press("pause")

func _on_menu_released() -> void:
	Input.action_release("pause")

func _on_resume_pressed() -> void:
	MenuNode.visible=false
	get_tree().paused = false
	inMenu = false

func _on_dance_pressed() -> void:
	Input.action_press("dance")

func _on_dance_released() -> void:
	Input.action_release("dance")

func _on_up_pressed() -> void:
	Input.action_press("move_up")

func _on_up_released() -> void:
	Input.action_release("move_up")

func _on_down_pressed() -> void:
	Input.action_press("move_down")

func _on_down_released() -> void:
	Input.action_release("move_down")

func _on_return_pressed() -> void:
	yoParentNode.emit("Return")
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_quit_mobile_pressed() -> void:
	get_tree().quit()

func _on_return_mobile_pressed() -> void:
	yoParentNode.emit("Return")
	get_tree().paused = false

func _on_resume_mobile_pressed() -> void:
	MenuNode.visible=false
	get_tree().paused = false
	inMenu = false

func _on_dialog_pressed() -> void:
	Input.action_press("start_dialogue")

func _on_dialog_released() -> void:
	Input.action_release("start_dialogue")
