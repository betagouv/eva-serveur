# Mise en action : deux écrans en transition

Le pro déclare la mise en action d'une évaluation en illettrisme potentiel (voir **Mise en action** dans `CONTEXT.md`) depuis deux écrans. Ils posent la même question, enregistrent via les mêmes endpoints, mais n'ont ni les mêmes composants ni le même JS.

- **Fiche évaluation** : la carte « Suivi de l'accompagnement » (EVA-1152), nouvelle interface.
- **Tableau de bord** : la liste des mises en action, ancienne interface, appelée à passer sur la carte de la fiche (EVA-1156).

## Ce qui est commun

- **Endpoints** (`app/admin/evaluation_eva.rb`) :
  - `PUT mise_en_action` : réponse Oui / Non / Je ne sais pas ;
  - `PATCH renseigner_qualification` : type d'aide ou raison (`qualification`, et `precision_autre` pour « Autre »). Répond 200 avec `qualification` (libellé à afficher) et `repondue_le`, ou 422 avec `erreur` (message à afficher).
- **Choix proposés** : `MiseEnAction::Questionnaire`. Un choix ajouté au modèle apparaît sur les deux écrans.
- **Règles** : dans `MiseEnAction` (cohérence avec la réponse, précision obligatoire avec « Autre », effacement de la précision). Le JS n'en valide aucune : il affiche ce que le serveur renvoie.
- **JS** : `app/assets/javascripts/mise_en_action.js.erb` déclare les chemins et constantes venant de Ruby et les fonctions partagées (`ouvreQcm`, `fermeQcm`, `ecouteBoutons`…). Les deux autres fichiers l'utilisent : il doit être inclus en premier dans `active_admin.js`.

## Ce qui diffère

| | Tableau de bord | Fiche évaluation |
|---|---|---|
| JS | `mise_en_action_tableau_de_bord.js` | `suivi_accompagnement_illettrisme.js` |
| Composant des choix | `Qcm` : boutons radio | `QualificationMiseEnActionComponent` : tags DSFR |
| Choisir | Cocher n'envoie rien, active « Valider » (pour « Autre », une fois « Précisez » rempli) | Le clic sur un tag enregistre aussitôt, sauf « Autre » |
| Enregistrer | « Valider » | Clic sur le tag, ou « Enregistrer » pour « Autre » |
| Ne pas qualifier | « Ignorer » enregistre `indetermine` | Impossible |
| Libellé affiché après enregistrement | Aucun, « Autre » compris | Renvoyé par le serveur (`qualification`) |
| Date « Répondu le » | Non mise à jour sans recharger | Mise à jour depuis la réponse |
| Erreur 422 | Affichée sous le champ « Précisez » | Affichée sous le champ « Précisez » |
| Champ « Précisez » | Apparaît quand « Autre » est coché, sans réserver sa place | Place réservée, masqué avec `visibility: hidden` (maquette) |
| Modifier une réponse « Autre » | Retrouvée en JS pendant la visite (`data-precision-enregistree`) : l’évaluation quitte le tableau de bord au rechargement | Retrouvée depuis la base au chargement de la page |
| Changer de réponse avant de qualifier | Non | Lien « Changer de réponse » |

## Pièges connus
- **Le DSFR gère `aria-pressed`.** Un tag DSFR avec `aria-pressed` est un tag sélectionnable : le DSFR inverse lui-même l'attribut au clic. Ne pas le poser aussi en JS au clic sur ce tag, les deux s'annulent. Le poser seulement quand un autre élément change l'état (un autre choix qui désélectionne « Autre »).
- **Le message d'erreur vient du serveur.** Le JS ne contrôle pas le champ vide : il envoie, et affiche l'`erreur` de la 422. Le texte n'existe donc qu'une fois, dans les traductions du modèle.

## Quand le tableau de bord passera sur la carte (EVA-1156)

- Supprimer `mise_en_action_tableau_de_bord.js`, `Qcm` et les partiels de l'ancien questionnaire.
- Décider du sort d'« Ignorer » et de la valeur `indetermine` (voir **Qualification ignorée** dans `CONTEXT.md`).
- Envisager que `PUT mise_en_action` renvoie le HTML de la liste à afficher au lieu de JSON : il n'y aurait plus deux listes dans le DOM ni d'état à resynchroniser en JS.
- Envisager de passer `mise_en_action.js.erb` en `.js`, en transmettant chemins et constantes par des attributs `data-` sur la carte.
