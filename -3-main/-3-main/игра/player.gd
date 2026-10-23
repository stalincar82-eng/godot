extends CharacterBody3D

# Настройки скорости
@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var jump_velocity: float = 4.5

# Гравитация из настроек проекта
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Ссылки на узлы
@onready var pivot: Node3D = $Pivot
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	# 1. Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Воспроизведение трюка/атаки (Клавиша F или E)
	if Input.is_action_just_pressed("ui_accept") or Input.is_physical_key_pressed(KEY_F):
		playback.travel("Flair")

	# 3. Получение ввода движения (WASD / Стрелки)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# 4. Бег (Left Shift)
	var is_running := Input.is_key_pressed(KEY_SHIFT)
	var current_speed := run_speed if is_running else walk_speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Плавный поворот персонажа в сторону движения
		var target_rotation = atan2(-direction.x, -direction.z)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, target_rotation, delta * 10.0)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# 5. Передача параметров в AnimationTree
	var speed_percent = velocity.length() / run_speed
	anim_tree.set("parameters/Locomotion/SpeedBlend/blend_position", speed_percent)

	move_and_slide()
