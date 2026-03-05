# Raspberry Pi 5 Ansible管理用Makefile

.DEFAULT_GOAL := help

.PHONY: \
	ping \
	ssh-check info syntax-check \
	disable-auto-update disable-auto-update-dry \
	install-docker install-docker-dry \
	install-zenoh install-zenoh-dry \
	install-chrony reboot check-time-sync \
	check-ip disable-dhcp-eth0 disable-dhcp-wlan0 \
	apt-upgrade dry-run verbose inventory help

# SSH接続確認
ping:
	ansible rpi5 -m ping

# 詳細なSSH接続確認
ssh-check:
	ansible-playbook playbooks/ssh-check.yml

# システム情報取得
info:
	ansible rpi5 -m setup

# 構文チェック
syntax-check:
	@if [ -n "$(PLAYBOOK)" ]; then \
		ansible-playbook --syntax-check playbooks/$(PLAYBOOK); \
	else \
		for f in playbooks/*.yml; do \
			echo "Checking $$f..."; \
			ansible-playbook --syntax-check $$f || exit 1; \
		done; \
	fi

# 自動アップデート無効化
disable-auto-update:
	ansible-playbook playbooks/disable-auto-update.yml

# 自動アップデート無効化（ドライラン）
disable-auto-update-dry:
	ansible-playbook --check playbooks/disable-auto-update.yml

# Docker インストール
install-docker:
	ansible-playbook playbooks/install-docker.yml

# Docker インストール（ドライラン）
install-docker-dry:
	ansible-playbook --check playbooks/install-docker.yml

# zenoh バイナリインストール
install-zenoh:
	ansible-playbook playbooks/install-zenoh.yml

# zenoh バイナリインストール（ドライラン）
install-zenoh-dry:
	ansible-playbook --check playbooks/install-zenoh.yml

# chrony インストール
install-chrony:
	ansible-playbook playbooks/install-chrony.yml

# システム再起動
reboot:
	ansible-playbook playbooks/reboot.yml

# 時刻同期状態チェック
check-time-sync:
	ansible-playbook playbooks/check-time-sync.yml

# IP アドレス確認
check-ip:
	ansible-playbook playbooks/check-ip.yml

# apt upgrade
apt-upgrade:
	ansible-playbook playbooks/apt-upgrade.yml

# eth0 DHCP 無効化
disable-dhcp-eth0:
	ansible-playbook playbooks/disable-dhcp-eth0.yml

# wlan0 DHCP 無効化
disable-dhcp-wlan0:
	ansible-playbook playbooks/disable-dhcp-wlan0.yml

# ドライラン
dry-run:
	ansible-playbook --check playbooks/ssh-check.yml

# 詳細出力で実行
verbose:
	ansible-playbook -vvv playbooks/ssh-check.yml

# インベントリ確認
inventory:
	ansible-inventory --list

# ヘルプ
help:
	@echo "利用可能なコマンド:"
	@echo "  make ping        - 基本的なSSH接続確認（全台）"
	@echo "  make ssh-check   - 詳細なSSH接続確認とシステム情報取得"
	@echo "  make info        - システム情報のみ取得"
	@echo "  make syntax-check - playbook構文チェック"
	@echo "  make dry-run     - ドライラン実行"
	@echo "  make verbose     - 詳細出力で実行"
	@echo "  make disable-auto-update     - 自動アップデート無効化"
	@echo "  make disable-auto-update-dry - 自動アップデート無効化（ドライラン）"
	@echo "  make install-docker          - Docker インストール"
	@echo "  make install-docker-dry      - Docker インストール（ドライラン）"
	@echo "  make install-zenoh           - zenoh バイナリインストール"
	@echo "  make install-zenoh-dry       - zenoh バイナリインストール（ドライラン）"
	@echo "  make install-chrony          - chrony インストール"
	@echo "  make reboot                  - システム再起動"
	@echo "  make check-time-sync         - 時刻同期状態チェック"
	@echo "  make check-ip                - IP アドレス確認"
	@echo "  make disable-dhcp-eth0       - eth0 DHCP 無効化"
	@echo "  make disable-dhcp-wlan0      - wlan0 DHCP 無効化"
	@echo "  make apt-upgrade             - apt upgrade"
