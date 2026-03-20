class_name Collectable extends Area3D

@export var min_points = -500
@export var max_points = 500
var person_points: int
var dog_points: int
var _main: Main

func _ready() -> void:
	_main = find_parent("Main") as Main
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)
	var local_player := _get_local_player()
	if local_player:
		apply_color_for_player(local_player)

func _get_local_player() -> Player:
	var main := find_parent("Main")
	if not main:
		return null
	return main.get_node("Players").get_node_or_null(str(multiplayer.get_unique_id())) as Player

func apply_color_for_player(player: Player) -> void:
	var pts: int = dog_points if player is Dog else person_points
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = _points_to_color(pts)
	$Sphere.material = mat

func _points_to_color(pts: int) -> Color:
	if pts <= 0:
		var t: float = 0.0 if min_points == 0 else clamp(float(pts - min_points) / float(-min_points), 0.0, 1.0)
		return Color.RED.lerp(Color.YELLOW, t)
	else:
		var t: float = 0.0 if max_points == 0 else clamp(float(pts) / float(max_points), 0.0, 1.0)
		return Color.YELLOW.lerp(Color.GREEN, t)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		collect(body)

func collect(body: Player) -> void:
	if _main:
		_main.onCollected(body, self)
