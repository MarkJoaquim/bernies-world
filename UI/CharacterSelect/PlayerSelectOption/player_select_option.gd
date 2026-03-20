class_name PlayerSelectOption extends Control

var player_name
var type
var id
var dog_icon_texture = load("res://assets/UI/dog.png")
var owner_icon_texture = load("res://assets/UI/owner.png")

func set_player_info(player_info):
	player_name = player_info.name
	type = player_info.type
	id = player_info.id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Name.text = player_name
	if type == "dog":
		%Icon.texture = dog_icon_texture
		%Button.text = "+Owner"
	elif type == "person":
		%Icon.texture = owner_icon_texture
		%Button.text = "+Dog"

func _on_button_pressed() -> void:
	var new_player_name = find_parent("CharacterSelect").find_child("NameInput").text
	var new_player_type = "person" if type == "dog" else "dog"
	Multihelper.requestSpawn(new_player_name, multiplayer.get_unique_id(), new_player_type, id)
	find_parent("CharacterSelect").queue_free()
