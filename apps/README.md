# MARATHON Tactical — External App Styling & Generated Themes

Комплект стилизованных конфигураций для системных терминалов, CLI-инструментов, просмотрщиков и GTK/Qt тулкитов в единой визуальной системе **MARATHON Tactical**.

## Содержимое каталога

| Приложение | Конфигурация | Динамическая палитра (`Settings Hub`) |
|---|---|---|
| **Ghostty** | `ghostty/config` | `generated/ghostty-colors` |
| **Kitty** | `kitty/kitty.conf` | `generated/kitty-colors.conf` |
| **Alacritty** | `alacritty/alacritty.toml` | `generated/alacritty-colors.toml` |
| **Foot** | `foot/foot.ini` | `generated/foot-colors.ini` |
| **btop++** | `btop/btop.conf` | `generated/btop-marathon.theme` |
| **Yazi** | `yazi/yazi.toml` | `generated/yazi-colors.toml` |
| **Starship** | `starship/starship.toml` | — |
| **Fastfetch** | `fastfetch/config.jsonc` | — |
| **GTK 3.0 / 4.0** | `gtk-3.0/`, `gtk-4.0/` (`settings.ini`, `widgets.css`) | `generated/gtk-colors.css` |
| **Qt6ct** | `qt6ct/qt6ct.conf` | `generated/qt6ct-colors.conf` |
| **mpv** | `mpv/mpv.conf`, `mpv/input.conf` | — |
| **imv** | `imv/config` | — |
| **Zathura** | `zathura/zathurarc` | — |

## Живая синхронизация палитры

Когда в **Settings Hub** (`Appearance -> Sync App Themes`) включена опция `appThemeSyncEnabled`, `SettingsAdapter.qml` автоматически обновляет все файлы в `~/.config/marathon-tactical/apps/generated/` при смене корпоративной фракции, поверхностной темы (`TACTICAL` / `DEEP_VOID` / `STEALTH_SLATE`) или пользовательского акцента.

## Безопасное применение (Opt-in)

Конфиги **не** перезаписывают `~/.config/*` при обычной установке:

```bash
# Предпросмотр изменений без записи:
bash scripts/apply-themes.sh --dry-run

# Применить темы с автоматическим резервным копированием в ~/.config/marathon-tactical-app-backups/:
bash scripts/apply-themes.sh

# Полный откат предыдущих пользовательских конфигов приложений:
bash scripts/apply-themes.sh --restore
```
