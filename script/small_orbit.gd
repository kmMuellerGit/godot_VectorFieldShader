@tool
extends Node3D

@export var orbit_speed : float = 1.0
@export var orbit_distance : float = 5.0
@export var orbit_center : Vector3 = Vector3(0,0,0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orbit_center = self.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position = orbit_center + Vector3(
		orbit_distance * cos(orbit_speed * Time.get_ticks_msec()/1000.0),
		0,
		orbit_distance * sin(orbit_speed * Time.get_ticks_msec()/1000.0)
	)
