extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_spawn_button_pressed() -> void:
	Multihelper.requestSpawn(%NameInput.text, multiplayer.get_unique_id(), "person")
	queue_free()

func _on_dog_button_pressed() -> void:
	Multihelper.requestSpawn(%NameInput.text, multiplayer.get_unique_id(), "dog")
	queue_free()
