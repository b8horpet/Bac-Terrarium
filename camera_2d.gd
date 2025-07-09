extends Camera2D

const ZOOM_FACTOR := 1.1
@onready var target_zoom := zoom.x
@onready var target_pos := self.position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mbi := (event as InputEventMouseButton).button_index
		if mbi == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			target_zoom *= ZOOM_FACTOR
		elif mbi == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom /= ZOOM_FACTOR
	elif event is InputEventKey:
		var ke := event as InputEventKey
		if ke.keycode == Key.KEY_Q and ke.pressed:
			target_zoom *= ZOOM_FACTOR
		elif ke.keycode == Key.KEY_E and ke.pressed:
			target_zoom /= ZOOM_FACTOR
	target_zoom = clampf(target_zoom, 0.2, 5.0)
	var margin := lerpf(0.1,0.8,clampf(1/target_zoom,0.2,1.0))
	drag_left_margin=margin
	drag_right_margin=margin
	drag_top_margin=margin
	drag_bottom_margin=margin

func _physics_process(delta: float) -> void:
	zoom = lerp(zoom,Vector2.ONE*target_zoom,1-pow(2.0,-20*delta))
