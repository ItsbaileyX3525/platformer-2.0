extends Node

@onready var textBoxScene = preload("res://scenes/speech.tscn")

var dialogueLines: Array[String] = []
var currentLineIndex = 0

var textBox
var textBoxPos: Vector2

var isdialogueActive = false
var canAdvanceLine = false

func startDialogue(position: Vector2, lines: Array[String]):
	if isdialogueActive:
		return
	
	dialogueLines = lines
	print(position)
	textBoxPos = position
	_showTextBox()
	
	isdialogueActive = true
	
func _showTextBox():
	textBox = textBoxScene.instantiate()
	textBox.finishedDisplaying.connect(_onTextBoxFinishedDisplaying)
	get_tree().root.add_child(textBox)
	print(textBox.position)
	textBox.global_position = textBoxPos
	textBox.displayText(dialogueLines[currentLineIndex])
	canAdvanceLine = false

func  _onTextBoxFinishedDisplaying():
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
