# Distribution locale

## Linux

Dependances natives dans une distro Fedora:

```bash
sudo dnf install -y gstreamer1-devel gstreamer1-plugins-base-devel
```

Dependances natives dans une distro Debian/Ubuntu:

```bash
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

```bash
distrobox enter my-distrobox -- bash -lc 'export PATH="$HOME/.local/share/flutter/bin:$PATH"; flutter build linux'
```

Artefact:

```text
build/linux/x64/release/bundle/dactykids
```

## Windows

Ce build doit etre lance sur Windows avec Visual Studio Desktop C++ installe.

```powershell
flutter build windows
```

Artefact:

```text
build/windows/x64/runner/Release/
```

Pour une diffusion publique, ajouter un installateur et une signature de code.

## macOS

Ce build doit etre lance sur macOS avec Xcode installe.

```bash
flutter build macos
```

Artefact:

```text
build/macos/Build/Products/Release/dactykids.app
```

Pour une diffusion publique, ajouter signature Apple et notarisation.

## Android debug

```bash
distrobox enter my-distrobox -- bash -lc 'export PATH="$HOME/.local/share/flutter/bin:$PATH"; flutter build apk --debug'
```

Artefact:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Android release

Creer une cle upload hors depot:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copier `android/key.properties.example` vers `android/key.properties`, puis renseigner les mots de passe.

```bash
distrobox enter my-distrobox -- bash -lc 'export PATH="$HOME/.local/share/flutter/bin:$PATH"; flutter build apk --release'
```

Artefact APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Pour Google Play:

```bash
distrobox enter my-distrobox -- bash -lc 'export PATH="$HOME/.local/share/flutter/bin:$PATH"; flutter build appbundle --release'
```

Artefact AAB:

```text
build/app/outputs/bundle/release/app-release.aab
```

Sans `android/key.properties`, la configuration retombe sur la cle debug pour permettre les builds locaux/CI, mais ce build ne doit pas etre publie.

## Notes

- Android release publique necessite une cle de signature dediee.
- Windows et macOS sont construits sur runners natifs dans la CI.
- La CI publie des artefacts temporaires par plateforme sur chaque execution.
- Les donnees enfant restent locales via `shared_preferences`.
- Le workflow CI est documente dans `docs/ci.md`.
- Les checks performance sont documentes dans `docs/performance.md`.
