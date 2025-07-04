extends Camera2D

const MAP_SIZE := Vector2(2225.0, 2225.0)
# SYSTEM_OFFSET is the observed error in the view when zoom is 1.0.
# For example, if view is shifted left by 576 and up by 325, error is (-576, -325).
# The correction applied will be -SYSTEM_OFFSET / current_zoom_scalar.
const SYSTEM_OFFSET := Vector2(576.0, 324.0) 
# .
# .
# Zoom parameters
var current_zoom_scalar := 1.0
var min_zoom_scalar := 0.1 # Calculated in _ready based on map and viewport
var max_zoom_scalar := 4.0  # Maximum zoom-in level (e.g., 4x)
const ZOOM_FACTOR_INCREMENT := 1.15 # How much each wheel step zooms

# Panning parameters
var is_panning := false
var is_tweening := false

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
	
	# Set initial camera position so its top-left view is at map origin (0,0)
	# This assumes global_position is the center of the camera's view.
	if current_zoom_scalar > 0.00001: # Ensure zoom is valid
		var initial_view_half_size_world = (viewport_size / current_zoom_scalar) / 2.0
		var true_initial_logical_center = initial_view_half_size_world
		var initial_correction_scaled = -SYSTEM_OFFSET / current_zoom_scalar if current_zoom_scalar != 0 else Vector2.ZERO
		self.global_position = true_initial_logical_center + initial_correction_scaled
	else:
		# Fallback if zoom is invalid, though it should be clamped correctly above.
		var true_initial_logical_center = MAP_SIZE / 2.0 
		# Assuming zoom is 1.0 for fallback correction, or handle appropriately
		var fallback_correction_scaled = -SYSTEM_OFFSET # Or -SYSTEM_OFFSET / 1.0
		self.global_position = true_initial_logical_center + fallback_correction_scaled

	# Ensure this camera is the active one
	make_current()
	# Call _process once to immediately apply clamping with initial values
	_process(0.0)


func _input(event: InputEvent) -> void:
	if is_tweening:
		return

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
					
					var old_correction_scaled = -SYSTEM_OFFSET / old_zoom_val if old_zoom_val != 0 else Vector2.ZERO
					var old_true_logical_center = self.global_position - old_correction_scaled
					
					current_zoom_scalar = new_clamped_zoom_scalar
					self.zoom = Vector2(current_zoom_scalar, current_zoom_scalar)
					
					# Adjust camera position to keep the point under the mouse stationary
					if old_zoom_val != 0 and current_zoom_scalar != 0: # Avoid division by zero
						var new_true_logical_center = world_mouse_pos + (old_true_logical_center - world_mouse_pos) * (old_zoom_val / current_zoom_scalar)
						var new_correction_scaled = -SYSTEM_OFFSET / current_zoom_scalar
						self.global_position = new_true_logical_center + new_correction_scaled
					else: # Should not happen if zoom is always positive
						var new_correction_scaled = -SYSTEM_OFFSET / current_zoom_scalar if current_zoom_scalar != 0 else Vector2.ZERO
						self.global_position = old_true_logical_center + new_correction_scaled # Fallback: re-apply correction with new zoom

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
	# if is_tweening:
	# 	return
	current_zoom_scalar = self.zoom.x
	self.global_position = _get_clamped_position_for_zoom(self.global_position, current_zoom_scalar)


func _set_tweening(value: bool) -> void:
	is_tweening = value
	# Also disable panning when a tween starts
	if value:
		is_panning = false

func _get_corrected_position(pos: Vector2, zm: float) -> Vector2:
	if zm <= 0.00001:
		return pos
	var correction_scaled = -SYSTEM_OFFSET / zm
	return pos - correction_scaled

func _get_uncorrected_position(corrected_pos: Vector2, zm: float) -> Vector2:
	if zm <= 0.00001:
		return corrected_pos
	var correction_scaled = -SYSTEM_OFFSET / zm
	return corrected_pos + correction_scaled

func _get_clamped_position_for_zoom(pos: Vector2, zm: float) -> Vector2:
	if zm <= 0.00001:
		return pos

	var viewport_size = get_viewport_rect().size
	var view_half_size_world = (viewport_size / zm) / 2.0

	var min_cam_pos_x = view_half_size_world.x
	var max_cam_pos_x = MAP_SIZE.x - view_half_size_world.x
	var min_cam_pos_y = view_half_size_world.y
	var max_cam_pos_y = MAP_SIZE.y - view_half_size_world.y

	var true_logical_center = _get_corrected_position(pos, zm)

	var clamped_true_logical_center = true_logical_center
	if min_cam_pos_x > max_cam_pos_x:
		clamped_true_logical_center.x = MAP_SIZE.x / 2.0
	else:
		clamped_true_logical_center.x = clamp(true_logical_center.x, min_cam_pos_x, max_cam_pos_x)

	if min_cam_pos_y > max_cam_pos_y:
		clamped_true_logical_center.y = MAP_SIZE.y / 2.0
	else:
		clamped_true_logical_center.y = clamp(true_logical_center.y, min_cam_pos_y, max_cam_pos_y)

	return _get_uncorrected_position(clamped_true_logical_center, zm)

func tween_to(target_position: Vector2, duration: float, target_zoom_level: float = -1.0):
	var final_zoom = current_zoom_scalar
	if target_zoom_level > 0:
		final_zoom = clamp(target_zoom_level, min_zoom_scalar, max_zoom_scalar)

	var clamped_target_position = _get_clamped_position_for_zoom(target_position, final_zoom)

	var tween = create_tween()
	# Make tweens parallel if we are changing zoom
	if target_zoom_level > 0:
		tween.set_parallel(true)

	tween.tween_property(self, "global_position", clamped_target_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if target_zoom_level > 0:
		var new_clamped_zoom = clamp(target_zoom_level, min_zoom_scalar, max_zoom_scalar)
		var target_zoom_vec = Vector2(new_clamped_zoom, new_clamped_zoom)
		tween.tween_property(self, "zoom", target_zoom_vec, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_set_tweening(true)
	tween.finished.connect(func():
		if target_zoom_level > 0:
			current_zoom_scalar = clamp(target_zoom_level, min_zoom_scalar, max_zoom_scalar)
		_set_tweening(false)
	)
	await tween.finished
