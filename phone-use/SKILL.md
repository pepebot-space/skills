---
name: phone-use
description: Control a connected iPhone, iOS simulator, Android emulator, or Android device from macOS through PhoneAgent's JSON-RPC bridge. Use when users ask to automate mobile UI actions, inspect accessibility trees, toggle Settings switches, navigate apps, or capture screenshots by sending RPC methods like get_tree, get_screen_image, get_context, tap_element, enter_text, scroll, swipe, and open_app.
---

# PhoneAgent (phone-use)

Use this workflow to drive iOS or Android UI through PhoneAgent's JSON-RPC bridge.

All shell commands below assume you are in the repo root:

```bash
cd "$(git rev-parse --show-toplevel)"
```

## Start the RPC bridge

1. Choose a platform bridge (both listen on `127.0.0.1:45678` by default).

```bash
# iOS (XCTest-hosted bridge)
$HOME/.pepebot/workspace/skills/phone-use/scripts/start_rpc_bridge_local.sh

# Android (adb bridge; emulator or physical device)
$HOME/.pepebot/workspace/skills/phone-use/scripts/start_android_rpc_bridge_local.sh
```

Notes:
- `start_rpc_bridge_local.sh` is interactive and will show a numbered list of iOS devices/simulators.
  Enter the number for the destination you want.
- `start_rpc_bridge_local.sh` starts a localhost-only forwarder.
- On Xcode "Connect via network", it uses the CoreDevice tunnel automatically (no extra deps).
- For USB fallback forwarding, install `pymobiledevice3` into a local venv:
  `python3 -m venv .venv && ./.venv/bin/python -m pip install -U pip && ./.venv/bin/python -m pip install pymobiledevice3`
- `start_android_rpc_bridge_local.sh` uses `adb`; if multiple devices are connected it prompts for the serial.

2. Keep the bridge process running.
3. Wait for `PHONEAGENT_RPC_READY ...` in logs before sending RPC calls.
4. Confirm socket readiness before first RPC:

```bash
$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py get-tree >/dev/null && echo rpc-ready
```

## Resolve host and port

1. Always use `127.0.0.1:45678` as the RPC endpoint (or `rpc.py --port <port>` if customized).

Notes:
- Both bridges are localhost-only.
- iOS physical-device flow uses a localhost forwarder.
- If you need to forward manually, first get a device UDID via `xcrun devicectl list devices`, then run:
  `python3 $HOME/.pepebot/workspace/skills/phone-use/scripts/forward_rpc_localhost.py --udid <UDID>` (binds `127.0.0.1:45678`)

## Send RPC calls

Use the helper CLI:

```bash
# iOS bundle identifier
$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py open-app com.apple.Preferences

# Android package name
$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py open-app com.android.settings
$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py get-tree | head

# Use coordinates copied from the tree (XCUI frame string).
$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py enter-text \
  --coordinate '{{33.0, 861.0}, {364.0, 38.0}}' \
  --text 'Display'

$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py tap-element \
  --coordinate '{{37.7, 969.7}, {199.7, 29.0}}'
```

## Core operating loop

1. Call `get_tree`.
2. Identify the best target element in the tree (label/identifier) and copy its frame coordinate string.
3. Prefer coordinate-based actions (`tap_element` / `enter_text`).
4. Use the returned `tree` from the action response to verify the UI changed as expected.
5. Repeat until complete.
6. When the task is complete, always capture a screenshot for the user:
   - Prefer `get_context` and write `result.screenshot_base64` to a PNG (or use `$HOME/.pepebot/workspace/skills/phone-use/scripts/rpc.py get-screen-image`, which writes PNG files to `/tmp/phoneagent-artifacts`).
   - Include the PNG path in your final message so the user can open it.

Use `swipe` to reveal off-screen content, then use the returned `tree` (or call `get_tree` if needed).
Use one request at a time per server. Do not fire concurrent batches.
Split long keyboard input into chunks; do not send giant `enter_text` payloads in one call.

## RPC method reference

All RPC requests are newline-delimited JSON objects with this shape:

```json
{"id":1,"method":"<method>","params":{...}}
```

All success responses look like:

```json
{"id":1,"result":{...}}
```

### `get_tree`

- Does: Returns the accessibility tree of the currently focused app.
- Params: none.
- Returns: `{"tree": "<string>"}`

Example:
```json
{"id":1,"method":"get_tree","params":{}}
```

### `get_screen_image`

- Does: Captures the current screen as a base64-encoded PNG plus image dimensions (when available).
- Params: none.
- Returns: `{"screenshot_base64":"<base64>","metadata":{"width":<number>,"height":<number>}}`

