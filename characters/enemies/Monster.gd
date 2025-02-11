extends KinematicBody

onready var character_mover = $CharacterMover
onready var anim_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager
onready var nav: Navigation = get_parent() # Monster must always be a child of Navigation node!

enum STATES {
	IDLE,
	CHASE,
	ATTACK,
	DEAD
}
var cur_state = STATES.IDLE

var _player = null
var path = []

export var sight_angle = 45

export var attack_angle = 5.0

# how fast Monster turns in face_dir(), in degrees.
export var turn_speed = 360.0

# how far away Monster can attack, in meters
export var attack_range = 2.0

# how often Monster attacks in seconds
export var attack_rate = 0.5

export var attack_anim_speed_mod = 0.5

var attack_timer : Timer

var can_attack = true

signal attack


func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	
	
	_player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt")
	
	health_manager.init()
	health_manager.connect("dead", self, "set_state_dead")
	health_manager.connect("gibbed", $Graphics, "hide")
	character_mover.init(self)
	set_state_idle()

func _process(delta):
	# print(can_see_player())
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_delta(delta)

func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")

func set_state_chase():
	cur_state = STATES.CHASE
	can_attack = true
	print("CHASINGYOU")
	anim_player.play("walk_loop", 0.2)

func set_state_attack():
	cur_state = STATES.ATTACK

func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("die")
	character_mover.freeze()
	$CollisionShape.disabled = true

func process_state_idle(delta):
	if can_see_player():
		set_state_chase()

func process_state_chase(delta):
	if within_dist_of_player(attack_range) and has_los_player():
		set_state_attack()
	var player_pos: Vector3 = _player.global_transform.origin
	var our_pos: Vector3 = global_transform.origin
	path = nav.get_simple_path(our_pos, player_pos)

	var goal_pos = player_pos
	# if path is longer than the current position, 
	if path.size() > 1:
		# set the goal position to the next position on path
		goal_pos = path[1]
		
	# var dir: Vector3 = our_pos.direction_to(goal_pos)
	var dir = goal_pos - our_pos
	dir.y = 0 # make it into a 2d vector
	#print(dir)
	
	character_mover.set_move_vec(dir)
	
	face_dir(dir, delta)

func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO) # stop moving
	if can_attack:
		# while attacking, if out of range or can't see player, go back to chase mode
		if !within_dist_of_player(attack_range) or !can_see_player():
			set_state_chase()
		elif !player_within_angle(attack_angle) and can_attack:
			face_dir(global_transform.origin.direction_to(_player.global_transform.origin), delta)
		else:
			start_attack()
			

func process_state_delta(delta):
	pass

func hurt(damage: int, dir: Vector3):
	print("och! dmg: ", damage)
	if cur_state == STATES.IDLE:
		set_state_chase()
	health_manager.hurt(damage, dir)

func start_attack():
	can_attack = false
	anim_player.play("attack", -1, attack_anim_speed_mod)
	attack_timer.start()

func emit_attack_signal():
	emit_signal("attack")

func finish_attack():
	can_attack = true


# returns whether the  player is within this monster's field of view.
# field of view determined by the constant, sight_angle
func can_see_player():
	return player_within_angle(sight_angle) and has_los_player()

func player_within_angle(angle: float):
	var dir_to_player = global_transform.origin.direction_to(_player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < angle

# returns true if monster's sight of player is not obstructed
func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP
	var player_pos = _player.global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	if result:
		return false
	return true

# aims to rotate Monster towards dir in the current frame.
# dir: direction to turn towards
# delta: time since last frame
func face_dir(dir: Vector3, delta):
	# get the angle from Monster's forward vector to dir
	var angle_diff = global_transform.basis.z.angle_to(dir)
	
	# determine if we turn right by getting dot product of Monster's right vector and dir
	# (also determines which way is faster to turn, right or left)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	
	var amt_to_turn = deg2rad(turn_speed) * delta
	
	# if the angle difference is less than the amount we can turn,
	if abs(angle_diff) < amt_to_turn:
		# just set it to the goal direction
		rotation.y = atan2(dir.x, dir.z)
	else:
		# increment the turning by amt_to_turn * the sign
		rotation.y += amt_to_turn * turn_right
	
	# aim towards player
	$AimAtObject.aim_at_pos(_player.global_transform.origin)

func alert(check_los=true):
	# check if not already in IDLE state
	if cur_state != STATES.IDLE:
		return
	if check_los and !has_los_player():
		return
	set_state_chase()

func within_dist_of_player(dist: float):
	return global_transform.origin.distance_to(_player.global_transform.origin) < attack_range
