extends Control

## 低於這個比例的拖曳不移動角色。
const DEADZONE := 0.15
const _KNOB_RATIO := 0.38
const _MOUSE_POINTER := -2

var _player: CharacterBody2D
## -1 未按住，-2 滑鼠，0 以上是觸控 index。
var _pointer := -1
var _knob_offset := Vector2.ZERO


func _ready() -> void:
	if owner is CharacterBody2D:
		_player = owner
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	set_process_input(true)
	queue_redraw()


func _exit_tree() -> void:
	_release()


func _input(event: InputEvent) -> void:
	var handled := false
	if event is InputEventScreenTouch:
		handled = _on_screen_touch(event)
	elif event is InputEventScreenDrag:
		handled = _on_screen_drag(event)
	elif _pointer < 0 and event is InputEventMouseButton:
		handled = _on_mouse_button(event)
	elif event is InputEventMouseMotion:
		handled = _on_mouse_motion(event)
	if handled and is_inside_tree():
		get_viewport().set_input_as_handled()


func _draw() -> void:
	var center := _center()
	var radius := _radius()
	draw_circle(center, radius, Color(1, 1, 1, 0.24))
	draw_arc(center, radius, 0.0, TAU, 64, Color(1, 1, 1, 0.6), 3.0, true)
	draw_circle(center + _knob_offset, radius * _KNOB_RATIO, Color(0.97, 0.97, 0.97, 0.92))


## offset 是搖桿中心指向拖曳點的向量。回傳螢幕方向，長度 0～1。
func axes_from_offset(offset: Vector2, radius: float) -> Vector2:
	if radius <= 0.0:
		return Vector2.ZERO
	var raw := offset.limit_length(radius) / radius
	var magnitude := raw.length()
	if magnitude <= DEADZONE or is_zero_approx(magnitude):
		return Vector2.ZERO
	var scaled := minf((magnitude - DEADZONE) / (1.0 - DEADZONE), 1.0)
	return raw / magnitude * scaled


func _on_screen_touch(event: InputEventScreenTouch) -> bool:
	if event.pressed:
		if _pointer != -1:
			return false
		if not _try_grab(event.position):
			return false
		_pointer = event.index
		_drag_to(event.position)
		return true
	if event.index != _pointer:
		return false
	_release()
	return true


func _on_screen_drag(event: InputEventScreenDrag) -> bool:
	if event.index != _pointer:
		return false
	_drag_to(event.position)
	return true


func _on_mouse_button(event: InputEventMouseButton) -> bool:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return false
	if event.pressed:
		if _pointer != -1 or not _try_grab(event.position):
			return false
		_pointer = _MOUSE_POINTER
		_drag_to(event.position)
		return true
	if _pointer != _MOUSE_POINTER:
		return false
	_release()
	return true


func _on_mouse_motion(event: InputEventMouseMotion) -> bool:
	if _pointer != _MOUSE_POINTER:
		return false
	_drag_to(event.position)
	return true


func _try_grab(screen_pos: Vector2) -> bool:
	return _to_local(screen_pos).distance_to(_center()) <= _radius()


func _drag_to(screen_pos: Vector2) -> void:
	var offset := _to_local(screen_pos) - _center()
	var radius := _radius()
	_knob_offset = offset.limit_length(radius)
	if _player != null:
		_player.screen_move_axes = axes_from_offset(_knob_offset, radius)
	queue_redraw()


func _release() -> void:
	_pointer = -1
	_knob_offset = Vector2.ZERO
	if _player != null:
		_player.screen_move_axes = Vector2.ZERO
	if is_inside_tree():
		queue_redraw()


func _center() -> Vector2:
	return size * 0.5


func _radius() -> float:
	return maxf(minf(size.x, size.y) * 0.5 - 2.0, 1.0)


func _to_local(screen_pos: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_pos
