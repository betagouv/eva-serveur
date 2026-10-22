---
statut: accepté
tickets: EVA-1157, EVA-1193, EVA-1190, EVA-1191
---

# Le statut de suivi est calculé en SQL, depuis un point d'entrée unique

Le pro doit voir, trier et filtrer le statut de suivi (Suite engagée, Reporté, Pas de suite, À renseigner, ou non concerné) dans la liste des évaluations et dans celle des bénéficiaires. Nous calculons ce statut à la volée, par une expression SQL unique portée par `EvaluationsEva::StatutSuivi`, au lieu de le stocker dans une colonne. Le statut ne dépend pas seulement de la mise en action : il dépend aussi de données qui changent ailleurs et de règles qui vont encore bouger (voir « Options écartées »).

## Décisions

- **Une seule source de vérité.** L'affichage, le tri et le filtre (EVA-1190) lisent la même expression SQL (`CASE … END`). Aucune méthode Ruby ne recalcule le statut d'une évaluation : on aurait deux implémentations susceptibles de diverger.
- **Le champ `statut` existant de l'évaluation n'est pas réutilisé.** Il signifie autre chose (à suivre, suivi en cours, suivi effectué).
- **« Non concerné » est une valeur à part entière** (`non_concerne`), au même titre que `suite_engagee`, `reporte`, `pas_de_suite` et `a_renseigner`.
- **`reporte` est déclaré mais pas encore atteignable.** Il a son libellé, son badge et son rang de tri, mais aucune branche du `CASE` ne le produit avant EVA-1153 (réponse « Je ne sais pas encore »). Jusqu'à EVA-1152, `suite_engagee` et `pas_de_suite` viennent de la réponse Oui/Non (`mises_en_action.effectuee`).
- **Évaluation concernée** : illettrisme potentiel, compétences de base complètes, bénéficiaire non anonymisé, et passation (`debutee_le`) à partir de `DATE_STATUT_SUIVI`.
  - L'illettrisme potentiel est celui de la synthèse lecture/écriture (`synthese_competences_de_base`), comme l'onglet « Illettrisme potentiel » et le tableau de bord. Les profils 1 et 2 en numératie, que compte la pastille du bénéficiaire, ne rendent **pas** une évaluation concernée (décision PO).
  - Cette règle est volontairement distincte de celle du tableau de bord des mises en action, qui n'a pas de borne de date. On ne factorise pas les deux.
- **Tri** : un rang 1 à 5 (Suite engagée, Reporté, Pas de suite, À renseigner, non concerné) est calculé à côté du statut. Le tri décroissant inverse simplement l'ordre.
- **Bénéficiaires (EVA-1191)** : ils réutilisent la même expression, appliquée à leur évaluation de référence (dernière évaluation concernée dans la structure du pro). Après EVA-1186, seule cette jointure change : elle pointera vers la mise en action en cours du bénéficiaire dans la structure.
- **Affichage** : un `StatutSuiviComponent` (badge DSFR ou tiret) s'appuie sur un `InfoBulleComponent` générique (info-bulle DSFR `fr-tooltip`, accessible au clavier). Les deux sont documentés dans le ui_kit.

## `DATE_STATUT_SUIVI`

Cette variable d'environnement (format `AAAA-MM-JJ`) marque le début du suivi. Elle met de côté le **stock** : les évaluations passées avant cette date affichent un tiret, même sans réponse. Sans elle, toutes les anciennes passations en illettrisme potentiel restées sans réponse passeraient d'un coup en « À renseigner » à la mise en production, et noieraient les vrais suivis (cohérent avec EVA-1156).

- On compare la **date de passation** (`debutee_le`), celle qu'affiche la liste et que filtrent « Depuis le » et « Avant le » (décision PO).
- **Variable absente : aucune évaluation n'est concernée** (tirets partout). Un oubli de configuration reste invisible au lieu d'afficher le stock en « À renseigner ».
- Elle doit être définie en production et en préproduction. En préproduction, une date passée permet de montrer des badges sur des données existantes. Les tests la fixent explicitement.

## Options écartées

- **Colonne `statut_suivi` stockée** : tri et filtre triviaux, et indexables. Mais le statut change quand l'une de ces données change :
  - la réponse de la mise en action ;
  - `DATE_STATUT_SUIVI` (par exemple déplacée en préprod pour une démonstration) ;
  - l'anonymisation du bénéficiaire ;
  - la synthèse ou la complétude de l'évaluation, qui peuvent être recalculées ;
  - les règles elles-mêmes, qui évoluent avec EVA-1152, EVA-1153 et EVA-1186.

  Il faudrait mettre la colonne à jour à chacun de ces événements (callbacks dispersés, faciles à oublier) et la recalculer sur tout l'historique à chaque changement de règle. Un cas oublié afficherait un statut faux sans que personne ne s'en aperçoive.

  En contrepartie, le tri par statut ne peut pas utiliser d'index. C'est négligeable : les listes sont paginées et restreintes aux évaluations du pro. Si elles deviennent lentes, ou une fois les règles stabilisées (après EVA-1186), stocker le statut redevient envisageable sans toucher aux écrans, qui passent tous par `StatutSuivi`.
- **Calcul en Ruby** : impossible de trier ou filtrer en base sans charger toute la liste, et double implémentation dès qu'on ajoute le SQL.
- **Info-bulle Bootstrap** (mécanisme actuel de `PastilleComponent`) : le ticket demande le composant DSFR, déjà chargé dans l'admin, et Bootstrap est une dépendance à retirer. La migration de `PastilleComponent` fait l'objet d'un ticket séparé.

## Questions ouvertes

- Position de la colonne « Suivi » pour les comptes qui ne voient pas la colonne « Structure ».
- Couleur du badge « À renseigner » : beige-gris-galet personnalisé (maquette) ou couleur DSFR standard.
