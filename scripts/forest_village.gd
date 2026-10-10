extends Area2D

@export var location_label: Label
@export var place_name := "西方森林村莊"
@export var outside_name := "野外"

var _player_inside := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# 地名標籤是較晚加入的畫面 UI，等整棵場景進樹後再綁定。
	call_deferred("_bind_label")


func _bind_label() -> void:
	_resolve_label()
	_set_label(outside_name)
	_sync_overlapping()


func _sync_overlapping() -> void:
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _player_inside:
		return
	_player_inside = true
	_set_label(place_name)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = false
	_set_label(outside_name)


func _resolve_label() -> void:
	if location_label != null:
		return
	location_label = get_node_or_null("../LocationUI/LocationLabel") as Label


func _set_label(value: String) -> void:
	_resolve_label()
	if location_label == null:
		push_error("森林村莊找不到地名標籤。")
		return
	location_label.text = value
