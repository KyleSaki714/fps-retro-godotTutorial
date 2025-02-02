extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 4
export var max_speed = 25
var drag = 0.0 # calcs in _ready
export var jump_force = 30
export var gravity = 60

var pressed_jump = false 
var move_vec : Vector3 # auto inits to Vector3.ZERO
var velocity : Vector3
var snap_vec : Vector3 # how body "sticks" to the ground when moving
export var ignore_rotation = false
# if true, moves on planes relative to global coordinates, not itself

signal movement_info

var frozen = false
# "dies" just keep them in place

func _ready():
	drag = float(move_accel) / max_speed
	# to prevent integer division

func init(_body_to_move : KinematicBody):
	body_to_move = _body_to_move
	# so the body knows exactly what body to move

func jump():
	pressed_jump = true

func set_move_vec(_move_vec: Vector3):
	move_vec = _move_vec.normalized()

func _physics_process(delta):
	if frozen:
		return
	var cur_move_vec = move_vec
	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * Vector3(drag, 0 ,drag) + gravity * Vector3.DOWN * delta
	# (accel * direction we're moving) - current velocity * drag air resistance?) +
	# gravity and down and delta, adds all this to velocity
	velocity = body_to_move.move_and_slide_with_snap(velocity, snap_vec,Vector3.UP)
	# snap keeps it connected to the ground on slopes
	# also: moveandslidew/snap returns with vector3 0 at the y if hit a cieling
	
	var grounded = body_to_move.is_on_floor()
	if grounded:
		velocity.y = -0.01
		# want to keep moving down
	if grounded and pressed_jump:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.DOWN
	pressed_jump = false
	# sets it back to false because we already jumped on this frame
	emit_signal("movement_info", velocity, grounded)

func freeze():
	frozen = true

func unfreeze():
	frozen = false
