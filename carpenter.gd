extends Node

const MERCHANT_NAME := "森林村莊木匠"
const WOOD_PER_FURNITURE := 2
const CRAFT_SECONDS := 10.0

## 木匠自己的可用資產。履約資金不在這裡。加工中的木材另計。
var gold := 50
var wood := 0
var furniture := 0

## IDLE：閒置。WORKING：正在把已投入的木材做成家具。
var work_state := "IDLE"
var wood_in_process := 0
var last_result := ""

signal production_changed

var _timer: Timer


func _ready() -> void:
	_ensure_timer()


func craft_seconds_left() -> float:
	if work_state != "WORKING" or _timer == null:
		return 0.0
	return _timer.time_left


## 原料夠、而且目前沒有進行中的工作，才扣木材並開始計時。
func try_start_production() -> bool:
	if work_state == "WORKING":
		return false
	if wood < WOOD_PER_FURNITURE:
		return false
	_ensure_timer()
	wood -= WOOD_PER_FURNITURE
	wood_in_process = WOOD_PER_FURNITURE
	work_state = "WORKING"
	last_result = "木匠正在製作家具"
	_timer.start(CRAFT_SECONDS)
	production_changed.emit()
	return true


func _on_craft_finished() -> void:
	if work_state != "WORKING":
		return
	wood_in_process = 0
	furniture += 1
	work_state = "IDLE"
	last_result = "木匠完成 1 單位家具"
	production_changed.emit()
	try_start_production()


func _ensure_timer() -> void:
	if _timer != null:
		return
	_timer = Timer.new()
	_timer.name = "CraftTimer"
	_timer.one_shot = true
	_timer.wait_time = CRAFT_SECONDS
	_timer.timeout.connect(_on_craft_finished)
	add_child(_timer)
