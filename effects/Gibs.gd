extends Spatial

func _ready():
	hide()

func enable_gibs():
	show()
	for child in get_children():
		if child.has_method("init"):
			child.init()
		if "emitting" in child: # in checks for field signature?
			child.emitting = true
