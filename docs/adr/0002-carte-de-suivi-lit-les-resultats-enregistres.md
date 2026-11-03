---
statut: accepté
tickets: EVA-1152
---

# La carte de suivi lit les résultats enregistrés dans l'évaluation, pas la restitution recalculée

La carte « Suivi de l'accompagnement » s'affiche sur la fiche d'une évaluation Eva quand `EvaluationEva#illettrisme_potentiel?` est vrai : synthèse des compétences de base « illettrisme potentiel », ou profil 1 ou 2 en numératie (`app/views/admin/evaluations_eva/_show.html.arb`). Cette condition est plus large que celle du tableau de bord, qui ne retient que la synthèse « illettrisme potentiel », avec des compétences de base complètes et un bénéficiaire non anonyme (`EvaluationsEva::TableauDeBordMisesEnAction`).

La carte de suivi de la mise en action affiche les résultats de l'évaluation (profils de littératie et de numératie, niveaux de français et de mathématiques). Elle les lit dans les colonnes de l'évaluation (`positionnement_niveau_*`, `niveau_cefr`, `niveau_cnef`), remplies par `PersisteRestitutionJob` après chaque partie, et non dans la restitution recalculée à l'affichage. La page de restitution, elle, recalcule tout depuis les événements de la passation : quand les colonnes ne sont pas à jour, les deux peuvent afficher des résultats différents pour la même évaluation.

## Pourquoi

- **Cohérence avec le reste du suivi.** Le statut de suivi (ADR 0001), le tableau de bord, les listes, les filtres et les exports lisent tous ces mêmes colonnes. La carte décide avec les mêmes données qu'eux.
- **Coût.** Recalculer une restitution charge tous les événements de la passation. C'est acceptable sur la page de restitution, qui affiche une seule évaluation et a besoin du détail (sous-profils, scores). Ce ne l'est pas pour la carte de suivi, que le tableau de bord doit reprendre (EVA-1156) : il en affiche plusieurs à la fois, et chaque carte referait ce calcul.
- **Même calcul.** Les colonnes sont remplies par le même `Synthetiseur` que la restitution : quand elles sont à jour, les deux affichages concordent.

## Conséquences

- Une évaluation dont les colonnes n'ont jamais été recalculées affiche « Score non calculé » dans la carte alors que la restitution montre un profil. La correction passe par les données, pas par la carte : `rake evaluations:calcule_restitution` pour les résultats, `rake evaluations:recalcule_completude_positionnement` pour la complétude corrigée le 21/09/2026.
- La préprod est rechargée chaque semaine depuis `db/evaluations_tests.sql`, qui garde les valeurs calculées à l'export. Les tâches de rattrapage n'y ont pas d'effet durable : une correction des calculs doit aussi être reportée dans le dump, comme pour les 3 évaluations corrigées le 02/11/2026 (08c5adee).

## Options écartées

- **Recalculer la restitution dans la carte** : toujours juste, mais trop coûteux pour une carte destinée au tableau de bord, et en désaccord avec le statut de suivi tant que les colonnes ne sont pas à jour.
- **Faire lire les colonnes à la page de restitution** : les deux affichages seraient toujours cohérents. Mais la restitution recalcule depuis les événements volontairement : elle montre toujours la valeur juste, et affiche un détail (sous-profils, scores) que les colonnes ne contiennent pas. La faire lire les colonnes demanderait une validation métier et un gros refactoring de la restitution, hors de portée d'EVA-1152.
