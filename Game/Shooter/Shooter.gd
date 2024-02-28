extends Node2D

signal died

var bullet_scene: PackedScene = preload("res://Game/Bullet/Bullet.tscn")
var is_dead: bool = false
var last_direction: float = 1.0
var moving: bool = false
var time_since_last_move: float = 0  # Track time since last movement input

func _ready():
	moving = false  # Ensure moving is initialized to false

func set_data(in_id: int, in_lifetime: float, in_position: Vector2, in_color: Color) -> void:
	$ShooterBody.set_data(in_id, in_lifetime, in_color)
	$ShooterBody.position = in_position
	$Bullet.position = in_position
	$Bullet.connect("bullet_destroyed", Callable(self, "_on_bullet_destroyed"))
	$Bullet.set_data(in_id)

	set_multiplayer_authority(in_id)

func handle_input(delta: float, direction: Vector2) -> void:
	var animation_player = $ShooterBody/AnimationPlayer
	if animation_player:
		if direction.length() == 0:
			time_since_last_move += delta
			if time_since_last_move > 0.1 and moving:  # Add a slight delay to ensure it's not a brief stop
				animation_player.play("idle")
				moving = false
		else:
			time_since_last_move = 0  # Reset timer on movement
			if not moving:
				animation_player.play("walk")
				moving = true

			var sprite = $ShooterBody
			if direction.x != 0:
				last_direction = sign(direction.x)
				sprite.scale.x = abs(sprite.scale.x) * last_direction
				sprite.scale.y = abs(sprite.scale.y)

	$ShooterBody.handle_input(delta, direction)

func get_lifetime() -> float:
	return $ShooterBody.lifetime

func _on_bullet_destroyed() -> void:
	$Bullet.position = $ShooterBody.position
	$Bullet._ready()

func _on_shooter_body_died():
	is_dead = true
	died.emit()

func hide_self() -> void:
	$ShooterBody.hide()
	$Bullet.hide()
	$Bullet/CollisionShape2D.call_deferred("set_disabled", true)
	$ShooterBody/PlayerInterface/ProgressBar.visible = false
	$ShooterBody/PlayerInterface/Username.visible = false

func show_self() -> void:
	$ShooterBody.show()
	$Bullet.show()
	$Bullet/CollisionShape2D.call_deferred("set_disabled", false)
	$ShooterBody/PlayerInterface/ProgressBar.visible = true
	$ShooterBody/PlayerInterface/Username.visible = true
