---
statut: accepté
tickets: EVA-1226
---

# Sortir d'ActiveAdmin page par page, en gardant son cadre le temps de la transition

L'administration est construite sur ActiveAdmin (AA). Son rendu (tableaux, pagination, actions groupées, filtres) n'est pas au style du DSFR, et chaque écart se corrige par des surcharges CSS ou des patchs Arbre (`lib/active_admin/views/*_override.rb`, `_adaptation_dsfr.scss`) qui s'accumulent. Nous voulons sortir d'AA, mais une réécriture complète de l'administration d'un bloc coûterait plusieurs mois et ferait courir trop de risques de régression.

## Décision

- **On sort d'AA au fur et à mesure, une page à la fois**, à l'occasion d'un ticket qui touche cette page. Aucune réécriture globale n'est prévue.
- **Le contenu d'une page sort d'abord, son cadre ensuite.** La vue de la page devient un ERB classique, avec ViewComponents et DSFR, sans Arbre. AA ne fournit plus que le contrôleur, ransack (`params[:q]`), le tri (`params[:order]`), la pagination Kaminari, les autorisations et le cadre (en-tête, menu, flash, sidebar). La première page traitée est la liste des bénéficiaires (`app/views/admin/beneficiaires/index.html.erb`).
- **La couture avec AA tient en un réglage** : une vue ERB placée dans `app/views/admin/<ressource>/` est trouvée avant le template d'AA, et le contrôleur pose `@page_dsfr` (`lib/active_admin/page_dsfr.rb`). AA encadre alors la vue de son layout, comme une action personnalisée, sans sa barre de titre ni sa sidebar. Pour une liste simple, `liste_dsfr { |parametres| … }` dans `ActiveAdmin.register` fait ce réglage, désactive les filtres d'AA et construit l'objet de filtres ; les référentiels partagent ainsi `Referentiels::FiltresListe` et le partial `admin/referentiels/_liste`.
- **L'en-tête de la page est aussi sorti d'AA** : fil d'Ariane, titre, actions, puis recherche et filtres, dans `EntetePageComponent`. La logique des filtres d'une liste (lecture des paramètres, valeurs choisies, droits) est portée par une classe dédiée et testée, par exemple `Beneficiaires::FiltresListe`, que le partial des filtres se contente d'afficher.
- **Les briques sont des composants qui ne dépendent pas d'AA**, pour être réutilisées par les pages suivantes puis hors d'AA :
  - `TableauComponent` : tri, sélection de lignes, en-tête et pied de tableau ;
  - le thème Kaminari `dsfr` : `paginate collection, theme: "dsfr"` ;
  - `EntetePageComponent` : fil d'Ariane DSFR, titre, actions et barre ;
  - `FiltresComponent` et `Filtres::*` : barre de recherche DSFR, puis bouton Filtrer qui ouvre un panneau à onglets ; ils émettent les prédicats ransack ;
  - `selection_tableau.js` : compteur de lignes sélectionnées et activation des actions.
- **Les actions groupées sont des `collection_action`** qui reçoivent la sélection d'un vrai formulaire, au lieu des `batch_action` d'AA. Elles appellent `authorize!` explicitement : AA ne vérifie les droits ni des `batch_action` ni des `collection_action`, son option `if:` ne fait que masquer l'entrée de menu.
- **On n'ajoute pas de nouvelle surcharge CSS d'AA** pour une page sortie. Si un style d'AA déborde sur un composant DSFR, on corrige l'adaptation existante (`_adaptation_dsfr.scss`) plutôt que d'empiler une règle de plus.

## Étapes suivantes

1. Migrer les autres pages de liste au fil des tickets, comme les bénéficiaires puis les campagnes. Les composants existent déjà, il reste à écrire la vue et la classe de filtres.
2. Faire de même pour les fiches et les formulaires, avec des composants de formulaire DSFR à la place de Formtastic.
3. Sortir le cadre (en-tête, menu, sidebar) dans un layout Rails. Une page dont la vue est déjà en ERB passe alors sur un contrôleur Rails classique sans changer de vue. Cette étape est transverse à toute l'administration et ne se fait qu'une fois.

## Options écartées

- **Réécrire l'administration d'un bloc** : plusieurs mois de travail sans rien livrer entre-temps, avec un risque de régression sur les droits, les exports et les restitutions.
- **Une application front séparée (Vue ou autre)** : la complexité est côté serveur (ransack, CanCan, tri SQL du statut de suivi) et le resterait. Il faudrait en plus une API pour chaque écran, un bundler, une seconde pile technique, des tests et une i18n en double, et une bibliothèque DSFR communautaire.
- **Sortir une page entière d'AA tout de suite, contrôleur compris** : cela impose de recopier le cadre d'AA dans un layout à part, et donc d'avoir deux versions à garder alignées tant que le reste de l'administration est dans AA.
- **Continuer à habiller AA au DSFR par des surcharges** : chaque version d'AA ou du DSFR casse un peu plus ces surcharges, et la dette grandit au lieu de diminuer.
