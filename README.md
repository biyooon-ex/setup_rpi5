# Raspberry Pi 5 Ansible Setup

Raspberry Pi 5 (Ubuntu Server 24.04.4 LTS 64-bit) の初期セットアップを自動化する Ansible playbook です。

## 目的

このリポジトリは [Giocci Platform](https://github.com/biyooon-ex/giocci_platform) の性能計測を行う際に利用する Raspberry Pi 5 x 3 台のセットアップ自動化を目的としています。

※性能計測を行うためには giocci client 、giocci relay 、 giocci engine を動作させる実機が 3 台必要です。

## 前提条件

1. Raspberry Pi Imager で Ubuntu Server 24.04.4 LTS (64-bit) を SD に焼く
2. Imager の設定でユーザー作成と SSH 公開鍵登録を済ませている
3. 起動後、SSH 接続が可能な状態になっている
4. ホストマシンに Ansible がインストール済み

## Raspberry Pi の初期準備

Raspberry Pi Imager で以下を設定してから SD を作成します。

- ユーザー名/パスワード
- SSH を有効化し公開鍵を登録
- (必要なら) Wi-Fi 設定

Ubuntu 起動後は `sudo nmap -sn 192.168.0.0/24` などで IP を把握してください。

## Ansible の初期設定

### 1. インベントリファイル設定

`inventory.yml` の IP とユーザーを実機に合わせます。

```yaml
ansible_host: 192.168.0.3 # `sudo nmap -sn 192.168.0.0/24` などで把握した IP アドレス
ansible_user: ubuntu
```

### 2. SSH 鍵設定

`inventory.yml` の鍵パスを設定します。

```yaml
ansible_ssh_private_key_file: ~/.ssh/set_your_key
```

## セットアップ手順 (推奨順序)

### 1. SSH 接続確認

```bash
make ping
make ssh-check
```

### 2. 静的 IP 設定 (eth0)

各ターゲットごとに固定 IP を設定します。

#### rpi5-00

```bash
ansible-playbook -l rpi5-00 -e "static_ip=192.168.0.100 netmask=24 gateway=192.168.0.1 dns_servers=['8.8.8.8','8.8.4.4']" playbooks/setup-static-ip.yml
```

実行後は `inventory.yml` の `rpi5-00` の `ansible_host` を以下のように更新します。

```yaml
ansible_host: 192.168.0.100
```

#### rpi5-01

```bash
ansible-playbook -l rpi5-01 -e "static_ip=192.168.0.101 netmask=24 gateway=192.168.0.1 dns_servers=['8.8.8.8','8.8.4.4']" playbooks/setup-static-ip.yml
```

実行後は `inventory.yml` の `rpi5-01` の `ansible_host` を以下のように更新します。

```yaml
ansible_host: 192.168.0.101
```

#### rpi5-02

```bash
ansible-playbook -l rpi5-02 -e "static_ip=192.168.0.102 netmask=24 gateway=192.168.0.1 dns_servers=['8.8.8.8','8.8.4.4']" playbooks/setup-static-ip.yml
```

実行後は `inventory.yml` の `rpi5-02` の `ansible_host` を以下のように更新します。

```yaml
ansible_host: 192.168.0.102
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

eth0 が static IP のみになっていることを確認します。

```bash
make check-ip
```

### 8. 自動アップデートの無効化

```bash
make disable-auto-update
make reboot
```

### 9. apt upgrade

`make apt-upgrade` は `/etc/apt/sources.list.d/ubuntu.sources` の `Suites:` に `noble-updates` が無い場合だけ追記してからアップグレードを実行します。

```bash
make apt-upgrade
make reboot
```

### 10. 時刻同期 (chrony)

```bash
make install-chrony
make check-time-sync
```

### 11. Docker

```bash
make install-docker
```

### 12. zenoh

```bash
make install-zenoh
```

### 13. mise

```bash
make install-mise
```

### 14. dev-tools

```bash
make install-dev-tools
```

## 補足

- `make help` で利用可能なコマンド一覧を表示できます。
- inventory.yml の host 識別子を (ex. rpi5-00) 書き換える場合は、リポジトリ内の識別子を検索し置換するようにしてください。
