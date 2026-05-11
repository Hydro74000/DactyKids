# DactyKids

DactyKids est un jeu educatif Flutter pour apprendre la dactylographie aux
enfants de 5 a 10 ans. L'application fonctionne hors ligne, sans compte enfant,
avec des profils locaux separes et une progression adaptee a chaque enfant.

Version courante: `1.0.0`.

Le projet vise une experience douce et encourageante: des lecons courtes, un
clavier visuel, des mini-jeux animes, des recompenses, et des outils simples
pour les parents ou enseignants.

Fait pour mes enfants, partagé pour les autres :)

## Fonctionnalites

- Parcours progressif: rangee de repos, rangee superieure, rangee inferieure,
  syllabes, mots, phrases simples, paragraphes courts, majuscules, chiffres,
  symboles et accents.
- Layouts clavier: AZERTY francais et QWERTY US.
- Profils enfants multiples: avatar, reglages, progression et recompenses
  separes.
- Mini-jeux: Ballons, Taupes, Jardin, Vaisseau et Course.
- Aide pedagogique: doigt a utiliser, guide visuel des mains, clavier aide,
  feedback immediat et mode aide en cas d'erreurs.
- Recompenses: badges, etoiles par lecon, portefeuille d'etoiles persistant par
  profil, bonus sans faute.
- Espace parent/enseignant: resume de progression, touches a retravailler,
  export CSV, sauvegarde/restauration JSON et suppression locale d'un profil.
- Accessibilite: contraste eleve, mode tres lisible, niveaux de gris,
  navigation clavier et tests avec texte agrandi.
- Audio local: sons doux pour succes, erreur et fin de lecon, desactivables.

## Mode d'emploi

1. Ouvrir l'application.
2. Choisir ou creer un profil enfant.
3. Selectionner une lecon disponible dans le parcours.
4. Taper les touches, mots ou phrases demandes.
5. Observer le clavier aide, le doigt conseille et les mains si l'option est
   activee.
6. Finir la lecon pour gagner des etoiles et debloquer la suite.
7. Utiliser les mini-jeux dedies quand ils sont debloques, ou les laisser se
   lancer implicitement pendant les lecons.

Les sessions recommandees durent 3 a 8 minutes. La precision compte davantage
que la vitesse, surtout au debut.

## Conseils parent / enseignant

- Une lecon terminee avec 90 % ou plus est consideree comme acquise.
- Les touches a retravailler indiquent les erreurs recurrentes du profil actif.
- Le WPM est indicatif et devient surtout utile pour les enfants deja a l'aise.
- Le CSV parent peut etre colle dans un tableur pour un suivi ponctuel.
- La sauvegarde JSON permet de restaurer les profils et progressions locales.
- Toutes les donnees enfant restent locales a l'appareil.

Voir aussi [docs/parent_enseignant.md](docs/parent_enseignant.md).

## Reglages utiles

- Son doux: active/desactive les sons locaux.
- Aide mains et doigts: affiche ou masque l'image des mains.
- Timer: affiche le temps de session.
- Objectif hebdomadaire: aide au suivi parent.
- Mode visuel standard, contraste eleve, tres lisible ou niveaux de gris.
- Layout clavier AZERTY FR ou QWERTY US.


## Plateformes

DactyKids est une application Flutter multi-plateforme.

- Android
- Linux
- Windows
- macOS


## Installation

### Android

L'APK release local est produit ici:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Pour l'installer manuellement avec ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Depuis un telephone, il est aussi possible de transferer l'APK puis de l'ouvrir
avec le gestionnaire de fichiers. Android demandera peut-etre d'autoriser
l'installation depuis cette source.

### Linux

Le bundle Linux est produit ici:

```text
build/linux/x64/release/bundle/dactykids
```

Lancer l'application:

```bash
build/linux/x64/release/bundle/dactykids
```

### Windows

La CI GitHub Actions produit deux artefacts:

- `dactykids-windows`: dossier portable `Release/`.
- `dactykids-windows-installer`: installateur `dactykids-setup.exe`.

L'installateur NSIS installe l'application dans le profil utilisateur et ajoute
des raccourcis bureau/menu demarrer.

### macOS

La CI GitHub Actions produit un artefact `dactykids-macos` contenant
`dactykids.app`.

