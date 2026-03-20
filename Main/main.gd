class_name Main extends Node

const MAX_COLLECTABLES = 5
var _collectable_scene = preload("res://Collectable/collectable.tscn")
var points = 0

func _ready() -> void:
	if Multihelper.isHost:
		for i in MAX_COLLECTABLES:
			_spawn_collectable()

func _process(_delta: float) -> void:
	if !Multihelper.isHost:
		return

func onCollected(collector: Player, collected: Collectable) -> void:
	if collector is Dog:
		points += collected.dog_points
	elif collector is Person:
		points += collected.person_points
	%ScoreLabel.text = "Score: %s" % points
	collected.queue_free()
	_spawn_collectable()

func _spawn_collectable() -> void:
	var c := _collectable_scene.instantiate()
	c.position = Vector3(randf_range(-50.0, 50.0), 0.5, randf_range(-50.0, 50.0))
	c.person_points = randi_range(c.min_points, c.max_points)
	c.dog_points = randi_range(c.min_points, c.max_points)
	$Collectables.add_child(c, true)
