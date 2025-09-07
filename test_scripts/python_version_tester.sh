#!/usr/bin/env bash
set -Eeuo pipefail

# Comick Downloader - Multi-Python Version Runner (direct binaries)
# - Uses installed pyenv interpreters only
# - Installs only missing packages
# - Per-version run folders next to this .sh
# - Builds Pillow for 3.7/3.6 using Python's own MACOSX_DEPLOYMENT_TARGET

VERSIONS=(
  "3.13.7"
  "3.12.7"
  "3.11.9"
  "3.10.14"
  "3.9.19"
  "3.8.20"
  "3.7.17"
)

export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_NO_INPUT=1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PYTHON_SCRIPT_PATH="$ROOT_DIR/comick_downloader.py"
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if [ ! -f "$PYTHON_SCRIPT_PATH" ]; then
  echo "Error: 'comick_downloader.py' not found at: $PYTHON_SCRIPT_PATH"
  exit 1
fi

pybin_for_version() {
  local version="$1"
  local base="$PYENV_ROOT/versions/$version/bin"
  if [[ "$version" == 2.* ]]; then
    echo "$base/python"; return
  fi
  if [ -x "$base/python3" ]; then
    echo "$base/python3"
  else
    echo "$base/python"
  fi
}

has_module() {
  local py="$1" module="$2"
  "$py" - <<PY
import importlib, sys
try: importlib.import_module("$module")
except Exception: sys.exit(1)
PY
}

ensure_pip_ready() {
  local py="$1"
  if ! "$py" -m pip --version >/dev/null 2>&1; then
    "$py" -m ensurepip --upgrade >/dev/null 2>&1 || true
  fi
}

pip_install_if_missing() {
  local py="$1" module="$2" spec="$3"
  if has_module "$py" "$module"; then return 0; fi
  echo "  • Installing missing: $spec"
  "$py" -m pip install "$spec" >/dev/null
}

# Homebrew helpers (jpeg/png/freetype/tiff/webp/lcms2)
brew_prefix() { command -v brew >/dev/null 2>&1 || { echo ""; return; }; brew --prefix "$1" 2>/dev/null || true; }
ensure_brew_formula() {
  local f="$1"
  command -v brew >/dev/null 2>&1 || return 0
  brew ls --versions "$f" >/dev/null 2>&1 || { echo "  • Installing Homebrew formula: $f"; brew install "$f" >/dev/null; }
}

pillow_build_env() {
  local -a incs=() libs=() pkgs=()
  local f pref
  for f in jpeg-turbo libpng freetype libtiff webp little-cms2 zlib; do
    pref="$(brew_prefix "$f")"
    if [ -n "$pref" ]; then
      incs+=("-I$pref/include"); libs+=("-L$pref/lib"); pkgs+=("$pref/lib/pkgconfig")
    fi
  done
  # Some setups use 'jpeg' formula name
  pref="$(brew_prefix jpeg)"
  if [ -n "$pref" ]; then
    incs+=("-I$pref/include"); libs+=("-L$pref/lib"); pkgs+=("$pref/lib/pkgconfig")
  fi
  local CPPFLAGS="${incs[*]}"
  local LDFLAGS="${libs[*]}"
  local PKG_CONFIG_PATH=""
  if [ ${#pkgs[@]} -gt 0 ]; then PKG_CONFIG_PATH="$(IFS=:; echo "${pkgs[*]}")"; fi
  echo "$CPPFLAGS|$LDFLAGS|$PKG_CONFIG_PATH"
}

py_macos_target() {
  local py="$1"
  "$py" - <<'PY'
try:
    import sysconfig
    v = sysconfig.get_config_var('MACOSX_DEPLOYMENT_TARGET')
    print(v or "")
except Exception:
    print("")
PY
}

ensure_pillow_compilable() {
  local version="$1" py="$2"

  # Ensure brew libs present (best effort)
  if command -v brew >/dev/null 2>&1; then
    for f in jpeg-turbo libpng freetype libtiff webp little-cms2 zlib; do
      ensure_brew_formula "$f" || true
    done
  fi

  # If Pillow already importable, done
  if has_module "$py" PIL.Image; then return 0; fi

  local envs cpp ld pkg py_target
  envs="$(pillow_build_env)"
  cpp="${envs%%|*}"; envs="${envs#*|}"
  ld="${envs%%|*}";  envs="${envs#*|}"
  pkg="${envs%%|*}"

  py_target="$(py_macos_target "$py")"
  # If Python doesn't report a target, align to current OS (major.minor)
  if [[ -z "$py_target" ]]; then
    py_target="$(sw_vers -productVersion | cut -d. -f1-2)"
  fi

  local PILLOW_SPEC
  if [[ "$version" == 3.6.* ]]; then
    PILLOW_SPEC="Pillow==8.3.2"
  elif [[ "$version" == 3.7.* ]]; then
    PILLOW_SPEC="Pillow==9.5.0"
  else
    PILLOW_SPEC="Pillow>=10"
  fi

  echo "  • Building Pillow for $version (MACOSX_DEPLOYMENT_TARGET=$py_target)..."
  env \
    CPPFLAGS="$cpp" \
    CFLAGS="$cpp -mmacosx-version-min=$py_target -arch arm64" \
    LDFLAGS="$ld -mmacosx-version-min=$py_target -arch arm64" \
    PKG_CONFIG_PATH="$pkg" \
    MACOSX_DEPLOYMENT_TARGET="$py_target" \
    "$py" -m pip install --no-binary=:all: "$PILLOW_SPEC" >/dev/null
}

ensure_lxml_present() {
  local version="$1" py="$2"
  # The Python script now falls back to html.parser automatically,
  # but we still try to provide lxml for >= 3.8.
  case "$version" in
    3.8.*)  local LXML_SPEC="lxml==5.1.0" ;;
    3.9.*|3.10.*|3.11.*|3.12.*|3.13.*) LXML_SPEC="lxml==6.0.1" ;;
    *)      return 0 ;;
  esac
  has_module "$py" lxml.etree || { echo "  • Installing lxml for $version: $LXML_SPEC"; "$py" -m pip install "$LXML_SPEC" >/dev/null; }
}

