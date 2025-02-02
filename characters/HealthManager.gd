extends Spatial

var blood_spray = preload("res://effects/BloodSpray.tscn")
var gibs = preload("res://effects/Gibs.tscn")
signal dead
signal hurt
signal healed
signal health_changed
signal gibbed #explode

export var max_health = 100
var cur_health = 1

export var gib_at = -20
# if health is at -20, do gib

func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)

# int, direction damage came from, damage type? damage_type="normal"
# dir: used for blood splatter and stuff
func hurt(damage: int, dir: Vector3):
	spawn_blood(dir)
	if cur_health <= 0:
		return
	cur_health -= damage
	if cur_health <= gib_at:
		print("gibbed")
		pass # make gib spawner
		emit_signal("gibbed")
		spawn_gibs()
		
	if cur_health <= 0:
		emit_signal("dead")
		print("dead")
	else:
		emit_signal("hurt")
	emit_signal("health_changed", cur_health)
	print('oof! hurt: ', damage, ' current health: ', cur_health)
	

func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health += amount
	if cur_health > max_health:
		cur_health = max_health
	print('healed ', amount, ' current health', cur_health)
	emit_signal("healed")
	emit_signal("health_changed", cur_health)

func spawn_blood(dir):
	var blood_spray_instance = blood_spray.instance()
	# gets the root of the world scene, add the HEI to it
	get_tree().get_root().add_child(blood_spray_instance) 
	# set the pos of the HEI to the intersection point
	blood_spray_instance.global_transform.origin = global_transform.origin 
	
	# if the hit object's surface normal is facing up dont do anything
	if dir.angle_to(Vector3.UP) < 0.00005:
		return
	# if facing upside down (ceiling) flip upside down
	if dir.angle_to(Vector3.DOWN) < 0.00005:
		return
	
	# use the cross product to create 3 vectors for a Basis transform 
	var y = dir
	var x = y.cross(Vector3.UP)
	var z = x.cross(y)
	
	blood_spray_instance.global_transform.basis = Basis(x, y, z)

func spawn_gibs():
	var gibs_instance = gibs.instance()
	get_tree().get_root().add_child(gibs_instance)
	gibs_instance.global_transform.origin = global_transform.origin
	gibs_instance.enable_gibs()
