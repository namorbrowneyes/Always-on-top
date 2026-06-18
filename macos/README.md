# Always-on-Top — macOS (Hammerspoon)

A macOS port of this project's Windows AutoHotkey utility, built on
[Hammerspoon](https://www.hammerspoon.org/). Press **Ctrl + Space** to pin the
focused window on top; press it again on that window to unpin. Each pinned window
gets its own pulsing 🔒 badge in its corner, and you can pin as many windows as
you like.

## Why it works differently from the Windows version

macOS has **no public API** to set another application's window level, so true
OS-level "always on top" isn't available without disabling part of System
Integrity Protection (the route tools like `yabai` take). Instead this port:

- **Re-raises** each pinned window whenever another window comes forward.
  `hs.window:raise()` does *not* steal keyboard focus, so you keep typing where
  you are while the pinned window stays visually on top.
- Draws the 🔒 badge as Hammerspoon's **own** canvas window, set to the overlay
  level — Hammerspoon *can* force its own windows on top.

This is robust for the common case (pin a reference window, work in another). If
you need bulletproof OS-level pinning, use `yabai` + `skhd` (requires a partial
SIP disable).

## Install

1. Install Hammerspoon:
   ```sh
   brew install --cask hammerspoon
   ```
   Launch it once and grant **Accessibility** permission when prompted
   (System Settings → Privacy & Security → Accessibility).

2. Copy `alwaysontop.lua` into `~/.hammerspoon/`:
   ```sh
   cp alwaysontop.lua ~/.hammerspoon/
   ```

3. Load it from `~/.hammerspoon/init.lua` (create the file if needed):
   ```lua
   require("alwaysontop")
   ```

4. Reload Hammerspoon (menubar icon → *Reload Config*, or run `hs.reload()` in
   the Hammerspoon console).

## Usage

- **Ctrl + Space** — toggle always-on-top for the focused window.
- **Ctrl + Alt + F** — maximize the focused window to fill its screen *without*
  native full-screen (see below).
- Pin multiple windows; toggling only affects the focused one.
- A pinned window unpins automatically if it's closed or hidden.

## Full-screen apps (e.g. Microsoft Remote Desktop)

macOS gives any app in **native full-screen** (the green button / View → Full
Screen) its **own Space**, and the OS does not allow another app's window to be
drawn over a full-screen Space. No tool can override this without disabling part
of System Integrity Protection — so pinned windows **cannot** float over a
natively full-screened app.

Workaround: don't use native full-screen for the app you want to overlay
(e.g. RDP). Instead focus it and press **Ctrl + Alt + F** — it fills the screen
but stays a normal window, so your pins keep floating over it. Pins over a
**windowed** (or maximized) app work automatically, including apps like RDP that
take focus inside an embedded view.

## Configuration

Edit the `CONFIG` block at the top of `alwaysontop.lua`:

| Key         | Default      | Description                                                  |
|-------------|--------------|--------------------------------------------------------------|
| `mods`      | `{"ctrl"}`   | Modifier(s): `ctrl` / `alt` / `cmd` / `shift`.               |
| `key`       | `"space"`    | Toggle key.                                                  |
| `maxMods` / `maxKey` | `{"ctrl","alt"}` / `"f"` | Pseudo-fullscreen (maximize) hotkey.          |
| `fillUnderMenuBar` | `false` | `true` = maximize edge-to-edge under the menu bar.            |
| `corner`    | `"TopLeft"`  | Badge corner: `TopLeft` / `TopRight` / `BottomLeft` / `BottomRight`. |
| `size`      | `30`         | Badge size in points (Retina handled automatically).        |
| `accent`    | amber/gold   | Glow + rim color (`{red=, green=, blue=}`, 0–1).             |
| `glowMin/Max` | `4` / `16` | Pulse glow blur range.                                       |
| `pulseSecs` | `2.0`        | Full breathe cycle duration.                                |

> **Note:** Ctrl + Space is also macOS's default "Select previous input source"
> shortcut. Hammerspoon's hotkey takes priority in practice, but if it feels
> flaky, disable that shortcut (System Settings → Keyboard → Keyboard Shortcuts →
> Input Sources) or pick a different `mods`/`key`.
