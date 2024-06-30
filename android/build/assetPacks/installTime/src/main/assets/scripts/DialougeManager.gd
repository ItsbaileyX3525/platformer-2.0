extends Node

@onready var textBoxScene := preload("res://scenes/speech.tscn")
@onready var timer := Timer.new()
var canSkipText: bool = false

func canSkip() -> void:
	canSkipText = true

func _ready() -> void:
	timer.set_wait_time(0.25)
	add_child(timer)
	timer.timeout.connect(canSkip)

var dialogueLines: Array[String] = []
var SFX
var currentLineIndex := 0
var isSpeech: bool = false

var textBox: MarginContainer
var textBoxPos: Vector2

var isdialogueActive := false
var canAdvanceLine := false

func startDialogue(position: Vector2, lines: Array[String], speechSfx) -> void:
	if isdialogueActive:
		return
	if not typeof(speechSfx) == TYPE_BOOL:
		SFX = speechSfx
		isSpeech = true
	else:
		isSpeech=false
		SFX = false
	
	dialogueLines = lines
	textBoxPos = position
	
	_showTextBox()
	
	isdialogueActive = true
	
func _showTextBox() -> void:
	textBox = textBoxScene.instantiate()
	textBox.finishedDisplaying.connect(_onTextBoxFinishedDisplaying)
	get_tree().root.add_child(textBox)
	textBox.global_position = textBoxPos
	textBox.displayText(dialogueLines[currentLineIndex],SFX)
	canAdvanceLine = false
	textBox.letterTime = 0.09
	textBox.spaceTime = 0.09
	textBox.puncTime = .2
	timer.start()

func  _onTextBoxFinishedDisplaying() -> void:
	canAdvanceLine = true
	
func clearDialogue() -> void:
	if is_instance_valid(textBox):
		textBox.queue_free()
		canAdvanceLine = true
		isdialogueActive = false
		currentLineIndex = 0
	return

func speedDialogue()  -> void:
	textBox.letterTime = .005
	textBox.spaceTime = .005
	textBox.puncTime = .005

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue") and isdialogueActive and canAdvanceLine:
		textBox.letterTime = 0.09
		textBox.spaceTime = 0.09
		textBox.puncTime = .2
		canSkipText = false
		textBox.queue_free()
		timer.start()
		
		
		
		currentLineIndex += 1
		if currentLineIndex >= dialogueLines.size():
			isdialogueActive = false
			currentLineIndex = 0
			return
		
		_showTextBox()
	if event.is_action_pressed("advance_dialogue") and isdialogueActive and not canAdvanceLine and canSkipText:
		speedDialogue()
