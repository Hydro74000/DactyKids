# DactyKids

Application Flutter offline-first pour apprendre la dactylographie aux enfants de 5 a 10 ans.

Le projet suit `plan_reecriture_jeu_dactylo_enfants.md` :

- parcours home/top/bottom rows, mots, phrases, paragraphes, chiffres, symboles et accents ;
- profils enfants locaux separes avec avatar, reglages et progression ;
- layouts AZERTY FR et QWERTY US ;
- moteur de prompts, matching, feedback, scoring et progression ;
- clavier visuel accessible ;
- modes visuels standard, contraste eleve, tres lisible et niveaux de gris ;
- 5 mini-jeux debloques selon l'avancee ;
- audio doux local ;
- mode parent avec CSV, sauvegarde/restauration JSON et suppression locale ;
- CI/CD Linux, Windows, macOS et Android.

## Lancer

Flutter n'est pas inclus dans ce depot. Avec Flutter installe :

```bash
flutter pub get
flutter test
flutter run -d linux
```

Les builds Android et desktop dependront de l'installation Flutter locale et des toolchains ciblees. Voir `docs/distribution.md` pour Linux, Windows, macOS et Android.

## Documents utiles

- `docs/parent_enseignant.md`
- `docs/distribution.md`
- `docs/ci.md`
- `docs/performance.md`
- `docs/release_checklist.md`
- `docs/tests_utilisateurs.md`
- `docs/versioning.md`
- `CHANGELOG.md`
