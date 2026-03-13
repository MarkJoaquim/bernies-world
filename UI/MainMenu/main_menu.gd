extends Control

@onready var characterSelectScene := preload("res://UI/CharacterSelect/character_select.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_button_pressed():
	Multihelper.create_game()
	proceed()

func _on_join_button_pressed() -> void:
	Multihelper.join_game()
	proceed()

func proceed():
	add_sibling(characterSelectScene.instantiate())
	queue_free()
