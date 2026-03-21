class_name Player extends CharacterBody3D

@export var player_name: String

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _update_collectables_color() -> void:
	var main := find_parent("Main")
	if not main:
		return
	for c in main.get_node("Collectables").get_children():
		if c.has_method(&"apply_color_for_player"):
			c.apply_color_for_player(self)

@rpc("any_peer", "call_local", "unreliable_ordered")
func sendInputstwo(data):
	moveServer(data["move"], data["angle"])

@rpc("any_peer", "call_local", "unreliable_ordered")
func moveServer(_vel, angle):
	pass #rotation = angle
	
@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendPos(pos):
	pass #position = pos

@rpc("any_peer", "call_local", "unreliable_ordered")
func sendForce(f):
	velocity += f
