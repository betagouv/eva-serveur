---
statut: accepté
tickets: EVA-1153
---

# « Pas encore » est un état d'attente avec une date de revue, pas une réponse

À la question « Cette personne a-t-elle reçu de l'aide depuis cette évaluation ? », le pro répond Oui, Non ou Pas encore. Avec Pas encore, il choisit quand refaire le point : dans 7 jours, 14 jours, 1 mois, ou à une date précise. Jusqu'à cette date, la mise en action est reportée ; à partir de cette date, la question lui est reposée.

## Comment c'est stocké

- **La réponse reste dans le booléen `effectuee`** : `true` pour Oui, `false` pour Non, `nil` pour Pas encore. `nil` veut aussi dire « jamais répondu » : c'est `repondue_le` qui distingue les deux. Cette lecture est enfermée dans `MiseEnAction#repondu_pas_encore?` et le scope `repondues_pas_encore`, jamais réécrite ailleurs.
- **La date de revue (`date_revue`) est la seule source de vérité** pour le statut, le tableau de bord et la relance.
- **Le choix du pro est aussi enregistré** (`choix_date_revue` : `7_jours`, `14_jours`, `1_mois` ou `date_precise`), validé avec le PO, pour trois raisons :
  - comme pour les autres réponses, on garde ce que le pro a choisi (`remediation` pour Oui, `difficulte` pour Non) ;
  - au retour sur « Pas encore », une date précise est retrouvée (« Choisir une date » sélectionné, date pré-remplie), comme « Autre » avec sa précision ; comme les autres choix de Oui et Non, les délais ne restent pas sélectionnés ;
  - des statistiques sur les délais choisis restent possibles.
- **La date de revue est calculée par le serveur au moment de l'enregistrement, à partir du choix** : `MiseEnAction#reporte_dans(choix_date_revue, date_precise = nil)`. Les puces ne portent que leur choix ; seule « Choisir une date » transmet une date. Le JS ne calcule rien.
- **La date de revue doit être à partir de demain, au jour où le pro la choisit**, et non par rapport à `repondue_le` : le parcours se fait en deux temps (Pas encore, puis la date) et le pro peut choisir la date plusieurs jours après avoir répondu. La règle n'est vérifiée que quand la date change : une date devenue passée depuis reste valide. Une date vide est refusée avec le même message.
- **« Pas encore » remplace « je ne sais pas »**, à l'écran comme dans le code. Seule la variable d'environnement `ACTIVE_MISE_EN_ACTION_JE_NE_SAIS_PAS` garde l'ancien nom (voir `docs/mise_en_action_ecrans.md`).
- **La colonne `motif` est conservée** mais n'est plus remplie : le choix du motif de Pas encore fera l'objet d'un autre ticket.

## Ce que ça change pour le suivi

- **Statut de suivi** : « reporté » tant que la date de revue n'est pas atteinte (`MiseEnAction.reportees`), puis « à renseigner ». Le statut reste calculé (ADR 0001).
- **Tableau de bord** : une évaluation reportée en sort, puis y revient le jour de sa date de revue.
- **Fiche évaluation** : avant la date de revue, la carte affiche « Pas encore, la suite est à confirmer » et la relance prévue. À partir de la date de revue, elle repose la question en rappelant la réponse (« Le JJ/MM/AAAA, vous aviez répondu « Pas encore »… »).

## Options écartées

- **Remplacer `effectuee` par une colonne `reponse` (oui, pas_encore, non)** : plus explicite, mais demande une migration des données et touche le statut de suivi (SQL), les scopes, le presenter et le JS. Les prédicats et scopes de `MiseEnAction` donnent la même lisibilité sans ce coût.
- **Ne stocker que la date de revue, sans le choix** (première version) : au retour sur « Pas encore », on n'aurait pas su si la date venait d'une puce ou de « Choisir une date », ni pu remontrer au pro son choix comme pour « Autre ». C'est pourquoi `choix_date_revue` est stocké.
