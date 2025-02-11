extends Spatial

func aim_at_pos(pos: Vector3):
	rotation = Vector3.ZERO
	var offset = to_local(pos)
	offset.x = 0 # pivot on the x axis
	rotation.x = -atan2(offset.y, offset.z)
