extends Node

@onready var textBoxScene := preload("res://scenes/speech.tscn")

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
		print("Has speech")
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

func  _onTextBoxFinishedDisplaying() -> void:
	canAdvanceLine = true
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue") and isdialogueActive and canAdvanceLine:
		textBox.queue_free()
		
		currentLineIndex += 1
		if currentLineIndex >= dialogueLines.size():
			isdialogueActive = false
			currentLineIndex = 0
			return
		
		_showTextBox()
