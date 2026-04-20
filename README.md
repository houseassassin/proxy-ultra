# ProxyUltra 🚀

> **Enterprise-grade VPN & Reverse Proxy Automation Framework**  
> *Architected and Developed by **Houseassassin***

<div align="center">
  <img src="https://img.shields.io/badge/Architecture-Bash_%2B_Docker-blue?style=for-the-badge" alt="Architecture" />
  <img src="https://img.shields.io/badge/Platform-Ubuntu_%7C_Debian-orange?style=for-the-badge" alt="Platform" />
  <img src="https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge" alt="Status" />
</div>

<br/>

**ProxyUltra (`pxu`)** is the ultimate command-line infrastructure lifecycle manager. Built from the ground up to eliminate script-sprawl and duplicated spaghetti code, it elegantly installs, isolates, routes, and updates modern networking services inside secure Docker containers on any naked Linux VPS.

---

## 🌟 Modules & Features

Unlike monolithic scripts, ProxyUltra uses an idempotent **Plugin Engine**. Every service is an isolated module:

### 🛡️ VPN Panels & Nodes
*   **Remnawave Panel & Node** — Deploy the complete subscription-based VPN ecosystem (Valkey, Postgres 17, and backend components).
*   **3x-ui** — Standard, multi-protocol panel for XRAY instances.
*   **Marzban** — High-performance, modern Xray/Sing-box node orchestration panel.
*   **Wireguard (wg-easy)** — Dead-simple personal VPN with a Web UI and native bcrypt protections.
*   **Netbird** — Zero-configuration P2P private networks.

### 🌐 Routing & Obfuscation
*   **Telegram MTProxy** — Spin up an official Telegram Proxy node featuring TLS masking (`ee` secrets) to defeat DPI.
*   **Cloudflare WARP (SOCKS5)** — Automatically reroute outbound node traffic through the Cloudflare Backbone to bypass generic IP bans and CAPTCHAs.
*   **Selfsteal (Anti-DPI)** — Snippet that utilizes Caddy to natively mimic legitimate domains (e.g., `google.com`) for perfect camouflage.

### 🚀 Enterprise Operations
*   **Automated TLS/SSL** — Built-in `acme.sh` module orchestrates certificates with zero user intervention.
*   **Fail2Ban DDoS Shield** — Monitors Docker auth logs to block multi-scanning bots natively via UFW.
*   **Telegram Push Alerts** — Silent Markdown pings straight to your chat on successful deployments or backups.
*   **cron-based Auto-Backups** — Automate daily database dumps and configuration archives.
*   **TCP BBR Tuning** — Instant network acceleration via Linux Kernel tweaks.

---

## 🛠️ Installation & Usage

**ProxyUltra** comes with a beautiful graphical terminal interface, meaning you never have to memorize obscure commands. 

1. Clone this repository onto a fresh Debian 11+ or Ubuntu 20.04+ node.
2. Grant executing permissions:
   ```bash
   chmod +x ./bin/pxu
   ```
3. Boot up the GUI!
   ```bash
   ./bin/pxu menu
   ```

### Command Line Mode
For power users who want to bypass the GUI, `pxu` ships with robust headless capabilities:

```bash
# General Syntax
./bin/pxu <action> <service>

# Examples:
./bin/pxu install 3x-ui
./bin/pxu update remnawave
./bin/pxu backup remnawave
./bin/pxu remove netbird

# Run universal system diagnostics and health checks
./bin/pxu doctor
```

---

## 🧠 System Architecture

```text
proxy-ultra/
├── bin/
│   └── pxu                  <-- Core executable
├── core/                    <-- Idempotent bash engine, logger, & state manager
├── lib/                     <-- Reusable abstractions (firewall, docker, ssl, crypto)
├── ui/                      <-- Whiptail interactive TUI layer
└── services/                <-- Isolated plugin modules
    ├── remnawave/           
    ├── marzban/
    ├── mtproxy/
    └── ... 
```

**Designed for SysAdmins, crafted for perfection.**  
*By Houseassassin.*
