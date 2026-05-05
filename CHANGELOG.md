# Changelog

## 0.1.0 - 2026-05-04

### Ajoute

- Parcours de dactylographie enfants 5-10 ans.
- Layouts AZERTY FR et QWERTY US.
- Profils locaux multiples avec avatar et reglages separes.
- Progression locale par profil.
- Lecons home row, top row, bottom row, syllabes, mots, phrases, paragraphes, chiffres, symboles et accents.
- 5 mini-jeux: Ballons, Taupes, Jardin, Vaisseau, Course.
- Recompenses et resume parent par monde.
- Export CSV parent.
- Sauvegarde/restauration JSON locale.
- Suppression locale d'un profil et de sa progression.
- Modes visuels Standard, Contraste eleve, Tres lisible et Niveaux de gris.
- Audio doux local.
- Tests unitaires, widget, accessibilite, contenu, sauvegarde et performance.
- CI GitHub Actions Linux, Windows, macOS et Android.
- Builds Linux, APK debug, APK release et AAB release.

### Notes release

- Android release utilise une cle dediee si `android/key.properties` est fourni.
- Sans cle dediee, le build release local/CI retombe sur la cle debug et ne doit pas etre publie.
- Windows et macOS sont valides via runners natifs GitHub Actions.
