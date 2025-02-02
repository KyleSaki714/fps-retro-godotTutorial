extends KinematicBody

export var start_move_speed = 30
export var gravity = 35.0
export var drag = 0.01
export var velo_retained_on_bounce = 0.8 # https://en.wikipedia.org/wiki/Coefficient_of_restitution
var velocity = Vector3.ZERO
var initialized = false

func init():
	initialized = true
	velocity = -global_transform.basis.y * start_move_speed

func _physics_process(delta):
	if !initialized:
		return
	
	# velocity, drag, and gravity vector
	velocity += -velocity * drag + Vector3.DOWN * gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	# r = d - 2 ( d . n ) n
	# https://www.fabrizioduroni.it/blog/post/2017/08/25/how-to-calculate-reflection-vector
	if collision:
		var d = velocity
		var n = collision.normal
		var r = d - 2 * d.dot(n) * n
		velocity = r * velo_retained_on_bounce
