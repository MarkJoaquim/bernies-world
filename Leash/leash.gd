class_name Leash extends Node3D
const SCENE = preload("res://Leash/leash.tscn")

var from: Person
var to: Dog

@export var LENGTH = 5.0
@export var ELASTIC_CONSTANT = 0.05

var _line_mesh := ImmediateMesh.new()
@onready var _line := $Line as MeshInstance3D

static func createLeash(_from: Person, _to: Dog):
	var leash := SCENE.instantiate() as Leash
	leash.from = _from
	leash.to = _to
	return leash

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.6, 0.4, 0.2)
	_line.material_override = mat
	_line.mesh = _line_mesh

func _process(_delta: float) -> void:
	if not from or not to:
		return
	_line_mesh.clear_surfaces()
	_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_line_mesh.surface_add_vertex(_line.to_local(from.get_hand().global_position))
	_line_mesh.surface_add_vertex(_line.to_local(to.global_position))
	_line_mesh.surface_end()

func _physics_process(_delta: float) -> void:
	if from and to:
		applyLeashTension()

@rpc("authority", "call_local", "unreliable_ordered")
func applyLeashTension():
	var hand_pos: Vector3 = from.get_hand().global_position
	var dog_pos: Vector3 = to.global_position
	var dist: float = hand_pos.distance_to(dog_pos)
	if dist > LENGTH:
		var stretch: float = dist - LENGTH
		var force: float = ELASTIC_CONSTANT * stretch * stretch
		var dir: Vector3 = (dog_pos - hand_pos).normalized()
		from.sendForce(dir * force)
		to.sendForce(-dir * force)
