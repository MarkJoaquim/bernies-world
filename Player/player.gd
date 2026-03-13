class_name Player extends CharacterBody2D
const SCENE = preload("res://Player/player.tscn")

const SPEED = 200.0

@onready var bodySprite := $Body as Sprite2D

@export var playerName : String:
	set(value):
		playerName = value

@export var characterFile : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if name == str(multiplayer.get_unique_id()):
		$Camera2D.enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if str(multiplayer.get_unique_id()) == name:
		var vel = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown") * SPEED
		var mouse_position = get_global_mouse_position()
		var direction_to_mouse = mouse_position - global_position
		var angle = direction_to_mouse.angle()
		moveProcess(vel, angle)
		var inputData = {
			"vel": vel,
			"angle": angle
		}
		sendInputstwo.rpc_id(1, inputData)
		sendPos.rpc(position)

@rpc("any_peer", "call_local", "unreliable_ordered")
func sendInputstwo(data):
	moveServer(data["vel"], data["angle"])

@rpc("any_peer", "call_local", "unreliable_ordered")
func moveServer(_vel, angle):
	$Body.rotation = angle

func moveProcess(vel, angle):
	velocity = vel
	if velocity != Vector2.ZERO:
		move_and_slide()
	$Body.rotation = angle

@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendPos(pos):
	position = pos
