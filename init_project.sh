#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/.local/share/flutter}"
FLUTTER_BIN="${DACTYKIDS_FLUTTER_BIN:-$FLUTTER_ROOT/bin/flutter}"

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf '\n!! %s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

run_sudo() {
  if have sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

install_linux_packages() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    warn "Installation automatique des paquets systeme ignoree hors Linux."
    return
  fi

  if have apt-get; then
    log "Installation des prerequis Linux via apt-get"
    run_sudo apt-get update
    run_sudo apt-get install -y \
      clang \
      cmake \
      curl \
      git \
      libgtk-3-dev \
      libgstreamer1.0-dev \
      libgstreamer-plugins-base1.0-dev \
      ninja-build \
      openjdk-17-jdk \
      pkg-config \
      unzip \
      xz-utils \
      zip
    return
  fi

  if have dnf; then
    log "Installation des prerequis Linux via dnf"
    run_sudo dnf install -y \
      clang \
      cmake \
      curl \
      git \
      gtk3-devel \
      gstreamer1-devel \
      gstreamer1-plugins-base-devel \
      java-17-openjdk-devel \
      ninja-build \
      pkgconf-pkg-config \
      unzip \
      xz \
      zip
    return
  fi

  if have pacman; then
    log "Installation des prerequis Linux via pacman"
    run_sudo pacman -Sy --needed --noconfirm \
      clang \
      cmake \
      curl \
      git \
      gtk3 \
      gst-plugins-base-libs \
      jdk17-openjdk \
      ninja \
      pkgconf \
      unzip \
      xz \
      zip
    return
  fi

  warn "Gestionnaire de paquets non reconnu. Installe manuellement Flutter, git, clang, cmake, GTK3, GStreamer, Ninja, pkg-config, unzip, xz, zip et JDK 17."
}

install_windows_packages() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) ;;
    *)
      return
      ;;
  esac

  if ! have winget; then
    warn "winget introuvable. Installe manuellement Git for Windows et Visual Studio 2022 avec le workload Desktop development with C++."
    return
  fi

  log "Installation des prerequis Windows via winget"
  winget install --accept-package-agreements --accept-source-agreements \
    --id Git.Git --source winget || true
  winget install --accept-package-agreements --accept-source-agreements \
    --id Microsoft.VisualStudio.2022.BuildTools --source winget \
    --override "--quiet --wait --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended" || true
  winget install --accept-package-agreements --accept-source-agreements \
    --id NSIS.NSIS --source winget || true
}

install_flutter() {
  if have flutter; then
    FLUTTER_BIN="$(command -v flutter)"
    log "Flutter deja disponible: $FLUTTER_BIN"
    return
  fi

  if [[ -x "$FLUTTER_BIN" ]]; then
    log "Flutter deja installe: $FLUTTER_BIN"
    return
  fi

  if ! have git; then
    warn "git est requis pour installer Flutter."
    exit 1
  fi

  log "Installation de Flutter stable dans $FLUTTER_ROOT"
  mkdir -p "$(dirname "$FLUTTER_ROOT")"
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_ROOT"
}

ensure_path_hint() {
  local flutter_dir
  flutter_dir="$(dirname "$FLUTTER_BIN")"
  if [[ ":$PATH:" != *":$flutter_dir:"* ]]; then
    warn "Ajoute Flutter a ton PATH pour les prochains shells:"
    warn "export PATH=\"$flutter_dir:\$PATH\""
  fi
}

main() {
  cd "$PROJECT_DIR"

  install_linux_packages
  install_windows_packages
  install_flutter
  ensure_path_hint

  case "$(uname -s)" in
    Linux)
      log "Activation desktop Linux Flutter"
      "$FLUTTER_BIN" config --enable-linux-desktop
      ;;
    MINGW*|MSYS*|CYGWIN*)
      log "Activation desktop Windows Flutter"
      "$FLUTTER_BIN" config --enable-windows-desktop
      ;;
  esac

  log "Recuperation des dependances Flutter"
  "$FLUTTER_BIN" pub get

  log "Diagnostic Flutter"
  "$FLUTTER_BIN" doctor

  if have sdkmanager; then
    log "Acceptation des licences Android si possible"
    yes | "$FLUTTER_BIN" doctor --android-licenses || true
  else
    warn "sdkmanager introuvable. Pour les builds Android, installe Android SDK/command-line tools si Flutter doctor le demande."
  fi

  log "Projet pret pour le developpement"
}

main "$@"
