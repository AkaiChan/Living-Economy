# Living Economy 專案狀態

Godot 4.7.2。直式 540×960。主場景 `scenes/world.tscn`（`uid://ctqcpx71tlqsv`）。

Build #11 尚未開始。

## 已完成

- Build #1：等距草地 TileMap（64×32）。
- Build #2：玩家 `CharacterBody2D`，WASD／方向鍵沿菱形軸移動，速度 120，鏡頭跟隨。
- Build #3：左下虛擬搖桿。螢幕軸向，鍵盤優先於搖桿。
- Build #4：西方森林村莊。`Area2D` 進出改地名，不阻擋移動。
- Build #5：村莊木材攤。靠近出現「交易」，買 1 木材 10 G。介面開啟時停止移動。
- Build #6：攤販節點持有金錢與木材。購買是雙方資產轉移。
- Build #7：玩家可把木材賣回攤販，收購價 7 G。攤販金錢不足則不成交。
- Build #8：AI 行商每 5 秒檢查。木材少於 1 時，呼叫攤販的購買函式買 1 單位。
- Build #9：木匠用自己的 30 G 預留履約資金，發布「木材 × 2、報酬 30 G」委託。玩家接單後到市場買木材，再回工會交付。
- Build #10：交付後木匠若有 2 木材且閒置，自動加工 10 秒，得到 1 家具。桌面驗收已通過。

## 檔案責任

| 檔案 | 責任 |
|---|---|
| `scenes/world.tscn` | 草地、村莊實例、玩家實例、地名 UI |
| `scenes/player.tscn` | 玩家碰撞、外觀、鏡頭、搖桿 |
| `scenes/forest_village.tscn` | 村莊外觀、攤販、行商、木匠、工會公告欄與介面 |
| `scripts/player.gd` | 移動與玩家的金錢、木材。`movement_locked` 時速度為 0 |
| `scripts/joystick.gd` | 把指標寫入 `player.screen_move_axes` |
| `scripts/forest_village.gd` | 只更新地名，不碰經濟 |
| `scripts/market_stall.gd` | 攤販資產與買賣。`buy_one_from_stall` 供玩家與 AI 共用 |
| `scripts/ai_merchant.gd` | 行商資產與 5 秒決策，只向攤販購買 |
| `scripts/guild_board.gd` | 單一委託、履約資金、工會介面 |
| `scripts/carpenter.gd` | 木匠資產與生產。工會只在交付成功後呼叫 `try_start_production()` |
| `assets/grass.png` | 草地貼圖 |
| `assets/icon.svg` | 專案圖示 |

沒有 Autoload，也沒有 GuildManager、Inventory 或 ProductionManager。

## 呼叫關係

```
搖桿 → 玩家.screen_move_axes
玩家輸入 → 玩家移動

村莊區域 → 地名標籤

玩家「購買」→ 攤販.buy_one_from_stall(玩家)
行商計時器 → 攤販.buy_one_from_stall(行商)
玩家「出售」→ 攤販._try_sell_one()

工會啟動 → 木匠金錢轉入委託履約資金
玩家「交付」→ 工會轉移木材與報酬 → 木匠.try_start_production()
木匠計時結束 → 木匠.furniture += 1
木匠.production_changed → 工會介面若開著就刷新
```

節點都在 `ForestVillage` 底下找兄弟節點：行商找 `Stall`，工會找 `Carpenter`。

## 資產與生產規則

初始執行階段數值（委託發布前）：

| 個體 | 金錢 | 木材 | 其他 |
|---|---:|---:|---|
| 玩家 | 100 | 0 | |
| 攤販 | 0 | 5 | 售價 10，收購價 7 |
| AI 行商 | 30 | 0 | 目標木材 1，每 5 秒 |
| 木匠 | 50 | 0 | 家具 0 |
| 委託履約資金 | 0 | | |

木匠付得起 30 G 才發布委託：可用金錢 50→20，履約資金 0→30，狀態 `OPEN`。付不起則不發布、不動資產。

接單只把狀態改成 `ACCEPTED`，不轉移資產。交付前必須是 `ACCEPTED`、玩家木材 ≥ 2、履約資金 ≥ 30。通過後同一函式內：玩家木材 −2、木匠木材 +2、玩家金錢 +30、履約資金 −30、狀態 `COMPLETED`。完成後不能再領。

生產不在工會裡判斷。`try_start_production()` 要求閒置且木材 ≥ 2，才把 2 木材移入 `wood_in_process` 並啟動一次性 10 秒 `CraftTimer`。時間到且仍是 `WORKING` 才把加工中木材清掉、家具 +1、回到 `IDLE`。已在製作時再次呼叫不會重開計時器。生產不改任何人的金錢。

交易守恆看金錢總和，以及含加工中木材的木材總和。生產完成會把 2 木材變成 1 家具，之後木材總量減少 2。

## 已知限制

- 只有西方森林村莊，沒有第二座城市。
- 市場只有木材。家具沒有買家，也不會自動販售。
- 價格是常數，不是動態定價。
- 只有一張工會委託。沒有取消、逾期、競標，AI 不接委託。
- 10 秒是原型加工時間，不是世界工作日。
- 沒有存檔。
- 中文靠系統字型後備，專案裡沒有嵌入字型。
- 手機實機觸控（搖桿、交易、工會按鈕）尚未在裝置上驗過。桌面滑鼠走同一組按鈕。
