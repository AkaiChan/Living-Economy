extends Node

const MERCHANT_NAME := "森林村莊行商"
const WOOD_TARGET := 1
const TICK_SECONDS := 5.0

## 行商自己的資產（執行階段狀態，非 UI 專用）。
var gold := 30
var wood := 0

var _stall: Node2D

@onready var _timer: Timer = $DecisionTimer


func _ready() -> void:
	_stall = get_parent().get_node("Stall") as Node2D
	_timer.wait_time = TICK_SECONDS
	_timer.timeout.connect(_on_decision_tick)
	_timer.start()


func _on_decision_tick() -> void:
	if wood >= WOOD_TARGET:
		return
	if _stall == null:
		return
	_stall.buy_one_from_stall(self)
