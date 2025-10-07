extends HSlider

@export var bus: StringName = "Master"

@export var bus_index := AudioServer.get_bus_index(bus)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = SoundManager.get_volume(bus_index)
	
	value_changed.connect(func (v: float):
		SoundManager.set_volume(bus_index, v)
		)
	
	
