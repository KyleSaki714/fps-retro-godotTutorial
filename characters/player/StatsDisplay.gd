extends Label

var _ammo = 0
var _health = 0

func update_ammo(amnt):
	_ammo = amnt
	update_display()

func update_health(amnt):
	_health = amnt
	update_display()

func update_display():
	text = "Health: " + str(_health)
	var ammo_amnt = str(_ammo)
	if _ammo < 0:
		ammo_amnt = "inf"
	text += "\nAmmo: " + ammo_amnt