Pour lancer une app non signee en local:

```bash
open build/macos/Build/Products/Release/dactykids.app
```

Si Gatekeeper bloque une app telechargee depuis GitHub Actions:

```bash
xattr -dr com.apple.quarantine dactykids.app
open dactykids.app
```

Ce mode convient aux tests locaux. Pour une diffusion publique, il faudra une
signature Apple Developer et une notarisation.

## Developpement

### Prerequis

Le projet utilise Flutter stable et Dart.

Le script d'initialisation installe les prerequis connus quand le gestionnaire
de paquets est disponible:

```bash
./init_project.sh
```

Sur Linux, il installe notamment Flutter, Git, Clang, CMake, GTK3, GStreamer,
Ninja, JDK 17 et les outils d'archive.

Sur Windows, il installe via `winget` quand disponible:

- Git for Windows
- Visual Studio 2022 Build Tools
- workload Desktop development with C++
- NSIS

### Commandes courantes

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d linux
```

Le script de build complet lance format check, analyse, tests et builds
disponibles pour la plateforme:

```bash
./build.sh
```

Sur Linux, `build.sh` relance automatiquement dans la distrobox
`my-distrobox` si elle existe.

## Builds et artefacts

### Linux

```bash
flutter build linux
```

Artefact:

```text
build/linux/x64/release/bundle/dactykids
```

### Android

```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Artefacts:

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### Windows

Depuis Windows uniquement:

```bash
flutter build windows
makensis windows/installer/dactykids.nsi
```

Artefacts:

```text
build/windows/x64/runner/Release/
build/windows/dactykids-setup.exe
```

### macOS

Depuis macOS uniquement:

```bash
flutter build macos
```

Artefact:

```text
build/macos/Build/Products/Release/dactykids.app
```

Voir [docs/distribution.md](docs/distribution.md) pour les details par
plateforme.

## Signature Android

Le projet est configure pour signer les releases Android avec:

```text
android/key.properties
```

Dans l'environnement local actuel, les secrets sont stockes hors Git:

```text
secrets/dactykids-release.jks
secrets/keystore.txt
android/key.properties
```

Ces fichiers sont ignores par Git. Il faut sauvegarder `secrets/` dans un
coffre-fort ou un stockage securise: sans cette cle, il ne sera plus possible
de publier une mise a jour compatible avec les APK deja signes.

## CI/CD

Le workflow GitHub Actions [flutter.yml](.github/workflows/flutter.yml) lance:

- format check
- `flutter analyze`
- `flutter test`
- build Linux
- build Windows portable
- installateur Windows NSIS
- build macOS
- APK Android debug
- APK Android release
- AAB Android release

Artefacts CI:

- `dactykids-linux`
- `dactykids-windows`
- `dactykids-windows-installer`
- `dactykids-macos`
- `dactykids-android-apks`
- `dactykids-android-aab`

Voir [docs/ci.md](docs/ci.md).

## Structure du projet

```text
assets/content/          Contenus pedagogiques, lecons, layouts, wordlists
assets/images/game/      Images et sprites des mini-jeux
assets/branding/         Icone source de l'application
assets/sounds/           Sons locaux
lib/domain/              Moteur de frappe, scoring, prompts, clavier
lib/data/                Chargement contenu et stockage local
lib/presentation/        Ecrans, widgets, theme, audio
test/                    Tests unitaires, widgets, accessibilite, assets
docs/                    Documentation release, CI, distribution, parent
windows/installer/       Script NSIS
```

## Documentation

- [Guide parent / enseignant](docs/parent_enseignant.md)
- [Distribution locale](docs/distribution.md)
- [CI/CD](docs/ci.md)
- [Performance](docs/performance.md)
- [Checklist release](docs/release_checklist.md)
- [Tests utilisateurs](docs/tests_utilisateurs.md)
- [Versioning](docs/versioning.md)
- [Changelog](CHANGELOG.md)

## Confidentialite

DactyKids ne requiert pas de compte enfant. Les profils, reglages, progressions
et sauvegardes sont locaux a l'appareil. Les exports CSV/JSON sont produits a
la demande par le parent ou l'enseignant.

## Licence

Ce projet est distribue sous licence MIT. Voir [LICENSE](LICENSE).
