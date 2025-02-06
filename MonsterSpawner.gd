extends Spatial

var birdmonster = preload("res://characters/enemies/BirdMonster.tscn")
var reptilemonster = preload("res://characters/enemies/ReptileMonster.tscn")

export var _spawn_diameter = 3

func _ready():
	spawn()

# spawns a number of enemies within the specified _spawn_diameter.
func spawn(spawn_count=10):
	for n in range(spawn_count):
		var reptile_monster_inst = birdmonster.instance()
		reptile_monster_inst.global_transform = Transform(reptile_monster_inst.global_transform.basis, global_transform.origin + rand_point())
		get_tree().get_root().get_node("./World/Navigation").add_child(reptile_monster_inst)
		


# checks if able to spawn a monster there.

# selects a random point in the diameter to spawn the monster, 
# returns the offset to be added to the monster's transform.
func rand_point() -> Vector3:
	var x = rand_range(-1.0, 1.0) * _spawn_diameter
	var z = rand_range(-1.0, 1.0) * _spawn_diameter
	var offset = Vector3(x, 0, z)
	return offset
