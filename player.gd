extends CharacterBody2D

## 像素／秒。正規化後，各方向（含斜向）速度相同。
const SPEED := 120.0

# 64×32 菱形格的右上、右下軸，兩軸等長。左上、左下是反方向。
const _NORTHEAST := Vector2(2, -1)
const _SOUTHEAST := Vector2(2, 1)

## 虛擬搖桿的螢幕方向，長度 0～1。
## x：-1 左 ～ +1 右
## y：-1 上 ～ +1 下，與 Godot 畫面座標相同
var screen_move_axes := Vector2.ZERO

## 菱形軸向，保留給原本的 touch_axes 介面。
## x：-1 西南（左下，A）～ +1 東北（右上，D）
## y：-1 西北（左上，W）～ +1 東南（右下，S）
var touch_axes := Vector2.ZERO

## 玩家資產。只有交易檢查通過後才會改這兩個數。
var gold := 100
var wood := 0
## 市場介面開啟時暫停移動。
var movement_locked := false


func _physics_process(_delta: float) -> void:
	velocity = _desired_direction() * SPEED
	move_and_slide()


## 鍵盤優先，其次是螢幕搖桿，最後才是菱形 touch_axes。
func _desired_direction() -> Vector2:
	if movement_locked:
		return Vector2.ZERO
	var keyboard := Vector2(
		Input.get_axis("move_southwest", "move_northeast"),
		Input.get_axis("move_northwest", "move_southeast")
	)
	if not keyboard.is_zero_approx():
		return direction_from_axes(keyboard)
	if not screen_move_axes.is_zero_approx():
		return screen_move_axes.limit_length(1.0)
	return direction_from_axes(touch_axes)


## 把菱形軸向轉成螢幕上的移動方向。
## 回傳長度等於輸入強度（最大 1）；方向不同時速度仍一致。
func direction_from_axes(axes: Vector2) -> Vector2:
	var strength := axes.length()
	if is_zero_approx(strength):
		return Vector2.ZERO
	var unit := axes / strength
	var screen := (_NORTHEAST * unit.x + _SOUTHEAST * unit.y).normalized()
	return screen * minf(strength, 1.0)
