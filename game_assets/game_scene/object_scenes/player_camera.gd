extends Camera2D

const MAP_SIZE := Vector2(2225.0, 2225.0)

# Zoom parameters
var current_zoom_scalar := 1.0
var min_zoom_scalar := 0.1 # Calculated in _ready based on map and viewport
var max_zoom_scalar := 4.0  # Maximum zoom-in level (e.g., 4x)
const ZOOM_FACTOR_INCREMENT := 1.15 # How much each wheel step zooms

# Panning parameters
var is_panning := false

func _ready() -> void:
	# Calculate min_zoom_scalar to ensure camera view doesn't exceed map size
	var viewport_size = get_viewport_rect().size
	if viewport_size.x > 0.0 and viewport_size.y > 0.0 and MAP_SIZE.x > 0.0 and MAP_SIZE.y > 0.0:
		min_zoom_scalar = max(viewport_size.x / MAP_SIZE.x, viewport_size.y / MAP_SIZE.y)
	else:
		# Fallback if sizes are invalid (should not happen in a running game)
		min_zoom_scalar = 0.1 

	# Initialize zoom, clamped to valid range
	current_zoom_scalar = clamp(1.0, min_zoom_scalar, max_zoom_scalar) # Start at 1.0x zoom if possible
	self.zoom = Vector2(current_zoom_scalar, current_zoom_scalar)
	
	# Optional: Center camera on the map initially
	self.global_position = MAP_SIZE / 2.0
	
	# Ensure this camera is the active one
	make_current()
	# Call _process once to immediately apply clamping with initial values
	_process(0.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# --- Zooming Logic ---
		if event.is_pressed():
			var target_zoom_scalar = current_zoom_scalar
			var perform_zoom = false
			
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom_scalar *= ZOOM_FACTOR_INCREMENT
				perform_zoom = true
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom_scalar /= ZOOM_FACTOR_INCREMENT
				perform_zoom = true
			
			if perform_zoom:
				var new_clamped_zoom_scalar = clamp(target_zoom_scalar, min_zoom_scalar, max_zoom_scalar)
				
				# Only apply zoom if it actually changes, to avoid unnecessary calculations
				if abs(new_clamped_zoom_scalar - current_zoom_scalar) > 0.0001:
					var old_zoom_val = current_zoom_scalar
					var world_mouse_pos = get_global_mouse_position() # Point to zoom towards
					
					current_zoom_scalar = new_clamped_zoom_scalar
					self.zoom = Vector2(current_zoom_scalar, current_zoom_scalar)
					
					# Adjust camera position to keep the point under the mouse stationary
					# Formula: NewCamPos = WorldMousePos + (OldCamPos - WorldMousePos) * (OldZoom / NewZoom)
					if old_zoom_val != 0 and current_zoom_scalar != 0: # Avoid division by zero
						self.global_position = world_mouse_pos + (self.global_position - world_mouse_pos) * (old_zoom_val / current_zoom_scalar)
					# Position clamping will be handled in _process

		# --- Panning Logic (Right Mouse Button) ---
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				is_panning = true
				# Optional: Change mouse cursor or capture mode here
				# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_panning = false
				# Optional: Restore mouse cursor or mode here
				# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	elif event is InputEventMouseMotion and is_panning:
		# Pan the camera based on mouse movement
		# event.relative is the mouse displacement in screen pixels since the last frame
		if current_zoom_scalar != 0: # Avoid division by zero
			# Move camera in opposite direction of mouse drag, scaled by zoom
			self.global_position -= event.relative / current_zoom_scalar
			# Position clamping will be handled in _process


func _process(_delta: float) -> void:
	# Clamp camera's global_position to stay within map boundaries
	var viewport_size = get_viewport_rect().size
	
	# Ensure current_zoom_scalar is valid before calculations
	if current_zoom_scalar <= 0.00001: # Effectively zero or negative
		return # Avoid division by zero or invalid calculations

	# Half of the camera's view size in world units
	var view_half_size_world = (viewport_size / current_zoom_scalar) / 2.0

	# Calculate allowed min/max camera center positions
	# Assumes map origin is (0,0) and extends to MAP_SIZE
	var min_cam_pos_x = view_half_size_world.x
	var max_cam_pos_x = MAP_SIZE.x - view_half_size_world.x
	var min_cam_pos_y = view_half_size_world.y
	var max_cam_pos_y = MAP_SIZE.y - view_half_size_world.y
	
	var new_clamped_pos = self.global_position

	# If view is wider than map (due to aspect ratio and zoom limits), center it on map's X
	if min_cam_pos_x > max_cam_pos_x:
		new_clamped_pos.x = MAP_SIZE.x / 2.0
	else:
		new_clamped_pos.x = clamp(self.global_position.x, min_cam_pos_x, max_cam_pos_x)

	# If view is taller than map, center it on map's Y
	if min_cam_pos_y > max_cam_pos_y:
		new_clamped_pos.y = MAP_SIZE.y / 2.0
	else:
		new_clamped_pos.y = clamp(self.global_position.y, min_cam_pos_y, max_cam_pos_y)
		
	self.global_position = new_clamped_pos
