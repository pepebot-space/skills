#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage:
  start_android_rpc_bridge_local.sh [--serial <adb-serial>]

What this does:
  - Starts the PhoneAgent Android JSON-RPC bridge on 127.0.0.1:45678.
  - Lets you pick a connected adb device/emulator if --serial is not provided.

Requirements:
  - adb available in PATH, PHONEAGENT_ADB, or standard Android SDK paths
  - At least one connected Android emulator/device
USAGE
}

SERIAL=""
ADB_BIN="${PHONEAGENT_ADB:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --serial)
      [[ $# -ge 2 ]] || { echo "--serial requires a value" >&2; exit 2; }
      SERIAL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

resolve_adb() {
  if [[ -n "$ADB_BIN" && -x "$ADB_BIN" ]]; then
    echo "$ADB_BIN"
    return 0
  fi
  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi
  local root
  for root in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk"; do
    [[ -z "$root" ]] && continue
    if [[ -x "$root/platform-tools/adb" ]]; then
      echo "$root/platform-tools/adb"
      return 0
    fi
  done
  return 1
}

ADB_BIN="$(resolve_adb || true)"
if [[ -z "$ADB_BIN" ]]; then
  echo "adb was not found. Set PHONEAGENT_ADB or add adb to PATH." >&2
  exit 1
fi

"$ADB_BIN" start-server >/dev/null

if [[ -z "$SERIAL" ]]; then
  DEVICES=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && DEVICES+=("$line")
  done < <("$ADB_BIN" devices | awk 'NR>1 && $2=="device"{print $1}')
  if ((${#DEVICES[@]} == 0)); then
    echo "No adb devices detected. Start an emulator in Android Studio and retry." >&2
    exit 1
  fi

  if ((${#DEVICES[@]} == 1)); then
    SERIAL="${DEVICES[0]}"
    echo "Using adb device: $SERIAL" >&2
  else
    if [[ ! -e /dev/tty ]]; then
      echo "Multiple adb devices found and no TTY available for selection." >&2
      exit 1
    fi
    echo "Select Android destination:" >&2
    for i in "${!DEVICES[@]}"; do
      printf '%d) %s\n' "$((i + 1))" "${DEVICES[$i]}" >&2
    done
    while true; do
      printf 'Enter number (1-%d) [default 1]: ' "${#DEVICES[@]}" >&2
      IFS= read -r choice </dev/tty || true
      if [[ -z "${choice:-}" ]]; then
        choice="1"
      fi
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#DEVICES[@]} )); then
        SERIAL="${DEVICES[$((choice - 1))]}"
        break
      fi
    done
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
fi

PYTHON="python3"
if [[ -x "$REPO_ROOT/.venv/bin/python" ]]; then
  PYTHON="$REPO_ROOT/.venv/bin/python"
fi

echo "Starting Android RPC bridge on 127.0.0.1:45678 (serial=$SERIAL)" >&2
"$PYTHON" "$SCRIPT_DIR/android_rpc_bridge.py" --serial "$SERIAL" --adb-binary "$ADB_BIN"
