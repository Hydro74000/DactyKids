#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/.local/share/flutter}"
FLUTTER_BIN="${DACTYKIDS_FLUTTER_BIN:-}"
DISTROBOX_NAME="${DACTYKIDS_DISTROBOX:-my-distrobox}"

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf '\n!! %s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

resolve_flutter() {
  if [[ -n "$FLUTTER_BIN" && -x "$FLUTTER_BIN" ]]; then
    return
  fi

  if command -v flutter >/dev/null 2>&1; then
    FLUTTER_BIN="$(command -v flutter)"
    return
  fi

  if [[ -x "$FLUTTER_ROOT/bin/flutter" ]]; then
    FLUTTER_BIN="$FLUTTER_ROOT/bin/flutter"
    return
  fi

  warn "Flutter introuvable. Lance ./init_project.sh ou definis DACTYKIDS_FLUTTER_BIN."
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./build.sh [--help]

Lance les checks et builds disponibles pour DactyKids:
  - flutter pub get
  - dart format --output=none --set-exit-if-changed lib test
  - flutter analyze
  - flutter test
  - Linux: flutter build linux
  - Android: APK debug, APK release, App Bundle release
  - macOS/Windows: build natif si lance sur la plateforme correspondante

Note Windows:
  Flutter refuse `flutter build windows` sur un hote Linux avant meme CMake.
  Wine ne suffit donc pas pour produire le build Windows; lance ce script sur
  Windows avec Visual Studio 2022 Desktop C++ installe.

Variables utiles:
  DACTYKIDS_FLUTTER_BIN=/chemin/flutter
  FLUTTER_ROOT=$HOME/.local/share/flutter
  DACTYKIDS_DISTROBOX=my-distrobox
  DACTYKIDS_NO_DISTROBOX=1
EOF
}

maybe_enter_distrobox() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    return
  fi
  if [[ "${DACTYKIDS_NO_DISTROBOX:-0}" == "1" ||
        "${DACTYKIDS_IN_DISTROBOX:-0}" == "1" ]]; then
    return
  fi
  if ! command -v distrobox >/dev/null 2>&1; then
    return
  fi
  if ! distrobox list 2>/dev/null | grep -q "$DISTROBOX_NAME"; then
    return
  fi

  log "Relance dans la distrobox $DISTROBOX_NAME"
  exec distrobox enter "$DISTROBOX_NAME" -- bash -lc \
    "cd '$PROJECT_DIR' && DACTYKIDS_IN_DISTROBOX=1 ./build.sh $*"
}

run_build() {
  log "$*"
  "$FLUTTER_BIN" "$@"
}

main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
  fi

  cd "$PROJECT_DIR"
  maybe_enter_distrobox "$@"
  resolve_flutter

  log "Flutter: $FLUTTER_BIN"
  "$FLUTTER_BIN" --version

  run_build pub get
  log "dart format --output=none --set-exit-if-changed lib test"
  "$(dirname "$FLUTTER_BIN")/dart" format --output=none --set-exit-if-changed lib test
  run_build analyze
  run_build test

  case "$(uname -s)" in
    Linux)
      run_build build linux
      run_build build apk --debug
      run_build build apk --release
      run_build build appbundle --release
      warn "Build Windows ignore: Flutter Desktop Windows doit etre lance sur un hote Windows natif. Wine n'est pas supporte par la commande Flutter."
      ;;
    Darwin)
      run_build build macos
      if [[ -d android ]]; then
        run_build build apk --debug
        run_build build apk --release
        run_build build appbundle --release
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      run_build build windows
      if have makensis; then
        log "makensis windows/installer/dactykids.nsi"
        makensis windows/installer/dactykids.nsi
      else
        warn "makensis introuvable: installateur Windows NSIS non genere. Lance ./init_project.sh pour installer NSIS."
      fi
      ;;
    *)
      warn "Plateforme non reconnue pour les builds natifs: $(uname -s)"
      ;;
  esac

  log "Builds termines"
  printf '%s\n' \
    "Linux:   build/linux/x64/release/bundle/dactykids" \
    "Android: build/app/outputs/flutter-apk/app-debug.apk" \
    "Android: build/app/outputs/flutter-apk/app-release.apk" \
    "Android: build/app/outputs/bundle/release/app-release.aab" \
    "Windows: build/windows/x64/runner/Release/ (si lance sur Windows natif)" \
    "Windows: build/windows/dactykids-setup.exe (si NSIS disponible)" \
    "macOS:   build/macos/Build/Products/Release/dactykids.app"
}

main "$@"
