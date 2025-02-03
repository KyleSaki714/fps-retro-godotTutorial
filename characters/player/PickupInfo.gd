extends Label

const MAX_LINES = 5
var _pickups_info = []

func _ready():
	text = ""

func add_pickups_info(pickup_type, amnt:int):
	$RemoveInfoTimer.start()
	match pickup_type:
		Pickup.PICKUP_TYPES.MACHINE_GUN:
			_pickups_info.push_back("Picked up Machine Gun")
		Pickup.PICKUP_TYPES.MACHINE_GUN_AMMO:
			_pickups_info.push_back("Picked up Machine Gun Ammo: " + str(amnt))
		Pickup.PICKUP_TYPES.SHOTGUN:
			_pickups_info.push_back("Picked up ShotGun")
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			_pickups_info.push_back("Picked up ShotGun Ammo: " + str(amnt))
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			_pickups_info.push_back("Picked up Rocket Launcher")
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
			_pickups_info.push_back("Picked up Rocket Launcher Ammo: " + str(amnt))
	while _pickups_info.size() >= MAX_LINES:
		_pickups_info.pop_front()
	update_display()

func remove_pickups_info():
	if _pickups_info.size() > 0:
		_pickups_info.pop_front()
	update_display()

func update_display():
	text = ""
	for pickups_info_text in _pickups_info:
		text += pickups_info_text + "\n"


