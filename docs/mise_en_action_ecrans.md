# Mise en action : une seule carte, deux écrans

Le pro déclare la mise en action d'une évaluation en illettrisme potentiel (voir **Mise en action** dans `CONTEXT.md`) depuis deux écrans, qui affichent **la même carte** `SuiviAccompagnementIllettrismeComponent` et partagent le même JS (`mise_en_action.js.erb` + `suivi_accompagnement_illettrisme.js`).

- **Fiche évaluation** (EVA-1152) : la carte « Suivi de l'accompagnement » de l'évaluation consultée.
- **Tableau de bord** (EVA-1156) : le bloc « Suivi des bénéficiaires », qui propose **une personne à la fois**.

## Ce qui est commun

- **Endpoints** (`app/admin/evaluation_eva.rb`) :
  - `PUT mise_en_action` : réponse Oui / Non / Pas encore (`MiseEnAction::REPONSE_PAS_ENCORE`). Pas encore répond 204, sans contenu ;
  - `PATCH renseigner_date_revue` : date de revue de Pas encore (`date_revue` et `choix_date_revue`). Répond 200 avec `relance_prevue` et `repondue_le`, ou 422 avec `erreur` ;
  - `PATCH renseigner_qualification` : type d'aide ou raison (`qualification`, et `precision_autre` pour « Autre »). Répond 200 avec `qualification` (libellé à afficher) et `repondue_le`, ou 422 avec `erreur` (message à afficher).
- **Choix proposés** : `MiseEnAction::Questionnaire`. Un choix ajouté au modèle apparaît sur les deux écrans.
- **Règles** : dans `MiseEnAction` (cohérence avec la réponse, précision obligatoire avec « Autre », effacement de la précision). Le JS n'en valide aucune : il affiche ce que le serveur renvoie.
- **« Pas encore » s'appelait « je ne sais pas »** : les noms du code ont été renommés (`REPONSE_PAS_ENCORE`, valeur `pas_encore`, `pas_encore_actif?`, `pas_encore_affiche?`, clés de traduction `*_pas_encore`). Seule la variable d'environnement qui active la fonctionnalité garde son nom, pour ne pas changer la configuration des environnements : `ACTIVE_MISE_EN_ACTION_JE_NE_SAIS_PAS`.
- **JS** : `mise_en_action.js.erb` déclare les chemins et constantes venant de Ruby et les fonctions partagées (`ouvreQcm`, `fermeQcm`, `ecouteBoutons`…). `suivi_accompagnement_illettrisme.js` l'utilise : il doit être inclus après lui dans `active_admin.js`.

## Ce que le tableau de bord ajoute

`SuiviAccompagnementIllettrismeComponent.new(evaluation:, tableau_de_bord: true)` :

| | Fiche évaluation | Tableau de bord |
|---|---|---|
| En-tête | large, sans lien | compact, avec « Voir l'évaluation » (`EnteteMiseEnActionComponent`, `compact:` et `lien_evaluation:`) |
| Personnes | l'évaluation consultée | la première de `EvaluationsEva::TableauDeBordMisesEnAction`, une à la fois |
| Après une réponse complète | la confirmation remplace la question | `data-personne-suivante` : le JS recharge `/admin?suivi_enregistre=<id>`, qui remercie le pro et propose la personne suivante |
| Plus rien à renseigner | — | écran « Tout est à jour, merci » (`_tout_a_jour.html.erb`) |

## Pièges connus
- **Le DSFR gère `aria-pressed`.** Un tag DSFR avec `aria-pressed` est un tag sélectionnable : le DSFR inverse lui-même l'attribut au clic. Ne pas le poser aussi en JS au clic sur ce tag, les deux s'annulent. Le poser seulement quand un autre élément change l'état (un autre choix qui désélectionne « Autre »).
- **Le message d'erreur vient du serveur.** Le JS ne contrôle pas le champ vide : il envoie, et affiche l'`erreur` de la 422. Le texte n'existe donc qu'une fois, dans les traductions du modèle. Vaut pour « Précisez » et pour la date de revue (`afficheErreurChamp`).
- **Dans les tests de feature, attendre la réponse du serveur avant de cliquer à nouveau.** Après un clic qui enregistre (une puce, « Enregistrer »), attendre que la confirmation s'affiche avant « Modifier la réponse » : sinon la réponse du serveur arrive après et réaffiche la confirmation par-dessus la question.
- **Sur le tableau de bord, la confirmation n'est jamais affichée** : la page est rechargée dès que le serveur a accepté la réponse.

## Reste à décider

- Le sort d'« Ignorer » et de la valeur `indetermine`, qui n'ont plus d'écran depuis la disparition du questionnaire du tableau de bord (voir **Qualification ignorée** dans `CONTEXT.md`).
- Passer `mise_en_action.js.erb` en `.js`, en transmettant chemins et constantes par des attributs `data-` sur la carte.
