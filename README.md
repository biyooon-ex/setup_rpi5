# Raspberry Pi 5 Ansible Setup

Raspberry Pi 5 (Ubuntu Server 24.04.3 LTS 64-bit) の初期セットアップを自動化する Ansible playbook です。

## 前提条件

1. Raspberry Pi Imager で Ubuntu Server 24.04.3 LTS (64-bit) を SD に焼く
2. Imager の設定でユーザー作成と SSH 公開鍵登録を済ませている
3. 起動後、SSH 接続が可能な状態になっている
4. コントロールマシンに Ansible がインストール済み

## 初期準備 (Imager 側の設定)

Raspberry Pi Imager で以下を設定してから SD を作成します。

- ユーザー名/パスワード
- SSH を有効化し公開鍵を登録
- (必要なら) Wi-Fi 設定

起動後はルータの管理画面や `arp -a` などで IP を把握してください。

## 初期設定 (Ansible 側)

### 1. インベントリファイル設定

`inventory.yml` の IP とユーザーを実機に合わせます。

```yaml
ansible_host: 192.168.0.100  # 実際のIPアドレスに変更
ansible_user: ubuntu
```

### 2. SSH 鍵設定

SSH 鍵認証を使う場合は `inventory.yml` に鍵パスを設定済みなら不要です。
パスワード認証を使う場合は以下を追加してください。

```yaml
ansible_ssh_pass: your_password
```

## セットアップ手順 (推奨順序)

### 1. SSH 接続確認

```bash
make ping
make ssh-check
```

### 2. 静的 IP 設定 (eth0)

各ホストごとに固定 IP を設定します。

```bash
# rpi5-00
ansible-playbook -l rpi5-00 -e "static_ip=192.168.0.100 netmask=24 gateway=192.168.0.1 dns_servers=['8.8.8.8','8.8.4.4']" playbooks/setup-static-ip.yml

# rpi5-01
ansible-playbook -l rpi5-01 -e "static_ip=192.168.0.101 netmask=24 gateway=192.168.0.1 dns_servers=['8.8.8.8','8.8.4.4']" playbooks/setup-static-ip.yml

# rpi5-02
ansible-playbook -l rpi5-02 -e "static_ip=192.168.0.102 netmask=24 gateway=192.168.0.1 dns_servers=['8.8.8.8','8.8.4.4']" playbooks/setup-static-ip.yml
```

### 3. IP 確認

```bash
make check-ip
```

### 4. wlan0 DHCP 無効化

Wi-Fi を使わない場合は DHCP を無効化します。無効化後、`wlan0` は IP を持たなくなります。
eth0 に static IP が設定されていない場合は失敗するようにしています。

```bash
make disable-dhcp-wlan0
```

### 5. eth0 DHCP 無効化

eth0 に static IP が設定されていない場合は失敗するようにしています。

```bash
make disable-dhcp-eth0
```

### 6. 再起動

```bash
make reboot
```

### 7. IP 確認 (再起動後)

```bash
make check-ip
```

### 8. 時刻同期 (chrony)

```bash
make install-chrony
make check-time-sync
```

### 9. Docker

```bash
make install-docker
```

### 10. zenoh

```bash
make install-zenoh
```

### 11. mise

```bash
make install-mise
```

### 12. apt upgrade

```bash
make apt-upgrade
make reboot
```

## 補足

- `make help` で利用可能なコマンド一覧を表示できます。
- `disable-dhcp-wlan0` 実行後は Wi-Fi 接続が切れるため、必ず eth0 で到達できる状態で実行してください。

## トラブルシューティング

- SSH 接続エラー: IP アドレス、ユーザー名、SSH 鍵を確認
- 権限エラー: sudo パスワードが必要な場合は `--ask-become-pass` を使用
- Python 未インストール: `ansible_python_interpreter` のパスを確認
