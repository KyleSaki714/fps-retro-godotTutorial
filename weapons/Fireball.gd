extends KinematicBody

var speed = 20
var impact_damage = 20 # extra direct damage
var exploded = false

func _ready():
	hide() # so rocket doesn't appear immediately in front of player's camera when instanced

func set_bodies_to_exclude(bodies_to_exclude: Array):
	for body in bodies_to_exclude:
		add_collision_exception_with(body)

func _physics_process(delta):
	# KinematicCollision is information about collision with another body after moving 
	# move and collide parameters: forward vector * speed * time since last frame
	# move and SLIDE multiplies delta automatically, collide does not
	var collision : KinematicCollision = move_and_collide(-global_transform.basis.z * speed * delta)
	if collision:
		var collider = collision.collider
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z)
		explode()
		
func explode():
	$SmokeParticles.emitting = true
	speed = 0
	$Graphics.hide()
	$CollisionShape.disabled = true
	$DestroyAfterHitTimer.start()
	$FireParticles.emitting = false
	

