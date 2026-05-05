# Changelog

## 1.0.0 - 2026-05-05

### Ajoute

- Interface enfant refondue avec assets visuels, animations et mini-jeux plus dynamiques.
- Images et sprites de jeu pour ballons, jardin, taupes, vaisseau et course.
- Progression visuelle par mini-jeu: taupes qui sortent, jardin qui pousse, voiture qui avance et se cabosse, fusee qui change de planete.
- Sprites de voiture endommagee cumulativement jusqu'au niveau en feu.
- Guide mains/doigts avec sprites dedies par doigt, rouge en mode standard et noir en contraste eleve.
- Option pour activer/desactiver l'aide mains/doigts.
- Portefeuille d'etoiles persistant par profil.
- Scoring de fin de niveau en etoiles avec bonus parfait et etoile platine.
- Acces dedie aux mini-jeux, debloques selon la progression, avec prompts aleatoires hors lecons.
- Lancement implicite des mini-jeux conserve pendant les lecons.
- Icône d'application propagee sur Android, Linux, macOS et Windows.
- Installateur Windows NSIS via GitHub Actions.
- Scripts `init_project.sh` et `build.sh` pour initialiser et construire le projet.
- Keystore Android release local hors Git et APK/AAB signes localement.
- README complet oriente utilisateur puis developpeur.

### Modifie

- Layout de l'ecran lecon reorganise pour eviter les debordements: feedback dans le header, mains sous le clavier aide.
- Lettres retirees des images de mini-jeux; la consigne reste sous la scene et via accessibilite.
- Liste des lecons rendue scrollable avec centrage sur la lecon courante.
- Documentation distribution/CI/release mise a jour pour Android signe, Windows NSIS et macOS non signe.
- Version du projet montee a `1.0.0+100`.

### Corrige

- Debordements des lecons longues hors ecran.
- Disparition des mains et du mode aide sur prompts de plusieurs lignes.
- Surimpressions graphiques de la course/voiture.
- Mauvais alignement de l'aide doigt par remplacement des marqueurs runtime par sprites prerendus.
- Plusieurs risques de regression couverts par tests assets, widgets, accessibilite et navigation clavier.

### Notes release

- Android release local signe avec `secrets/dactykids-release.jks` et `android/key.properties`, tous deux ignores par Git.
- Windows et macOS sont construits par GitHub Actions sur runners natifs.
- Windows produit un artefact portable et un installateur NSIS non signe.
- macOS produit une app non signee; pour diffusion publique large, signature Apple et notarisation restent necessaires.
- Les donnees enfant restent locales, sans compte, pub, chat ni partage social.

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
