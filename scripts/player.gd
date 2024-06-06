extends CharacterBody2D

@export var speed = 300
@export var gravity = 30
@export var jumpForce = 600
@export var deathBarrier: Node2D

@onready var idleChonk = $IdleChonky
@onready var idleAnim = $IdleChonky/AnimationPlayer
@onready var leftChonk = $ChonkyLeft
@onready var leftChonkAnim = $ChonkyLeft/AnimationPlayer
@onready var rightChonkAnim = $ChonkyRight/AnimationPlayer
@onready var rightChonk = $ChonkyRight
@onready var danceChonk = $DanceChonky
@onready var backgroundSFX = $BackgroundMusic
@onready var danceChonkAnim = $DanceChonky/AnimationPlayer
@onready var deathCounter = $RichTextLabel
@onready var transition = $ColorRect
@onready var transitionText = $RichTextLabel2
@onready var deathSFX = $Death
@onready var danceSFX = $Dance
@onready var controlsNode = $MobileControls
@onready var LeftButton = $MobileControls/Left
@onready var RightButton = $MobileControls/Right
@onready var UpButton = $MobileControls/Jump
@onready var MenuNode = $Menu2

var deaths = 0
var fixedTimestep = 1.0/60.0
var timer = 0.0
var jumpTimer = 0.0
var isDancing = false
var backgroundTime = 0.0
var onMobile = false
var canDoubleJump = false

#Mobile controls
var movingLeft = false
var jumping = false
var movingRight = false

func _ready() -> void:
	match OS.get_name():
		"Windows":
			controlsNode.visible=false
		"Web":
			$Menu2/Quit.visible=false
			controlsNode.visible=false
			onMobile = JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true)
			if onMobile:
				controlsNode.visible=true

func show_transition():
	transition.visible=true
	transitionText.visible=true
	gravity=0

func hide_transition():
	transition.visible=false
	transitionText.visible=false
	position.y = -350
	position.x = 0
	gravity=30

func Death(newPos: Vector2) -> void:
	position = newPos
	deaths+=1
	deathSFX.play()
	deathCounter.text = "Deaths: %s" % deaths
	#if deaths == 1:
		#DiscordRPC.state = "Died 1 time."
	#else:
		#DiscordRPC.state = "Died %s times." % deaths
	#DiscordRPC.refresh()
	
func addJump():
	canDoubleJump = true

func  step() -> void:
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 750:
			velocity.y = 750
	if position.y > 1900:
		Death(Vector2(0,250))
	if Input.is_action_just_pressed("pause"):
		MenuNode.visible= not MenuNode.visible

func _physics_process(delta):
	timer += delta
	if timer>= fixedTimestep:
		timer=0
		step()
	
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
	var hDirection = Input.get_axis("move_left", "move_right") 
	
	velocity.x = speed * hDirection
	
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
		print(leftChonkAnim.is_playing())
		if not leftChonkAnim.is_playing():
			print("Starting playing")
			idleAnim.stop()
			leftChonk.visible = true
			leftChonkAnim.play("move_left")
			rightChonkAnim.stop()
			rightChonk.visible = false
			idleChonk.visible = false
			danceChonk.visible=false
			danceSFX.stop()
			danceChonkAnim.stop()
			if not backgroundSFX.playing:
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
			if not backgroundSFX.playing:
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
				backgroundTime = backgroundSFX.get_playback_position()
				backgroundSFX.stop()
				danceSFX.play()
				
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

func _on_interact_released() -> void:
	Input.action_release("click")

func _on_menu_pressed():
	Input.action_press("pause")

func _on_menu_released():
	Input.action_release("pause")

func _on_touch_screen_button_pressed():
	get_tree().quit()

func _on_resume_pressed() -> void:
	MenuNode.visible=false

func _on_dance_pressed() -> void:
	Input.action_press("dance")

func _on_dance_released() -> void:
	Input.action_release("dance")
