class_name Dog extends Player

@export var SPEED = 10.0
@export var JUMP = 10.0
@export var ACCELERATION = 60.0
@export var FALL_ACCELERATION = 10.0
@export var TERMINAL_VELOCITY = -20.0
@export var FRICTION = 60.0
@export var MOUSE_SENSITIVITY = 0.002

var _pitch: float = 0.0
var _paused := false

func _ready() -> void:
	if name == str(multiplayer.get_unique_id()):
		$Camera3D.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$CanvasLayer/PauseMenu.resumed.connect(_on_resume)
		_update_collectables_color()

func _on_resume() -> void:
	_set_paused(false)

func _set_paused(paused: bool) -> void:
	_paused = paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$CanvasLayer/PauseMenu.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$CanvasLayer/PauseMenu.hide()

func _input(event: InputEvent) -> void:
	if name != str(multiplayer.get_unique_id()):
		return
	if Input.is_action_just_pressed("pause"):
		_set_paused(!_paused)
	if event is InputEventMouseMotion and not _paused:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_pitch = clamp(_pitch - event.relative.y * MOUSE_SENSITIVITY, -PI / 2.0, PI / 2.0)
		$Camera3D.rotation.x = _pitch

func _physics_process(delta: float) -> void:
	if str(multiplayer.get_unique_id()) != name:
		return

	var moveInput2d = Input.get_vector("moveUp", "moveDown", "moveRight", "moveLeft")
	if moveInput2d != Vector2.ZERO:
		var move_dir = transform.basis * Vector3(moveInput2d.x, 0, moveInput2d.y)
		velocity.x = move_toward(velocity.x, move_dir.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, move_dir.z * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += JUMP

	velocity.y -= FALL_ACCELERATION * delta
	velocity.y = max(velocity.y, TERMINAL_VELOCITY)

	move_and_slide()

	var inputData = {
		"move": moveInput2d,
		"angle": rotation
	}
	sendInputstwo.rpc_id(1, inputData)
	sendPos.rpc(position)
