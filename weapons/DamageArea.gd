extends Area

var bodies_to_exclude = [] # bodies that should not get "shot"
var damage = 1 # is set by the weapon itself

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	print("RAH")
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and !body in bodies_to_exclude:
			# call body's hurt method:
			# pass in dmg, and a vector3 that represents direction pointing from damagearea to body
			body.hurt(damage, global_transform.origin.direction_to(body.global_transform.origin))
