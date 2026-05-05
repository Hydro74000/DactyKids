# Performance

## Budgets automatises

La suite `test/performance/performance_budget_test.dart` verifie:

- chargement des layouts et lecons sous 500 ms en test Flutter;
- 1000 frappes moteur sous 100 ms.

Ces budgets sont volontairement larges: ils servent a detecter les regressions grossieres avant une release.

## Commande

```bash
distrobox enter my-distrobox -- bash -lc 'export PATH="$HOME/.local/share/flutter/bin:$PATH"; flutter test test/performance'
```

## Verification manuelle avant release

- Demarrer l'app Linux et ouvrir l'accueil sans attente perceptible.
- Ouvrir Profil, Reglages, Parent et Mini-jeux.
- Lancer une lecon courte et verifier que chaque frappe reagit immediatement.
- Tester avec le mode Tres lisible et animations reduites.
