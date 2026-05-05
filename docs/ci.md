# CI/CD

## Workflow GitHub Actions

Le workflow `.github/workflows/flutter.yml` lance:

- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- budgets performance inclus dans `flutter test`
- `flutter build linux`
- `flutter build windows`
- `flutter build macos`
- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`
- upload des artefacts par plateforme

## Artefacts de release

- Linux: `build/linux/x64/release/bundle/dactykids`
- Windows: `build/windows/x64/runner/Release/`
- macOS: `build/macos/Build/Products/Release/dactykids.app`
- Android debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Android release local: `build/app/outputs/flutter-apk/app-release.apk`
- Android App Bundle: `build/app/outputs/bundle/release/app-release.aab`

## Artefacts CI

- `dactykids-linux`
- `dactykids-windows`
- `dactykids-macos`
- `dactykids-android-apks`
- `dactykids-android-aab`

## Performance

Les budgets de performance sont documentes dans `docs/performance.md`.

## Avant release

La checklist de sortie est documentee dans `docs/release_checklist.md`.
La procedure de version est documentee dans `docs/versioning.md`.

## A finaliser pour une release publique

- Ajouter une signature Android release.
- Ajouter signature/notarisation macOS.
- Ajouter installateur Windows signe.
- Publier les artefacts signes sur une release GitHub taggee.
