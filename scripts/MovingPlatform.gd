extends AnimatableBody2D

@export var collisionEnabled = true
@export var spriteVisible=true
@onready var collision = $CollisionShape2D

func _process(delta: float) -> void:
	if collisionEnabled:
		collision.disabled=false
	else:
		collision.disabled=true
		
	if spriteVisible:
		visible=true
	else:
		visible=false
