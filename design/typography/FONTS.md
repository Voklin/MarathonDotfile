# Typography & Font License Audit — MARATHON Tactical

Все шрифты в проекте отбираются с проверяемой открытой лицензией и поддержкой табулярных цифр для телеметрии HUD (часы, проценты, workspace-индикаторы).

---

## 1. Рекомендованный стек для CachyOS Linux (проверенные Open Source лицензии)

| Роль | Семейство шрифта | Пакет CachyOS / Arch Linux | Лицензия | Назначение в HUD |
|---|---|---|---|---|
| **Mono / Telemetry** (приоритет 1) | `JetBrains Mono` / `JetBrainsMono Nerd Font` | `ttf-jetbrains-mono` / `ttf-jetbrains-mono-nerd` | **SIL Open Font License 1.1** | Часы `HH:MM:SS`, workspace `01..06`, проценты громкости/яркости/батареи, коды модулей `SYS // ONLINE`, Lock Screen |
| **Mono** (приоритет 2) | `IBM Plex Mono` | `ttf-ibm-plex` | **SIL Open Font License 1.1** | Резервный технический моноширинный шрифт |
| **UI Sans** (приоритет 1) | `Space Grotesk` | `ttf-space-grotesk` (AUR) или системный пакет | **SIL Open Font License 1.1** | Заголовки активных окон, названия приложений в Launcher, сводки уведомлений |
| **UI Sans** (приоритет 2) | `Inter` / `IBM Plex Sans` | `inter-font` / `ttf-ibm-plex` | **SIL Open Font License 1.1** | Основной читаемый кириллический/латинский UI-шрифт (Unicode & длинные заголовки) |
| **Последний fallback** | `DejaVu Sans Mono` / `Noto Sans` | Штатные пакеты Arch/CachyOS | Bitstream Vera / SIL OFL 1.1 | Гарантированное отображение кириллицы, CJK и символов без зависимостей |

---

## 2. Стек среды разработки на Windows 11 (QtQuick Preview)

На Windows 11 ([`ENVIRONMENT_REPORT.md`](../../docs/ENVIRONMENT_REPORT.md)) системные шрифты определяются через [`ui/tokens/Tokens.qml`](../../ui/tokens/Tokens.qml):
- `fontUi`: `Bahnschrift` -> `Segoe UI Variable` -> `Segoe UI`
- `fontMono`: `JetBrains Mono` (если установлен) -> `Consolas` -> `Cascadia Mono`

---

## 3. Запреты и правила рендеринга

1. Запрещено включать в репозиторий проприетарные или нелицензированные шрифты из игровых дистрибутивов Bungie Marathon.
2. Все динамические числовые индикаторы обязаны использовать моноширинный шрифт либо `font.features: { "tnum": 1 }` / `Font.TabularFigures`, чтобы ширина элементов HUD не дёргалась при смене `9%` <-> `100%` или каждую секунду на часах.
3. Резолв шрифтов выполняется централизованно в [`ui/tokens/Tokens.qml`](../../ui/tokens/Tokens.qml) через `Qt.fontFamilies()`.

