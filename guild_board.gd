extends Node2D

const GUILD_NAME := "西方森林村莊工會"
const CONTRACT_NAME := "木匠的木材採購"
const WOOD_NEED := 2
const REWARD := 30

## 委託執行階段狀態。關閉介面不會清掉。
var status := ""
var escrow_gold := 0

var _player: CharacterBody2D
var _player_near := false
var _guild_open := false
var _carpenter: Node

@onready var _interaction: Area2D = $Interaction
@onready var _guild_button: Button = $GuildUI/GuildButton
@onready var _panel: Panel = $GuildUI/Panel
@onready var _details: Label = $GuildUI/Panel/Details
@onready var _message: Label = $GuildUI/Panel/Message


func _ready() -> void:
	_carpenter = get_parent().get_node("Carpenter")
	_interaction.body_entered.connect(_on_body_entered)
	_interaction.body_exited.connect(_on_body_exited)
	_guild_button.pressed.connect(_on_guild_pressed)
	_panel.get_node("AcceptButton").pressed.connect(_on_accept_pressed)
	_panel.get_node("DeliverButton").pressed.connect(_on_deliver_pressed)
	_panel.get_node("CloseButton").pressed.connect(_on_close_pressed)
	_guild_button.visible = false
	_panel.visible = false
	if status == "":
		try_open_contract(_carpenter)
	_carpenter.production_changed.connect(_on_production_changed)
	set_process(false)
	call_deferred("_sync_overlapping")


func _exit_tree() -> void:
	_set_movement_locked(false)


func _process(_delta: float) -> void:
	if not _guild_open or _carpenter == null:
		return
	_refresh()


## 發布前先確認木匠付得起全額。不夠就不建立委託，也不動資產。
func try_open_contract(payer: Node) -> bool:
	if status != "":
		return false
	if payer.gold < REWARD:
		return false
	payer.gold -= REWARD
	escrow_gold = REWARD
	status = "OPEN"
	return true


func _sync_overlapping() -> void:
	for body in _interaction.get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _player_near:
		return
	_player = body as CharacterBody2D
	_player_near = true
	if not _guild_open:
		_guild_button.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != _player:
		return
	_player_near = false
	_guild_button.visible = false
	if _guild_open:
		_close_guild()


func _on_guild_pressed() -> void:
	if not _player_near or _player == null:
		return
	_guild_open = true
	_guild_button.visible = false
	_panel.visible = true
	_message.text = ""
	_set_movement_locked(true)
	set_process(true)
	_refresh()


func _on_accept_pressed() -> void:
	if not _guild_open or not _player_near or _player == null:
		_message.text = "距離太遠"
		_close_guild()
		return
	_message.text = accept_contract()
	_refresh()


func _on_deliver_pressed() -> void:
	if not _guild_open or not _player_near or _player == null:
		_message.text = "距離太遠"
		_close_guild()
		return
	_message.text = deliver_contract(_player)
	_refresh()


func _on_close_pressed() -> void:
	_close_guild()


func _close_guild() -> void:
	var was_open := _guild_open
	_guild_open = false
	_panel.visible = false
	if was_open:
		_set_movement_locked(false)
	set_process(false)
	_guild_button.visible = _player_near


func accept_contract() -> String:
	if status != "OPEN":
		return "目前不能接受"
	status = "ACCEPTED"
	return "已接受委託"


## 檢查全部通過後，才一次轉移木材與報酬。
func deliver_contract(player: Node) -> String:
	if status != "ACCEPTED":
		return "目前不能交付"
	if player.wood < WOOD_NEED:
		return "木材不足"
	if escrow_gold < REWARD:
		return "履約資金不足"
	player.wood -= WOOD_NEED
	_carpenter.wood += WOOD_NEED
	player.gold += REWARD
	escrow_gold -= REWARD
	status = "COMPLETED"
	_carpenter.try_start_production()
	return "委託完成，已支付 %d G" % REWARD


func _refresh() -> void:
	if _player == null or _carpenter == null:
		return
	var state_text := "目前沒有委託"
	if status != "":
		state_text = status
	var recent := "尚無"
	if _carpenter.last_result != "":
		recent = _carpenter.last_result
	_details.text = (
		"委託：%s\n"
		+ "委託人：%s\n"
		+ "需求：木材 × %d\n"
		+ "報酬：%d G\n"
		+ "狀態：%s\n"
		+ "玩家木材：%d\n"
		+ "木匠金錢：%d G\n"
		+ "履約資金：%d G\n"
		+ "木匠木材：%d    家具：%d\n"
		+ "生產：%s\n"
		+ "最近：%s"
	) % [
		CONTRACT_NAME,
		_carpenter.MERCHANT_NAME,
		WOOD_NEED,
		REWARD,
		state_text,
		_player.wood,
		_carpenter.gold,
		escrow_gold,
		_carpenter.wood,
		_carpenter.furniture,
		_production_text(),
		recent,
	]


func _production_text() -> String:
	if _carpenter.work_state == "WORKING":
		return "製作中（剩餘 %d 秒）" % int(ceil(_carpenter.craft_seconds_left()))
	return "閒置"


func _on_production_changed() -> void:
	if _guild_open:
		_refresh()


func _set_movement_locked(locked: bool) -> void:
	if _player == null:
		return
	_player.movement_locked = locked
	if locked:
		_player.velocity = Vector2.ZERO
