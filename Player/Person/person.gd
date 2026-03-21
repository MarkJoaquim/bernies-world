class_name Person extends Player

@export var SPEED = 10.0
@export var JUMP = 10.0
@export var ACCELERATION = 60.0
@export var FALL_ACCELERATION = 10.0
@export var TERMINAL_VELOCITY = -20.0
@export var FRICTION = 60.0

@export var HAND_RADIUS := 0.75

func _ready() -> void:
	if name == str(multiplayer.get_unique_id()):
		$Camera3D.make_current()
		_update_collectables_color()

func _physics_process(delta: float) -> void:
	if str(multiplayer.get_unique_id()) != name:
		return

	var camera := $Camera3D as Camera3D
	var ray_origin := camera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_dir := camera.project_ray_normal(get_viewport().get_mouse_position())
	var plane := Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(ray_origin, ray_dir)
	if intersection == null:
		return
	var dir := Vector3(intersection.x - global_position.x, 0.0, intersection.z - global_position.z)
	if dir.length_squared() < 0.001:
		return
	%Hand.position = dir.normalized() * HAND_RADIUS

	var moveInput2d = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	if moveInput2d != Vector2.ZERO:
		velocity.x = move_toward(velocity.x, moveInput2d.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, moveInput2d.y * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += JUMP

	velocity.y -= FALL_ACCELERATION * delta
	velocity.y = max(velocity.y, TERMINAL_VELOCITY)

	move_and_slide()

	var angle = rotation
	var inputData = {
		"move": moveInput2d,
		"angle": angle
	}
	sendInputstwo.rpc_id(1, inputData)
	sendPos.rpc(position)
	#sendHandPos.rpc(%Hand.position)

func get_hand():
	return %Hand
	
@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendHandPos(pos):
	pass #%Hand.position = pos
