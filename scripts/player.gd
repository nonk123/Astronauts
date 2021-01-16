extends KinematicBody2D


# The g constant in px * s^(-2).
const STANDARD_GRAVITY = 9.8 * 32.0

# Accelerate this much when walking. In px * s^(-2).
export(float) var walking_speed = 256.0

# Push given when you jump, in px/s.
export(float) var jump_height = 256.0

# Friction seen during ground movement.
export(float) var friction_coefficient = 1.0

var velocity = Vector2()


func _ready():
	if is_network_master():
		$Shape/Camera.current = true
		add_child(preload("res://entities/ui.tscn").instance())


func _physics_process(delta):
	if is_network_master():
		run_physics(delta)
	else:
		# Predict movement based on the received velocity.
		velocity = move_and_slide(velocity, Vector2(0.0, -1.0))


func _process(_delta):
	var animation = $Shape/Animation
	
	# All the animations are aligned to the right.
	animation.flip_h = velocity.x < 0.0;
	
	if not is_on_floor():
		animation.play("jumping")
	elif abs(velocity.x) > 12.0:
		animation.play("walking")
	else:
		animation.play("standing")
	
	if is_network_master():
		if Input.is_action_just_pressed("exit"):
			get_tree().quit(0)
		
		var debugInfo = $UI/HBox/VBox/DebugInfo
		var format = [position.x, position.y, velocity.x, velocity.y]
		
		debugInfo.text = "P: %.2f %.2f; V: %.2f %.2f" % format


# Return a number between -1.0 and 1.0 according to the pressed movement keys.
# Return 0.0 if not moving.
func get_movement_axis():
	var axis = 0.0
	
	if Input.is_action_pressed("move_left"):
		axis -= 1.0
	
	if Input.is_action_pressed("move_right"):
		axis += 1.0
	
	return axis


puppet func receive_update(master_position, master_velocity):
	position = master_position
	velocity = master_velocity


# Physics simulation run by the node's master.
func run_physics(delta):
	velocity.y += STANDARD_GRAVITY * delta # positive y is downwards
	
	if is_on_floor():
		velocity.x += get_movement_axis() * walking_speed * delta
		
		var base_friction = friction_coefficient * STANDARD_GRAVITY * delta
		velocity.x -= base_friction * velocity.x / walking_speed
		
		if Input.is_action_just_pressed("jump"):
			velocity.y -= jump_height
	
	rpc_unreliable("receive_update", position, velocity)
	velocity = move_and_slide(velocity, Vector2(0.0, -1.0))
