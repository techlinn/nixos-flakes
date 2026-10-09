# Alt+Tab switcher

This folder is a second Quickshell config. It runs as its own instance, next to
the bar in `../quickshell`, and provides the Alt+Tab switcher (hold `ALT`, tap
`TAB`, release), in `switcher/`.

It is started at login (`exec-once` in `hyprland.conf`). Colours, fonts and
corner radius come from the bar's `Theme.js` through `Commons/`, and
`pwnbox-theme` restarts this instance on every theme change. To restart it by
hand:

```bash
qs kill -p ~/.config/quickshell-overlays; qs -n -p ~/.config/quickshell-overlays
```

## switcher/ — the Alt+Tab switcher

Written for pwnbox; no outside code. A panel in the middle of the screen with
one live preview per window, most recently used first. Each card is as wide as
its window's shape, so previews fill their cards.

- **Keys.** The `ALT + TAB` and `ALT + SHIFT + TAB` binds in `hyprland.conf`
  step through it as Hyprland global shortcuts, and a release bind on `ALT`
  switches. Inside the panel: arrow keys step, `ENTER` or `SPACE` switches,
  `ESC` cancels, `Q` or `DELETE` closes the highlighted window. The pointer
  only selects after it has really moved, so opening the panel under a resting
  pointer changes nothing.
- **Order.** It keeps its own most-recently-used list. A focus shorter than
  100 ms does not count: Hyprland briefly focuses a workspace's last window on
  the way to another one, and counting that would send the next Alt+Tab to the
  wrong window. A quick tap therefore goes back and forth between the last two
  windows.
- **Motion.** It opens with a short scale-and-fade (`openDuration`,
  `popDuration` near the top of `Switcher.qml`) and the highlight glides
  between cards. Hyprland's own layer animation is switched off for it
  (`layerrule = no_anim` in `hyprland.conf`), otherwise the two would overlap.
- Window previews are only captured while the panel is up, and never while no
  monitor is connected (Hyprland 0.55 crashes on a capture request then).
