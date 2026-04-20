<div align="center">
 
 ![ProxyUltra](https://img.shields.io/badge/ProxyUltra-1.0-blue?style=for-the-badge)
 ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
 ![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20Debian-orange?style=for-the-badge)
 
 **Универсальный фреймворк для автоматизации VPN инфраструктуры, прокси-серверов и систем защиты**
 
 *Architected and Developed by **Houseassassin***
 
 [![Stars](https://img.shields.io/github/stars/houseassassin/proxy-ultra?style=social)](https://github.com/houseassassin/proxy-ultra)
 [![Forks](https://img.shields.io/github/forks/houseassassin/proxy-ultra?style=social)](https://github.com/houseassassin/proxy-ultra)
 
 </div>
 
 ---
 
 <div align="center">
 
 ### 🔥 Основные компоненты
 </div>
 
 <table>
 <tr>
 <td width="50%" align="center">
 
 ### 🎯 Панели управления
 - **Remnawave** — Полный стек (Postgres 17, Valkey, Sub-page)
 - **3x-ui** — Классическая мультипротокольная панель
 - **Marzban** — Современная панель на Python для Xray/Sing-box
 - **3DP-Manager** — Продвинутый GUI для управления 3x-ui
 
 </td>
 <td width="50%" align="center">
 
 ### 🌐 Протоколы и Ноды
 - **Wireguard (wg-easy)** — Конфигурация в один клик через Web UI
 - **MTProxy** — Нативный прокси для Telegram с Fake-TLS
 - **Remnanode** — Быстрое развертывание нод для Remnawave
 - **Netbird** — Zero-config P2P Mesh VPN
 
 </td>
 </tr>
 </table>
 
 ### ⚡ Дополнительные возможности
 - **Cloudflare WARP** — Интеграция исходящего трафика через SOCKS5 для обхода капч
 - **Selfsteal (Anti-DPI)** — Маскировка трафика через Caddy под легитимные домены
 - **TDL (MTProto)** — Загрузка огромных файлов (бэкапов) в Telegram до 4GB
 - **Fail2Ban Shield** — Автоматическая защита от DDoS и брутфорса
 - **Telegram Alerts** — Уведомления о статусе системы прямо в ваш чат
 - **Auto-Backups** — Ежедневное резервное копирование по расписанию (Cron)
 - **TCP BBR Tuning** — Мгновенная оптимизация сетевого стека ядра Linux
 
 ---
 
 <div align="center">
 
 ### 🎮 Интерактивное меню (TUI)
 </div>
 
 <table>
 <tr>
 <td width="50%" align="center">
 
 ### 🛡️ Безопасность и Сеть
 - 🧱 **Fail2Ban**: Мониторинг и блокировка атакующих IP
 - 🔑 **SSL/TLS**: Автоматический выпуск сертификатов через acme.sh
 - 🚀 **BBR**: Включение ускорения TCP трафика
 - 🛡️ **UFW**: Автоматическая настройка правил фаервола
 
 </td>
 <td>
 
 ### 📦 Управление и Бэкапы
 - 📦 **Backup**: Ручное и автоматическое создание архивов
 - 🕒 **Cron**: Настройка расписания для ежедневных задач
 - 📱 **Telegram**: Привязка бота для алертов и MTProto сессий
 - 🩺 **Doctor**: Глобальная диагностика всех установленных сервисов
 
 </td>
 </tr>
 </table>
 
 ---
 
 ## 🖥️ Быстрый старт
 - Вариант 1 (Рекомендуемый)
 ```bash
 bash <(curl -fsSL https://raw.githubusercontent.com/houseassassin/proxy-ultra/main/install.sh)
 ```
 - Вариант 2
 ```bash
 git clone https://github.com/houseassassin/proxy-ultra.git && cd proxy-ultra && chmod +x bin/pxu && ./bin/pxu menu
 ```
 
 ---
 
 ## 💡 Как это работает
 
 1. **🎯 Выбор опции** в графическом меню (Whiptail)
 2. **📝 Ввод данных**:
    - 🌐 Домены для панелей и прокси
    - 🔌 Кастомные порты во время установки
    - 🔑 API ключи для Telegram и MTProto
 3. **⚡ Автоматизация**:
    - ✅ Проверка зависимостей и установка Docker
    - 📦 Развертывание изолированных контейнеров
    - ⚙️ Генерация безопасных паролей (lib_crypto)
    - 📋 Автоматическая регистрация в Telegram боте
 
 ---
 
 <div align="center">
 
 ### 🛡️ Безопасность и Стабильность
 </div>
 
 - 🔐 Использование безопасных генераторов строк для всех паролей
 - 🗑️ Изоляция данных каждого сервиса в `/opt/pxu/data`
 - 🔒 Защищенное хранение состояния системы в `/etc/pxu/.state`
 - 🛡️ Валидация портов и доменов перед установкой
 
 ---
 
 <div align="center">
 
 Если фреймворк был полезен — поставьте ⭐️ на [GitHub](https://github.com/houseassassin/proxy-ultra)!
 
 [![Star](https://img.shields.io/github/stars/houseassassin/proxy-ultra?style=social)](https://github.com/houseassassin/proxy-ultra)
 
 Developed by: **Houseassassin**
 
 </div>
 
 ---
 
 License: MIT
 
 ---
 
 <div align="center">
 
 **ProxyUltra** — ваш универсальный архитектурный фреймворк для управления будущим вашей сети! 🚀
 
 </div>
