extends CharacterBody2D

@export var max_speed := 300.0
@export var acceleration := 120.0
@export var friction := 10.0
var speed := 0.0  # Den aktuella hastigheten för bilen'
@export var base_max_speed := 100.0
@export var max_gear := 5
@export var min_gear := -1
var gear := 1  # Startväxeln är framåt

func handle_gear_change() -> void:
	if Input.is_action_just_pressed("gear_up") and gear < max_gear:
		gear += 1
	elif Input.is_action_just_pressed("gear_down") and gear > min_gear:
		gear -= 1
	   
	# Justera maxhastighet baserat på växeln
	max_speed = base_max_speed * abs(gear)	
	
@export var max_steering_angle := 40.0
var steering_angle := 0.0
func update_steering_angle(delta: float) -> void:
	if Input.is_action_pressed("turn_right"):
		steering_angle = min(steering_angle + 100 * delta, max_steering_angle)
	elif Input.is_action_pressed("turn_left"):
		steering_angle = max(steering_angle - 100 * delta, -max_steering_angle)
	else:
		steering_angle = move_toward(steering_angle, 0, 60.0 * delta)

func _process(delta: float) -> void:
	handle_gear_change()
	update_steering_angle(delta)
	rotation += deg_to_rad(steering_angle) * delta

	# Hantera acceleration och bromsning
	if Input.is_action_pressed("accelerate"):
		speed += acceleration * delta
	elif Input.is_action_pressed("brake"):
		speed -= acceleration * delta
	else:
		# Gradvis sänkning av hastigheten när ingen knapp är tryckt
		speed = move_toward(speed, 0, friction * delta)
	   
	# Begränsa hastigheten
	speed = clamp(speed, -max_speed, max_speed)

	# Uppdatera bilens position i riktning mot rotationen
	var forward_movement = Vector2(cos(rotation), sin(rotation)) * speed * delta
	position += forward_movement
