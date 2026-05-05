# Checklist release

## Automatique

- `CHANGELOG.md` mis a jour
- `pubspec.yaml` versionne
- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `flutter build linux`
- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`
- GitHub Actions vert sur Linux, Windows, macOS et Android.

## Parcours produit

- Creer un profil enfant.
- Changer avatar, clavier et mode visuel.
- Terminer `F, J et espace`.
- Declencher une erreur et verifier le feedback doux.
- Ouvrir Recompenses et Mini-jeux.
- Ouvrir Parent, copier CSV, copier sauvegarde.
- Restaurer une sauvegarde JSON.
- Supprimer un profil non unique.

## Accessibilite

- Tester Standard, Contraste, Tres lisible et Niveaux de gris.
- Tester scaling systeme 200 %.
- Tester navigation clavier Tab/Entree sur l'accueil.
- Tester lecteur d'ecran sur menus principaux selon plateforme.
- Verifier que les sons ont toujours un equivalent visuel.

## Packaging

- Android release signe avec une vraie cle avant publication.
- macOS signe et notarise avant diffusion publique large; artefact GitHub non signe acceptable pour test/distribution manuelle.
- Windows signe avant diffusion publique large; installateur NSIS non signe acceptable pour test/distribution manuelle.
- Artefacts CI recuperes et nommes avec version/date.
- Tag Git cree selon `docs/versioning.md`.

## Donnees enfant

- Aucun compte enfant requis.
- Donnees locales uniquement.
- Export, restauration et suppression locale verifies.