echo "=== Comick Downloader - Multi-Python Version Runner ==="
echo "Project Root: $ROOT_DIR"
echo "Script Dir (per-version outputs here): $SCRIPT_DIR"
echo "Pyenv Root: $PYENV_ROOT"
echo "Testing versions: ${VERSIONS[*]}"
echo "======================================================"

successful_versions=()
failed_versions=()

for version in "${VERSIONS[@]}"; do
  echo ""
  echo "--- Testing Python $version ---"

  PY_BIN="$(pybin_for_version "$version")"
  if [ ! -x "$PY_BIN" ]; then
    echo "✗ Python binary not found or not executable: $PY_BIN"
    failed_versions+=("$version (binary missing)")
    continue
  fi

  if [[ "$version" == 2.* ]]; then
    echo "Skipping $version (cannot run a Python 3 script)."
    successful_versions+=("$version (Skipped)")
    continue
  fi

  echo "Using interpreter: $PY_BIN"
  "$PY_BIN" -V || true

  echo "Checking dependencies (installing only if missing)..."
  ensure_pip_ready "$PY_BIN"

  pip_install_if_missing "$PY_BIN" requests "requests>=2.25" || { failed_versions+=("$version (requests)"); continue; }
  pip_install_if_missing "$PY_BIN" bs4      "beautifulsoup4>=4.9" || { failed_versions+=("$version (bs4)"); continue; }

  ensure_lxml_present "$version" "$PY_BIN" || { failed_versions+=("$version (lxml)"); continue; }

  if [[ "$version" == 3.6.* || "$version" == 3.7.* ]]; then
    if ! ensure_pillow_compilable "$version" "$PY_BIN"; then
      echo "✗ Pillow build failed for $version"
      failed_versions+=("$version (Pillow)")
      continue
    fi
  else
    pip_install_if_missing "$PY_BIN" PIL.Image "Pillow>=10" || { failed_versions+=("$version (Pillow)"); continue; }
  fi

  if [[ "$version" == 3.7.* ]]; then
    pip_install_if_missing "$PY_BIN" pypdf "pypdf<5" || { failed_versions+=("$version (pypdf)"); continue; }
  elif [[ "$version" == 3.6.* ]]; then
    "$PY_BIN" -m pip install "pypdf<3" >/dev/null 2>&1 || "$PY_BIN" -m pip install "PyPDF2<3" >/dev/null 2>&1 || true
  else
    pip_install_if_missing "$PY_BIN" pypdf "pypdf>=3" || { failed_versions+=("$version (pypdf)"); continue; }
  fi

  "$PY_BIN" -m pip install "cloudscraper" >/dev/null 2>&1 || true

  RUN_DIR="$SCRIPT_DIR/$version"
  mkdir -p "$RUN_DIR"
  ln -sf "$PYTHON_SCRIPT_PATH" "$RUN_DIR/comick_downloader.py"

  echo "Running in: $RUN_DIR"
  (
    cd "$RUN_DIR"
    if "$PY_BIN" comick_downloader.py \
      --group GROUP #REPLACE WITH GROUP \
      --chapters "1-2" \
      --format pdf \
      --keep-chapters \
      "https://comick.io/comic/#REPLACE_WITH_ACTUAL_URL"; then
      echo "✓ Download task completed successfully for Python $version"
      successful_versions+=("$version")
    else
      echo "✗ Download task failed for Python $version"
      failed_versions+=("$version (execution failed)")
    fi
  )
done

echo ""
echo "====================="
echo "=== Test Summary ==="
echo "====================="
echo ""
echo "Successful runs:"
if [ ${#successful_versions[@]} -eq 0 ]; then
  echo "- None"
else
  for v in "${successful_versions[@]}"; do
    echo "- $v"
  done
fi
echo ""
echo "Failed runs:"
if [ ${#failed_versions[@]} -eq 0 ]; then
  echo "- None"
else
  for v in "${failed_versions[@]}"; do
    echo "- $v"
  done
fi
echo ""
echo "Outputs are in per-version folders under: '$SCRIPT_DIR'"
echo "Example: $SCRIPT_DIR/3.12.7/comics and $SCRIPT_DIR/3.12.7/tmp_*"