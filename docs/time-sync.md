# 時刻同期チェックについて

## 概要

`playbooks/check-time-sync.yml` は Raspberry Pi 5 の時刻同期状態をチェックします。

## チェック項目

### 1. chrony サービス状態

`systemd` モジュールで chrony サービスの状態を確認します。

- **判定**: `ActiveState == 'active'` で正常

### 2. NTP 同期状態

`timedatectl show --property=NTPSynchronized --value` で NTP 同期の有効/無効を確認します。

- **判定**: `yes` で正常

### 3. Stratum (ストラタム / 階層)

NTP サーバーの階層レベルを示す値です。数値が小さいほど正確な時刻源に近いことを意味します。

| Stratum | 意味 |
|---------|------|
| 0 | 原子時計、GPS など物理的な基準時計（直接接続不可） |
| 1 | Stratum 0 に直接接続されたサーバー（最も正確） |
| 2 | Stratum 1 から時刻を取得するサーバー |
| 3 | Stratum 2 から時刻を取得するサーバー |
| 4-15 | さらに下位の階層 |
| 16 | **未同期状態（エラー）** |

**判定基準**:
- Stratum < 16 で正常
- 一般的なサーバーは Stratum 2-4 が理想的

### 4. Leap status (うるう秒状態)

うるう秒の挿入/削除に関する状態を示します。

| Status | 意味 |
|--------|------|
| Normal | **通常状態**（うるう秒の予定なし） |
| Insert second | 次の月末にうるう秒が挿入される予定 |
| Delete second | 次の月末にうるう秒が削除される予定 |
| Not | 時刻未同期（`Not synchronised`。本チェックの表示上は `Not`） |

**判定基準**:
- `Normal` が正常状態

### 5. System time offset (システム時刻のオフセット)

NTP で取得した正確な時刻と、システムのローカル時刻のずれをミリ秒単位で示します。検証用に元の秒単位の値も併記されます。

**表示例**:
- `1.151 ms fast (0.001151329 seconds fast)` → システム時刻が 1.151 ミリ秒進んでいる
- `0.353 ms slow (0.000353217 seconds slow)` → システム時刻が 0.353 ミリ秒遅れている

**補足**:
- このずれは chrony が徐々に修正していきます
- 数ミリ秒程度なら正常範囲
- 数百ミリ秒以上ずれている場合は同期に問題がある可能性あり
- このチェックでは表示のみで、判定には使用していません

## 総合判定

以下の全ての条件を満たせば `OK ✓`、1つでも満たさなければ `NG ✗` と判定します。

1. chrony サービスが `active`
2. NTP 同期が `yes`
3. Stratum < 16
4. Leap status が `Normal`

## 実行方法

```bash
# 全ホストをチェック
make check-time-sync

# 特定のホストをチェック
ansible-playbook -l rpi5-00 playbooks/check-time-sync.yml
```

## トラブルシューティング

### Stratum が 16 になっている

- NTP サーバーへの接続に失敗している可能性
- ファイアウォールで UDP 123 がブロックされていないか確認
- `chronyc sources -v` で参照先の状態を確認

### NTP 同期が no

- chrony サービスが起動しているか確認: `systemctl status chrony`
- 時刻源が設定されているか確認: `/etc/chrony/chrony.conf`

### System offset が大きい（数百ミリ秒以上）

- 同期開始直後の可能性（徐々に修正される）
- ハードウェアクロックのドリフトが大きい可能性
- `chronyc makestep` で強制的に時刻を合わせることも可能（要注意）
