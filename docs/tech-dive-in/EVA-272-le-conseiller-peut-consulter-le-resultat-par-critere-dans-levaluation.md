# EVA-272 - le-conseiller-peut-consulter-le-resultat-par-critere-dans-levaluation

- Utiliser le [composant accordéon](https://betagouv.github.io/dsfr-view-components/components/accordion/)
- Créer la notion de "Critère" (validé par Stéphane) à travers la classe : Restitution::Critere::Numeratie
Cette classe aura un `libelle`, `code_clea`, `tests_proposes`, `max_tests`, `pourcentage_reussite`
- Remplir les critères dans la méthode : `Restitution::PlaceDuMarche.competences_numeratie`
- Afficher les critères dans la vue `app/views/admin/evaluations/positionnement/_sous_competences.erb`
- Créer un composant Table avec le [design de l'état](https://www.systeme-de-design.gouv.fr/composants-et-modeles/composants/tableau/) car il n'existe pas sur la gem