Example:
```json
{"id":2,"method":"get_screen_image","params":{}}
```

### `get_context`

- Does: Convenience method that returns both the current accessibility tree and the current screen image.
- Params: none.
- Returns: `{"tree":"<string>","screenshot_base64":"<base64>","metadata":{"width":<number>,"height":<number>}}`

Example:
```json
{"id":3,"method":"get_context","params":{}}
```

### `open_app`

- Does: Brings the specified app to the foreground (and makes it the focused app for subsequent calls).
- Params: `bundle_identifier` (string, required).
  - iOS: pass bundle identifier (example `com.apple.Preferences`).
  - Android: pass package name (example `com.android.settings`).
- Returns: `{"bundle_identifier":"<string>", "tree":"<string>"}` (Android also includes `package_name`).

Example:
```json
{"id":4,"method":"open_app","params":{"bundle_identifier":"com.apple.Preferences"}}
```

### `tap`

- Does: Taps an absolute point in the current app.
- Params: `x` (number, required), `y` (number, required). Coordinates are in absolute screen points as reported by the tree.
- Returns: `{"tree":"<string>"}`

Example:
```json
{"id":5,"method":"tap","params":{"x":120,"y":300}}
```

### `tap_element`

- Does: Taps the *center* of an element using its XCUI frame string from the accessibility tree.
- Params:
- `coordinate` (string, required). Must look like `{{x, y}, {w, h}}` (copied from the tree).
- `count` (integer, optional; default 1). Use 2 for double-tap.
- `longPress` (boolean, optional; default false). When true, performs a long-press gesture.
- Returns: `{"coordinate":"<string>", "count":<number>, "longPress":<bool>, "tree":"<string>"}`

Example:
```json
{"id":6,"method":"tap_element","params":{"coordinate":"{{20.0, 165.0}, {390.0, 90.0}}","count":1,"longPress":false}}
```

### `enter_text`

- Does: Taps the center of the target element (to focus it), waits briefly for the keyboard, then types the provided text followed by a newline (Return).
- Params:
- `coordinate` (string, required). Must look like `{{x, y}, {w, h}}` (copied from the tree).
- `text` (string, required).
- Returns: `{"coordinate":"<string>", "tree":"<string>"}`

Example:
```json
{"id":7,"method":"enter_text","params":{"coordinate":"{{33.0, 861.0}, {364.0, 38.0}}","text":"hello"}}
```

### `scroll`

- Does: Scrolls by dragging from a starting point by the provided deltas.
- Params: `x` (number, required), `y` (number, required), `distanceX` (number, required), `distanceY` (number, required).
- Returns: `{"tree":"<string>"}`

Example:
```json
{"id":8,"method":"scroll","params":{"x":215,"y":760,"distanceX":0,"distanceY":-460}}
```

### `swipe`

- Does: Swipes in a direction starting from a given point (implemented as a bounded drag gesture).
- Params: `x` (number, required), `y` (number, required), `direction` (string, required; one of `up`, `down`, `left`, `right`).
- Returns: `{"tree":"<string>"}`

Example:
```json
{"id":9,"method":"swipe","params":{"x":215,"y":760,"direction":"up"}}
```

### `stop`

- Does: Stops the RPC server test (ends the `xcodebuild test` session).
- Params: none.
- Returns: `{}`

Example:
```json
{"id":10,"method":"stop","params":{}}
```

## iOS app bundle IDs

- Settings: `com.apple.Preferences`
- Camera: `com.apple.camera`
- Photos: `com.apple.mobileslideshow`
- Messages: `com.apple.MobileSMS`
- Home Screen: `com.apple.springboard`

## Android package names

- Settings: `com.android.settings`
- Camera (AOSP): `com.android.camera2`
- Photos (Google): `com.google.android.apps.photos`
- Messages (Google): `com.google.android.apps.messaging`
- Home Screen: launcher package varies by emulator/device

## Recovery playbook

1. If RPC hangs after `open_app`, restart the test-hosted server and retry with a known-good bundle id.
2. If taps fail due stale UI, call `get_tree` again and recalculate target.
3. If iOS bridge becomes unresponsive, stop/restart `xcodebuild test` and resume from latest verified app state.
4. If Android bridge becomes unresponsive, restart `adb` (`adb kill-server && adb start-server`), relaunch the bridge, and retry.

## End session

1. Send `stop` only when the task is complete.
2. If `stop` is not sent, terminate the `xcodebuild` session manually.
