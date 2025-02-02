extends Spatial

var hit_effect = preload("res://effects/BulletHitEffect.tscn")

export var distance = 10000 # how far you can shoot
var bodies_to_exclude = [] # bodies that should not get "shot"
var damage = 1 # is set by the weapon itself

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	var space_state = get_world().get_direct_space_state()
	var our_pos = global_transform.origin
	var result = space_state.intersect_ray(
		our_pos,
		our_pos - global_transform.basis.z * distance, # distance units in front of us
		bodies_to_exclude,
		1 + 4, # only hit world, or hitboxes. don't hit characters
		true,
		true)
	
	# thing that was hit has a hurt method (like the player)
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(damage, result.normal)
	# the thing that was hit must be a wall
	elif result:
		var hit_effect_instance = hit_effect.instance()
		# gets the root of the world scene, add the HEI to it
		get_tree().get_root().add_child(hit_effect_instance) 
		# set the pos of the HEI to the intersection point
		hit_effect_instance.global_transform.origin = result.position 
		
		# if the hit object's surface normal is facing up dont do anything
		if result.normal.angle_to(Vector3.UP) < 0.00005:
			return
		# if facing upside down (ceiling) flip upside down
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			return
		
		# use the cross product to create 3 vectors for a Basis transform 
		var y = result.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)
		
		hit_effect_instance.global_transform.basis = Basis(x, y, z)
		
		
	
