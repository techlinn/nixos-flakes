# Keybinds

Defined in `dotfiles/config/hypr/hyprland.conf`.

## Applications

| Keys | Action |
| --- | --- |
| `CTRL + SPACE` | App launcher (rofi) |
| `CTRL + ENTER` | Terminal (kitty) |
| `ALT + D` | Discord (Equibop) |
| `ALT + F` | Zen browser |
| `ALT + M` | Music (cmus) |
| `ALT + E` | Emoji picker |
| `ALT + S` | Theme & settings menu |
| `SUPER + E` | Files (Nautilus) |
| `SUPER + W` | Ranger (in kitty) |

## Workspaces

| Keys | Action |
| --- | --- |
| `ALT + {1-9}` | Switch to workspace |
| `SUPER + {1-9}` | Move window to workspace |
| `CTRL + ALT + ←/→` | Previous / next workspace |
| `CTRL + ALT + TAB` | Previous workspace |

## Alt+Tab

| Keys | Action |
| --- | --- |
| `ALT + TAB` | Window switcher: hold `ALT`, tap `TAB` to go further back, release to switch. A quick tap goes back to the previous window |
| `ALT + SHIFT + TAB` | Same, in the other direction |
| `←` `→` (while holding `ALT`) | Step through the windows |
| `Q` (while holding `ALT`) | Close the highlighted window |
| `ESC` (while holding `ALT`) | Cancel the switch |

It lives in `dotfiles/config/quickshell-overlays` (see its `NOTICE.md`).

## Windows

| Keys | Action |
| --- | --- |
| `ALT + arrows` | Focus window |
| `ALT + SHIFT + arrows` | Move window (tiled) |
| `SUPER + SHIFT + arrows` | Nudge floating window |
| `SUPER + CTRL + arrows` | Resize window |
| `SUPER + T` | Toggle floating |
| `SUPER + P` | Pseudo-tile |
| `SUPER + V` | Toggle split |
| `SUPER + F` / `SUPER + SHIFT + F` | Fullscreen / real fullscreen |
| `ALT + Z` | Close window (apps like Discord may keep running in the background) |
| `ALT + SHIFT + Q` | Quit the program that owns the window; asks it to quit, and stops it after 5 s if it does not (`pwnbox-quit`) |
| `SUPER + CTRL + {1-9}` | Set split ratio 0.1-0.9 |
| `SUPER + LMB drag` | Move window |
| `SUPER + RMB drag` | Resize window |

## System

| Keys | Action |
| --- | --- |
| `SUPER + L` | Lock screen |
| `SUPER + ESCAPE` | Power menu |
| `SUPER + \`` | Clipboard history |
| `SUPER + SHIFT + S` | Screenshot to clipboard (drag a box) |
| `PRINT` | Screenshot output |
| `SUPER + SHIFT + R` | Save screenshot |
| `SUPER + ALT + R` | Reload Hyprland |
| `SUPER + ALT + Q` | Exit Hyprland session |

## Media & hardware

| Keys | Action |
| --- | --- |
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume ±5% |
| `XF86AudioMute` | Mute output |
| `XF86AudioMicMute` | Mute microphone |
| `XF86AudioPlay` / `Next` / `Prev` | Media control |
| `XF86MonBrightnessUp` / `Down` | Brightness ±5% |
