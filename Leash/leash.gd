class_name Leash extends Node
const SCENE = preload("res://Leash/leash.tscn")

var from: Player
var to: Player

const LENGTH = 50

static func createLeash(_from: Player, _to: Player):
	var leash := SCENE.instantiate() as Leash
	leash.from = _from
	leash.to = _to
	return leash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var dist = from.position.distance_to(to.position)
	if (dist > LENGTH):
		to.position += (from.position - to.position).normalized() * ((dist - LENGTH)**2)
