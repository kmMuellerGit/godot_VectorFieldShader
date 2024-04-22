@tool
extends MeshInstance3D

@export var lookTarget : Node3D

@export var size : int = 10:
	get(): return size
	set(value): size=max(value,1)
	
@export var updateRate : float = 0.1
var lastUpdate : float = 0.0

# Easy access for user
@export var tex : Image = null

func query_vector(p : Vector3) -> Vector2 :
	var v =  lookTarget.global_transform.origin - p
	return Vector2(v.x,v.z)
	
func get_mat() -> ShaderMaterial:
	return self.get_surface_override_material(0)

func get_image_size()-> int:
	return self.size*2 + 1
	
func get_image(image_size : int)-> Image:
	return Image.create(image_size, image_size, false, Image.FORMAT_RGBAF)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !get_mat(): 
		printerr(self.name, " requires a surface override material.")
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# bad timer
	lastUpdate += delta
	if lastUpdate < updateRate: return
	lastUpdate = 0
	
	if !get_mat(): 
		printerr(self.name, " requires a surface override material.")
		return
		
	# Update render texture as needed.
	if !tex || tex.get_size()[0] != get_image_size():
		tex = get_image(get_image_size())
	
	# Query our made up system with real world coordinates.
	var unitSize : float = (self.scale.x * self.get_aabb().size.x) / ( get_image_size() )
	for x in range(-size, size+1):
		for z in range(-size, size+1):
			var offset = Vector3(x , 0, z) * unitSize
			# Query our vector field, which returns A-B direction without normalization.
			var v = query_vector(self.global_transform.origin + offset)
			# Normalize it to length of 1.0 and half it.  It is centered at 0,0 
			# Offset it to new center at 0.5,0.5 
			var nv = (v.normalized())*0.5 + Vector2(0.5,0.5)
			
			var color = Color(nv.x, nv.y,clamp(1.0 - v.length()/5, 0.5, 1.0), 1)
			tex.set_pixel(x + size,z + size,color)

	get_mat().set_shader_parameter("albedo_texture",ImageTexture.create_from_image(tex) )
