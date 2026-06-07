#!/usr/bin/env bash
# Installs the Meta Ads CLI (PyPI package `meta-ads`, command `meta`) so it runs
# inside the Cowork sandbox. The package requires Python >= 3.12. The sandbox
# usually ships an older Python, so we provision 3.12 with `uv` and install the
# CLI as a uv tool. This script is idempotent: if `meta` already works it exits
# fast.
#
# On success it prints, on the last line:
#   META_BIN=<absolute dir containing the `meta` executable>
# Add that dir to PATH in any later bash call before running `meta`.
set -euo pipefail

BIN_DIR="${META_CLI_BIN:-$HOME/.local/meta-ads/bin}"
TOOL_DIR="${META_CLI_TOOLS:-$HOME/.local/meta-ads/tools}"

# Fast path: already installed and runnable.
if [ -x "$BIN_DIR/meta" ] && "$BIN_DIR/meta" --version >/dev/null 2>&1; then
  echo "meta already installed: $("$BIN_DIR/meta" --version)"
  echo "META_BIN=$BIN_DIR"
  exit 0
fi

# Already on PATH from a system-wide Python 3.12+ install?
if command -v meta >/dev/null 2>&1 && meta --version >/dev/null 2>&1; then
  echo "meta found on PATH: $(meta --version)"
  echo "META_BIN=$(dirname "$(command -v meta)")"
  exit 0
fi

mkdir -p "$BIN_DIR" "$TOOL_DIR"

# Preferred: uv (handles Python 3.12 provisioning + isolated install).
if command -v uv >/dev/null 2>&1; then
  uv python install 3.12 >/dev/null 2>&1 || true
  UV_TOOL_BIN_DIR="$BIN_DIR" UV_TOOL_DIR="$TOOL_DIR" \
    uv tool install --force meta-ads --python 3.12 >&2
# Fallback: a usable Python 3.12+ is already present.
elif python3 -c 'import sys; sys.exit(0 if sys.version_info[:2] >= (3,12) else 1)' 2>/dev/null; then
  python3 -m pip install --user --upgrade meta-ads >&2 || \
    python3 -m pip install --break-system-packages --upgrade meta-ads >&2
  ln -sf "$(python3 -c 'import sysconfig,os;print(os.path.join(sysconfig.get_path("scripts","posix_user"),"meta"))')" "$BIN_DIR/meta" 2>/dev/null || true
else
  echo "ERROR: need either 'uv' or Python 3.12+ to install meta-ads." >&2
  exit 1
fi

if [ -x "$BIN_DIR/meta" ]; then
  echo "Installed: $("$BIN_DIR/meta" --version)"
  echo "META_BIN=$BIN_DIR"
elif command -v meta >/dev/null 2>&1; then
  echo "Installed: $(meta --version)"
  echo "META_BIN=$(dirname "$(command -v meta)")"
else
  echo "ERROR: install completed but 'meta' executable not found." >&2
  exit 1
fi
