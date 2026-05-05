# Versioning

## Format

Le champ `version` de `pubspec.yaml` suit:

```text
MAJOR.MINOR.PATCH+BUILD
```

- `MAJOR`: rupture de donnees locales ou changement produit majeur.
- `MINOR`: nouvelles fonctionnalites compatibles.
- `PATCH`: correctifs et contenus sans rupture.
- `BUILD`: numero Android `versionCode`.

## Procedure release

1. Mettre a jour `pubspec.yaml`.
2. Ajouter une entree dans `CHANGELOG.md`.
3. Lancer la checklist `docs/release_checklist.md`.
4. Verifier les artefacts CI.
5. Creer un tag Git:

```bash
git tag v0.1.0
git push origin v0.1.0
```

## Donnees locales

Toute evolution qui modifie les cles `shared_preferences` doit rester compatible avec:

- les profils existants;
- les progressions par profil;
- les sauvegardes JSON locales;
- la migration du profil legacy vers `profile_default`.
