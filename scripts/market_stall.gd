extends Node2D

const MERCHANT_NAME := "森林村莊木材商"
const AI_MERCHANT_NAME := "森林村莊行商"
const BUY_PRICE := 10
const SELL_PRICE := 7
const GOOD_NAME := "木材"

## 這位攤販自己的資產。市場介面只讀這些數字。
var gold := 0
var wood := 5

## 最近一次 AI 向攤販購買的結果（供市場 UI 顯示）。
var ai_last_trade_line := "（尚無 AI 交易）"

var _player: CharacterBody2D
var _player_near := false
var _market_open := false
var _ai_merchant: Node

@onready var _interaction: Area2D = $Interaction
@onready var _trade_button: Button = $MarketUI/TradeButton
@onready var _panel: Panel = $MarketUI/Panel
@onready var _details: Label = $MarketUI/Panel/Details
@onready var _message: Label = $MarketUI/Panel/Message


func _ready() -> void:
	_ai_merchant = get_parent().get_node_or_null("AIMerchant")
	_interaction.body_entered.connect(_on_body_entered)
	_interaction.body_exited.connect(_on_body_exited)
	_trade_button.pressed.connect(_on_trade_pressed)
	_panel.get_node("BuyButton").pressed.connect(_on_buy_pressed)
	_panel.get_node("SellButton").pressed.connect(_on_sell_pressed)
	_panel.get_node("CloseButton").pressed.connect(_on_close_pressed)
	_trade_button.visible = false
	_panel.visible = false
	call_deferred("_sync_overlapping")


func _exit_tree() -> void:
	_set_movement_locked(false)


func _sync_overlapping() -> void:
	for body in _interaction.get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _player_near:
		return
	_player = body as CharacterBody2D
	_player_near = true
	if not _market_open:
		_trade_button.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != _player:
		return
	_player_near = false
	_trade_button.visible = false
	if _market_open:
		_close_market()


func _on_trade_pressed() -> void:
	if not _player_near or _player == null:
		return
	_market_open = true
	_trade_button.visible = false
	_panel.visible = true
	_message.text = ""
	_set_movement_locked(true)
	_refresh()


func _on_buy_pressed() -> void:
	if not _market_open or not _player_near or _player == null:
		_message.text = "距離太遠"
		_close_market()
		return
	_message.text = buy_one_from_stall(_player)
	_refresh()


func _on_sell_pressed() -> void:
	if not _market_open or not _player_near or _player == null:
		_message.text = "距離太遠"
		_close_market()
		return
	_message.text = _try_sell_one()
	_refresh()


func _on_close_pressed() -> void:
	_close_market()


func _close_market() -> void:
	var was_open := _market_open
	_market_open = false
	_panel.visible = false
	if was_open:
		_set_movement_locked(false)
	_trade_button.visible = _player_near


## 向攤販購買 1 木材。買方須有 gold、wood 欄位。不依賴市場 UI。
func buy_one_from_stall(buyer: Node) -> String:
	var result := _execute_buy_one(buyer)
	if buyer == _ai_merchant:
		_record_ai_trade_result(result)
	_refresh_if_market_open()
	return result


func _execute_buy_one(buyer: Node) -> String:
	if wood < 1:
		return "攤販缺貨"
	if buyer.gold < BUY_PRICE:
		return "金錢不足"
	buyer.gold -= BUY_PRICE
	buyer.wood += 1
	gold += BUY_PRICE
	wood -= 1
	return "已購買 1 木材"


func _record_ai_trade_result(result: String) -> void:
	if result == "已購買 1 木材":
		ai_last_trade_line = "%s購買了 1 木材，支付 %d G" % [AI_MERCHANT_NAME, BUY_PRICE]
	else:
		ai_last_trade_line = "%s：%s" % [AI_MERCHANT_NAME, result]


func _refresh_if_market_open() -> void:
	if _market_open:
		_refresh()


## 出售：玩家木材 >= 1 且攤販金錢 >= 7 才成交。
func _try_sell_one() -> String:
	if _player == null:
		return "距離太遠"
	if _player.wood < 1:
		return "沒有木材可出售"
	if gold < SELL_PRICE:
		return "攤販金錢不足"
	_player.wood -= 1
	_player.gold += SELL_PRICE
	wood += 1
	gold -= SELL_PRICE
	return "已出售 1 木材"


func _refresh() -> void:
	var ai_gold := 0
	var ai_wood := 0
	if _ai_merchant != null:
		ai_gold = _ai_merchant.gold
		ai_wood = _ai_merchant.wood
	var player_gold := 0
	var player_wood := 0
	if _player != null:
		player_gold = _player.gold
		player_wood = _player.wood
	_details.text = (
		"攤販：%s\n"
		+ "商品：%s\n"
		+ "木材售價：%d G\n"
		+ "木材收購價：%d G\n"
		+ "攤販木材：%d\n"
		+ "攤販金錢：%d G\n"
		+ "玩家金錢：%d G\n"
		+ "玩家木材：%d\n"
		+ "---\n"
		+ "AI：%s\n"
		+ "AI 金錢：%d G\n"
		+ "AI 木材：%d\n"
		+ "最近 AI：%s"
	) % [
		MERCHANT_NAME,
		GOOD_NAME,
		BUY_PRICE,
		SELL_PRICE,
		wood,
		gold,
		player_gold,
		player_wood,
		AI_MERCHANT_NAME,
		ai_gold,
		ai_wood,
		ai_last_trade_line,
	]


func _set_movement_locked(locked: bool) -> void:
	if _player == null:
		return
	_player.movement_locked = locked
	if locked:
		_player.velocity = Vector2.ZERO
